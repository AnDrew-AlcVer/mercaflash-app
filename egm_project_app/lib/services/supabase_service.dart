import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/producto_model.dart';

/*
class SupabaseService {
  final _client = Supabase.instance.client;

  // 1. FUNCIÓN PARA LEER PRODUCTOS
  Future<List<Producto>> obtenerProductos() async {
    final response = await _client.from('productos').select();
    return (response as List).map((p) => Producto.fromJson(p)).toList();
  }

  // 2. FUNCIÓN PARA BUSCAR POR CATEGORÍA
  Future<List<Producto>> obtenerPorCategoria(String categoria) async {
    final response = await _client
        .from('productos')
        .select()
        .eq('categoria', categoria);
    return (response as List).map((p) => Producto.fromJson(p)).toList();
  }

  // 3. FUNCIÓN PARA CREAR PEDIDO (Carrito)
  Future<void> crearPedido(List<Producto> carrito, double total) async {
    await _client.from('pedidos').insert({
      'total': total,
      'fecha': DateTime.now().toIso8601String(),
      // Aquí podrías añadir más lógica
    });
  }
}
*/