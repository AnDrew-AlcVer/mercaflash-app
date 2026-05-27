import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/producto_model.dart';

class UsuarioSesion {
  final String id;
  final String nombre;
  final String email;
  final String codigoPostal;
  final List<Alergeno> alergenos;

  const UsuarioSesion({
    required this.id,
    required this.nombre,
    required this.email,
    this.codigoPostal = '',
    this.alergenos = const [],
  });
}

class SupabaseService {
  final SupabaseClient _client = Supabase.instance.client;

  User? get usuarioActualRaw => _client.auth.currentUser;
  bool get sesionActiva => usuarioActualRaw != null;
  String? get _usuarioActualId => usuarioActualRaw?.id;

  Future<UsuarioSesion?> obtenerUsuarioActual() async {
    final user = usuarioActualRaw;
    if (user == null) return null;

    final metadata = user.userMetadata;
    final nombreMetadata = metadata?['nombre']?.toString().trim();
    final nombreCompletoMetadata = metadata?['full_name']?.toString().trim();

    String nombre = '';
    String email = user.email ?? '';
    String codigoPostal = ''; 

    try {
      final perfil = await _client
          .from('usuarios')
          .select('nombre, correo, codigo_postal')
          .eq('id', user.id)
          .maybeSingle();

      if (perfil != null) {
        nombre = perfil['nombre']?.toString().trim() ?? '';
        email = perfil['correo']?.toString().trim() ?? email; 
        codigoPostal = perfil['codigo_postal']?.toString().trim() ?? '';
        
        // LOGIN: Si obtenemos el CP de la base de datos, sobrescribimos el local 
        // para descartar el anterior.
        if (codigoPostal.isNotEmpty) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('mi_codigo_postal_real', codigoPostal);
        }
      }
    } catch (_) {}

    if (nombre.isEmpty && nombreMetadata != null && nombreMetadata.isNotEmpty) nombre = nombreMetadata;
    if (nombre.isEmpty && nombreCompletoMetadata != null && nombreCompletoMetadata.isNotEmpty) nombre = nombreCompletoMetadata;
    if (nombre.isEmpty) nombre = email.contains('@') ? email.split('@').first : 'Usuario';

    final alergenos = await obtenerAlergenosUsuario();
    return UsuarioSesion(
      id: user.id,
      nombre: nombre,
      email: email,
      codigoPostal: codigoPostal,
      alergenos: alergenos,
    );
  }

  Future<UsuarioSesion> iniciarSesion({required String email, required String password}) async {
    final response = await _client.auth.signInWithPassword(email: email.trim(), password: password);
    if (response.user == null) throw AuthException('No se ha podido iniciar sesión.');
    final usuario = await obtenerUsuarioActual();
    if (usuario == null) throw AuthException('No se ha podido cargar el usuario.');
    return usuario;
  }

  Future<UsuarioSesion> registrarUsuario({
    required String nombre,
    required String email,
    required String password,
    List<int> alergenosIds = const [],
  }) async {
    final nombreLimpio = nombre.trim();
    final emailLimpio = email.trim();

    // REGISTRO: Leemos el CP guardado en local en la pantalla inicial
    final prefs = await SharedPreferences.getInstance();
    final cpLocal = prefs.getString('mi_codigo_postal_real') ?? '00000';

    final response = await _client.auth.signUp(
      email: emailLimpio,
      password: password,
      data: {'nombre': nombreLimpio},
    );

    final user = response.user;
    if (user == null) throw AuthException('No se ha podido registrar el usuario.');

    // Subimos ese CP local al campo codigo_postal de la base de datos
    await _guardarPerfilUsuario(
      id: user.id,
      nombre: nombreLimpio,
      email: emailLimpio,
      codigoPostal: cpLocal,
    );

    await guardarAlergenosUsuario(alergenosIds, usuarioIdForzado: user.id);

    final usuario = await obtenerUsuarioActual();
    if (usuario != null) return usuario;

    final alergenosDisponibles = await obtenerAlergenosDisponibles();
    final seleccionados = alergenosDisponibles.where((a) => alergenosIds.contains(a.id)).toList();

    return UsuarioSesion(
      id: user.id,
      nombre: nombreLimpio.isEmpty ? emailLimpio.split('@').first : nombreLimpio,
      email: emailLimpio,
      codigoPostal: cpLocal,
      alergenos: seleccionados,
    );
  }

  Future<void> cerrarSesion() async => await _client.auth.signOut();
  Future<void> recuperarPassword(String email) async => await _client.auth.resetPasswordForEmail(email.trim());

  Future<void> _guardarPerfilUsuario({
    required String id, required String nombre, required String email, required String codigoPostal,
  }) async {
    try {
      await _client.from('usuarios').upsert({
        'id': id, 'nombre': nombre, 'apellidos': '', 'correo': email, 'telefono': '', 'codigo_postal': codigoPostal,
      }, onConflict: 'id');
    } catch (e) {
      throw AuthException('Error al guardar datos del usuario: $e');
    }
  }

  String mensajeErrorAuth(Object error) {
    if (error is AuthException) {
      final msg = error.message.toLowerCase();
      if (msg.contains('invalid login credentials')) return 'Correo o contraseña incorrectos.';
      if (msg.contains('already registered') || msg.contains('already exists')) return 'Ya existe una cuenta con ese correo.';
      if (msg.contains('password')) return 'La contraseña debe tener al menos 6 caracteres.';
      return error.message;
    }
    return 'Ha ocurrido un error. Revisa la conexión e inténtalo de nuevo.';
  }

  Future<List<Alergeno>> obtenerAlergenosDisponibles() async {
    try {
      final response = await _client.from('alergias').select('id, nombre, imagen').order('id', ascending: true);
      final lista = (response as List).map((row) => Alergeno.fromMap(Map<String, dynamic>.from(row as Map))).where((a) => a.id != 0).toList();
      if (lista.isNotEmpty) return _sinDuplicados(lista);
    } catch (_) {}
    return alergenosComunes;
  }

  Future<List<Alergeno>> obtenerAlergenosUsuario() async {
    final usuarioId = _usuarioActualId;
    if (usuarioId == null) return [];
    return _obtenerAlergenosUsuarioPorId(usuarioId);
  }

  Future<List<Alergeno>> _obtenerAlergenosUsuarioPorId(String usuarioId) async {
    try {
      final response = await _client.from('usuarios_alergias').select('alergia_id, alergias(id, nombre, imagen)').eq('usuario_id', usuarioId);
      final resultado = <Alergeno>[];
      for (final raw in response as List) {
        final row = Map<String, dynamic>.from(raw as Map);
        if (row['alergias'] is Map) {
          resultado.add(Alergeno.fromMap(Map<String, dynamic>.from(row['alergias'])));
        } else {
          final id = int.tryParse(row['alergia_id'].toString()) ?? 0;
          if (id != 0) resultado.add(_alergenoPorIdConFallback(id));
        }
      }
      return _sinDuplicados(resultado);
    } catch (_) { return []; }
  }

  Future<void> guardarAlergenosUsuario(List<int> alergenosIds, {String? usuarioIdForzado}) async {
    final usuarioId = usuarioIdForzado ?? _usuarioActualId;
    if (usuarioId == null) throw AuthException('Inicia sesión.');
    final idsLimpios = alergenosIds.where((id) => id > 0).toSet().toList();
    try {
      await _client.from('usuarios_alergias').delete().eq('usuario_id', usuarioId);
      if (idsLimpios.isEmpty) return;
      await _client.from('usuarios_alergias').insert(idsLimpios.map((id) => {'usuario_id': usuarioId, 'alergia_id': id}).toList());
    } catch (e) { throw AuthException('Error al guardar alérgenos.'); }
  }

  Future<List<Producto>> obtenerProductos() async {
    final misAlergenos = await obtenerAlergenosUsuario();
    try {
      final response = await _client.from('productos').select('*, categorias(nombre), productos_alergias(alergia_id, alergias(id, nombre, imagen))');
      return (response as List).map((raw) => Producto.fromMap(Map<String, dynamic>.from(raw as Map), alergenos: _extraerAlergenosProducto(Map<String, dynamic>.from(raw as Map)), alergenosUsuario: misAlergenos)).toList();
    } catch (_) { return []; }
  }

  Future<List<Producto>> obtenerProductosProximosACaducar() async {
    final todos = await obtenerProductos();
    return todos.where((p) => p.esFlash).toList();
  }

  Future<List<Receta>> obtenerRecetasSugeridas() async {
    final misAlergenos = await obtenerAlergenosUsuario();
    try {
      final response = await _client.from('recetas').select('*, recetas_productos(cantidad, alias, productos(id, nombre, fecha_caducidad, productos_alergias(alergia_id, alergias(id, nombre, imagen))))');
      return _mapearRecetas(response as List, misAlergenos);
    } catch (_) { return []; }
  }

  Future<List<CategoriaMercadona>> obtenerCategorias() async {
    try {
      final response = await _client.from('categorias').select();
      final categorias = (response as List).map((raw) {
        final row = Map<String, dynamic>.from(raw as Map);
        return CategoriaMercadona(id: row['id'].toString(), nombre: row['nombre']?.toString() ?? '', emoji: row['emoji']?.toString() ?? '');
      }).toList();
      categorias.add(const CategoriaMercadona(id: 'flash', nombre: 'Próximos a caducar', emoji: '⚡'));
      return categorias;
    } catch (_) { return const [CategoriaMercadona(id: 'flash', nombre: 'Próximos a caducar', emoji: '⚡')]; }
  }

  List<Receta> _mapearRecetas(List response, List<Alergeno> misAlergenos) {
    final recetas = <Receta>[];
    for (final raw in response) {
      final row = Map<String, dynamic>.from(raw as Map);
      final ingredientes = <IngredienteReceta>[];
      for (final rawRel in (row['recetas_productos'] as List?) ?? []) {
        final rel = Map<String, dynamic>.from(rawRel as Map);
        if (rel['productos'] is! Map) continue;
        final prodObj = Map<String, dynamic>.from(rel['productos']);
        final aliasTexto = rel['alias']?.toString().trim();
        final alergenosIng = _extraerAlergenosProducto(prodObj);
        ingredientes.add(IngredienteReceta(
          nombre: (aliasTexto != null && aliasTexto.isNotEmpty) ? aliasTexto : prodObj['nombre']?.toString() ?? 'Ingrediente',
          cantidad: rel['cantidad']?.toString() ?? '',
          productoId: prodObj['id']?.toString() ?? '',
          disponible: true,
          alergenos: alergenosIng,
          alergenosCoincidentes: _coincidenciasLocales(alergenosIng, misAlergenos),
        ));
      }
      recetas.add(Receta.fromMap(row, ingredientes, alergenosUsuario: misAlergenos));
    }
    return recetas;
  }

  List<Alergeno> _extraerAlergenosProducto(Map<String, dynamic> row) {
    final resultado = <Alergeno>[];
    if (row['productos_alergias'] is List) {
      for (final rel in row['productos_alergias']) {
        if (rel is! Map) continue;
        final r = Map<String, dynamic>.from(rel);
        if (r['alergias'] is Map) resultado.add(Alergeno.fromMap(Map<String, dynamic>.from(r['alergias'])));
      }
    }
    return _sinDuplicados(resultado);
  }

  Alergeno _alergenoPorIdConFallback(int id) => alergenosComunes.firstWhere((a) => a.id == id, orElse: () => Alergeno(id: id, nombre: 'Alérgeno $id'));
  
  List<Alergeno> _coincidenciasLocales(List<Alergeno> producto, List<Alergeno> usuario) {
    final idsUsuario = usuario.map((a) => a.id).toSet();
    return _sinDuplicados(producto.where((a) => idsUsuario.contains(a.id)).toList());
  }

  List<Alergeno> _sinDuplicados(List<Alergeno> alergenos) {
    final res = <Alergeno>[];
    for (final a in alergenos) {
      if (!res.contains(a) && a.nombre.trim().isNotEmpty) res.add(a);
    }
    res.sort((a, b) => a.nombre.compareTo(b.nombre));
    return res;
  }
}