import 'package:flutter/material.dart';

import '../models/producto_model.dart';
import '../screens/welcome_page.dart';
import '../services/supabase_service.dart';
import '../theme/app_theme.dart';
import 'main_screen.dart';

class MercadonaApp extends StatefulWidget {
  const MercadonaApp({super.key});

  @override
  State<MercadonaApp> createState() => _MercadonaAppState();
}

class _MercadonaAppState extends State<MercadonaApp> {
  final SupabaseService _service = SupabaseService();

  bool _comprobandoSesion = true;
  bool _mostrarApp = false;
  bool _sesionIniciada = false;
  String _nombreUsuario = 'Invitado';
  String _emailUsuario = '';
  List<Alergeno> _alergenosDisponibles = alergenosComunes;
  List<Alergeno> _alergenosUsuario = const [];
  int _selectedIndexInicial = 0;

  @override
  void initState() {
    super.initState();
    _comprobarSesionInicial();
  }

  Future<void> _comprobarSesionInicial() async {
    try {
      final alergenosDisponibles = await _service.obtenerAlergenosDisponibles();
      final usuario = await _service.obtenerUsuarioActual();

      if (!mounted) return;

      setState(() {
        _alergenosDisponibles = alergenosDisponibles;
        if (usuario != null) {
          _mostrarApp = true;
          _sesionIniciada = true;
          _nombreUsuario = usuario.nombre;
          _emailUsuario = usuario.email;
          _alergenosUsuario = usuario.alergenos;
          _selectedIndexInicial = usuario.alergenos.isEmpty ? 4 : 0;
        }
        _comprobandoSesion = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _comprobandoSesion = false);
    }
  }

  void _entrarComoInvitado() {
    setState(() {
      _mostrarApp = true;
      _sesionIniciada = false;
      _nombreUsuario = 'Invitado';
      _emailUsuario = '';
      _alergenosUsuario = const [];
      _selectedIndexInicial = 0;
    });
  }

  Future<String?> _autenticarDesdeBienvenida({
    required String nombre,
    required String email,
    required String password,
    required bool registrar,
    required List<int> alergenosIds,
  }) async {
    try {
      final usuario = registrar
          ? await _service.registrarUsuario(
              nombre: nombre,
              email: email,
              password: password,
              alergenosIds: alergenosIds,
            )
          : await _service.iniciarSesion(
              email: email,
              password: password,
            );

      if (!mounted) return null;

      setState(() {
        _mostrarApp = true;
        _sesionIniciada = true;
        _nombreUsuario = usuario.nombre;
        _emailUsuario = usuario.email;
        _alergenosUsuario = usuario.alergenos;
        _selectedIndexInicial = usuario.alergenos.isEmpty ? 4 : 0;
      });

      return null;
    } catch (e) {
      return _service.mensajeErrorAuth(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mercadona',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: _buildHome(),
    );
  }

  Widget _buildHome() {
    if (_comprobandoSesion) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppTheme.green),
        ),
      );
    }

    if (_mostrarApp) {
      return MainScreen(
        sesionInicialIniciada: _sesionIniciada,
        nombreUsuarioInicial: _nombreUsuario,
        emailUsuarioInicial: _emailUsuario,
        alergenosUsuarioIniciales: _alergenosUsuario,
        selectedIndexInicial: _selectedIndexInicial,
      );
    }

    return WelcomePage(
      alergenosDisponibles: _alergenosDisponibles,
      onContinueAsGuest: _entrarComoInvitado,
      onAuth: _autenticarDesdeBienvenida,
    );
  }
}
