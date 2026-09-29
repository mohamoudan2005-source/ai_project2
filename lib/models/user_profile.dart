import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserProfile {
  final String uid;
  final String displayName;
  final String? fullName;
  final String? username;
  final String? gender;
  final String? phone;
  final String email;
  final String? profileImage;
  final String photoURL;
  final String provider;
  final DateTime? createdAt;
  final DateTime? lastLoginAt;

  const UserProfile({
    required this.uid,
    required this.displayName,
    this.fullName,
    this.username,
    this.gender,
    this.phone,
    required this.email,
    this.profileImage,
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
    String? gender,
    String? phone,
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
      gender: gender,
      phone: phone,
      email: user.email ?? '',
      profileImage: null,
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
      gender: map['gender'] as String?,
      phone: map['phone'] as String?,
      email: map['email'] as String? ?? '',
      profileImage: map['profileImage'] as String?,
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
      if (gender != null) 'gender': gender,
      if (phone != null) 'phone': phone,
      'email': email,
      if (profileImage != null) 'profileImage': profileImage,
      'photoURL': photoURL,
      'provider': provider,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
      'lastLoginAt': FieldValue.serverTimestamp(),
    };
  }

  UserProfile copyWith({
    String? uid,
    String? displayName,
    String? fullName,
    String? username,
    String? gender,
    String? phone,
    String? email,
    String? profileImage,
    String? photoURL,
    String? provider,
    DateTime? createdAt,
    DateTime? lastLoginAt,
  }) {
    return UserProfile(
      uid: uid ?? this.uid,
      displayName: displayName ?? this.displayName,
      fullName: fullName ?? this.fullName,
      username: username ?? this.username,
      gender: gender ?? this.gender,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      profileImage: profileImage ?? this.profileImage,
      photoURL: photoURL ?? this.photoURL,
      provider: provider ?? this.provider,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }
}
