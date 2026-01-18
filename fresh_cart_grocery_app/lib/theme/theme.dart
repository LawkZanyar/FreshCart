import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const int seedValue = 0xFF259381;

final ColorScheme darkColorScheme = ColorScheme.fromSeed(
  seedColor: Color(seedValue),
  brightness: Brightness.dark,
);

final ThemeData appTheme = ThemeData(
  useMaterial3: true,
  colorScheme: darkColorScheme,
  textTheme: GoogleFonts.interTextTheme(),
  appBarTheme: AppBarTheme(
    centerTitle: true,
    elevation: 0,
    backgroundColor: darkColorScheme.primaryContainer,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
    ),
  ),
);
