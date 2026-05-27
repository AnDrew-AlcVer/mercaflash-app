import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Importante importar Supabase aquí

import 'app/main_screen.dart';
import 'screens/postal_code_page.dart';

void main() async {
  // 1. Esto es OBLIGATORIO antes de iniciar Supabase o SharedPreferences
  WidgetsFlutterBinding.ensureInitialized();

  // 2. INICIAMOS SUPABASE PRIMERO (¡Aquí daba el pantallazo rojo!)
  await Supabase.initialize(
    url: 'https://dpawbhtkvspqukvmewuk.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRwYXdiaHRrdnNwcXVrdm1ld3VrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzc1MDMzMTAsImV4cCI6MjA5MzA3OTMxMH0.iVeTff57W8OHPo9p8VwDwH9rRtlKeASpaUZu4Fj4yj4',
  );
  
  // 3. Leemos si el usuario ya pasó la pantalla del código postal alguna vez
  final prefs = await SharedPreferences.getInstance();
  final bool yaTieneCodigo = prefs.getBool('codigo_postal_guardado') ?? false;

  // 4. Arrancamos la app pasándole esa información
  runApp(MyApp(mostrarCodigo: !yaTieneCodigo));
}

class MyApp extends StatelessWidget {
  final bool mostrarCodigo;

  const MyApp({super.key, required this.mostrarCodigo});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mercadona',
      debugShowCheckedModeBanner: false,
      
      // AQUÍ ESTÁ LA MAGIA: 
      // Si NUNCA ha puesto el código postal -> Abre PostalCodePage
      // Si YA LO PUSO (aunque sea invitado) -> Abre MainScreen directamente
      home: mostrarCodigo ? const PostalCodePage() : const MainScreen(),
    );
  }
}