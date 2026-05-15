import 'package:flutter/material.dart';

import '../screens/welcome_page.dart';
import '../theme/app_theme.dart';
import 'main_screen.dart';

class MercadonaApp extends StatefulWidget {
  const MercadonaApp({super.key});

  @override
  State<MercadonaApp> createState() => _MercadonaAppState();
}

class _MercadonaAppState extends State<MercadonaApp> {
  bool _mostrarApp = false;
  bool _sesionIniciada = false;
  String _nombreUsuario = 'Invitado';

  void _entrarComoInvitado() {
    setState(() {
      _mostrarApp = true;
      _sesionIniciada = false;
      _nombreUsuario = 'Invitado';
    });
  }

  void _iniciarSesion(String nombre) {
    setState(() {
      _mostrarApp = true;
      _sesionIniciada = true;
      _nombreUsuario = nombre.trim().isEmpty ? 'Usuario' : nombre.trim();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mercadona',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: _mostrarApp
          ? MainScreen(
              sesionInicialIniciada: _sesionIniciada,
              nombreUsuarioInicial: _nombreUsuario,
            )
          : WelcomePage(
              onContinueAsGuest: _entrarComoInvitado,
              onLogin: _iniciarSesion,
            ),
    );
  }
}


