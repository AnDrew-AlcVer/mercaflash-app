import 'package:flutter/material.dart';
import '../app/main_screen.dart';
import '../screens/postal_code_page.dart'; // Importamos la NUEVA pantalla
import '../theme/app_theme.dart';

// 🔴 IMPORTANTE: Borra de los imports de arriba cualquier referencia a la antigua
// pantalla de inicio de sesión que se abría al principio.

class MercadonaApp extends StatelessWidget {
  final bool pedirCodigoPostalInicial;

  const MercadonaApp({
    super.key, 
    this.pedirCodigoPostalInicial = true,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mercadona',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      
      // AQUÍ ESTÁ LA CLAVE PARA DESAPARECER LA PANTALLA ANTIGUA:
      // Hemos quitado tu antigua pantalla de 'home:' y hemos puesto un condicional.
      // Si pedirCodigo es true -> Muestra el Código Postal.
      // Si es false -> Va directo al MainScreen (inicio).
      home: pedirCodigoPostalInicial 
          ? const PostalCodePage() 
          : const MainScreen(),
    );
  }
}