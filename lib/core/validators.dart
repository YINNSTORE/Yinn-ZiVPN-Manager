class Validators {
  static bool isValidBaseUrl(String s) {
    final v = s.trim();
    return v.startsWith("http://") || v.startsWith("https://");
  }

  static String normalizeBaseUrl(String s) {
    var v = s.trim();
    while (v.endsWith("/")) {
      v = v.substring(0, v.length - 1);
    }
    return v;
  }
}