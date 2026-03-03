import "package:flutter/material.dart";
import "../../data/activity_log.dart";
import "../../data/local_store.dart";
import "../../data/models.dart";
import "../../data/secure_store.dart";
import "../widgets/section_card.dart";
import "login_screen.dart";

class SettingsScreen extends StatefulWidget {
  final Session session;
  const SettingsScreen({super.key, required this.session});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  QuickCreateConfig? _cfg;

  final _prefixCtl = TextEditingController();
  final _digitsCtl = TextEditingController();
  final _daysCtl = TextEditingController();

  Future<void> _load() async {
    final cfg = await LocalStore.readQuickCreate();
    if (!mounted) return;
    setState(() {
      _cfg = cfg;
      _prefixCtl.text = cfg.prefix;
      _digitsCtl.text = "${cfg.digits}";
      _daysCtl.text = "${cfg.defaultDays}";
    });
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _save() async {
    final prefix = _prefixCtl.text.trim();
    final digits = int.tryParse(_digitsCtl.text.trim()) ?? 0;
    final days = int.tryParse(_daysCtl.text.trim()) ?? 0;

    if (prefix.isEmpty || digits < 1 || digits > 12 || days < 1 || days > 3650) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Config tidak valid")));
      return;
    }

    final cfg = QuickCreateConfig(prefix: prefix, digits: digits, defaultDays: days);
    await LocalStore.saveQuickCreate(cfg);
    await ActivityLog.add("info", "Settings saved: prefix=$prefix digits=$digits days=$days");
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Tersimpan")));
    setState(() => _cfg = cfg);
  }

  Future<void> _logout() async {
    await SecureStore.clearSession();
    await ActivityLog.add("info", "Logout");
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (r) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Session", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Text("Base URL: ${widget.session.baseUrl}"),
              const SizedBox(height: 8),
              OutlinedButton.icon(onPressed: _logout, icon: const Icon(Icons.logout), label: const Text("Logout")),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Quick Create Config", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
              const SizedBox(height: 10),
              TextField(controller: _prefixCtl, decoration: const InputDecoration(labelText: "Prefix (contoh: YinnTrialX)")),
              const SizedBox(height: 10),
              TextField(controller: _digitsCtl, decoration: const InputDecoration(labelText: "Digits (1-12)"), keyboardType: TextInputType.number),
              const SizedBox(height: 10),
              TextField(controller: _daysCtl, decoration: const InputDecoration(labelText: "Default Days"), keyboardType: TextInputType.number),
              const SizedBox(height: 12),
              FilledButton.icon(onPressed: _save, icon: const Icon(Icons.save), label: const Text("Save")),
              const SizedBox(height: 8),
              Text("Current: ${_cfg?.prefix ?? "-"} + ${_cfg?.digits ?? "-"} digits • ${_cfg?.defaultDays ?? "-"} days",
                  style: TextStyle(color: Theme.of(context).colorScheme.outline)),
            ],
          ),
        ),
      ],
    );
  }
}