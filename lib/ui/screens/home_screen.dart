import "package:flutter/material.dart";
import "../../data/models.dart";
import "../widgets/navy_app_bar.dart";
import "dashboard_screen.dart";
import "users_screen.dart";
import "quick_create_screen.dart";
import "activity_screen.dart";
import "settings_screen.dart";

class HomeScreen extends StatefulWidget {
  final Session session;
  const HomeScreen({super.key, required this.session});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _idx = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      DashboardScreen(session: widget.session),
      UsersScreen(session: widget.session),
      QuickCreateScreen(session: widget.session),
      const ActivityScreen(),
      SettingsScreen(session: widget.session),
    ];

    final titles = ["Dashboard", "Users", "Quick Create", "Activity", "Settings"];

    return Scaffold(
      appBar: NavyAppBar(title: titles[_idx]),
      body: pages[_idx],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _idx,
        onDestinationSelected: (v) => setState(() => _idx = v),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), label: "Dash"),
          NavigationDestination(icon: Icon(Icons.people_outline), label: "Users"),
          NavigationDestination(icon: Icon(Icons.flash_on_outlined), label: "Quick"),
          NavigationDestination(icon: Icon(Icons.receipt_long_outlined), label: "Log"),
          NavigationDestination(icon: Icon(Icons.settings_outlined), label: "Set"),
        ],
      ),
    );
  }
}