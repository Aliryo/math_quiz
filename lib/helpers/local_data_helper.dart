import 'package:shared_preferences/shared_preferences.dart';

class LocalDataHelper {
  LocalDataHelper._();

  static const String _usernameKey = 'username';

  //? Mengecek Apakah Nama Lengkap Sudah Ada Di Data Lokal
  static Future<bool> checkUsername() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString(_usernameKey);

    return username != null && username.isNotEmpty;
  }

  //? Menyimpan Nama Lengkap Ke Data Lokal
  static Future<void> saveUsername(String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_usernameKey, username);
  }

  //? Mengambil Nama Lengkap Dari Data Lokal
  static Future<String> getUsername() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString(_usernameKey) ?? '';
  }
}
