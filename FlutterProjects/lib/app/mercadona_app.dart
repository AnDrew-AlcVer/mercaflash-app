import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'main_screen.dart';

class MercadonaApp extends StatelessWidget {
  const MercadonaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mercadona',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const MainScreen(),
    );
  }
}
