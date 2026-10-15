import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cryptography/cryptography.dart';

/// AES-256-GCM field encryption.
///
/// TEST MODE: a hardcoded key is used for every user, in every build type.
/// Remove [_testKeyBase64] (set it to '') before release. After that, keys
/// come from [unlockWithPassphrase] and live only in memory.
///
/// The uid is bound to each ciphertext as authenticated data, so a value
/// copied into another user's document fails to decrypt.
class CryptoService {
  static const String prefix = 'enc:v1:';

  // TEST ONLY. This key was shared in chat, so never use it for real data.
  static const String _testKeyBase64 =
      '5d60CioaHsRxXKCssMvwcOTQsF9/fGT4/JRok5g4ebE=';

  static const int _pbkdf2Iterations = 600000;

  final AesGcm _algo = AesGcm.with256bits();
  final Map<String, SecretKey> _keys = {};

  static bool isEncrypted(Object? value) =>
      value is String && value.startsWith(prefix);

  // ── KEY MANAGEMENT ──────────────────────────────────────────────────────────

  bool get _useTestKey => _testKeyBase64.trim().isNotEmpty;

  /// True if a key is available for [uid] right now.
  bool isUnlocked(String uid) => _useTestKey || _keys.containsKey(uid);

  SecretKey _getKey(String uid) {
    if (_useTestKey) {
      final bytes = base64Decode(_testKeyBase64.trim());
      if (bytes.length != 32) {
        throw StateError(
          'Test key must decode to exactly 32 bytes (got ${bytes.length}).',
        );
      }
      return SecretKey(bytes);
    }
    final key = _keys[uid];
    if (key == null) {
      throw StateError(
        'Encryption key not available. Call unlockWithPassphrase first.',
      );
    }
    return key;
  }

  /// Random 16-byte salt, base64. Generate once per user and store it in
  /// Firestore (e.g. `users/{uid}.keySalt`). It is not secret.
  String generateSalt() => base64Encode(SecretKeyData.random(length: 16).bytes);

  /// Derives the key from [passphrase] + [saltBase64] and keeps it in memory.
  /// Only used when the test key is empty.
  Future<void> unlockWithPassphrase(
    String uid,
    String passphrase,
    String saltBase64,
  ) async {
    final pbkdf2 = Pbkdf2(
      macAlgorithm: Hmac.sha256(),
      iterations: _pbkdf2Iterations,
      bits: 256,
    );
    _keys[uid] = await pbkdf2.deriveKeyFromPassword(
      password: passphrase,
      nonce: base64Decode(saltBase64),
    );
  }

  /// Sets a raw 32-byte base64 key in memory (e.g. pasted from a backup).
  void setKey(String uid, String base64Key) {
    final bytes = base64Decode(base64Key.trim());
    if (bytes.length != 32) {
      throw ArgumentError('Invalid key: expected 32 bytes.');
    }
    _keys[uid] = SecretKey(bytes);
  }

  /// Returns the active key as base64 for backup. Never log or upload it.
  Future<String> exportKey(String uid) async =>
      base64Encode(await _getKey(uid).extractBytes());

  /// Forgets the in-memory key for [uid] (call on sign-out).
  void lock(String uid) => _keys.remove(uid);

  void lockAll() => _keys.clear();

  // ── STRINGS ─────────────────────────────────────────────────────────────────

  /// Output: `enc:v1:` + base64(nonce + ciphertext + mac). A fresh random
  /// nonce is used on every call.
  Future<String> encryptString(String uid, String plain) async {
    final box = await _algo.encrypt(
      utf8.encode(plain),
      secretKey: _getKey(uid),
      aad: utf8.encode(uid),
    );
    return '$prefix${base64Encode(box.concatenation())}';
  }

  /// Legacy plaintext (no prefix) is returned unchanged. Throws if the value
  /// is encrypted but can't be decrypted (wrong key, wrong uid, tampering).
  Future<String> decryptString(String uid, String value) async {
    if (!isEncrypted(value)) return value;
    final box = SecretBox.fromConcatenation(
      base64Decode(value.substring(prefix.length)),
      nonceLength: 12,
      macLength: 16,
    );
    final bytes = await _algo.decrypt(
      box,
      secretKey: _getKey(uid),
      aad: utf8.encode(uid),
    );
    return utf8.decode(bytes);
  }

  /// Produces a deterministic, user-scoped index token without exposing the
  /// indexed value or a reusable unsalted hash to Firestore.
  Future<String> hashSearchValue(String uid, String value) async {
    final mac = await Hmac.sha256().calculateMac(
      utf8.encode('$uid:$value'),
      secretKey: _getKey(uid),
    );
    return base64UrlEncode(mac.bytes).replaceAll('=', '');
  }

  // ── JSON MAPS ───────────────────────────────────────────────────────────────

  /// Encrypts a whole map as one string. Timestamps and DateTimes are stored
  /// as ISO-8601 strings.
  Future<String> encryptJson(String uid, Map<String, dynamic> map) {
    final json = jsonEncode(
      map,
      toEncodable: (o) {
        if (o is Timestamp) return o.toDate().toIso8601String();
        if (o is DateTime) return o.toIso8601String();
        return o.toString();
      },
    );
    return encryptString(uid, json);
  }

  Future<Map<String, dynamic>> decryptJson(String uid, String value) async {
    final plain = await decryptString(uid, value);
    return Map<String, dynamic>.from(jsonDecode(plain) as Map);
  }
}
