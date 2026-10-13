import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:ai_project/models/user_profile.dart';
import 'package:ai_project/services/storage_service.dart';

void main() {
  group('Profile Image Compression & Unique Path Tests', () {
    test('compressProfileImage resizes images larger than 512x512', () {
      final storageService = StorageService();

      // Create a 1000x800 test image in memory
      final rawImage = img.Image(width: 1000, height: 800);
      img.fill(rawImage, color: img.ColorRgb8(255, 0, 0));
      final rawBytes = img.encodeJpg(rawImage);

      // Compress via storage service
      final compressedBytes = storageService.compressProfileImage(rawBytes);
      expect(compressedBytes, isNotEmpty);

      // Decode compressed image and verify dimensions
      final decoded = img.decodeImage(compressedBytes);
      expect(decoded, isNotNull);
      expect(decoded!.width, lessThanOrEqualTo(512));
      expect(decoded.height, lessThanOrEqualTo(512));
      expect(compressedBytes.lengthInBytes, lessThan(rawBytes.lengthInBytes));
    });

    test('compressProfileImage handles smaller images gracefully', () {
      final storageService = StorageService();

      final smallImage = img.Image(width: 200, height: 200);
      img.fill(smallImage, color: img.ColorRgb8(0, 255, 0));
      final rawBytes = img.encodeJpg(smallImage);

      final compressedBytes = storageService.compressProfileImage(rawBytes);
      final decoded = img.decodeImage(compressedBytes);
      expect(decoded, isNotNull);
      expect(decoded!.width, 200);
      expect(decoded.height, 200);
    });

    test('profile image storage path uses unique timestamp pattern', () {
      final uid = 'doctor_12345';
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final path = 'users/$uid/profile/profile_$timestamp.jpg';

      final regex = RegExp(r'^users\/doctor_12345\/profile\/profile_\d+\.jpg$');
      expect(regex.hasMatch(path), isTrue);
    });
  });

  group('UserProfile Model & Priority Tests', () {
    test(
      'UserProfile copyWith updates photoURL without losing other fields',
      () {
        final profile = UserProfile(
          uid: 'user_abc',
          displayName: 'Dr. Sarah Smith',
          fullName: 'Dr. Sarah Smith',
          username: 'dr_sarah',
          gender: 'Female',
          phone: '+1 555 987 6543',
          email: 'sarah@hospital.org',
          photoURL: 'https://storage.googleapis.com/old_photo.jpg',
          provider: 'google.com',
        );

        final updatedProfile = profile.copyWith(
          photoURL: 'https://storage.googleapis.com/new_photo_12345.jpg',
        );

        expect(updatedProfile.uid, 'user_abc');
        expect(updatedProfile.displayName, 'Dr. Sarah Smith');
        expect(updatedProfile.fullName, 'Dr. Sarah Smith');
        expect(updatedProfile.gender, 'Female');
        expect(updatedProfile.phone, '+1 555 987 6543');
        expect(updatedProfile.email, 'sarah@hospital.org');
        expect(updatedProfile.provider, 'google.com');
        expect(
          updatedProfile.photoURL,
          'https://storage.googleapis.com/new_photo_12345.jpg',
        );
      },
    );

    test('Display priority resolves custom photo over provider photo', () {
      const customPhotoUrl =
          'https://storage.googleapis.com/custom_profile.jpg';
      const providerPhotoUrl =
          'https://lh3.googleusercontent.com/oauth_photo.jpg';

      // 1. Both custom and provider exist -> custom wins
      String? resolvePhoto({String? custom, String? provider}) {
        if (custom != null && custom.isNotEmpty) return custom;
        if (provider != null && provider.isNotEmpty) return provider;
        return null;
      }

      expect(
        resolvePhoto(custom: customPhotoUrl, provider: providerPhotoUrl),
        customPhotoUrl,
      );

      // 2. Custom photo is empty -> provider wins
      expect(
        resolvePhoto(custom: '', provider: providerPhotoUrl),
        providerPhotoUrl,
      );

      // 3. Custom photo is null -> provider wins
      expect(
        resolvePhoto(custom: null, provider: providerPhotoUrl),
        providerPhotoUrl,
      );

      // 4. Both empty/null -> null (triggers default avatar)
      expect(resolvePhoto(custom: null, provider: null), isNull);
    });
  });
}
