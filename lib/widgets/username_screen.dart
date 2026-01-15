import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/local_user_provider.dart';

class UsernameScreen extends StatefulWidget {
  const UsernameScreen({super.key});

  @override
  State<UsernameScreen> createState() => _UsernameScreenState();
}

class _UsernameScreenState extends State<UsernameScreen> {
  final TextEditingController _nameController = TextEditingController();
  String? _error;

  Future<void> _submit() async {
    final user = context.read<LocalUserProvider>();

    try {
      await user.setUsername(_nameController.text);
      // ❌ NO NAVIGATION
      // RootGate will automatically rebuild → Home
    } catch (e) {
      setState(() => _error = "Enter at least 3 characters");
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Welcome to SpeedMaths Pro",
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 20),

              TextField(
                controller: _nameController,
                textAlign: TextAlign.center,
                maxLength: 15,
                decoration: InputDecoration(
                  hintText: "Enter your username",
                  errorText: _error,
                  counterText: "",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              ElevatedButton(
                onPressed: _submit,
                child: const Text("Continue"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
