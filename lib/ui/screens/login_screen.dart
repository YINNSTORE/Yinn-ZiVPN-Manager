import "package:flutter/material.dart";
import "../../core/constants.dart";
import "../../core/validators.dart";
import "../../data/activity_log.dart";
import "../../data/models.dart";
import "../../data/secure_store.dart";
import "../../data/zivpn_api.dart";
import "../widgets/navy_app_bar.dart";
import "../widgets/primary_button.dart";
import "home_screen.dart";

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _baseUrl = TextEditingController();
  final _apiKey = TextEditingController();
  bool _loading = false;
  String? _hint;

  @override
  void initState() {
    super.initState();
    _autoFillBaseUrl();
  }

  Future<void> _autoFillBaseUrl() async {
    final ip = await ZiVpnApi.detectPublicIp();
    final targetIp = (ip == null || ip.isEmpty) ? "127.0.0.1" : ip;
    final url = "http://$targetIp:${AppConstants.defaultPort}";
    setState(() {
      _baseUrl.text = url;
      _hint = "Auto base URL: $url";
    });
  }

  Future<void> _login() async {
    final base = _baseUrl.text.trim();
    final key = _apiKey.text.trim();

    if (!Validators.isValidBaseUrl(base)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Base URL harus mulai http:// atau https://")));
      return;
    }
    if (key.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("API Key wajib diisi")));
      return;
    }

    setState(() => _loading = true);

    try {
      final session = Session(baseUrl: Validators.normalizeBaseUrl(base), apiKey: key);
      final api = ZiVpnApi(session);
      await api.info(); // test
      await SecureStore.saveSession(session);
      await ActivityLog.add("login", "Login OK (info test success)");
      if (!mounted) return;

      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => HomeScreen(session: session)));
    } catch (e) {
      await ActivityLog.add("error", "Login failed: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Login gagal: $e")));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const NavyAppBar(title: "Login"),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (_hint != null)
              Align(
                alignment: Alignment.centerLeft,
                child: Text(_hint!, style: TextStyle(color: Theme.of(context).colorScheme.outline)),
              ),
            const SizedBox(height: 12),
            TextField(
              controller: _baseUrl,
              decoration: const InputDecoration(
                labelText: "Base URL",
                hintText: "http://1.2.3.4:8080",
                prefixIcon: Icon(Icons.link),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _apiKey,
              decoration: const InputDecoration(
                labelText: "API Key",
                prefixIcon: Icon(Icons.key),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            PrimaryButton(
              text: "Login (Test /api/info)",
              icon: Icons.login,
              loading: _loading,
              onPressed: _login,
            ),
            const SizedBox(height: 10),
            Text(
              "Auth pakai header X-API-Key. Login sukses kalau /api/info sukses.",
              style: TextStyle(color: Theme.of(context).colorScheme.outline),
            ),
          ],
        ),
      ),
    );
  }
}