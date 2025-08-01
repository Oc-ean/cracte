import 'package:flutter/material.dart';

enum CurrentAppTheme {
  system('system', ThemeMode.system),
  light('lightMode', ThemeMode.light),
  dark('darkMode', ThemeMode.dark);

  final String name;
  final ThemeMode themeMode;
  const CurrentAppTheme(this.name, this.themeMode);
}
