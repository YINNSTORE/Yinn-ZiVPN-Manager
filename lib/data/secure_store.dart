import "package:flutter_secure_storage/flutter_secure_storage.dart";
import "models.dart";

class SecureStore {
  static const _baseUrlKey = "session_base_url";
  static const _apiKeyKey = "session_api_key";
  static const _storage = FlutterSecureStorage();

  static Future<void> saveSession(Session s) async {
    await _storage.write(key: _baseUrlKey, value: s.baseUrl);
    await _storage.write(key: _apiKeyKey, value: s.apiKey);
  }

  static Future<Session?> readSession() async {
    final baseUrl = await _storage.read(key: _baseUrlKey);
    final apiKey = await _storage.read(key: _apiKeyKey);
    if (baseUrl == null || apiKey == null) return null;
    if (baseUrl.trim().isEmpty || apiKey.trim().isEmpty) return null;
    return Session(baseUrl: baseUrl, apiKey: apiKey);
  }

  static Future<void> clearSession() async {
    await _storage.delete(key: _baseUrlKey);
    await _storage.delete(key: _apiKeyKey);
  }
}