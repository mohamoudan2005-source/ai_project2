import 'package:ai_project/app/models/prediction_result.dart';
import 'package:ai_project/services/firestore_service.dart';

/// Legacy DBService adapter extending [FirestoreService].
/// Guarantees that existing callers (e.g. AppController) automatically route
/// all operations through user-isolated Firestore paths with
/// `FirebaseAuth.instance.currentUser!.uid`, removing hard-coded user IDs.
class DBService extends FirestoreService {
  DBService({super.firestore, super.auth});

  @override
  Future<List<PredictionHistoryItem>> loadHistory() async {
    return loadCases();
  }

  @override
  Future<void> saveHistory(PredictionHistoryItem history) async {
    return saveCase(history);
  }
}
