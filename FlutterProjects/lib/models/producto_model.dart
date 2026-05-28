class Alergeno {
  final int id;
  final String nombre;
  final String? imagen;

  const Alergeno({
    required this.id,
    required this.nombre,
    this.imagen,
  });

  factory Alergeno.fromMap(Map<String, dynamic> data) {
    return Alergeno(
      id: int.tryParse(data['id'].toString()) ?? 0,
      nombre: data['nombre']?.toString() ?? '',
      // IMPORTANTE: Asegúrate de que en tu Base de Datos la columna se llame "imagen".
      // Si se llama distinto (ej. "icono" o "url_imagen"), cámbialo aquí abajo:
      imagen: data['imagen']?.toString(),
    );
  }

  String get nombreNormalizado {
    return nombre
        .toLowerCase()
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ü', 'u')
        .replaceAll('ñ', 'n')
        .trim();
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is Alergeno &&
            ((id != 0 && other.id == id) ||
                other.nombreNormalizado == nombreNormalizado);
  }

  @override
  int get hashCode => id != 0 ? id.hashCode : nombreNormalizado.hashCode;
}

// HE AÑADIDO IMÁGENES DE PRUEBA AQUÍ PARA QUE NO LLEGUEN VACÍAS
const List<Alergeno> alergenosComunes = [
  Alergeno(id: 1, nombre: 'Gluten', imagen: 'https://cdn-icons-png.flaticon.com/512/7543/7543117.png'),
  Alergeno(id: 2, nombre: 'Leche / lactosa', imagen: 'https://cdn-icons-png.flaticon.com/512/375/375278.png'),
  Alergeno(id: 3, nombre: 'Huevo', imagen: 'https://cdn-icons-png.flaticon.com/512/837/837560.png'),
  Alergeno(id: 4, nombre: 'Cacahuetes', imagen: 'https://cdn-icons-png.flaticon.com/512/2403/2403163.png'),
  Alergeno(id: 5, nombre: 'Frutos secos', imagen: 'https://cdn-icons-png.flaticon.com/512/2619/2619522.png'),
  Alergeno(id: 6, nombre: 'Soja', imagen: 'https://cdn-icons-png.flaticon.com/512/6554/6554477.png'),
  Alergeno(id: 7, nombre: 'Pescado', imagen: 'https://cdn-icons-png.flaticon.com/512/3132/3132693.png'),
];

class Producto {
  final String id;
  final String nombre;
  final String cantidad;
  final String categoria;
  final String categoriaId;
  final String subcategoria;
  final double precio;
  final double? precioAnterior;
  final int? diasCaducidad;
  final String? imagenUrl;
  final String emoji;
  final bool esNovedad;
  final bool esBajadaPrecio;
  final bool esFlash;
  final String descripcion;
  final List<Alergeno> alergenos;
  final List<Alergeno> alergenosCoincidentes;
  final bool mostrarOferta;

  const Producto({
    required this.id,
    required this.nombre,
    required this.cantidad,
    required this.categoria,
    required this.categoriaId,
    this.subcategoria = '',
    required this.precio,
    this.precioAnterior,
    this.diasCaducidad,
    this.imagenUrl,
    this.emoji = '🛒',
    this.esNovedad = false,
    this.esBajadaPrecio = false,
    this.esFlash = false,
    this.descripcion = '',
    this.alergenos = const [],
    this.alergenosCoincidentes = const [],
    this.mostrarOferta = false,
  });

  factory Producto.fromMap(
    Map<String, dynamic> data, {
    List<Alergeno> alergenos = const [],
    List<Alergeno> alergenosUsuario = const [],
  }) {
    int? diasCalculados;
    if (data['fecha_caducidad'] != null) {
      try {
        final fecha = DateTime.parse(data['fecha_caducidad'].toString());
        diasCalculados = fecha.difference(DateTime.now()).inDays;
      } catch (_) {
        diasCalculados = null;
      }
    }

    final precioOriginal = (data['precio_original'] as num?)?.toDouble() ?? 0;
    final precioOfertaRaw = (data['precio_oferta'] as num?)?.toDouble();
    final estaDeOferta = precioOfertaRaw != null &&
        precioOfertaRaw > 0 &&
        precioOfertaRaw < precioOriginal;
    final precioOferta = precioOfertaRaw ?? precioOriginal;

    final catId = data['categoria_id']?.toString() ?? '';
    
    String catNombre = data['categoria']?.toString() ?? 'Despensa';
    if (data['categorias'] != null && data['categorias'] is Map) {
       catNombre = data['categorias']['nombre']?.toString() ?? catNombre;
    }

    final emojiIcon = data['emoji']?.toString() ?? '🛒';
    final coincidencias = _coincidenciasAlergenos(alergenos, alergenosUsuario);

    return Producto(
      id: data['id'].toString(),
      nombre: data['nombre']?.toString() ?? '',
      cantidad: data['cantidad']?.toString() ?? '1 ud.',
      categoria: catNombre,     
      categoriaId: catId,       
      subcategoria: data['subcategoria']?.toString() ?? '',
      precio: estaDeOferta ? precioOferta : precioOriginal,
      precioAnterior: estaDeOferta ? precioOriginal : null,
      diasCaducidad: diasCalculados,
      imagenUrl: data['imagen']?.toString(),
      emoji: emojiIcon,
      esNovedad: data['es_novedad'] == true,
      esBajadaPrecio: estaDeOferta,
      esFlash: diasCalculados != null && diasCalculados <= 2,
      descripcion: data['descripcion']?.toString() ?? '',
      alergenos: _sinDuplicadosAlergenos(alergenos),
      alergenosCoincidentes: coincidencias,
      mostrarOferta: data['mostrar_oferta'] == true, 
    );
  }

  bool get tieneCaducidad => diasCaducidad != null;
  bool get caducaHoy => diasCaducidad != null && diasCaducidad! <= 0;
  bool get caducaPronto =>
      diasCaducidad != null && diasCaducidad! > 0 && diasCaducidad! <= 2;

  bool get tieneAlergenos => alergenos.isNotEmpty;
  bool get tieneAlertaAlergenos => alergenosCoincidentes.isNotEmpty;

  String get caducidadTexto {
    if (diasCaducidad == null) return '';
    
    // 1. Calculamos la fecha sumando los días a la fecha actual
    final fecha = DateTime.now().add(Duration(days: diasCaducidad!));
    
    // 2. Extraemos día, mes y año añadiendo un '0' a la izquierda si hace falta (ej: 05 en vez de 5)
    final dia = fecha.day.toString().padLeft(2, '0');
    final mes = fecha.month.toString().padLeft(2, '0');
    final anio = fecha.year.toString();
    
    return 'Válido hasta $dia/$mes/$anio';
  }

  String get precioTexto => '${precio.toStringAsFixed(2).replaceAll('.', ',')} €';

  String get precioAnteriorTexto => precioAnterior == null
      ? ''
      : '${precioAnterior!.toStringAsFixed(2).replaceAll('.', ',')} €';

  String get alergenosTexto => _listaAlergenosTexto(alergenos);

  String get alertaAlergenosTexto => _listaAlergenosTexto(alergenosCoincidentes);

  int get descuentoPorcentaje {
    if (precioAnterior == null || precioAnterior == 0) return 0;
    final descuento = 100 - ((precio / precioAnterior!) * 100);
    return descuento.round();
  }
}

class CategoriaMercadona {
  final String id;
  final String nombre;
  final String emoji;

  const CategoriaMercadona({
    required this.id,
    required this.nombre,
    required this.emoji,
  });
}

class Receta {
  final String id;
  final String titulo;
  final String etiqueta;
  final String descripcion;
  final int tiempoMinutos;
  final String dificultad;
  final int raciones;
  final String emoji;
  final String? imagenUrl;
  final List<IngredienteReceta> ingredientes;
  final List<String> pasos;
  final List<Alergeno> alergenos;
  final List<Alergeno> alergenosCoincidentes;

  const Receta({
    required this.id,
    required this.titulo,
    required this.etiqueta,
    required this.descripcion,
    required this.tiempoMinutos,
    required this.dificultad,
    required this.raciones,
    required this.emoji,
    this.imagenUrl,
    required this.ingredientes,
    required this.pasos,
    this.alergenos = const [],
    this.alergenosCoincidentes = const [],
  });

  factory Receta.fromMap(
    Map<String, dynamic> data,
    List<IngredienteReceta> listaIngredientes, {
    List<Alergeno> alergenosUsuario = const [],
  }) {
    final preparacionRaw = data['preparacion']?.toString() ?? '';
    final listaPasos = preparacionRaw
        .split('●')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    final alergenosReceta = <Alergeno>[];
    for (final ingrediente in listaIngredientes) {
      alergenosReceta.addAll(ingrediente.alergenos);
    }
    final alergenosUnicos = _sinDuplicadosAlergenos(alergenosReceta);
    final coincidencias = _coincidenciasAlergenos(alergenosUnicos, alergenosUsuario);

    return Receta(
      id: data['id'].toString(),
      titulo: data['titulo']?.toString() ?? '',
      etiqueta: coincidencias.isNotEmpty
          ? 'Contiene alérgenos de tu perfil'
          : 'Recomendado para ti',
      descripcion: data['descripcion']?.toString().trim().isNotEmpty == true
          ? data['descripcion'].toString()
          : 'Receta paso a paso para aprovechar tus productos.',
      tiempoMinutos: int.tryParse(data['tiempo_minutos'].toString()) ?? 30,
      dificultad: data['dificultad']?.toString() ?? 'Media',
      raciones: int.tryParse(data['raciones'].toString()) ?? 2,
      emoji: '👨‍🍳',
      ingredientes: listaIngredientes,
      pasos: listaPasos,
      imagenUrl: data['imagen']?.toString(),
      alergenos: alergenosUnicos,
      alergenosCoincidentes: coincidencias,
    );
  }

  int get productosACaducar {
    return ingredientes
        .where((ingrediente) =>
            ingrediente.diasCaducidad != null && ingrediente.diasCaducidad! <= 2)
        .length;
  }

  bool get tieneAlergenos => alergenos.isNotEmpty;
  bool get tieneAlertaAlergenos => alergenosCoincidentes.isNotEmpty;

  String get alergenosTexto => _listaAlergenosTexto(alergenos);

  String get alertaAlergenosTexto => _listaAlergenosTexto(alergenosCoincidentes);
}

class IngredienteReceta {
  final String nombre;
  final String cantidad;
  final bool disponible;
  final int? diasCaducidad;
  final String productoId;
  final List<Alergeno> alergenos;
  final List<Alergeno> alergenosCoincidentes;

  const IngredienteReceta({
    required this.nombre,
    required this.cantidad,
    required this.disponible,
    required this.productoId,
    this.diasCaducidad,
    this.alergenos = const [],
    this.alergenosCoincidentes = const [],
  });

  bool get tieneAlergenos => alergenos.isNotEmpty;
  bool get tieneAlertaAlergenos => alergenosCoincidentes.isNotEmpty;

  String get alergenosTexto => _listaAlergenosTexto(alergenos);

  String get alertaAlergenosTexto => _listaAlergenosTexto(alergenosCoincidentes);

  String? get caducidadTexto {
    if (diasCaducidad == null) return null;
    
    final fecha = DateTime.now().add(Duration(days: diasCaducidad!));
    final dia = fecha.day.toString().padLeft(2, '0');
    final mes = fecha.month.toString().padLeft(2, '0');
    final anio = fecha.year.toString();
    
    return 'Válido hasta $dia/$mes/$anio';
  }
}

List<Alergeno> _coincidenciasAlergenos(
  List<Alergeno> alergenos,
  List<Alergeno> alergenosUsuario,
) {
  final idsUsuario = alergenosUsuario.map((a) => a.id).toSet();
  final nombresUsuario = alergenosUsuario.map((a) => a.nombreNormalizado).toSet();
  final coincidencias = <Alergeno>[];

  for (final alergeno in alergenos) {
    final coincidePorId = alergeno.id != 0 && idsUsuario.contains(alergeno.id);
    final coincidePorNombre = nombresUsuario.contains(alergeno.nombreNormalizado);
    if ((coincidePorId || coincidePorNombre) && !coincidencias.contains(alergeno)) {
      coincidencias.add(alergeno);
    }
  }

  return _sinDuplicadosAlergenos(coincidencias);
}

List<Alergeno> _sinDuplicadosAlergenos(List<Alergeno> alergenos) {
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

String _listaAlergenosTexto(List<Alergeno> alergenos) {
  if (alergenos.isEmpty) return '';
  return _sinDuplicadosAlergenos(alergenos).map((a) => a.nombre).join(', ');
}