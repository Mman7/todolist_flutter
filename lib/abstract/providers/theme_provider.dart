import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  void intializeThemeData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    dynamic intialTheme = prefs.getString('theme') ?? "";

    if (intialTheme == '') return;
    if (intialTheme == 'ThemeMode.light') changeTheme(ThemeMode.light);
    if (intialTheme == 'ThemeMode.dark') changeTheme(ThemeMode.dark);
  }

  void saveTheme(ThemeMode currentTheme) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('theme', '$currentTheme');
  }

  changeTheme(ThemeMode value) {
    _themeMode = value;
    saveTheme(value);
    notifyListeners();
  }
}
