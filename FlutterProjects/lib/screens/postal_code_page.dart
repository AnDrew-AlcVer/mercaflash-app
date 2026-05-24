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

  // Esta función guarda en la memoria del móvil que ya se ha pasado este paso
  Future<void> _entrar() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('codigo_postal_guardado', true);

    if (!mounted) return;
    
    // Navegamos al MainScreen y ELIMINAMOS esta pantalla del historial
    // para que si el usuario le da hacia atrás, no vuelva aquí.
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
              
              // LOGO NUEVO
              Image.asset(
                // OJO: Asegúrate de poner la extensión correcta (.png o .jpg)
                'assets/images/logotextmercadona.png', 
                height: 40, // Ajusta este valor para que quede al tamaño que te guste
                fit: BoxFit.contain,
              ),
              
              const SizedBox(height: 50),
              
              // SALUDO
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
              
              // INPUT CÓDIGO POSTAL
              TextField(
                controller: _codigoController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: 'Código postal',
                  hintStyle: TextStyle(color: Colors.black38, fontSize: 18),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black26),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: AppTheme.green, width: 2),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // BOTÓN USAR MI UBICACIÓN
              TextButton.icon(
                onPressed: _entrar, 
                icon: const Icon(Icons.near_me_rounded, color: AppTheme.green, size: 20),
                label: const Text(
                  'Usar mi ubicación',
                  style: TextStyle(color: AppTheme.green, fontSize: 16, fontWeight: FontWeight.w600),
                ),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  alignment: Alignment.centerLeft,
                ),
              ),
              
              const SizedBox(height: 40),
              
              // BOTÓN ENTRAR VERDE
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _entrar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Entrar',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}