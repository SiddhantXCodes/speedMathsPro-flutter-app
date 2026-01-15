import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Timer _symbolTimer;

  final List<_FloatingSymbol> _symbols = [];
  final List<String> _mathChars = ["+", "-", "×", "÷", "√", "%", "π"];

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);

    _symbolTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      if (_symbols.length < 12 && mounted) {
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
  }

  @override
  void dispose() {
    _controller.dispose();
    _symbolTimer.cancel();
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

              const Center(
                child: CircularProgressIndicator(),
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
