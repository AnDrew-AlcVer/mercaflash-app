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
    return Producto(
      id: data['id'].toString(),
      nombre: data['nombre'] ?? '',
      cantidad: data['cantidad'] ?? '',
      categoria: data['categoria'] ?? '',
      subcategoria: data['subcategoria'] ?? '',
      precio: double.tryParse(data['precio'].toString()) ?? 0,
      precioAnterior: data['precio_anterior'] == null
          ? null
          : double.tryParse(data['precio_anterior'].toString()),
      diasCaducidad: data['dias_caducidad'] == null
          ? null
          : int.tryParse(data['dias_caducidad'].toString()),
      imagenUrl: data['imagen_url'],
      emoji: data['emoji'] ?? '🛒',
      esNovedad: data['es_novedad'] == true,
      esBajadaPrecio: data['es_bajada_precio'] == true,
      esFlash: data['es_flash'] == true,
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

  int get productosACaducar {
    return ingredientes
        .where((ingrediente) => ingrediente.diasCaducidad != null)
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
