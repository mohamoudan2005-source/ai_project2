import 'package:ai_project/app/services/db_service.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:ai_project/app/application/app_controller.dart';
import 'package:ai_project/app/application/app_state.dart';
import 'package:ai_project/app/services/ai_service.dart';

final aiServiceProvider = Provider((ref) {
  return AiService();
});

final storageServiceProvider = Provider((ref) {
  return DBService();
});

final appProvider = StateNotifierProvider<AppController, AppState>((ref) {
  AppController appController = AppController(
    ref.read(aiServiceProvider),
    ref.read(storageServiceProvider),
  );

  return appController;
});
