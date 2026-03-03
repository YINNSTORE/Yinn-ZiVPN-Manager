import "package:flutter/material.dart";
import "../../data/activity_log.dart";
import "../../data/local_store.dart";
import "../../data/models.dart";
import "../../data/zivpn_api.dart";
import "../widgets/primary_button.dart";
import "../widgets/section_card.dart";

class QuickCreateScreen extends StatefulWidget {
  final Session session;
  const QuickCreateScreen({super.key, required this.session});

  @override
  State<QuickCreateScreen> createState() => _QuickCreateScreenState();
}

class _QuickCreateScreenState extends State<QuickCreateScreen> {
  QuickCreateConfig? _cfg;
  bool _loading = false;

  Future<void> _loadCfg() async {
    final cfg = await LocalStore.readQuickCreate();
    if (!mounted) return;
    setState(() => _cfg = cfg);
  }

  @override
  void initState() {
    super.initState();
    _loadCfg();
  }

  Future<void> _quickCreate() async {
    final cfg = _cfg ?? QuickCreateConfig.defaults();
    final pw = "${cfg.prefix}${ZiVpnApi.genDigits(cfg.digits)}";

    setState(() => _loading = true);
    try {
      final api = ZiVpnApi(widget.session);
      await api.createUser(password: pw, days: cfg.defaultDays);
      await ActivityLog.add("create", "QuickCreate OK: $pw (${cfg.defaultDays} days)");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Create sukses: $pw")));
    } catch (e) {
      await ActivityLog.add("error", "QuickCreate failed ($pw): $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Create gagal: $e")));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _manualCreate() async {
    final pwCtl = TextEditingController();
    final daysCtl = TextEditingController(text: "${_cfg?.defaultDays ?? 1}");

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Create user"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: pwCtl, decoration: const InputDecoration(labelText: "Password")),
            const SizedBox(height: 10),
            TextField(
              controller: daysCtl,
              decoration: const InputDecoration(labelText: "Days"),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Batal")),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text("Create")),
        ],
      ),
    );

    if (ok != true) return;

    final pw = pwCtl.text.trim();
    final days = int.tryParse(daysCtl.text.trim()) ?? 0;
    if (pw.isEmpty || days <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Input tidak valid")));
      return;
    }

    setState(() => _loading = true);
    try {
      final api = ZiVpnApi(widget.session);
      await api.createUser(password: pw, days: days);
      await ActivityLog.add("create", "Manual create OK: $pw ($days days)");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Create sukses")));
    } catch (e) {
      await ActivityLog.add("error", "Manual create failed: $pw ($e)");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Create gagal: $e")));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cfg = _cfg ?? QuickCreateConfig.defaults();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Quick Create", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Text("Prefix: ${cfg.prefix}"),
              Text("Digits: ${cfg.digits}"),
              Text("Default days: ${cfg.defaultDays}"),
              const SizedBox(height: 12),
              PrimaryButton(
                text: "Quick Create Now",
                icon: Icons.flash_on,
                loading: _loading,
                onPressed: _quickCreate,
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: _loading ? null : _manualCreate,
                icon: const Icon(Icons.add),
                label: const Text("Manual Create"),
              ),
            ],
          ),
        ),
      ],
    );
  }
}