import 'package:flutter/material.dart';

class BootScreen extends StatelessWidget {
  final String message;

  const BootScreen({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 20),
              Text(message, style: const TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }
}
