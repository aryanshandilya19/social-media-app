import 'package:shared_preferences/shared_preferences.dart';

class AuthStorage {
  static Future<void> saveTokens({
    required String token,
    required String refreshToken,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString("token", token);
    await prefs.setString("refreshToken", refreshToken);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();

    final token = prefs.getString("token");

    // 🔥 FIX: handle empty string
    if (token == null || token.isEmpty) {
      return null;
    }

    return token;
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("token");
    await prefs.remove("refreshToken");
  }
  static Future<void> saveUserId(String id) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString("userId", id);
}

static Future<String?> getUserId() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString("userId");
}
}
