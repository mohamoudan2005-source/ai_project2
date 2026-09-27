import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserProfile {
  final String uid;
  final String displayName;
  final String? fullName;
  final String? username;
  final String email;
  final String photoURL;
  final String provider;
  final DateTime? createdAt;
  final DateTime? lastLoginAt;

  const UserProfile({
    required this.uid,
    required this.displayName,
    this.fullName,
    this.username,
    required this.email,
    required this.photoURL,
    required this.provider,
    this.createdAt,
    this.lastLoginAt,
  });

  factory UserProfile.fromFirebaseUser(
    User user, {
    String? providerOverride,
    String? fullName,
    String? username,
  }) {
    String provider = providerOverride ?? 'firebase';
    if (user.providerData.isNotEmpty) {
      provider = user.providerData.first.providerId;
    }
    final effectiveName = (fullName != null && fullName.isNotEmpty)
        ? fullName
        : (user.displayName ??
              (user.email != null && user.email!.isNotEmpty
                  ? user.email!.split('@').first
                  : 'User'));

    return UserProfile(
      uid: user.uid,
      displayName: effectiveName,
      fullName: fullName ?? user.displayName,
      username:
          username ??
          (user.email != null && user.email!.isNotEmpty
              ? user.email!.split('@').first
              : null),
      email: user.email ?? '',
      photoURL: user.photoURL ?? '',
      provider: provider,
      createdAt: user.metadata.creationTime,
      lastLoginAt: user.metadata.lastSignInTime,
    );
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      uid: map['uid'] as String? ?? '',
      displayName:
          map['displayName'] as String? ?? map['fullName'] as String? ?? '',
      fullName: map['fullName'] as String?,
      username: map['username'] as String?,
      email: map['email'] as String? ?? '',
      photoURL: map['photoURL'] as String? ?? '',
      provider: map['provider'] as String? ?? 'firebase',
      createdAt: _parseDateTime(map['createdAt']),
      lastLoginAt: _parseDateTime(map['lastLoginAt']),
    );
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    } else if (value is String) {
      return DateTime.tryParse(value);
    }
    return null;
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'displayName': displayName,
      if (fullName != null) 'fullName': fullName,
      if (username != null) 'username': username,
      'email': email,
      'photoURL': photoURL,
      'provider': provider,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
      'lastLoginAt': FieldValue.serverTimestamp(),
    };
  }
}
