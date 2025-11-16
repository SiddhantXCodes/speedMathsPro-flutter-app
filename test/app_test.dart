import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

import 'helpers/helpers/firebase_mocks.dart';
import 'helpers/helpers/test_app.dart';

import 'package:speedmaths_pro/features/home/screens/home_screen.dart';

void main() {
  // ------------------------------------------------------------
  // 🔥 Initialize all Firebase mocks before ANY test runs
  // ------------------------------------------------------------
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await setupFirebaseMocks();
  });

  testWidgets(
    "🚀 Full App Launch → SpeedMathApp loads and HomeScreen appears",
    (tester) async {
      // Load entire app
      await tester.pumpWidget(createTestApp());

      // wait for all providers + async builds
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // HomeScreen must exist
      expect(find.byType(HomeScreen), findsOneWidget);
    },
  );
}
