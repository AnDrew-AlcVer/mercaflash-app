import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/mercadona_app.dart';

export 'app/mercadona_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://dpawbhtkvspqukvmewuk.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRwYXdiaHRrdnNwcXVrdm1ld3VrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzc1MDMzMTAsImV4cCI6MjA5MzA3OTMxMH0.iVeTff57W8OHPo9p8VwDwH9rRtlKeASpaUZu4Fj4yj4',
  );

  runApp(const MercadonaApp());
}
