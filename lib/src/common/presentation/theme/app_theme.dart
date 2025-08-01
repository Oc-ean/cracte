import 'package:cracte/src/common/common.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData lightTheme = ThemeData(
  useMaterial3: false,
  fontFamily: GoogleFonts.poppins().fontFamily,
  primaryColor: lightPrimary,
  colorScheme: ColorScheme.fromSwatch().copyWith(
    secondary: lightAccent,
    primary: lightPrimary,
    brightness: Brightness.light,
  ),
  scaffoldBackgroundColor: lightBG,
  appBarTheme: AppBarTheme(
    backgroundColor: lightBG,
    elevation: 0.0,
    titleTextStyle: TextStyle(
      color: Colors.black,
      fontSize: 18,
      fontWeight: FontWeight.bold,
      fontFamily: GoogleFonts.poppins().fontFamily,
    ),
    iconTheme: const IconThemeData(color: Colors.black),
  ),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: lightBG,
  ),
  cardColor: lightCardColor,
  tabBarTheme: TabBarTheme(
    indicatorColor: lightAccent,
  ),
  radioTheme: RadioThemeData(
    fillColor: WidgetStateProperty.all(darkAccent),
    overlayColor: WidgetStateProperty.all(darkAccent),
  ),
  inputDecorationTheme: const InputDecorationTheme(
    border: InputBorder.none,
    focusedBorder: InputBorder.none,
  ),
);

ThemeData darkTheme = ThemeData(
  useMaterial3: false,
  fontFamily: GoogleFonts.poppins().fontFamily,
  brightness: Brightness.dark,
  primaryColor: darkPrimary,
  colorScheme: ColorScheme.fromSwatch().copyWith(
    secondary: darkAccent,
    primary: darkPrimary,
    brightness: Brightness.dark,
  ),
  scaffoldBackgroundColor: darkBG,
  appBarTheme: AppBarTheme(
    backgroundColor: darkBG,
    elevation: 0.0,
    titleTextStyle: TextStyle(
      color: Colors.white,
      fontSize: 18,
      fontWeight: FontWeight.bold,
      fontFamily: GoogleFonts.poppins().fontFamily,
    ),
    iconTheme: const IconThemeData(color: Colors.white),
  ),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: darkBG,
  ),
  bottomAppBarTheme: BottomAppBarTheme(
    color: darkBG,
  ),
  cardColor: darkCardColor,
  radioTheme: RadioThemeData(
    fillColor: WidgetStateProperty.all(darkAccent),
    overlayColor: WidgetStateProperty.all(darkAccent),
  ),
  inputDecorationTheme: const InputDecorationTheme(
    border: InputBorder.none,
    focusedBorder: InputBorder.none,
  ),
);
