// lib/features/quiz/quiz_repository.dart

import 'dart:developer' as dev;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../services/hive_service.dart';
import '../../models/daily_score.dart';

/// 🚀 Clean, unified QuizRepository for new quiz system.
class QuizRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ===========================================================================
  // 🟦 PRACTICE QUIZ → LOCAL ONLY
  // ===========================================================================
  Future<void> savePracticeScore(int score, int timeTakenSeconds) async {
    try {
      await HiveService.savePracticeScore(
        DailyScore(
          date: DateTime.now(),
          score: score,
          totalQuestions: score,
          timeTakenSeconds: timeTakenSeconds,
          isRanked: false,
        ),
      );
      dev.log("📘 Saved PRACTICE score → practice_scores");
    } catch (e, st) {
      dev.log("❌ Failed saving PRACTICE score: $e", stackTrace: st);
    }
  }

  // ===========================================================================
  // 🟨 MIXED QUIZ → LOCAL ONLY
  // ===========================================================================
  Future<void> saveMixedScore(int score, int timeTakenSeconds) async {
    try {
      await HiveService.saveMixedScore(
        DailyScore(
          date: DateTime.now(),
          score: score,
          totalQuestions: score,
          timeTakenSeconds: timeTakenSeconds,
          isRanked: false,
        ),
      );
      dev.log("📙 Saved MIXED score → mixed_scores");
    } catch (e, st) {
      dev.log("❌ Failed saving MIXED score: $e", stackTrace: st);
    }
  }

  // ===========================================================================
  // 🟥 RANKED QUIZ → FIREBASE (ONE SCORE PER DAY)
  // ===========================================================================
  Future<void> saveRankedScore(int score, int timeTakenSeconds) async {
    final user = _auth.currentUser;

    if (user == null) {
      dev.log("⚠️ User offline → queue ranked attempt");
      await _queueOfflineRanked(score, timeTakenSeconds);
      return;
    }

    try {
      await _uploadRankedToFirebase(user, score, timeTakenSeconds);
      dev.log("🔥 Ranked uploaded to Firebase");
    } catch (e, st) {
      dev.log(
        "❌ Ranked upload FAILED → queue offline",
        error: e,
        stackTrace: st,
      );
      await _queueOfflineRanked(score, timeTakenSeconds);
    }
  }

  // ===========================================================================
  // 🟩 INTERNAL — SAVE RANKED ATTEMPT (ONE PER DAY)
  // ===========================================================================
  Future<void> _uploadRankedToFirebase(
    User user,
    int score,
    int timeTakenSeconds,
  ) async {
    final now = DateTime.now();

    // yyyy-MM-dd
    final todayKey =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

    // -----------------------------
    // 1️⃣ Save ONE ranked attempt per day (overwrite)
    // -----------------------------
    final attemptRef = _firestore
        .collection("ranked_attempts")
        .doc(user.uid)
        .collection("attempts")
        .doc(todayKey); // ✔ ONE ATTEMPT PER DAY

    await attemptRef.set({
      "uid": user.uid,
      "score": score,
      "timeTaken": timeTakenSeconds,
      "timestamp": FieldValue.serverTimestamp(),
      "dateKey": todayKey,
    }, SetOptions(merge: true));

    dev.log("📌 Ranked daily attempt saved → $todayKey");

    // -----------------------------
    // 2️⃣ Update Daily Leaderboard (also ONE per day)
    // -----------------------------
    final leaderboardRef = _firestore
        .collection("daily_leaderboard")
        .doc(todayKey)
        .collection("entries")
        .doc(user.uid);

    await leaderboardRef.set({
      "uid": user.uid,
      "name": user.displayName ?? "Player",
      "photoUrl": user.photoURL ?? "",
      "score": score,
      "timeTaken": timeTakenSeconds,
      "timestamp": FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    dev.log("🏆 Leaderboard updated → $todayKey");
  }

  // ===========================================================================
  // 🟨 OFFLINE QUEUE (updated — still stores ONLY one score per day)
  // ===========================================================================
  Future<void> _queueOfflineRanked(int score, int timeTakenSeconds) async {
    final now = DateTime.now();
    final todayKey =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

    try {
      await HiveService.queueForSync("ranked_attempt", {
        "score": score,
        "timeTaken": timeTakenSeconds,
        "timestamp": now.toIso8601String(),
        "dateKey": todayKey,
      });

      dev.log("📥 Offline ranked attempt queued ($todayKey)");
    } catch (e, st) {
      dev.log("❌ Failed queueing ranked attempt: $e", stackTrace: st);
    }
  }

  // ===========================================================================
  // 🔄 SYNC OFFLINE RANKED ATTEMPTS (one per day)
  // ===========================================================================
  Future<void> syncOfflineRankedFromQueue(Map<String, dynamic> data) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _uploadRankedToFirebase(
        user,
        data["score"] ?? 0,
        data["timeTaken"] ?? 0,
      );
      dev.log("🔄 Offline ranked attempt synced");
    } catch (e, st) {
      dev.log("❌ Sync failed: $e", stackTrace: st);
    }
  }

  // ===========================================================================
  // 🟦 DAILY LEADERBOARD STREAM
  // ===========================================================================
  Stream<QuerySnapshot<Map<String, dynamic>>> getDailyLeaderboard() {
    final now = DateTime.now();
    final todayKey =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

    return _firestore
        .collection("daily_leaderboard")
        .doc(todayKey)
        .collection("entries")
        .orderBy("score", descending: true)
        .orderBy("timeTaken")
        .snapshots();
  }

  // ===========================================================================
  // 🔍 CHECK IF USER PLAYED TODAY
  // ===========================================================================
  Future<bool> hasPlayedToday() async {
    final user = _auth.currentUser;
    if (user == null) return false;

    final now = DateTime.now();
    final todayKey =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

    try {
      final doc = await _firestore
          .collection("ranked_attempts")
          .doc(user.uid)
          .collection("attempts")
          .doc(todayKey)
          .get();

      return doc.exists;
    } catch (e) {
      dev.log("⚠️ hasPlayedToday error: $e");
      return false;
    }
  }
}
