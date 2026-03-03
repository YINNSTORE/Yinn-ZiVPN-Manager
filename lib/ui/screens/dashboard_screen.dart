import "package:flutter/material.dart";
import "../../data/activity_log.dart";
import "../../data/models.dart";
import "../../data/zivpn_api.dart";
import "../widgets/section_card.dart";
import "../widgets/status_chip.dart";

class DashboardScreen extends StatefulWidget {
  final Session session;
  const DashboardScreen({super.key, required this.session});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _loading = false;
  String? _err;
  ServerInfo? _info;

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _err = null;
    });

    try {
      final api = ZiVpnApi(widget.session);
      final info = await api.info();
      await ActivityLog.add("info", "Fetch /api/info OK");
      if (!mounted) return;
      setState(() => _info = info);
    } catch (e) {
      await ActivityLog.add("error", "Fetch /api/info failed: $e");
      if (!mounted) return;
      setState(() => _err = "$e");
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (_err != null)
            SectionCard(
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_outlined),
                  const SizedBox(width: 10),
                  Expanded(child: Text("API error: $_err")),
                ],
              ),
            ),
          if (_err != null) const SizedBox(height: 12),
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text("Server Info", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                    const Spacer(),
                    StatusChip(text: _loading ? "Loading" : (_info != null ? "Online" : "Unknown")),
                  ],
                ),
                const SizedBox(height: 10),
                Text("Public IP: ${_info?.publicIp ?? "-"}"),
                Text("Port: ${_info?.port ?? "-"}"),
                Text("Service: ${_info?.service ?? "-"}"),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: _loading ? null : _load,
                  icon: const Icon(Icons.refresh),
                  label: const Text("Refresh"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}