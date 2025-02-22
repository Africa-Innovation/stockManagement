import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static Future<void> saveUserSession(String phone) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_phone', phone);
  }

  static Future<String?> getUserSession() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_phone');
  }

  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_phone');
  }
  

  
}
