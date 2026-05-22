import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/producto_model.dart';

class UsuarioSesion {
  final String id;
  final String nombre;
  final String email;
  final List<Alergeno> alergenos;

  const UsuarioSesion({
    required this.id,
    required this.nombre,
    required this.email,
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

    try {
      final perfil = await _client
          .from('usuarios')
          .select('nombre, email')
          .eq('id', user.id)
          .maybeSingle();

      if (perfil != null) {
        nombre = perfil['nombre']?.toString().trim() ?? '';
        email = perfil['email']?.toString().trim() ?? email;
      }
    } catch (_) {
      // La tabla de perfil es opcional. Auth sigue funcionando aunque no exista.
    }

    if (nombre.isEmpty && nombreMetadata != null && nombreMetadata.isNotEmpty) {
      nombre = nombreMetadata;
    }

    if (nombre.isEmpty &&
        nombreCompletoMetadata != null &&
        nombreCompletoMetadata.isNotEmpty) {
      nombre = nombreCompletoMetadata;
    }

    if (nombre.isEmpty) {
      nombre = email.contains('@') ? email.split('@').first : 'Usuario';
    }

    final alergenos = await obtenerAlergenosUsuario();
    return UsuarioSesion(
      id: user.id,
      nombre: nombre,
      email: email,
      alergenos: alergenos,
    );
  }

  Future<UsuarioSesion> iniciarSesion({
    required String email,
    required String password,
  }) async {
    final response = await _client.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );

    final user = response.user;
    if (user == null) {
      throw AuthException('No se ha podido iniciar sesión.');
    }

    final usuario = await obtenerUsuarioActual();
    if (usuario == null) {
      throw AuthException('No se ha podido cargar el usuario.');
    }

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

    final response = await _client.auth.signUp(
      email: emailLimpio,
      password: password,
      data: {'nombre': nombreLimpio},
    );

    final user = response.user;
    if (user == null) {
      throw AuthException('No se ha podido registrar el usuario.');
    }

    await _guardarPerfilUsuario(
      id: user.id,
      nombre: nombreLimpio,
      email: emailLimpio,
    );

    await guardarAlergenosUsuario(alergenosIds, usuarioIdForzado: user.id);

    final usuario = await obtenerUsuarioActual();
    if (usuario != null) return usuario;

    final alergenosDisponibles = await obtenerAlergenosDisponibles();
    final seleccionados = alergenosDisponibles
        .where((alergeno) => alergenosIds.contains(alergeno.id))
        .toList();

    return UsuarioSesion(
      id: user.id,
      nombre: nombreLimpio.isEmpty ? emailLimpio.split('@').first : nombreLimpio,
      email: emailLimpio,
      alergenos: seleccionados,
    );
  }

  Future<void> cerrarSesion() async {
    await _client.auth.signOut();
  }

  Future<void> recuperarPassword(String email) async {
    await _client.auth.resetPasswordForEmail(email.trim());
  }

  Future<void> _guardarPerfilUsuario({
    required String id,
    required String nombre,
    required String email,
  }) async {
    try {
      await _client.from('usuarios').upsert(
        {
          'id': id,
          'nombre': nombre,
          'email': email,
        },
        onConflict: 'id',
      );
    } catch (_) {
      // No bloqueamos registro/login si la tabla usuarios no está exactamente igual.
    }
  }

  String mensajeErrorAuth(Object error) {
    if (error is AuthException) {
      final message = error.message.toLowerCase();

      if (message.contains('invalid login credentials')) {
        return 'Correo o contraseña incorrectos.';
      }

      if (message.contains('email not confirmed')) {
        return 'Tienes que confirmar tu correo antes de iniciar sesión.';
      }

      if (message.contains('user already registered') ||
          message.contains('already registered') ||
          message.contains('already exists')) {
        return 'Ya existe una cuenta con ese correo.';
      }

      if (message.contains('password')) {
        return 'La contraseña debe tener al menos 6 caracteres.';
      }

      if (message.contains('email')) {
        return 'Revisa que el correo esté bien escrito.';
      }

      return error.message;
    }

    final text = error.toString().toLowerCase();
    if (text.contains('usuarios_alergias')) {
      return 'No se han podido guardar los alérgenos. Revisa la tabla usuarios_alergias.';
    }

    return 'Ha ocurrido un error. Revisa la conexión e inténtalo de nuevo.';
  }

  Future<List<Alergeno>> obtenerAlergenosDisponibles() async {
    try {
      final response = await _client
          .from('alergias')
          .select('id, nombre')
          .order('id', ascending: true);

      final lista = (response as List)
          .map((row) => Alergeno.fromMap(Map<String, dynamic>.from(row as Map)))
          .where((alergeno) => alergeno.id != 0 && alergeno.nombre.trim().isNotEmpty)
          .toList();

      if (lista.isNotEmpty) return _sinDuplicados(lista);
    } catch (_) {
      // Si la tabla no existe o no hay permisos, usamos una lista segura por defecto.
    }

    return alergenosComunes;
  }

  Future<List<Alergeno>> obtenerAlergenosUsuario() async {
    final usuarioId = _usuarioActualId;
    if (usuarioId == null) return [];
    return _obtenerAlergenosUsuarioPorId(usuarioId);
  }

  Future<List<Alergeno>> _obtenerAlergenosUsuarioPorId(String usuarioId) async {
    try {
      final response = await _client
          .from('usuarios_alergias')
          .select('alergia_id, alergias(id, nombre)')
          .eq('usuario_id', usuarioId);

      final resultado = <Alergeno>[];
      for (final raw in response as List) {
        final row = Map<String, dynamic>.from(raw as Map);
        final alergiaRelacionada = row['alergias'];
        if (alergiaRelacionada is Map) {
          resultado.add(Alergeno.fromMap(Map<String, dynamic>.from(alergiaRelacionada)));
        } else {
          final id = int.tryParse(row['alergia_id'].toString()) ?? 0;
          if (id != 0) resultado.add(_alergenoPorIdConFallback(id));
        }
      }
      return _sinDuplicados(resultado);
    } catch (_) {
      try {
        final response = await _client
            .from('usuarios_alergias')
            .select('alergia_id')
            .eq('usuario_id', usuarioId);

        return _sinDuplicados(
          (response as List)
              .map((raw) {
                final row = Map<String, dynamic>.from(raw as Map);
                return _alergenoPorIdConFallback(
                  int.tryParse(row['alergia_id'].toString()) ?? 0,
                );
              })
              .where((alergeno) => alergeno.id != 0)
              .toList(),
        );
      } catch (_) {
        return [];
      }
    }
  }

  Future<void> guardarAlergenosUsuario(
    List<int> alergenosIds, {
    String? usuarioIdForzado,
  }) async {
    final usuarioId = usuarioIdForzado ?? _usuarioActualId;
    if (usuarioId == null) {
      throw AuthException('Inicia sesión para guardar tus alérgenos.');
    }

    final idsLimpios = alergenosIds.where((id) => id > 0).toSet().toList();

    await _client.from('usuarios_alergias').delete().eq('usuario_id', usuarioId);

    if (idsLimpios.isEmpty) return;

    await _client.from('usuarios_alergias').insert(
          idsLimpios
              .map(
                (id) => {
                  'usuario_id': usuarioId,
                  'alergia_id': id,
                },
              )
              .toList(),
        );
  }

  Future<List<Producto>> obtenerProductos() async {
    final misAlergenos = await obtenerAlergenosUsuario();

    try {
      final response = await _client
          .from('productos')
          .select('*, categorias(nombre), productos_alergias(alergia_id, alergias(id, nombre))');

      return (response as List).map((raw) {
        final row = Map<String, dynamic>.from(raw as Map);
        final alergenosProducto = _extraerAlergenosProducto(row);
        return Producto.fromMap(
          row,
          alergenos: alergenosProducto,
          alergenosUsuario: misAlergenos,
        );
      }).toList();
    } catch (_) {
      final response = await _client.from('productos').select('*, categorias(nombre), productos_alergias(alergia_id)');

      return (response as List).map((raw) {
        final row = Map<String, dynamic>.from(raw as Map);
        final alergenosProducto = _extraerAlergenosProducto(row);
        return Producto.fromMap(
          row,
          alergenos: alergenosProducto,
          alergenosUsuario: misAlergenos,
        );
      }).toList();
    }
  }

  Future<List<Producto>> obtenerProductosProximosACaducar() async {
    final todos = await obtenerProductos();
    return todos.where((producto) => producto.esFlash).toList();
  }

  Future<List<Receta>> obtenerRecetasSugeridas() async {
    final misAlergenos = await obtenerAlergenosUsuario();

    try {
      final response = await _client
          .from('recetas')
          .select('*, recetas_productos(cantidad, productos(nombre, fecha_caducidad, productos_alergias(alergia_id, alergias(id, nombre))))');

      return _mapearRecetas(response as List, misAlergenos);
    } catch (_) {
      final response = await _client
          .from('recetas')
          .select('*, recetas_productos(cantidad, productos(nombre, fecha_caducidad, productos_alergias(alergia_id)))');

      return _mapearRecetas(response as List, misAlergenos);
    }
  }

  Future<List<CategoriaMercadona>> obtenerCategorias() async {
    try {
      final response = await _client.from('categorias').select();

      final categorias = <CategoriaMercadona>[];
      for (final raw in response as List) {
        final row = Map<String, dynamic>.from(raw as Map);
        categorias.add(
          CategoriaMercadona(
            id: row['id'].toString(),
            nombre: row['nombre']?.toString() ?? '',
            emoji: row['emoji']?.toString() ?? '',
          ),
        );
      }

      categorias.add(
        const CategoriaMercadona(
          id: 'flash',
          nombre: 'Próximos a caducar',
          emoji: 'https://cdn-icons-png.flaticon.com/512/1164/1164382.png',
        ),
      );

      return categorias;
    } catch (_) {
      return const [
        CategoriaMercadona(id: 'flash', nombre: 'Próximos a caducar', emoji: '⚡'),
      ];
    }
  }

  List<Receta> _mapearRecetas(List response, List<Alergeno> misAlergenos) {
    final recetas = <Receta>[];

    for (final raw in response) {
      final row = Map<String, dynamic>.from(raw as Map);
      final ingredientesDeEstaReceta = <IngredienteReceta>[];
      final relacionIngredientes = (row['recetas_productos'] as List?) ?? [];

      for (final rawRel in relacionIngredientes) {
        final rel = Map<String, dynamic>.from(rawRel as Map);
        final productoObjRaw = rel['productos'];
        if (productoObjRaw == null || productoObjRaw is! Map) continue;

        final productoObj = Map<String, dynamic>.from(productoObjRaw);
        final cantidadTexto = rel['cantidad']?.toString() ?? '';
        final alergenosIngrediente = _extraerAlergenosProducto(productoObj);

        int? diasCaducidad;
        if (productoObj['fecha_caducidad'] != null) {
          try {
            final caducidad = DateTime.parse(productoObj['fecha_caducidad'].toString());
            diasCaducidad = caducidad.difference(DateTime.now()).inDays;
          } catch (_) {
            diasCaducidad = null;
          }
        }

        ingredientesDeEstaReceta.add(
          IngredienteReceta(
            nombre: productoObj['nombre']?.toString() ?? 'Ingrediente',
            cantidad: cantidadTexto,
            disponible: true,
            diasCaducidad: diasCaducidad,
            alergenos: alergenosIngrediente,
            alergenosCoincidentes: _coincidenciasLocales(alergenosIngrediente, misAlergenos),
          ),
        );
      }

      recetas.add(
        Receta.fromMap(
          row,
          ingredientesDeEstaReceta,
          alergenosUsuario: misAlergenos,
        ),
      );
    }

    return recetas;
  }

  List<Alergeno> _extraerAlergenosProducto(Map<String, dynamic> row) {
    final resultado = <Alergeno>[];

    final relaciones = row['productos_alergias'];
    if (relaciones is List) {
      for (final rawRelacion in relaciones) {
        if (rawRelacion is! Map) continue;
        final relacion = Map<String, dynamic>.from(rawRelacion);
        final alergiaRelacionada = relacion['alergias'];
        if (alergiaRelacionada is Map) {
          resultado.add(Alergeno.fromMap(Map<String, dynamic>.from(alergiaRelacionada)));
        } else {
          final id = int.tryParse(relacion['alergia_id'].toString()) ?? 0;
          if (id != 0) resultado.add(_alergenoPorIdConFallback(id));
        }
      }
    }

    final textoAlergenos = row['alergenos'] ?? row['alergias'] ?? row['alergenos_texto'];
    if (textoAlergenos is String && textoAlergenos.trim().isNotEmpty) {
      final partes = textoAlergenos
          .split(RegExp(r'[,;/]'))
          .map((parte) => parte.trim())
          .where((parte) => parte.isNotEmpty);
      for (final parte in partes) {
        resultado.add(_alergenoPorNombreConFallback(parte));
      }
    }

    return _sinDuplicados(resultado);
  }

  Alergeno _alergenoPorIdConFallback(int id) {
    return alergenosComunes.firstWhere(
      (alergeno) => alergeno.id == id,
      orElse: () => Alergeno(id: id, nombre: 'Alérgeno $id'),
    );
  }

  Alergeno _alergenoPorNombreConFallback(String nombre) {
    final normalizado = nombre.trim().toLowerCase();
    return alergenosComunes.firstWhere(
      (alergeno) => alergeno.nombreNormalizado == normalizado,
      orElse: () => Alergeno(id: normalizado.hashCode.abs(), nombre: nombre.trim()),
    );
  }

  List<Alergeno> _coincidenciasLocales(List<Alergeno> producto, List<Alergeno> usuario) {
    final idsUsuario = usuario.map((a) => a.id).toSet();
    final nombresUsuario = usuario.map((a) => a.nombreNormalizado).toSet();
    final resultado = <Alergeno>[];

    for (final alergeno in producto) {
      if ((idsUsuario.contains(alergeno.id) || nombresUsuario.contains(alergeno.nombreNormalizado)) &&
          !resultado.contains(alergeno)) {
        resultado.add(alergeno);
      }
    }

    return _sinDuplicados(resultado);
  }

  List<Alergeno> _sinDuplicados(List<Alergeno> alergenos) {
    final resultado = <Alergeno>[];
    for (final alergeno in alergenos) {
      if (alergeno.nombre.trim().isEmpty) continue;
      if (!resultado.contains(alergeno)) {
        resultado.add(alergeno);
      }
    }
    resultado.sort((a, b) => a.nombre.compareTo(b.nombre));
    return resultado;
  }
}
