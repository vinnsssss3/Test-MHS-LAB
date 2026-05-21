import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/validated_field.dart';
import '../widgets/themed_button.dart';

// Page 2 — username/password + Google OAuth login
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey   = GlobalKey<FormState>();
  final _userCtrl  = TextEditingController();
  final _passCtrl  = TextEditingController();
  bool  _showPass  = false;
  bool  _googleLoading = false;

  final _googleSignIn = GoogleSignIn(scopes: ['email']);

  @override
  void dispose() {
    _userCtrl.dispose(); _passCtrl.dispose(); super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final ok = await context.read<AuthProvider>().login(
      _userCtrl.text.trim(), _passCtrl.text);
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pushReplacementNamed('/hub');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(context.read<AuthProvider>().error ?? 'Login failed')));
    }
  }

  Future<void> _googleSignInTap() async {
    setState(() => _googleLoading = true);
    try {
      final account = await _googleSignIn.signIn();
      if (account == null) return;
      final auth    = await account.authentication;
      final idToken = auth.idToken;
      if (idToken == null) throw Exception('No ID token from Google');
      if (!mounted) return;
      final ok = await context.read<AuthProvider>().googleLogin(idToken);
      if (!mounted) return;
      if (ok) {
        Navigator.of(context).pushReplacementNamed('/hub');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(context.read<AuthProvider>().error ?? 'Google login failed')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Google sign-in error: $e')));
      }
    } finally {
      if (mounted) setState(() => _googleLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth   = context.watch<AuthProvider>();
    final accent = Theme.of(context).colorScheme.primary;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 32),
                Icon(Icons.auto_awesome, size: 52, color: accent),
                const SizedBox(height: 12),
                Text('Welcome back',
                  style: Theme.of(context).textTheme.headlineLarge),
                Text('Sign in to GachaMerch',
                  style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 32),
                ValidatedField(
                  label: 'Username',
                  controller: _userCtrl,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'This field is required' : null,
                ),
                const SizedBox(height: 16),
                ValidatedField(
                  label: 'Password',
                  controller: _passCtrl,
                  obscureText: !_showPass,
                  suffixIcon: IconButton(
                    icon: Icon(_showPass ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _showPass = !_showPass),
                  ),
                  validator: (v) => (v == null || v.isEmpty)
                      ? 'This field is required' : null,
                ),
                const SizedBox(height: 24),
                ThemedButton(
                  label: 'Sign In',
                  loading: auth.loading,
                  icon: Icons.login,
                  onPressed: _submit,
                ),
                const SizedBox(height: 12),
                // Google sign-in button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    icon: _googleLoading
                        ? const SizedBox(width: 18, height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.g_mobiledata, size: 26),
                    label: const Text('Sign in with Google'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: accent,
                      side: BorderSide(color: accent),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: _googleLoading ? null : _googleSignInTap,
                  ),
                ),
                const SizedBox(height: 20),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text("Don't have an account?",
                    style: Theme.of(context).textTheme.bodyMedium),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/register'),
                    child: Text('Register', style: TextStyle(color: accent)),
                  ),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
