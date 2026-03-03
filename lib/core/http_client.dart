import "dart:convert";
import "package:http/http.dart" as http;

class HttpX {
  static Future<Map<String, dynamic>> getJson(
    Uri url, {
    required Map<String, String> headers,
    Duration timeout = const Duration(seconds: 12),
  }) async {
    final resp = await http.get(url, headers: headers).timeout(timeout);
    final body = resp.body;
    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      throw HttpException("HTTP ${resp.statusCode}: $body");
    }
    final decoded = jsonDecode(body);
    if (decoded is Map<String, dynamic>) return decoded;
    throw HttpException("Invalid JSON object");
  }

  static Future<Map<String, dynamic>> postJson(
    Uri url, {
    required Map<String, String> headers,
    required Map<String, dynamic> body,
    Duration timeout = const Duration(seconds: 12),
  }) async {
    final resp = await http
        .post(url, headers: headers, body: jsonEncode(body))
        .timeout(timeout);
    final text = resp.body;
    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      throw HttpException("HTTP ${resp.statusCode}: $text");
    }
    final decoded = jsonDecode(text);
    if (decoded is Map<String, dynamic>) return decoded;
    throw HttpException("Invalid JSON object");
  }
}

class HttpException implements Exception {
  final String message;
  HttpException(this.message);
  @override
  String toString() => message;
}