import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image/image.dart' as img;
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

final firebaseStorageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

/// Reusable Firebase Storage service handling user-isolated X-ray image uploads.
/// All examination images are strictly stored under `users/{doctorUid}/cases/{caseId}.jpg`
/// using the authenticated doctor's UID.
class StorageService {
  final FirebaseStorage? _customStorage;
  final FirebaseAuth? _customAuth;

  StorageService({FirebaseStorage? storage, FirebaseAuth? auth})
    : _customStorage = storage,
      _customAuth = auth;

  FirebaseStorage get _storage => _customStorage ?? FirebaseStorage.instance;
  FirebaseAuth get _auth => _customAuth ?? FirebaseAuth.instance;

  /// Retrieves the current authenticated user's UID.
  String get currentUserId {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError(
        'Authentication Error: No authenticated user found for Firebase Storage operation.',
      );
    }
    return user.uid;
  }

  /// Compresses and resizes raw image bytes for profile photo (max 512x512, JPEG 85%).
  Uint8List compressProfileImage(Uint8List rawBytes) {
    try {
      final decoded = img.decodeImage(rawBytes);
      if (decoded == null) return rawBytes;

      img.Image resized;
      if (decoded.width > 512 || decoded.height > 512) {
        if (decoded.width >= decoded.height) {
          resized = img.copyResize(decoded, width: 512);
        } else {
          resized = img.copyResize(decoded, height: 512);
        }
      } else {
        resized = decoded;
      }

      return Uint8List.fromList(img.encodeJpg(resized, quality: 85));
    } catch (e) {
      debugPrint('Profile image compression fallback: $e');
      return rawBytes;
    }
  }

  /// Uploads an X-ray image file to `users/{doctorUid}/cases/{caseId}.jpg`
  /// and returns the permanent Firebase Storage download URL.
  Future<String> uploadCaseImage({
    required String caseId,
    required Uint8List imageBytes,
    String contentType = 'image/jpeg',
  }) async {
    final doctorUid = currentUserId;
    final storageRef = _storage.ref().child(
      'users/$doctorUid/cases/$caseId.jpg',
    );

    final metadata = SettableMetadata(
      contentType: contentType,
      customMetadata: {
        'doctorUid': doctorUid,
        'caseId': caseId,
        'uploadedAt': DateTime.now().toIso8601String(),
      },
    );

    // Upload raw bytes (cross-platform: works seamlessly on Android, iOS, and Web)
    await storageRef.putData(imageBytes, metadata);

    // Retrieve permanent download URL
    final String photoURL = await storageRef.getDownloadURL();
    return photoURL;
  }

  /// Uploads the authenticated user's profile image to Cloudinary and returns
  /// its secure URL.
  Future<String> uploadProfileImage({required Uint8List imageBytes}) async {
    if (_auth.currentUser == null) {
      throw StateError('No authenticated user found.');
    }

    final compressedBytes = compressProfileImage(imageBytes);
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('https://api.cloudinary.com/v1_1/wj0cdtru/image/upload'),
    );
    request.fields['upload_preset'] = 'pzg8lzup';
    request.files.add(
      http.MultipartFile.fromBytes(
        'file',
        compressedBytes,
        filename: 'profile.jpg',
      ),
    );

    debugPrint('PROFILE IMAGE: upload started');
    final streamedResponse = await request.send().timeout(
      const Duration(seconds: 30),
    );
    final response = await http.Response.fromStream(streamedResponse);
    debugPrint('PROFILE IMAGE: HTTP status = ${response.statusCode}');
    debugPrint('PROFILE IMAGE: Cloudinary response: ${response.body}');
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StateError(
        'Cloudinary upload failed: ${response.statusCode} ${response.body}',
      );
    }

    final responseData = jsonDecode(response.body);
    if (responseData is! Map<String, dynamic> ||
        responseData['secure_url'] is! String ||
        (responseData['secure_url'] as String).isEmpty) {
      throw const FormatException(
        'Cloudinary response did not include a secure image URL.',
      );
    }
    final secureUrl = responseData['secure_url'] as String;
    final secureUri = Uri.tryParse(secureUrl);
    if (secureUri == null ||
        secureUri.scheme != 'https' ||
        secureUri.host != 'res.cloudinary.com') {
      throw const FormatException(
        'Cloudinary response contains an invalid secure_url.',
      );
    }
    debugPrint('PROFILE IMAGE: upload completed');
    debugPrint('PROFILE IMAGE: URL = $secureUrl');
    return secureUrl;
  }

  /// Minimal diagnostic test from an authenticated session to verify Firebase Storage
  Future<String> testStorageUpload() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('No authenticated Firebase user');
    }
    debugPrint(
      'PROFILE IMAGE: testing storage upload on bucket ${_storage.bucket} for user ${user.uid}',
    );
    final ref = _storage.ref().child('users/${user.uid}/profile/test.txt');
    await ref.putString('profile upload test');
    final url = await ref.getDownloadURL();
    debugPrint('STORAGE TEST URL: $url');
    return url;
  }

  /// Fetches raw image bytes from storage by download URL or reference
  Future<Uint8List?> getImageBytes(String photoURL) async {
    try {
      final ref = _storage.refFromURL(photoURL);
      return await ref.getData(15 * 1024 * 1024); // max 15MB
    } catch (_) {
      return null;
    }
  }
}
