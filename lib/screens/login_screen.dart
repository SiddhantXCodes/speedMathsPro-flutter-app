import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLogin = true;
  bool _loading = false;
  String? _error;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final auth = FirebaseAuth.instance;
      UserCredential cred;

      if (_isLogin) {
        // Login existing user
        cred = await auth.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        // ✅ Reload user data to get latest name
        await cred.user?.reload();
      } else {
        // Register new user
        cred = await auth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        // ✅ Set display name for new users
        await cred.user?.updateDisplayName(_nameController.text.trim());
        await cred.user?.reload();
      }

      // ✅ Force FirebaseAuth to refresh the current user globally
      await FirebaseAuth.instance.currentUser?.reload();

      if (mounted) Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      setState(() => _error = e.message ?? "Authentication failed");
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _resetPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains("@")) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter a valid email first.")),
      );
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password reset email sent.")),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final accent = AppTheme.adaptiveAccent(context);
    final textColor = AppTheme.adaptiveText(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(_isLogin ? "Login" : "Create Account"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Icon(Icons.lock_outline_rounded, size: 80, color: accent),
            const SizedBox(height: 16),
            Text(
              _isLogin
                  ? "Welcome back! Sign in to continue."
                  : "Create your SpeedMath account.",
              style: TextStyle(fontSize: 16, color: textColor.withOpacity(0.8)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),

            // FORM
            Form(
              key: _formKey,
              child: Column(
                children: [
                  if (!_isLogin) ...[
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: "Full Name",
                        prefixIcon: const Icon(Icons.person_outline_rounded),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      validator: (v) {
                        if (!_isLogin && (v == null || v.isEmpty)) {
                          return "Enter your name";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: "Email",
                      prefixIcon: const Icon(Icons.email_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return "Enter your email";
                      if (!v.contains('@')) return "Invalid email";
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: "Password",
                      prefixIcon: const Icon(Icons.lock_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.length < 6) {
                        return "Password must be at least 6 characters";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),

                  if (_isLogin)
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _resetPassword,
                        child: Text(
                          "Forgot Password?",
                          style: TextStyle(color: accent, fontSize: 13.5),
                        ),
                      ),
                    ),

                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        _error!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),

                  // Main Button
                  ElevatedButton(
                    onPressed: _loading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accent,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: _loading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            _isLogin ? "Login" : "Register",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                  ),
                  const SizedBox(height: 14),

                  // Toggle between Login/Register
                  TextButton(
                    onPressed: () => setState(() => _isLogin = !_isLogin),
                    child: Text(
                      _isLogin
                          ? "Don't have an account? Register"
                          : "Already have an account? Login",
                      style: TextStyle(color: accent),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),

            // OR Divider
            Row(
              children: [
                Expanded(child: Divider(color: textColor.withOpacity(0.3))),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    "OR",
                    style: TextStyle(
                      color: textColor.withOpacity(0.6),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Expanded(child: Divider(color: textColor.withOpacity(0.3))),
              ],
            ),
            const SizedBox(height: 25),

            // Google Sign-In Button
            OutlinedButton.icon(
              onPressed: () async {
                await AuthService().signInWithGoogle();
                if (mounted) Navigator.pop(context);
              },
              icon: Image.asset('assets/images/google_logo.png', height: 24),
              label: const Text(
                "Continue with Google",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                side: BorderSide(color: accent.withOpacity(0.7)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
