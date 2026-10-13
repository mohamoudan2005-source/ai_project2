import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:ai_project/app/providers/app_provider.dart';
import 'package:ai_project/models/user_profile.dart';
import 'package:ai_project/services/auth_service.dart';
import 'package:ai_project/services/firestore_service.dart';
import 'package:ai_project/widgets/user_profile_modal.dart';

void main() {
  testWidgets('saves profile fields and shows them after reopening', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final auth = _TestAuth(_TestUser());
    final firestore = _ProfileFirestoreService(auth);
    final authService = AuthService(auth: auth, firestoreService: firestore);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          firestoreServiceProvider.overrideWithValue(firestore),
          authServiceProvider.overrideWithValue(authService),
          userProfileStreamProvider.overrideWith(
            (ref) => firestore.userProfileStream(),
          ),
        ],
        child: ScreenUtilInit(
          designSize: const Size(430, 932),
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => Center(
                  child: ElevatedButton(
                    onPressed: () => UserProfileModal.show(context),
                    child: const Text('Open profile'),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open profile'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit profile'));
    await tester.pumpAndSettle();

    await tester.enterText(_field(0), 'Dr. Ada Lovelace');
    await tester.enterText(_field(1), 'Cardiology');
    await tester.enterText(_field(2), 'North Clinic');
    await tester.enterText(_field(4), 'Boston');
    await tester.enterText(_field(5), 'United States');
    await tester.enterText(_field(6), 'MED-9876');
    await tester.tap(find.text('Save Changes'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(firestore.saveCount, 1);
    expect(find.text('Cardiology'), findsOneWidget);
    expect(find.text('North Clinic'), findsOneWidget);
    expect(find.text('Boston, United States'), findsOneWidget);
    expect(find.text('MED-9876'), findsOneWidget);

    Navigator.of(tester.element(find.byType(UserProfileModal))).pop();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Open profile'));
    await tester.pumpAndSettle();

    expect(find.text('Cardiology'), findsOneWidget);
    expect(find.text('North Clinic'), findsOneWidget);
    expect(find.text('Boston, United States'), findsOneWidget);
    expect(find.text('MED-9876'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

Finder _field(int index) => find.byType(TextFormField).at(index);

class _ProfileFirestoreService extends FirestoreService {
  _ProfileFirestoreService(_TestAuth auth)
    : super(firestore: _UnusedFirestore(), auth: auth);
  int saveCount = 0;
  UserProfile _profile = UserProfile(
    uid: 'doctor-42',
    displayName: 'Dr. Ada Lovelace',
    fullName: 'Dr. Ada Lovelace',
    gender: 'Female',
    phone: '+1 555 0100',
    specialty: 'Internal Medicine',
    hospitalClinic: 'Central Hospital',
    city: 'London',
    country: 'United Kingdom',
    licenseNumber: 'OLD-123',
    email: 'ada@example.com',
    photoURL: '',
    provider: 'password',
  );

  @override
  Future<UserProfile?> getUserProfile([String? uid]) async => _profile;

  @override
  Stream<UserProfile?> userProfileStream([String? uid]) =>
      Stream.value(_profile);

  @override
  Future<void> updateDoctorProfile({
    required String fullName,
    String? gender,
    String? phone,
    String? specialty,
    String? hospitalClinic,
    String? city,
    String? country,
    String? licenseNumber,
  }) async {
    saveCount++;
    _profile = _profile.copyWith(
      fullName: fullName.trim(),
      displayName: fullName.trim(),
      gender: gender,
      phone: phone?.trim(),
      specialty: specialty?.trim(),
      hospitalClinic: hospitalClinic?.trim(),
      city: city?.trim(),
      country: country?.trim(),
      licenseNumber: licenseNumber?.trim(),
    );
  }
}

class _TestAuth implements FirebaseAuth {
  _TestAuth(this.currentUser);

  @override
  final User? currentUser;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _TestUser implements User {
  @override
  String get uid => 'doctor-42';

  @override
  String? get email => 'ada@example.com';

  @override
  String? get displayName => 'Dr. Ada Lovelace';

  @override
  bool get emailVerified => true;

  @override
  String? get photoURL => null;

  @override
  List<UserInfo> get providerData => const [];

  @override
  UserMetadata get metadata => _TestUserMetadata();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _TestUserMetadata implements UserMetadata {
  @override
  DateTime? get creationTime => null;

  @override
  DateTime? get lastSignInTime => null;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// ignore: subtype_of_sealed_class
class _UnusedFirestore implements FirebaseFirestore {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
