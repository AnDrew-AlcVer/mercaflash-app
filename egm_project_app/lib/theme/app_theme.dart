import 'package:flutter/material.dart';

class AppTheme {
  // ====================
  // PALETA DE COLORES
  // ====================
  
  // Identidad / Primario
  static const Color greenHaze = Color(0xFF00AA55);
  
  // Acento / Secundario
  static const Color creamCan = Color(0xFFF6CE4A);
  
  // Fondo / Contraste Base
  static const Color chathamsBlue = Color(0xFF15507C);

  // Escala Neutral (Grises)
  static const Color black1 = Color(0xFF000000);
  static const Color black2 = Color(0xFF1D1D1D); // o 0xFF333333
  static const Color black3 = Color(0xFF282828); // o 0xFF4F4F4F
  static const Color gray3 = Color(0xFF828282);
  static const Color gray4 = Color(0xFFBDBDBD);
  static const Color gray5 = Color(0xFFE0E0E0);
  static const Color white = Color(0xFFFFFFFF);

  // ====================
  // CONFIGURACIÓN DEL TEMA GENERAL
  // ====================
  static ThemeData get lightTheme {
    return ThemeData(
      // Usamos Material 3 para componentes más modernos
      useMaterial3: true,
      
      // Esquema de colores principal
      colorScheme: const ColorScheme.light(
        primary: greenHaze,
        secondary: creamCan,
        surface: white,
        onPrimary: white,
        onSecondary: black2,
        onSurface: black2,
        error: Colors.redAccent, // Para etiquetas de "Caduca hoy"
      ),
      
      scaffoldBackgroundColor: white, // Fondo blanco limpio del prototipo

      // ====================
      // TIPOGRAFÍAS
      // ====================
      textTheme: const TextTheme(
        // Heading 1 (H1)
        displayLarge: TextStyle(
          fontFamily: 'Roboto', // Familia para encabezados
          fontSize: 48,
          fontWeight: FontWeight.bold,
          height: 1.1, // 1.1x el tamaño de fuente
          letterSpacing: -0.4,
          color: black1,
        ),
        // Heading 2 (H2)
        displayMedium: TextStyle(
          fontFamily: 'Roboto',
          fontSize: 40,
          fontWeight: FontWeight.bold,
          height: 1.4,
          color: black1,
        ),
        // Medium Text
        titleMedium: TextStyle(
          fontFamily: 'Rv', // Familia general
          fontSize: 18,
          fontWeight: FontWeight.bold, // Puede ser Regular también
          color: black2,
        ),
        // Body Normal Text
        bodyMedium: TextStyle(
          fontFamily: 'Rv',
          fontSize: 16,
          fontWeight: FontWeight.normal,
          height: 1.4,
          color: black2,
        ),
        // Small Text
        bodySmall: TextStyle(
          fontFamily: 'Rv',
          fontSize: 14,
          fontWeight: FontWeight.normal,
          height: 1.4,
          letterSpacing: 0.4,
          color: gray3, // Gris para textos secundarios
        ),
      ),
      
      // Estilo por defecto para los botones principales (Green Haze)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: greenHaze,
          foregroundColor: white,
          textStyle: const TextStyle(
            fontFamily: 'Rv',
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24), // Bordes redondeados del prototipo
          ),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        ),
      ),
    );
  }
}