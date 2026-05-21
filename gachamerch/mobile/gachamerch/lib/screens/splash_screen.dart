import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

// Page 1 — checks token in secure storage, routes to Login or Hub
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _ctrl.forward();
    _init();
  }

  Future<void> _init() async {
    await Future.delayed(const Duration(milliseconds: 1600));
    if (!mounted) return;
    await context.read<AuthProvider>().initFromStorage();
    if (!mounted) return;
    final loggedIn = context.read<AuthProvider>().isLoggedIn;
    Navigator.of(context).pushReplacementNamed(loggedIn ? '/hub' : '/login');
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FadeTransition(
        opacity: _fade,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.auto_awesome, size: 80,
                color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 20),
              Text('GachaMerch',
                style: GoogleFonts.orbitron(
                  fontSize: 34, fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary)),
              const SizedBox(height: 8),
              Text('Three stores. One universe.',
                style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 40),
              const CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}
