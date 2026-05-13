import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://dpawbhtkvspqukvmewuk.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRwYXdiaHRrdnNwcXVrdm1ld3VrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzc1MDMzMTAsImV4cCI6MjA5MzA3OTMxMH0.iVeTff57W8OHPo9p8VwDwH9rRtlKeASpaUZu4Fj4yj4',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MercaFlash',
      debugShowCheckedModeBanner: false, // Quita la etiqueta roja de "DEBUG"
      theme: AppTheme.lightTheme, // Aquí aplica el tema personalizado
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'MERCADONA',
          style: TextStyle(
            color: AppTheme.greenHaze, // Usa el verde de la paleta
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
        elevation: 0, // Le quita la sombra para que se vea plano 
        backgroundColor: Colors.white,
      ),
      body: const Center(
        child: Text('Aquí irá el contenido principal'),
      ),
    );
  }
}