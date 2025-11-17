import 'dart:developer' as dev;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../services/hive_service.dart';
import '../../models/daily_score.dart';

/// 🚀 Clean, unified QuizRepository for new quiz system.
/// Handles:
/// - Practice (local)
/// - Mixed (local)
/// - Ranked (Firebase + local)
/// - Offline queue for ranked
class QuizRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ===========================================================================
  // 🟦 PRACTICE QUIZ → LOCAL ONLY (practice_scores)
  // ===========================================================================
  Future<void> savePracticeScore(int score, int timeTakenSeconds) async {
    try {
      final entry = DailyScore(
        date: DateTime.now(),
        score: score,
        totalQuestions: score,
        timeTakenSeconds: timeTakenSeconds,
        isRanked: false,
      );

      await HiveService.savePracticeScore(entry);
      dev.log("📘 Saved PRACTICE score → practice_scores");
    } catch (e, st) {
      dev.log("❌ Failed saving PRACTICE score: $e", stackTrace: st);
    }
  }

  // ===========================================================================
  // 🟨 MIXED QUIZ → LOCAL ONLY (mixed_scores)
  // ===========================================================================
  Future<void> saveMixedScore(int score, int timeTakenSeconds) async {
    try {
      final entry = DailyScore(
        date: DateTime.now(),
        score: score,
        totalQuestions: score,
        timeTakenSeconds: timeTakenSeconds,
        isRanked: false,
      );

      await HiveService.saveMixedScore(entry);
      dev.log("📙 Saved MIXED score → mixed_scores");
    } catch (e, st) {
      dev.log("❌ Failed saving MIXED score: $e", stackTrace: st);
    }
  }

  // ===========================================================================
  // 🟥 RANKED QUIZ → FIREBASE + LOCAL CACHE (ranked_scores)
  // ===========================================================================
  Future<void> saveRankedScore(int score, int timeTakenSeconds) async {
    final user = _auth.currentUser;

    // No login → offline queue + local save
    if (user == null) {
      dev.log("⚠️ User offline → queued ranked & saved locally");
      await _queueOfflineRanked(score, timeTakenSeconds);
      await HiveService.saveRankedScore(
        DailyScore(
          date: DateTime.now(),
          score: score,
          totalQuestions: score,
          timeTakenSeconds: timeTakenSeconds,
          isRanked: true,
        ),
      );
      return;
    }

    try {
      await _uploadRankedToFirebase(user, score, timeTakenSeconds);
      dev.log("🔥 Ranked uploaded & cached locally");
    } catch (e, st) {
      dev.log(
        "❌ Ranked upload FAILED → queued offline",
        error: e,
        stackTrace: st,
      );
      await _queueOfflineRanked(score, timeTakenSeconds);
    }
  }

  // ===========================================================================
  // 🟩 INTERNAL — Upload Ranked Data to Firebase
  // ===========================================================================
  Future<void> _uploadRankedToFirebase(
    User user,
    int score,
    int timeTakenSeconds,
  ) async {
    final todayKey = DateTime.now().toIso8601String().substring(0, 10);

    final entryRef = _firestore
        .collection('daily_leaderboard')
        .doc(todayKey)
        .collection('entries')
        .doc(user.uid);

    await entryRef.set({
      'uid': user.uid,
      'name': user.displayName ?? 'Player',
      'photoUrl': user.photoURL ?? '',
      'score': score,
      'timeTaken': timeTakenSeconds,
      'timestamp': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    dev.log("🏆 Firebase leaderboard updated");

    // Save to ranked_scores locally
    await HiveService.saveRankedScore(
      DailyScore(
        date: DateTime.now(),
        score: score,
        totalQuestions: score,
        timeTakenSeconds: timeTakenSeconds,
        isRanked: true,
      ),
    );
  }

  // ===========================================================================
  // 🟨 QUEUE RANKED QUIZ OFFLINE
  // ===========================================================================
  Future<void> _queueOfflineRanked(int score, int timeTakenSeconds) async {
    try {
      await HiveService.queueForSync('ranked_quiz', {
        'score': score,
        'timeTaken': timeTakenSeconds,
        'timestamp': DateTime.now().toIso8601String(),
      });

      dev.log("📥 Ranked queued offline");
    } catch (e, st) {
      dev.log("❌ Failed adding to offline queue: $e", stackTrace: st);
    }
  }

  // ===========================================================================
  // 🟧 SYNC OFFLINE RANKED WHEN INTERNET RETURNS
  // ===========================================================================
  Future<void> syncOfflineRankedFromQueue(Map<String, dynamic> data) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      await _uploadRankedToFirebase(
        user,
        data['score'] ?? 0,
        data['timeTaken'] ?? 0,
      );

      dev.log("🔄 Synced offline ranked entry");
    } catch (e, st) {
      dev.log("❌ Sync failed: $e", stackTrace: st);
    }
  }

  // ===========================================================================
  // 🟦 LEADERBOARD STREAMS
  // ===========================================================================
  Stream<QuerySnapshot<Map<String, dynamic>>> getDailyLeaderboard() {
    final todayKey = DateTime.now().toIso8601String().substring(0, 10);

    return _firestore
        .collection('daily_leaderboard')
        .doc(todayKey)
        .collection('entries')
        .orderBy('score', descending: true)
        .orderBy('timeTaken')
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getAllTimeLeaderboard() {
    return _firestore
        .collection('alltime_leaderboard')
        .orderBy('totalScore', descending: true)
        .limit(50)
        .snapshots();
  }

  // ===========================================================================
  // 🔍 CHECK IF USER HAS ALREADY PLAYED TODAY
  // ===========================================================================
  Future<bool> hasPlayedToday() async {
    final user = _auth.currentUser;
    if (user == null) return false;

    try {
      final todayKey = DateTime.now().toIso8601String().substring(0, 10);

      final doc = await _firestore
          .collection('daily_leaderboard')
          .doc(todayKey)
          .collection('entries')
          .doc(user.uid)
          .get();

      return doc.exists;
    } catch (e) {
      dev.log("⚠️ hasPlayedToday error: $e");
      return false;
    }
  }
}
