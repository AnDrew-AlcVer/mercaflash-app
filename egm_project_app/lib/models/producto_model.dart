class Producto {
  final String id;
  final String nombre;
  final double precio;
  final String imagenUrl;
  final String categoria;

  Producto({
    required this.id, 
    required this.nombre, 
    required this.precio, 
    required this.imagenUrl,
    required this.categoria,
  });

  // Esto convierte lo que llega de Supabase a un objeto de Dart
  factory Producto.fromJson(Map<String, dynamic> json) {
    return Producto(
      id: json['id'].toString(),
      nombre: json['nombre'] ?? 'Sin nombre',
      precio: (json['precio'] as num).toDouble(),
      imagenUrl: json['imagen_url'] ?? '',
      categoria: json['categoria'] ?? 'General',
    );
  }
}