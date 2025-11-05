import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Forces 120Hz animations if device supports it
  GestureBinding.instance.resamplingEnabled = false;

  runApp(const SpeedMathApp());
}
