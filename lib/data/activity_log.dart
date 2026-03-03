import "dart:convert";
import "package:shared_preferences/shared_preferences.dart";

class ActivityItem {
  final int ts;
  final String type; // create/renew/delete/login/info/error
  final String message;

  ActivityItem({required this.ts, required this.type, required this.message});

  Map<String, dynamic> toJson() => {"ts": ts, "type": type, "message": message};

  static ActivityItem fromJson(Map<String, dynamic> j) => ActivityItem(
        ts: (j["ts"] as num).toInt(),
        type: "${j["type"] ?? "info"}",
        message: "${j["message"] ?? ""}",
      );
}

class ActivityLog {
  static const _key = "activity_log_v1";
  static const _max = 250;

  static Future<List<ActivityItem>> readAll() async {
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getString(_key);
    if (raw == null || raw.trim().isEmpty) return [];
    final decoded = jsonDecode(raw);
    if (decoded is! List) return [];
    return decoded
        .whereType<Map<String, dynamic>>()
        .map(ActivityItem.fromJson)
        .toList()
        .reversed
        .toList(); // newest first
  }

  static Future<void> add(String type, String message) async {
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getString(_key);
    List list = [];
    if (raw != null && raw.trim().isNotEmpty) {
      final decoded = jsonDecode(raw);
      if (decoded is List) list = decoded;
    }
    list.add(ActivityItem(ts: DateTime.now().millisecondsSinceEpoch, type: type, message: message).toJson());
    if (list.length > _max) {
      list = list.sublist(list.length - _max);
    }
    await sp.setString(_key, jsonEncode(list));
  }

  static Future<void> clear() async {
    final sp = await SharedPreferences.getInstance();
    await sp.remove(_key);
  }
}