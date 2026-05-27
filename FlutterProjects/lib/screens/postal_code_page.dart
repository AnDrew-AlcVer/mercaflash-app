import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../app/main_screen.dart'; 
import '../theme/app_theme.dart'; 

class PostalCodePage extends StatefulWidget {
  const PostalCodePage({super.key});

  @override
  State<PostalCodePage> createState() => _PostalCodePageState();
}

class _PostalCodePageState extends State<PostalCodePage> {
  final TextEditingController _codigoController = TextEditingController();

  Future<void> _entrar() async {
    final prefs = await SharedPreferences.getInstance();
    
    // 1. Evitamos que vuelva a salir esta pantalla al reiniciar la app
    await prefs.setBool('codigo_postal_guardado', true);
    
    // 2. Guardamos el CP localmente (por defecto 00000 si lo dejan vacío)
    final cpTexto = _codigoController.text.trim();
    await prefs.setString('mi_codigo_postal_real', cpTexto.isNotEmpty ? cpTexto : '00000');

    if (!mounted) return;
    
    // pushReplacement destruye esta pantalla para que no se pueda volver atrás
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const MainScreen()),
    );
  }

  @override
  void dispose() {
    _codigoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 30),
              Image.asset(
                'assets/images/logotextmercadona.png', 
                height: 40,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 50),
              const Text(
                '¡Hola! 👋',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.black),
              ),
              const SizedBox(height: 12),
              const Text(
                'Recibe tu compra en casa',
                style: TextStyle(fontSize: 18, color: Colors.black87),
              ),
              const SizedBox(height: 40),
              TextField(
                controller: _codigoController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: 'Código postal',
                  hintStyle: TextStyle(color: Colors.black38, fontSize: 18),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black26)),
                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppTheme.green, width: 2)),
                ),
              ),
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: _entrar, 
                icon: const Icon(Icons.near_me_rounded, color: AppTheme.green, size: 20),
                label: const Text(
                  'Usar mi ubicación',
                  style: TextStyle(color: AppTheme.green, fontSize: 16, fontWeight: FontWeight.w600),
                ),
                style: TextButton.styleFrom(padding: EdgeInsets.zero, alignment: Alignment.centerLeft),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _entrar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                  ),
                  child: const Text('Entrar', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}