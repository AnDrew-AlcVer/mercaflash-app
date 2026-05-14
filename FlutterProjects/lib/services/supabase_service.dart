import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/producto_model.dart';

class SupabaseService {
  final SupabaseClient _client = Supabase.instance.client;

  // Por defecto, usamos el ID de Jordi para probar el filtro de alergia al pescado.
  // Si quieres probar el filtro de alergia al Gluten, cambia esta ID por la tuya:
  // '11111111-1111-1111-1111-111111111111'
  final String _usuarioActualId = '44444444-4444-4444-4444-444444444444';

  // --- LÓGICA DE ALERGIAS ---
  Future<List<int>> _obtenerMisAlergias() async {
    final response = await _client
        .from('usuarios_alergias')
        .select('alergia_id')
        .eq('usuario_id', _usuarioActualId);
    
    return (response as List).map((e) => e['alergia_id'] as int).toList();
  }

  // --- OBTENCIÓN DE DATOS REALES ---

  Future<List<Producto>> obtenerProductos() async {
    final misAlergiasIds = await _obtenerMisAlergias();

    // Traemos todos los productos y las alergias que contienen
    final response = await _client
        .from('productos')
        .select('*, productos_alergias(alergia_id)');

    List<Producto> productosSeguros = [];

    for (var row in response) {
      final alergiasProducto = (row['productos_alergias'] as List)
          .map((e) => e['alergia_id'] as int)
          .toList();

      // Filtro vital: Si el producto tiene una alergia que yo tengo, lo descartamos
      bool esSeguro = true;
      for (var miAlergia in misAlergiasIds) {
        if (alergiasProducto.contains(miAlergia)) {
          esSeguro = false;
          break;
        }
      }

      if (esSeguro) {
        productosSeguros.add(Producto.fromMap(row));
      }
    }

    return productosSeguros;
  }

  Future<List<Producto>> obtenerProductosProximosACaducar() async {
    // Reutilizamos la función principal para asegurar que las ofertas flash también pasen el filtro de alergias
    final todosLosSeguros = await obtenerProductos();
    return todosLosSeguros.where((producto) => producto.esFlash).toList();
  }

  Future<List<Receta>> obtenerRecetasSugeridas() async {
    final misAlergiasIds = await _obtenerMisAlergias();

    // Traemos las recetas, qué ingredientes llevan y qué alergias tiene cada ingrediente
    final response = await _client
        .from('recetas')
        .select('*, recetas_productos(cantidad, productos(nombre, fecha_caducidad, productos_alergias(alergia_id)))');

    List<Receta> recetasSeguras = [];

    for (var row in response) {
      bool recetaEsSegura = true;
      List<IngredienteReceta> ingredientesDeEstaReceta = [];

      final relacionIngredientes = row['recetas_productos'] as List;

      for (var rel in relacionIngredientes) {
        final productoObj = rel['productos'];
        final cantidadTexto = rel['cantidad'] as String;
        
        final alergiasDelIngrediente = (productoObj['productos_alergias'] as List)
            .map((e) => e['alergia_id'] as int)
            .toList();

        // Si tan solo UN ingrediente de la receta me da alergia, la receta entera se descarta
        for (var miAlergia in misAlergiasIds) {
          if (alergiasDelIngrediente.contains(miAlergia)) {
            recetaEsSegura = false;
            break;
          }
        }

        // Calculamos los días de caducidad del ingrediente para mostrar las alertas naranjas/rojas en la receta
        int? diasCaducidad;
        if (productoObj['fecha_caducidad'] != null) {
          DateTime caducidad = DateTime.parse(productoObj['fecha_caducidad']);
          diasCaducidad = caducidad.difference(DateTime.now()).inDays;
        }

        ingredientesDeEstaReceta.add(IngredienteReceta(
          nombre: productoObj['nombre'],
          cantidad: cantidadTexto,
          disponible: true, // Para la demo asumimos que los ingredientes están disponibles
          diasCaducidad: diasCaducidad,
        ));
      }

      if (recetaEsSegura) {
        recetasSeguras.add(Receta.fromMap(row, ingredientesDeEstaReceta));
      }
    }

    return recetasSeguras;
  }

  Future<List<CategoriaMercadona>> obtenerCategorias() async {
    // Hacemos la consulta a la tabla 'categorias' de Supabase
    final response = await _client.from('categorias').select();

    List<CategoriaMercadona> categorias = [];

    for (var row in response) {
      categorias.add(CategoriaMercadona(
        // Convertimos el id (que en Supabase es int4) a String para no romper el resto del código
        id: row['id'].toString(), 
        nombre: row['nombre'] as String,
        // Aquí recibes el string con la URL de la imagen que está en la base de datos
        emoji: row['emoji'] as String, 
      ));
    }

    // Añadimos manualmente la categoría Flash si la necesitas para mantener la lógica de tu UI
    categorias.add(const CategoriaMercadona(
      id: 'flash',
      nombre: 'Próximos a caducar',
      emoji: 'https://cdn-icons-png.flaticon.com/512/1164/1164382.png', // URL de un rayo por defecto (cámbiala si quieres)
    ));

    return categorias;
  }
}