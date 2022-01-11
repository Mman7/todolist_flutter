import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:tinycolor/color_extension.dart';

ThemeData lightTheme(BuildContext context) {
  return ThemeData(
      textButtonTheme: TextButtonThemeData(
          style: ButtonStyle(
              foregroundColor: MaterialStateProperty.all(
                  Theme.of(context).bottomAppBarColor),
              backgroundColor:
                  MaterialStateProperty.all(Theme.of(context).primaryColor))),
      primaryColor: Colors.blue,
      backgroundColor: HexColor('#E5EEF5'),
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
          backgroundColor: Theme.of(context).primaryColor),
      dialogTheme: DialogTheme(
          contentTextStyle: const TextStyle(color: Colors.white),
          backgroundColor: const Color.fromARGB(255, 39, 39, 39),
          titleTextStyle:
              TextStyle(color: Theme.of(context).colorScheme.secondary)),
      popupMenuTheme: PopupMenuThemeData(
        color: Colors.black.withAlpha(1000),
      ),
      appBarTheme: AppBarTheme(
          backgroundColor: Theme.of(context).primaryColor.darken(45)),
      textTheme: const TextTheme(
        bodyText1: TextStyle(color: Colors.white, fontSize: 20),
      ),
      primaryColor: Colors.blue,
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Theme.of(context).primaryColor.darken(45),
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.grey.withOpacity(0.5)),
      backgroundColor: Colors.white.withOpacity(0.15));
}
