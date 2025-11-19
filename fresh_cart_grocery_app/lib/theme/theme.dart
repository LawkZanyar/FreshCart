import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_color_utilities/material_color_utilities.dart';

const int seedValue = 0xFF259381;

final ColorScheme lightColorScheme = ColorScheme.fromSeed(
  seedColor: Color(seedValue),
  brightness: Brightness.light
);

final ThemeData appTheme = ThemeData(
  useMaterial3: true,
  colorScheme: lightColorScheme,
  textTheme: GoogleFonts.interTextTheme(),
  appBarTheme: AppBarTheme(
    centerTitle: true,
    elevation: 0,
    backgroundColor: lightColorScheme.primaryContainer,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        bottom: Radius.circular(16),
      )
    ),
  )
);