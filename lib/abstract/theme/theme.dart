import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';

ThemeData darkTheme(BuildContext context) {
  return ThemeData(
    canvasColor: Colors.white10,
    shadowColor: HexColor('#1C92FF').withAlpha(125),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
        foregroundColor: Theme.of(context).secondaryHeaderColor,
        backgroundColor: HexColor('#00D1FF')),
    dialogTheme: DialogTheme(
        contentTextStyle: const TextStyle(color: Colors.white),
        backgroundColor: const Color.fromARGB(255, 39, 39, 39),
        titleTextStyle:
            TextStyle(color: Theme.of(context).colorScheme.secondary)),
    appBarTheme: AppBarTheme(backgroundColor: HexColor('#040934')),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.white, fontSize: 20),
    ),
    colorScheme: const ColorScheme.dark().copyWith(
      primary: Colors.white,
      background: HexColor(('#110630')),
      brightness: Brightness.dark,
    ),
    primaryColor: Colors.blue,
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: HexColor('#040934'),
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey.withOpacity(0.5)),
  );
}
