import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';

ThemeData lightTheme(BuildContext context) {
  return ThemeData(
      textButtonTheme: TextButtonThemeData(
          style: ButtonStyle(
              foregroundColor: MaterialStateProperty.all(
                  Theme.of(context).bottomAppBarColor),
              backgroundColor:
                  MaterialStateProperty.all(Theme.of(context).primaryColor))),
      primaryColor: HexColor('#00D1FF'),
      secondaryHeaderColor: Colors.black,
      backgroundColor: HexColor('#F0F2F5'),
      canvasColor: HexColor('#ffffff').withOpacity(0.35),
      dialogTheme: DialogTheme(
          backgroundColor: Theme.of(context).bottomAppBarColor,
          titleTextStyle: TextStyle(color: Theme.of(context).primaryColor)),
      popupMenuTheme: PopupMenuThemeData(
          color: Theme.of(context).bottomAppBarColor,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(5)))),
      appBarTheme: AppBarTheme(
          foregroundColor: Colors.white,
          backgroundColor: Theme.of(context).primaryColor),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.blue,
        selectedItemColor: Colors.white,
      ),
      textTheme: const TextTheme(
        bodyText1: TextStyle(color: Colors.white, fontSize: 20),
      ));
}

ThemeData dark_theme(BuildContext context) {
  return ThemeData(
      floatingActionButtonTheme: FloatingActionButtonThemeData(
          foregroundColor: Theme.of(context).secondaryHeaderColor,
          backgroundColor: HexColor('#00D1FF')),
      dialogTheme: DialogTheme(
          contentTextStyle: const TextStyle(color: Colors.white),
          backgroundColor: const Color.fromARGB(255, 39, 39, 39),
          titleTextStyle:
              TextStyle(color: Theme.of(context).colorScheme.secondary)),
      popupMenuTheme: PopupMenuThemeData(
        color: Colors.black.withAlpha(1000),
      ),
      appBarTheme: AppBarTheme(backgroundColor: HexColor('#040934')),
      textTheme: const TextTheme(
        bodyText1: TextStyle(color: Colors.white, fontSize: 20),
      ),
      primaryColor: Colors.blue,
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: HexColor('#040934'),
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.grey.withOpacity(0.5)),
      backgroundColor: HexColor('#110630'));
}
