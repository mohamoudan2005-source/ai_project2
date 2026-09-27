import 'package:firebase_auth/firebase_auth.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:ai_project/app/application/app_controller.dart';
import 'package:ai_project/app/application/app_state.dart';
import 'package:ai_project/app/services/ai_service.dart';
import 'package:ai_project/app/services/db_service.dart';
import 'package:ai_project/services/auth_service.dart';
import 'package:ai_project/services/firestore_service.dart';

final aiServiceProvider = Provider((ref) {
  return AiService();
});

final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});

final storageServiceProvider = Provider<DBService>((ref) {
  return DBService();
});

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(firestoreService: ref.watch(firestoreServiceProvider));
});

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

final appProvider = StateNotifierProvider<AppController, AppState>((ref) {
  final appController = AppController(
    ref.read(aiServiceProvider),
    ref.read(storageServiceProvider),
  );

  return appController;
});
