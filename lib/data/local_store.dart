import "package:shared_preferences/shared_preferences.dart";
import "models.dart";

class LocalStore {
  static const _qcPrefix = "qc_prefix";
  static const _qcDigits = "qc_digits";
  static const _qcDays = "qc_days";

  static Future<QuickCreateConfig> readQuickCreate() async {
    final sp = await SharedPreferences.getInstance();
    final prefix = sp.getString(_qcPrefix);
    final digits = sp.getInt(_qcDigits);
    final days = sp.getInt(_qcDays);

    final def = QuickCreateConfig.defaults();
    return def.copyWith(
      prefix: prefix ?? def.prefix,
      digits: digits ?? def.digits,
      defaultDays: days ?? def.defaultDays,
    );
  }

  static Future<void> saveQuickCreate(QuickCreateConfig cfg) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_qcPrefix, cfg.prefix);
    await sp.setInt(_qcDigits, cfg.digits);
    await sp.setInt(_qcDays, cfg.defaultDays);
  }
}