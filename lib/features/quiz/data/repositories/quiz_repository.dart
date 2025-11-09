import 'dart:developer' as dev;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/services/hive_service.dart';
import '../models/quiz_session_model.dart';
import '../../../practice/data/models/practice_log.dart';
import '../../../performance/data/models/daily_score.dart';
import '../models/streak_data.dart';
import '../models/daily_quiz_meta.dart';

/// 🧩 QuizRepository — Handles both online and offline quiz storage.
///  - Saves ranked results to Firebase
///  - Saves practice/offline results to Hive
///  - Syncs streak and daily quiz metadata
///  - Provides cached leaderboard data for offline fallback
class QuizRepository {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  // ---------------------------------------------------------------------------
  // 💾 OFFLINE STORAGE
  // ---------------------------------------------------------------------------

  /// Save a regular (offline) quiz session locally in Hive
  Future<void> saveOfflineResult(Map<String, dynamic> result) async {
    try {
      final logData = PracticeLog(
        date: DateTime.now(),
        topic: result['topic'] ?? 'Mixed Practice',
        category: result['category'] ?? 'General',
        correct: result['correct'] ?? 0,
        incorrect: result['incorrect'] ?? 0,
        score: result['score'] ?? (result['correct'] ?? 0),
        total: result['total'] ?? 10,
        avgTime: (result['avgTime'] ?? 0).toDouble(),
        timeSpentSeconds: result['timeSpentSeconds'] ?? 0,
        questions: List<Map<String, dynamic>>.from(result['questions'] ?? []),
        userAnswers: Map<int, String>.from(result['userAnswers'] ?? {}),
      );

      await HiveService.addPracticeLog(logData);
      dev.log("✅ Offline quiz result saved (topic: ${logData.topic})");
    } catch (e, st) {
      dev.log("⚠️ Failed to save offline quiz result: $e", stackTrace: st);
    }
  }

  // ---------------------------------------------------------------------------
  // ☁️ ONLINE (RANKED) STORAGE
  // ---------------------------------------------------------------------------

  /// Save ranked (daily) quiz result to Firebase + local cache
  Future<void> saveRankedResult(QuizSessionModel session) async {
    final user = _auth.currentUser;
    if (user == null) {
      dev.log("⚠️ No logged in user, skipping online ranked save");
      await saveOfflineSession(session);
      return;
    }

    final todayKey = DateTime.now().toIso8601String().substring(0, 10);
    final dailyRef = _firestore
        .collection('daily_leaderboard')
        .doc(todayKey)
        .collection('entries')
        .doc(user.uid);

    final userData = {
      'uid': user.uid,
      'name': user.displayName ?? 'Player',
      'photoUrl': user.photoURL ?? '',
      'score': session.score,
      'correct': session.correct,
      'incorrect': session.incorrect,
      'total': session.total,
      'timeTaken': session.timeSpentSeconds,
      'timestamp': FieldValue.serverTimestamp(),
      'questions': session.questions,
      'userAnswers': session.userAnswers.map(
        (k, v) => MapEntry(k.toString(), v),
      ),
    };

    try {
      await dailyRef.set(userData, SetOptions(merge: true));
      dev.log("☁️ Ranked quiz uploaded to Firestore for $todayKey");

      // Update all-time leaderboard
      final allRef = _firestore.collection('alltime_leaderboard').doc(user.uid);
      await _updateAllTimeLeaderboard(allRef, userData);

      // Cache in Hive for trend
      await HiveService.addDailyScore(
        DailyScore(date: DateTime.parse(todayKey), score: session.score),
      );

      // Update streak
      await _updateStreak(todayKey);

      // Save metadata
      await HiveService.saveDailyQuizMeta(
        DailyQuizMeta(
          date: todayKey,
          totalQuestions: session.total,
          score: session.score,
          difficulty: session.difficulty ?? 'normal', // 🧩 Added required arg
        ),
      );
    } catch (e, st) {
      dev.log("❌ Firestore ranked save failed: $e", stackTrace: st);
      await saveOfflineSession(session);
    }
  }

  /// Helper to maintain all-time leaderboard in Firebase
  Future<void> _updateAllTimeLeaderboard(
    DocumentReference<Map<String, dynamic>> ref,
    Map<String, dynamic> userData,
  ) async {
    final snapshot = await ref.get();
    final currentScore = userData['score'] ?? 0;

    if (snapshot.exists) {
      final prev = snapshot.data()!;
      await ref.update({
        'name': userData['name'],
        'photoUrl': userData['photoUrl'],
        'totalScore': (prev['totalScore'] ?? 0) + currentScore,
        'quizzesTaken': (prev['quizzesTaken'] ?? 0) + 1,
        'bestDailyScore': currentScore > (prev['bestDailyScore'] ?? 0)
            ? currentScore
            : (prev['bestDailyScore'] ?? 0),
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } else {
      await ref.set({
        'uid': userData['uid'],
        'name': userData['name'],
        'photoUrl': userData['photoUrl'],
        'totalScore': currentScore,
        'quizzesTaken': 1,
        'bestDailyScore': currentScore,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    }
  }

  // ---------------------------------------------------------------------------
  // 🔥 STREAK HANDLING
  // ---------------------------------------------------------------------------

  Future<void> _updateStreak(String todayKey) async {
    try {
      final today = DateTime.now();
      final streak = HiveService.getStreak();

      if (streak == null) {
        await HiveService.saveStreak(
          StreakData(currentStreak: 1, lastActive: today),
        );
      } else {
        final diff = today.difference(streak.lastActive).inDays;
        if (diff == 1) {
          await HiveService.saveStreak(
            StreakData(
              currentStreak: streak.currentStreak + 1,
              lastActive: today,
            ),
          );
        } else if (diff > 1) {
          await HiveService.saveStreak(
            StreakData(currentStreak: 1, lastActive: today),
          );
        }
      }

      dev.log("🔥 Streak updated successfully for $todayKey");
    } catch (e, st) {
      dev.log("⚠️ Failed to update streak: $e", stackTrace: st);
    }
  }

  // ---------------------------------------------------------------------------
  // 💾 OFFLINE FALLBACK
  // ---------------------------------------------------------------------------

  Future<void> saveOfflineSession(QuizSessionModel session) async {
    try {
      final result = {
        'topic': session.topic,
        'category': session.category,
        'correct': session.correct,
        'incorrect': session.incorrect,
        'score': session.score,
        'total': session.total,
        'avgTime': session.avgTime,
        'timeSpentSeconds': session.timeSpentSeconds,
        'questions': session.questions,
        'userAnswers': session.userAnswers,
      };
      await saveOfflineResult(result);
    } catch (e, st) {
      dev.log("⚠️ Fallback save failed: $e", stackTrace: st);
    }
  }

  // ---------------------------------------------------------------------------
  // 📊 LEADERBOARD FETCH + CACHE
  // ---------------------------------------------------------------------------

  Stream<QuerySnapshot<Map<String, dynamic>>> getDailyLeaderboard() {
    final todayKey = DateTime.now().toIso8601String().substring(0, 10);
    return _firestore
        .collection('daily_leaderboard')
        .doc(todayKey)
        .collection('entries')
        .orderBy('score', descending: true)
        .orderBy('timeTaken')
        .limit(50)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getAllTimeLeaderboard() {
    return _firestore
        .collection('alltime_leaderboard')
        .orderBy('totalScore', descending: true)
        .limit(50)
        .snapshots();
  }

  Future<List<Map<String, dynamic>>> fetchDailyLeaderboardWithFallback() async {
    final todayKey = DateTime.now().toIso8601String().substring(0, 10);

    try {
      final query = await _firestore
          .collection('daily_leaderboard')
          .doc(todayKey)
          .collection('entries')
          .orderBy('score', descending: true)
          .orderBy('timeTaken')
          .limit(50)
          .get();

      final list = query.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'name': data['name'] ?? 'Player',
          'photoUrl': data['photoUrl'] ?? '',
          'score': data['score'] ?? 0,
          'timeTaken': data['timeTaken'] ?? 0,
          'correct': data['correct'] ?? 0,
        };
      }).toList();

      await HiveService.queueForSync('leaderboard_cache', {
        'key': todayKey,
        'data': list,
      });
      return list;
    } catch (e, st) {
      dev.log(
        "⚠️ Firestore unavailable, loading cached leaderboard",
        stackTrace: st,
      );
      return [];
    }
  }

  Future<List<Map<String, dynamic>>>
  fetchAllTimeLeaderboardWithFallback() async {
    const cacheKey = "alltime_leaderboard";
    try {
      final query = await _firestore
          .collection('alltime_leaderboard')
          .orderBy('totalScore', descending: true)
          .limit(50)
          .get();

      final list = query.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'name': data['name'] ?? 'Player',
          'photoUrl': data['photoUrl'] ?? '',
          'totalScore': data['totalScore'] ?? 0,
          'quizzesTaken': data['quizzesTaken'] ?? 0,
        };
      }).toList();

      await HiveService.queueForSync('leaderboard_cache', {
        'key': cacheKey,
        'data': list,
      });
      return list;
    } catch (e, st) {
      dev.log(
        "⚠️ Firestore unavailable, using cached all-time leaderboard",
        stackTrace: st,
      );
      return [];
    }
  }

  // ---------------------------------------------------------------------------
  // 🔍 UTILITIES
  // ---------------------------------------------------------------------------

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
      dev.log("⚠️ Failed to check play status: $e");
      return false;
    }
  }
}
