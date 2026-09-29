import 'package:firebase_auth/firebase_auth.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:ai_project/app/application/app_controller.dart';
import 'package:ai_project/app/application/app_state.dart';
import 'package:ai_project/app/services/ai_service.dart';
import 'package:ai_project/app/services/db_service.dart';
import 'package:ai_project/models/user_profile.dart';
import 'package:ai_project/services/auth_service.dart';
import 'package:ai_project/services/firestore_service.dart';
import 'package:ai_project/services/storage_service.dart';

final aiServiceProvider = Provider((ref) {
  return AiService();
});

final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});

final storageServiceProvider = Provider<DBService>((ref) {
  return DBService();
});

final firebaseStorageProvider = Provider<StorageService>((ref) {
  return StorageService();
});

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(firestoreService: ref.watch(firestoreServiceProvider));
});

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

final userProfileStreamProvider = StreamProvider<UserProfile?>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value(null);
  return ref.watch(firestoreServiceProvider).userProfileStream(user.uid);
});

final appProvider = StateNotifierProvider<AppController, AppState>((ref) {
  final appController = AppController(
    ref.read(aiServiceProvider),
    ref.read(storageServiceProvider),
    ref.read(firebaseStorageProvider),
  );

  return appController;
});
