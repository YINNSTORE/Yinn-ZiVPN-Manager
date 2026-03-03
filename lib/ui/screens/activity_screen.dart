import "package:flutter/material.dart";
import "package:intl/intl.dart";
import "../../data/activity_log.dart";
import "../widgets/section_card.dart";

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  List<ActivityItem> _items = [];
  bool _loading = false;

  Future<void> _load() async {
    setState(() => _loading = true);
    final items = await ActivityLog.readAll();
    if (!mounted) return;
    setState(() {
      _items = items;
      _loading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  String _fmt(int ts) {
    final dt = DateTime.fromMillisecondsSinceEpoch(ts);
    return DateFormat("yyyy-MM-dd HH:mm:ss").format(dt);
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              const Text("Activity Log", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
              const Spacer(),
              TextButton(
                onPressed: () async {
                  await ActivityLog.clear();
                  await _load();
                },
                child: const Text("Clear"),
              )
            ],
          ),
          if (_loading) const LinearProgressIndicator(),
          const SizedBox(height: 10),
          if (_items.isEmpty)
            const Text("Belum ada log.")
          else
            ..._items.map(
              (it) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: SectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("${it.type.toUpperCase()} • ${_fmt(it.ts)}",
                          style: const TextStyle(fontWeight: FontWeight.w800)),
                      const SizedBox(height: 6),
                      Text(it.message),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}