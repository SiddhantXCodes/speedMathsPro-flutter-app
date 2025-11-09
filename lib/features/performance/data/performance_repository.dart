import 'dart:developer';
import 'package:hive/hive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/services/hive_service.dart';
import './models/daily_score.dart';

/// 📊 PerformanceRepository — handles all ranked & practice score logic
/// Combines Firebase (online) and Hive (offline) seamlessly.
/// Provides leaderboard, performance trends, and background sync.
class PerformanceRepository {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  /// ----------------------------------------------------------
  /// 🧠 Fetch Leaderboard Header (Hybrid Online + Offline)
  /// ----------------------------------------------------------
  Future<Map<String, dynamic>> fetchLeaderboardHeader() async {
    final user = _auth.currentUser;
    if (user == null) {
      log("⚠️ No logged-in user, returning empty leaderboard");
      return {};
    }

    final uid = user.uid;
    final todayKey =
        "${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}";

    int? todayRank;
    int? allTimeRank;
    int? bestScore;
    int? totalScore;
    int? totalUsers;

    try {
      // 🔹 Fetch today's leaderboard
      final dailySnap = await _firestore
          .collection('daily_leaderboard')
          .doc(todayKey)
          .collection('entries')
          .orderBy('score', descending: true)
          .orderBy('timeTaken', descending: false)
          .get();

      int rank = 1;
      for (final doc in dailySnap.docs) {
        if (doc.id == uid) {
          todayRank = rank;
          break;
        }
        rank++;
      }

      // 🔹 Fetch all-time leaderboard summary
      final allSnap = await _firestore
          .collection('alltime_leaderboard')
          .orderBy('totalScore', descending: true)
          .get();

      totalUsers = allSnap.size;
      rank = 1;
      for (final doc in allSnap.docs) {
        if (doc.id == uid) {
          allTimeRank = rank;
          final data = doc.data();
          bestScore =
              (data['bestDailyScore'] ?? data['bestScore'] ?? 0) as int?;
          totalScore = (data['totalScore'] ?? 0) as int?;
          break;
        }
        rank++;
      }

      // 🔹 Cache locally for offline reuse
      final cacheBox = await Hive.openBox('leaderboard_cache');
      await cacheBox.put('header', {
        'todayRank': todayRank,
        'allTimeRank': allTimeRank,
        'totalUsers': totalUsers,
        'bestScore': bestScore,
        'totalScore': totalScore,
        'lastFetched': DateTime.now().toIso8601String(),
      });

      log("✅ Leaderboard header fetched and cached successfully");

      return {
        'todayRank': todayRank,
        'allTimeRank': allTimeRank,
        'totalUsers': totalUsers,
        'bestScore': bestScore,
        'totalScore': totalScore,
      };
    } catch (e, st) {
      log("⚠️ Leaderboard fetch failed: $e", stackTrace: st);

      // 🧭 Use cached data if available
      final cacheBox = await Hive.openBox('leaderboard_cache');
      final cached = cacheBox.get('header');
      if (cached != null) {
        log("📦 Using cached leaderboard data");
        return Map<String, dynamic>.from(cached);
      }

      return {};
    }
  }

  /// ----------------------------------------------------------
  /// 📈 Get Ranked Quiz Trend (last 7 days from local Hive)
  /// ----------------------------------------------------------
  Future<List<Map<String, dynamic>>> fetchRankedQuizTrend() async {
    try {
      final localScores = HiveService.getAllDailyScores();

      if (localScores.isEmpty) {
        log("⚠️ No local daily scores found");
        return [];
      }

      // Sort by date (descending) and take last 7 entries
      localScores.sort((a, b) => b.date.compareTo(a.date));
      final recent = localScores.take(7).toList().reversed.toList();

      final trend = recent.map((score) {
        return {
          'date': score.date,
          'score': score.score,
          'isRanked': score.isRanked,
        };
      }).toList();

      return trend;
    } catch (e, st) {
      log("⚠️ Failed to fetch ranked trend: $e", stackTrace: st);
      return [];
    }
  }

  /// ----------------------------------------------------------
  /// 💾 Save a new DailyScore locally
  /// ----------------------------------------------------------
  Future<void> saveDailyScore(DailyScore score) async {
    try {
      await HiveService.addDailyScore(score);
      log("🧩 DailyScore saved locally for ${score.date.toIso8601String()}");
    } catch (e, st) {
      log("⚠️ Failed to save DailyScore: $e", stackTrace: st);
    }
  }

  /// ----------------------------------------------------------
  /// ☁️ Sync local DailyScores with Firebase (Ranked only)
  /// ----------------------------------------------------------
  Future<void> syncLocalScoresToFirebase() async {
    final user = _auth.currentUser;
    if (user == null) {
      log("⚠️ User not logged in — skipping score sync");
      return;
    }

    try {
      final scores = HiveService.getAllDailyScores();

      for (final score in scores) {
        if (!score.isRanked) continue; // only ranked quizzes go online

        final dateKey =
            "${score.date.year}-${score.date.month.toString().padLeft(2, '0')}-${score.date.day.toString().padLeft(2, '0')}";

        await _firestore
            .collection('daily_leaderboard')
            .doc(dateKey)
            .collection('entries')
            .doc(user.uid)
            .set({
              'uid': user.uid,
              'email': user.email,
              'score': score.score,
              'totalQuestions': score.totalQuestions,
              'timeTakenSeconds': score.timeTakenSeconds,
              'timestamp': FieldValue.serverTimestamp(),
            }, SetOptions(merge: true));

        log("✅ Synced DailyScore → Firebase: $dateKey (${score.score})");
      }

      log("✅ All ranked DailyScores synced successfully");
    } catch (e, st) {
      log("⚠️ Failed to sync local scores: $e", stackTrace: st);
    }
  }

  /// ----------------------------------------------------------
  /// 🔄 Sync Data (called by SyncManager)
  /// ----------------------------------------------------------
  Future<void> syncData() async {
    try {
      await syncLocalScoresToFirebase();
      log("✅ PerformanceRepository sync complete.");
    } catch (e, st) {
      log("⚠️ PerformanceRepository sync failed: $e", stackTrace: st);
    }
  }

  /// ----------------------------------------------------------
  /// 🧾 Fetch Online Attempts — From Firestore (for history)
  /// ----------------------------------------------------------
  Future<List<Map<String, dynamic>>> fetchOnlineAttempts({
    int limit = 200,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return [];

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('ranked_attempts')
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'date': (data['date'] as Timestamp?)?.toDate(),
          'score': data['score'] ?? 0,
          'totalQuestions': data['totalQuestions'] ?? 0,
          'timeTakenSeconds': data['timeTakenSeconds'] ?? 0,
        };
      }).toList();
    } catch (e, st) {
      log("⚠️ fetchOnlineAttempts failed: $e", stackTrace: st);
      return [];
    }
  }

  /// ----------------------------------------------------------
  /// 🧹 Clear all locally stored performance data (Hive only)
  /// ----------------------------------------------------------
  Future<void> clearAllLocalData() async {
    try {
      await HiveService.clearDailyScores();
      final cacheBox = await Hive.openBox('leaderboard_cache');
      await cacheBox.clear();
      log("🧹 Cleared all local performance data successfully");
    } catch (e, st) {
      log("⚠️ Failed to clear local performance data: $e", stackTrace: st);
    }
  }
}
