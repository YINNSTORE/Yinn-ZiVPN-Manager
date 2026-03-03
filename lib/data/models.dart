class ServerInfo {
  final String publicIp;
  final dynamic port;
  final dynamic service;

  ServerInfo({required this.publicIp, required this.port, required this.service});

  factory ServerInfo.fromApi(Map<String, dynamic> data) {
    return ServerInfo(
      publicIp: "${data["public_ip"] ?? "-"}",
      port: data["port"],
      service: data["service"],
    );
  }
}

class UserData {
  final String password;
  final String expired;
  final String status;
  final int ipLimit;

  UserData({
    required this.password,
    required this.expired,
    required this.status,
    required this.ipLimit,
  });

  factory UserData.fromApi(Map<String, dynamic> m) {
    return UserData(
      password: "${m["password"] ?? ""}",
      expired: "${m["expired"] ?? ""}",
      status: "${m["status"] ?? ""}",
      ipLimit: (m["ip_limit"] is int) ? (m["ip_limit"] as int) : int.tryParse("${m["ip_limit"]}") ?? 0,
    );
  }
}

class Session {
  final String baseUrl;
  final String apiKey;

  Session({required this.baseUrl, required this.apiKey});
}

class QuickCreateConfig {
  final String prefix;
  final int digits;
  final int defaultDays;

  QuickCreateConfig({
    required this.prefix,
    required this.digits,
    required this.defaultDays,
  });

  factory QuickCreateConfig.defaults() => QuickCreateConfig(
        prefix: "YinnTrialX",
        digits: 5,
        defaultDays: 1,
      );

  QuickCreateConfig copyWith({String? prefix, int? digits, int? defaultDays}) {
    return QuickCreateConfig(
      prefix: prefix ?? this.prefix,
      digits: digits ?? this.digits,
      defaultDays: defaultDays ?? this.defaultDays,
    );
  }
}