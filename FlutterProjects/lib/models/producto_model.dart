class Producto {
  final String id;
  final String nombre;
  final String cantidad;
  final String categoria;
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

  const Producto({
    required this.id,
    required this.nombre,
    required this.cantidad,
    required this.categoria,
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
  });

  factory Producto.fromMap(Map<String, dynamic> data) {
    // 1. Calcular días de caducidad desde la fecha SQL
    int? diasCalculados;
    if (data['fecha_caducidad'] != null) {
      DateTime fecha = DateTime.parse(data['fecha_caducidad']);
      diasCalculados = fecha.difference(DateTime.now()).inDays;
    }

    // 2. Gestionar la lógica de precios
    final precioOriginal = (data['precio_original'] as num?)?.toDouble() ?? 0;
    final precioOfertaRaw = (data['precio_oferta'] as num?)?.toDouble();
    final estaDeOferta = precioOfertaRaw != null &&
        precioOfertaRaw > 0 &&
        precioOfertaRaw < precioOriginal;
    final precioOferta = precioOfertaRaw ?? precioOriginal;

    String cat = data['categoria'] ?? 'Despensa';
    String emojiIcon = data['emoji'] ?? '🛒';

    return Producto(
      id: data['id'].toString(),
      nombre: data['nombre'] ?? '',
      cantidad: data['cantidad'] ?? '1 ud.',
      categoria: cat,
      subcategoria: data['subcategoria'] ?? '',
      precio: estaDeOferta ? precioOferta : precioOriginal,
      precioAnterior: estaDeOferta ? precioOriginal : null,
      diasCaducidad: diasCalculados,
      // Usamos la nueva columna 'imagen' de tu DB
      imagenUrl: data['imagen'], 
      emoji: emojiIcon,
      esNovedad: data['es_novedad'] == true,
      esBajadaPrecio: estaDeOferta, 
      esFlash: diasCalculados != null && diasCalculados <= 2,
      descripcion: data['descripcion'] ?? '',
    );
  }

  bool get tieneCaducidad => diasCaducidad != null;

  bool get caducaHoy => diasCaducidad != null && diasCaducidad! <= 0;

  bool get caducaPronto =>
      diasCaducidad != null && diasCaducidad! > 0 && diasCaducidad! <= 2;

  String get caducidadTexto {
    if (diasCaducidad == null) return '';
    if (diasCaducidad! <= 0) return 'Caduca hoy';
    if (diasCaducidad == 1) return '1 día';
    return '$diasCaducidad días';
  }

  String get precioTexto => '${precio.toStringAsFixed(2).replaceAll('.', ',')} €';

  String get precioAnteriorTexto => precioAnterior == null
      ? ''
      : '${precioAnterior!.toStringAsFixed(2).replaceAll('.', ',')} €';

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
  });

  factory Receta.fromMap(Map<String, dynamic> data, List<IngredienteReceta> listaIngredientes) {
    String preparacionRaw = data['preparacion'] ?? '';
    List<String> listaPasos = preparacionRaw
        .split('●')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    return Receta(
      id: data['id'].toString(),
      titulo: data['titulo'] ?? '',
      etiqueta: 'Recomendado para ti',
      descripcion: 'Receta paso a paso para aprovechar tus productos.',
      tiempoMinutos: data['tiempo_minutos'] ?? 30,
      // CORRECCIÓN: 'dificultad' en lugar de 'difficulty'
      dificultad: data['dificultad'] ?? 'Media', 
      raciones: 2,
      emoji: '👨‍🍳',
      ingredientes: listaIngredientes,
      pasos: listaPasos,
      imagenUrl: data['imagen_url'], 
    );
  }

  int get productosACaducar {
    return ingredientes
        .where((ingrediente) => ingrediente.diasCaducidad != null && ingrediente.diasCaducidad! <= 2)
        .length;
  }
}

class IngredienteReceta {
  final String nombre;
  final String cantidad;
  final bool disponible;
  final int? diasCaducidad;

  const IngredienteReceta({
    required this.nombre,
    required this.cantidad,
    required this.disponible,
    this.diasCaducidad,
  });

  String? get caducidadTexto {
    if (diasCaducidad == null) return null;
    if (diasCaducidad! <= 0) return 'Caduca hoy';
    if (diasCaducidad == 1) return '1 día';
    return '$diasCaducidad días';
  }
}