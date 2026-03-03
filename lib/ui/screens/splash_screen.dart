import "package:flutter/material.dart";
import "../../data/secure_store.dart";
import "../../data/activity_log.dart";
import "home_screen.dart";
import "login_screen.dart";

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _boot();
  }

  Future<void> _boot() async {
    final s = await SecureStore.readSession();
    await Future.delayed(const Duration(milliseconds: 350));
    if (!mounted) return;
    if (s == null) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
      return;
    }
    await ActivityLog.add("info", "Auto session loaded");
    if (!mounted) return;
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => HomeScreen(session: s)));
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}