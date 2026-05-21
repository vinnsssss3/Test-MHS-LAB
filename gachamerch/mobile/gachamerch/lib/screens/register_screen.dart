import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../widgets/validated_field.dart';
import '../widgets/themed_button.dart';

// Page 3 — username, email, password, confirm password
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey    = GlobalKey<FormState>();
  final _userCtrl   = TextEditingController();
  final _emailCtrl  = TextEditingController();
  final _passCtrl   = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _showPass = false;
  bool _loading  = false;

  @override
  void dispose() {
    _userCtrl.dispose(); _emailCtrl.dispose();
    _passCtrl.dispose(); _confirmCtrl.dispose();
    super.dispose();
  }

  // Validation 2: password complexity
  String? _validatePassword(String? v) {
    if (v == null || v.isEmpty) return 'This field is required';
    if (v.length < 8) return 'Password must be 8+ chars with letters and digits';
    if (!v.contains(RegExp(r'[A-Za-z]'))) return 'Password must be 8+ chars with letters and digits';
    if (!v.contains(RegExp(r'\d'))) return 'Password must be 8+ chars with letters and digits';
    return null;
  }

  // Validation 4: passwords must match
  String? _validateConfirm(String? v) {
    if (v == null || v.isEmpty) return 'This field is required';
    if (v != _passCtrl.text) return 'Passwords do not match';
    return null;
  }

  // Validation 2: email format
  String? _validateEmail(String? v) {
    if (v == null || v.trim().isEmpty) return 'This field is required';
    final emailRx = RegExp(r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$');
    if (!emailRx.hasMatch(v.trim())) return 'Enter a valid email address';
    return null;
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _loading = true);
    try {
      await AuthService.register(
        _userCtrl.text.trim(),
        _emailCtrl.text.trim(),
        _passCtrl.text,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account created! Please sign in.')));
      Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(children: [
              const SizedBox(height: 12),
              // Validation 1: required
              ValidatedField(
                label: 'Username',
                controller: _userCtrl,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'This field is required';
                  if (!RegExp(r'^[A-Za-z0-9_]{3,50}$').hasMatch(v.trim())) {
                    return 'Username: 3–50 chars, letters/digits/underscore only';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              ValidatedField(
                label: 'Email',
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                validator: _validateEmail,
              ),
              const SizedBox(height: 14),
              ValidatedField(
                label: 'Password',
                controller: _passCtrl,
                obscureText: !_showPass,
                suffixIcon: IconButton(
                  icon: Icon(_showPass ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => _showPass = !_showPass),
                ),
                validator: _validatePassword,
              ),
              const SizedBox(height: 14),
              ValidatedField(
                label: 'Confirm Password',
                controller: _confirmCtrl,
                obscureText: !_showPass,
                validator: _validateConfirm,
              ),
              const SizedBox(height: 24),
              ThemedButton(
                label: 'Create Account',
                loading: _loading,
                icon: Icons.person_add,
                onPressed: _submit,
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
