import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/local_user_provider.dart';
import '../app.dart';

class BootScreen extends StatefulWidget {
  final String message;

  const BootScreen({super.key, required this.message});

  @override
  State<BootScreen> createState() => _BootScreenState();
}

class _BootScreenState extends State<BootScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Timer _symbolTimer;

  final List<_FloatingSymbol> _symbols = [];
  final List<String> _mathChars = ["+", "-", "×", "÷", "√", "%", "π"];

  final TextEditingController _nameController = TextEditingController();
  String? _error;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);

    _symbolTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      if (_symbols.length < 12) {
        setState(() {
          _symbols.add(
            _FloatingSymbol(
              char: _mathChars[Random().nextInt(_mathChars.length)],
              x: Random().nextDouble(),
              size: Random().nextDouble() * 26 + 18,
              speed: Random().nextDouble() * 1.1 + 0.7,
            ),
          );
        });
      }
    });

    // 🔁 Auto-skip if username already exists
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<LocalUserProvider>();
      if (user.hasUsername) {
        _goHome();
      }
    });
  }

  void _goHome() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const SpeedMathApp()),
    );
  }

  Future<void> _submit() async {
    final user = context.read<LocalUserProvider>();

    try {
      await user.setUsername(_nameController.text);
      _goHome();
    } catch (e) {
      setState(() => _error = "Enter at least 3 characters");
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _symbolTimer.cancel();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: AnimatedBuilder(
        animation: _controller,
        builder: (_, __) {
          return Stack(
            children: [
              // Background
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment(-1 + _controller.value, -1),
                    end: Alignment(1 - _controller.value, 1),
                    colors: [
                      theme.colorScheme.primary.withOpacity(0.45),
                      theme.colorScheme.secondary.withOpacity(0.45),
                      theme.scaffoldBackgroundColor.withOpacity(0.50),
                    ],
                  ),
                ),
              ),

              ..._symbols.map((s) {
                return Positioned(
                  left: s.x * MediaQuery.of(context).size.width,
                  top: s.offset(_controller.value) *
                      MediaQuery.of(context).size.height,
                  child: Opacity(
                    opacity: 0.20,
                    child: Text(
                      s.char,
                      style: TextStyle(
                        fontSize: s.size,
                        fontWeight: FontWeight.bold,
                        color: theme.brightness == Brightness.dark
                            ? Colors.white70
                            : Colors.black54,
                      ),
                    ),
                  ),
                );
              }),

              Center(
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
            ],
          );
        },
      ),
    );
  }
}

class _FloatingSymbol {
  final String char;
  final double x;
  final double speed;
  final double size;

  _FloatingSymbol({
    required this.char,
    required this.x,
    required this.speed,
    required this.size,
  });

  double offset(double t) => (t * speed) % 1.25;
}
