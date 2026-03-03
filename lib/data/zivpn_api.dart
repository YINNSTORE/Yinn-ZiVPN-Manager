import "dart:math";
import "package:http/http.dart" as http;
import "../core/constants.dart";
import "../core/http_client.dart";
import "../core/validators.dart";
import "models.dart";

class ZiVpnApi {
  final Session session;

  ZiVpnApi(this.session);

  Map<String, String> _headers() => {
        "Content-Type": "application/json",
        "X-API-Key": session.apiKey,
      };

  Uri _url(String path) {
    final base = Validators.normalizeBaseUrl(session.baseUrl);
    return Uri.parse("$base${AppConstants.apiBasePath}$path");
  }

  Future<ServerInfo> info() async {
    final json = await HttpX.getJson(_url("/info"), headers: _headers());
    if (json["success"] != true) {
      throw HttpException("API: success=false");
    }
    final data = (json["data"] is Map<String, dynamic>) ? (json["data"] as Map<String, dynamic>) : <String, dynamic>{};
    return ServerInfo.fromApi(data);
  }

  Future<List<UserData>> users() async {
    final json = await HttpX.getJson(_url("/users"), headers: _headers());
    if (json["success"] != true) {
      throw HttpException("API: success=false");
    }
    final data = json["data"];
    if (data is! List) return [];
    return data.whereType<Map<String, dynamic>>().map(UserData.fromApi).toList();
  }

  Future<void> createUser({required String password, required int days, int ipLimit = 2}) async {
    final json = await HttpX.postJson(
      _url("/user/create"),
      headers: _headers(),
      body: {"password": password, "days": days, "ip_limit": ipLimit},
    );
    if (json["success"] != true) {
      throw HttpException("Create failed: ${json["message"]}");
    }
  }

  Future<void> renewUser({required String password, required int days}) async {
    final json = await HttpX.postJson(
      _url("/user/renew"),
      headers: _headers(),
      body: {"password": password, "days": days},
    );
    if (json["success"] != true) {
      throw HttpException("Renew failed: ${json["message"]}");
    }
  }

  Future<void> deleteUser({required String password}) async {
    final json = await HttpX.postJson(
      _url("/user/delete"),
      headers: _headers(),
      body: {"password": password},
    );
    if (json["success"] != true) {
      throw HttpException("Delete failed: ${json["message"]}");
    }
  }

  static String genDigits(int n) {
    final r = Random.secure();
    final sb = StringBuffer();
    for (var i = 0; i < n; i++) {
      sb.write(r.nextInt(10));
    }
    return sb.toString();
  }

  static Future<String?> detectPublicIp() async {
    try {
      final resp = await http.get(Uri.parse(AppConstants.ipifyUrl)).timeout(const Duration(seconds: 7));
      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        final ip = resp.body.trim();
        if (ip.isNotEmpty) return ip;
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}