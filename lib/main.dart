import "package:flutter/material.dart";
import "app_theme.dart";
import "ui/screens/splash_screen.dart";

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const YinnZiVPNManagerApp());
}

class YinnZiVPNManagerApp extends StatelessWidget {
  const YinnZiVPNManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Yinn ZiVPN Manager",
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      home: const SplashScreen(),
    );
  }
}