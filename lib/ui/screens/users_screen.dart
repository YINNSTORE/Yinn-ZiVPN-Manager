import "package:flutter/material.dart";
import "../../data/activity_log.dart";
import "../../data/models.dart";
import "../../data/zivpn_api.dart";
import "../widgets/user_card.dart";

class UsersScreen extends StatefulWidget {
  final Session session;
  const UsersScreen({super.key, required this.session});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  bool _loading = false;
  String _q = "";
  String _filter = "all"; // all/active/expired
  List<UserData> _users = [];

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final api = ZiVpnApi(widget.session);
      final users = await api.users();
      await ActivityLog.add("info", "Fetch /api/users OK (count=${users.length})");
      if (!mounted) return;
      setState(() => _users = users);
    } catch (e) {
      await ActivityLog.add("error", "Fetch /api/users failed: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Load users gagal: $e")));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<UserData> get _filtered {
    var list = _users;
    if (_q.trim().isNotEmpty) {
      final qq = _q.trim().toLowerCase();
      list = list.where((u) => u.password.toLowerCase().contains(qq)).toList();
    }
    if (_filter == "active") {
      list = list.where((u) => !u.status.toLowerCase().contains("expired")).toList();
    } else if (_filter == "expired") {
      list = list.where((u) => u.status.toLowerCase().contains("expired")).toList();
    }
    return list;
  }

  Future<void> _renew(String password) async {
    final daysCtl = TextEditingController(text: "30");
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Renew user"),
        content: TextField(
          controller: daysCtl,
          decoration: const InputDecoration(labelText: "Days (angka)"),
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Batal")),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text("Renew")),
        ],
      ),
    );
    if (ok != true) return;

    final days = int.tryParse(daysCtl.text.trim()) ?? 0;
    if (days <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Days tidak valid")));
      return;
    }

    try {
      final api = ZiVpnApi(widget.session);
      await api.renewUser(password: password, days: days);
      await ActivityLog.add("renew", "Renew OK: $password +$days days");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Renew sukses")));
      await _load();
    } catch (e) {
      await ActivityLog.add("error", "Renew failed: $password ($e)");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Renew gagal: $e")));
    }
  }

  Future<void> _delete(String password) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete user"),
        content: Text("Yakin hapus $password ?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Batal")),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text("Hapus")),
        ],
      ),
    );
    if (ok != true) return;

    try {
      final api = ZiVpnApi(widget.session);
      await api.deleteUser(password: password);
      await ActivityLog.add("delete", "Delete OK: $password");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Delete sukses")));
      await _load();
    } catch (e) {
      await ActivityLog.add("error", "Delete failed: $password ($e)");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Delete gagal: $e")));
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
          TextField(
            decoration: const InputDecoration(
              labelText: "Search password",
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (v) => setState(() => _q = v),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              FilterChip(
                label: const Text("All"),
                selected: _filter == "all",
                onSelected: (_) => setState(() => _filter = "all"),
              ),
              const SizedBox(width: 8),
              FilterChip(
                label: const Text("Active"),
                selected: _filter == "active",
                onSelected: (_) => setState(() => _filter = "active"),
              ),
              const SizedBox(width: 8),
              FilterChip(
                label: const Text("Expired"),
                selected: _filter == "expired",
                onSelected: (_) => setState(() => _filter = "expired"),
              ),
              const Spacer(),
              IconButton(onPressed: _loading ? null : _load, icon: const Icon(Icons.refresh)),
            ],
          ),
          const SizedBox(height: 10),
          if (_loading) const LinearProgressIndicator(),
          const SizedBox(height: 10),
          if (_filtered.isEmpty)
            const Text("Tidak ada user (atau filter kosong).")
          else
            ..._filtered.map(
              (u) => UserCard(
                user: u,
                onRenew: () => _renew(u.password),
                onDelete: () => _delete(u.password),
              ),
            ),
        ],
      ),
    );
  }
}