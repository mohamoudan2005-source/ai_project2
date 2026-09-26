import 'dart:convert';
import 'package:ai_project/app/models/prediction_result.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class DBService {
  static const _streakKey = 'snap_sort_streak';
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  Future<List<PredictionHistoryItem>> loadHistory() async {
    QuerySnapshot result = await firestore
        .collection('users')
        .doc("1")
        .collection("history")
        .get();
    List<PredictionHistoryItem> history = result.docs
        .map(
          (e) =>
              PredictionHistoryItem.fromJson(e.data() as Map<String, dynamic>),
        )
        .toList();
    return history;
  }

  Future<void> saveHistory(PredictionHistoryItem history) async {
    var uuid = Uuid();
    var id = uuid.v4();
    try {
      await firestore
          .collection('users')
          .doc("1")
          .collection("history")
          .doc(id)
          .set(history.toJson());
    } catch (e) {
      print(e);
    }
  }

  Future<int> loadStreak() async {
    var result = await firestore.collection('users').doc("1").get();
    return result.data()?["streaks"] ?? 0;
  }

  Future<void> saveStreak(int streak) async {
    await firestore.collection('users').doc("1").update({"streaks": streak});
  }
}
