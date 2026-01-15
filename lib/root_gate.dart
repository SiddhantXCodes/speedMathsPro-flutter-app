import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/local_user_provider.dart';
import 'widgets/splash_screen.dart';
import 'widgets/username_screen.dart';
import 'app.dart';

class RootGate extends StatelessWidget {
  const RootGate({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<LocalUserProvider>();

    // 1️⃣ App / provider still loading
    if (!user.isInitialized) {
      return const SplashScreen();
    }

    // 2️⃣ First-time user → onboarding
    if (!user.hasUsername) {
      return const UsernameScreen();
    }

    // 3️⃣ Normal app
    return const SpeedMathApp();
  }
}
