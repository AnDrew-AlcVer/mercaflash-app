import 'package:flutter/material.dart';

class AppTheme {
  static const Color green = Color(0xFF009639);
  static const Color greenDark = Color(0xFF007A33);
  static const Color greenLight = Color(0xFFE4F7EC);

  static const Color yellow = Color(0xFFFFC857);
  static const Color yellowLight = Color(0xFFFFF3D4);

  static const Color red = Color(0xFFE94B5A);
  static const Color redLight = Color(0xFFFFECEF);

  static const Color orange = Color(0xFFF4A23A);
  static const Color orangeLight = Color(0xFFFFF0D8);

  static const Color background = Color(0xFFF6F6F6);
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF161616);
  static const Color gray = Color(0xFF777777);
  static const Color border = Color(0xFFE5E5E5);

  static ThemeData get lightTheme {
    final base = ThemeData.light(useMaterial3: true);

    return base.copyWith(
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: green,
        primary: green,
        secondary: yellow,
        surface: white,
      ),
      textTheme: base.textTheme.apply(
        fontFamily: 'Roboto',
        bodyColor: black,
        displayColor: black,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: white,
        elevation: 0,
        centerTitle: true,
        foregroundColor: green,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: green,
          foregroundColor: white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 15,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: green,
          side: const BorderSide(color: green, width: 1.3),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 76,
        backgroundColor: white,
        indicatorColor: greenLight,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);

          return TextStyle(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
            color: selected ? green : gray,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);

          return IconThemeData(
            color: selected ? green : gray,
          );
        }),
      ),
    );
  }
}