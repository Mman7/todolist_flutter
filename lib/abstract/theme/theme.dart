import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';

ThemeData darkTheme(BuildContext context) {
  return ThemeData(
    textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
      backgroundColor: HexColor('#0057FF'),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10))),
    )),
    canvasColor: Colors.white10,
    shadowColor: HexColor('#1C92FF').withAlpha(125),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
        foregroundColor: Theme.of(context).secondaryHeaderColor,
        backgroundColor: HexColor('#00D1FF')),
    dialogTheme: DialogTheme(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(17)),
        contentTextStyle: const TextStyle(color: Colors.white),
        backgroundColor: const Color.fromARGB(255, 39, 39, 39),
        titleTextStyle: const TextStyle(
            color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
    appBarTheme: AppBarTheme(backgroundColor: HexColor('#040934')),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.white, fontSize: 20),
    ),
    colorScheme: const ColorScheme.dark().copyWith(
      primary: Colors.white,
      surface: HexColor(('#110630')),
      brightness: Brightness.dark,
    ),
    primaryColor: HexColor('#0057FF'),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: HexColor('#040934'),
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey.withOpacity(0.5)),
  );
}
