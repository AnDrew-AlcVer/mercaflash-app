import 'package:flutter/material.dart';

import '../models/producto_model.dart';
import '../theme/app_theme.dart';
import '../widgets/ui_components.dart';

class DetalleRecetaPage extends StatefulWidget {
  final Receta receta;
  final List<Producto> productos;
  final Map<String, int> carrito;
  final VoidCallback onBack;
  final ValueChanged<List<Producto>> onAddProducts;

  const DetalleRecetaPage({
    super.key,
    required this.receta,
    required this.productos,
    required this.carrito,
    required this.onBack,
    required this.onAddProducts,
  });

  @override
  State<DetalleRecetaPage> createState() => _DetalleRecetaPageState();
}

class _DetalleRecetaPageState extends State<DetalleRecetaPage> {
  final Set<String> _seleccionados = {};

  @override
  Widget build(BuildContext context) {
    final ingredientesComprables = _ingredientesConProducto();

    return Column(
      children: [
        SimpleHeader(title: 'Receta', onBack: widget.onBack),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 30),
            children: [
              // 1. IMAGEN PRINCIPAL
              Container(
                height: 220,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppTheme.greenLight,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                alignment: Alignment.center,
                child: widget.receta.imagenUrl != null && widget.receta.imagenUrl!.isNotEmpty
                    ? Image.network(
                        widget.receta.imagenUrl!,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => 
                          Text(widget.receta.emoji, style: const TextStyle(fontSize: 80)),
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const Center(child: CircularProgressIndicator());
                        },
                      )
                    : Text(widget.receta.emoji, style: const TextStyle(fontSize: 80)),
              ),
              const SizedBox(height: 20),

              // 2. TÍTULO Y DESCRIPCIÓN
              Text(
                widget.receta.titulo,
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, height: 1.1),
              ),
              const SizedBox(height: 8),
              Text(
                widget.receta.descripcion,
                style: const TextStyle(color: AppTheme.gray, fontSize: 15, height: 1.4),
              ),
              const SizedBox(height: 16),

              // 3. DATOS CLAVE (Tiempo, raciones, dificultad)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FA), 
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _DatoClave(icon: Icons.schedule_rounded, valor: '${widget.receta.tiempoMinutos} min'),
                    Container(height: 30, width: 1, color: AppTheme.border),
                    _DatoClave(icon: Icons.people_outline_rounded, valor: '${widget.receta.raciones} rac.'),
                    Container(height: 30, width: 1, color: AppTheme.border),
                    _DatoClave(icon: Icons.local_fire_department_outlined, valor: widget.receta.dificultad),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 4. AVISOS DE ALÉRGENOS
              if (widget.receta.tieneAlertaAlergenos) ...[
                AllergenWarningBanner(
                  text: 'Esta receta contiene ${widget.receta.alertaAlergenosTexto}, marcado en tu perfil.',
                ),
                const SizedBox(height: 16),
              ] else if (widget.receta.tieneAlergenos) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.greenLight,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: AllergenTextLine(text: 'Alérgenos de la receta: ${widget.receta.alergenosTexto}'),
                ),
                const SizedBox(height: 16),
              ],
              
              const Divider(color: AppTheme.border, height: 30),

              // 5. LISTA DE INGREDIENTES DE LA RECETA (Formato tabla limpia)
              const Row(
                children: [
                  Icon(Icons.kitchen_rounded, color: AppTheme.green),
                  SizedBox(width: 8),
                  Text(
                    'Ingredientes necesarios',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Encabezados de la tabla
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'INGREDIENTE',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppTheme.gray, letterSpacing: 1.2),
                      ),
                    ),
                    Text(
                      'CANTIDAD',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppTheme.gray, letterSpacing: 1.2),
                    ),
                  ],
                ),
              ),
              const Divider(color: AppTheme.border, height: 1),
              const SizedBox(height: 8),
              
              // Filas de ingredientes
              ...widget.receta.ingredientes.map(
                (ingrediente) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          ingrediente.nombre,
                          style: const TextStyle(fontSize: 16, color: AppTheme.black, fontWeight: FontWeight.w500),
                        ),
                      ),
                      const SizedBox(width: 16),
                      if (ingrediente.cantidad.isNotEmpty)
                        Text(
                          ingrediente.cantidad,
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.green),
                          textAlign: TextAlign.right,
                        ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 8),
              const Divider(color: AppTheme.border, height: 1),
              const SizedBox(height: 24),

              // 6. CAJA PARA COMPRAR
              _MissingIngredientsBox(
                ingredientes: ingredientesComprables,
                seleccionados: _seleccionados,
                carrito: widget.carrito,
                onToggle: _toggleProducto,
                onAddSelected: _addSelectedProducts,
              ),

              const Divider(color: AppTheme.border, height: 40),

              // 7. PASOS DE PREPARACIÓN
              const Row(
                children: [
                  Icon(Icons.format_list_numbered_rounded, color: AppTheme.green),
                  SizedBox(width: 8),
                  Text(
                    'Preparación',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ...widget.receta.pasos.asMap().entries.map(
                    (entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: StepRow(numero: entry.key + 1, texto: entry.value),
                    ),
                  ),
            ],
          ),
        ),
      ],
    );
  }

  List<_IngredienteComprable> _ingredientesConProducto() {
    final resultado = <_IngredienteComprable>[];

    for (final ingrediente in widget.receta.ingredientes) {
      final producto = _buscarProductoParaIngrediente(ingrediente.nombre);
      if (producto != null) {
        resultado.add(_IngredienteComprable(ingrediente: ingrediente, producto: producto));
      }
    }

    resultado.sort((a, b) {
      if (a.producto.mostrarOferta && !b.producto.mostrarOferta) return -1;
      if (!a.producto.mostrarOferta && b.producto.mostrarOferta) return 1;
      return 0;
    });

    return resultado;
  }

  // AQUÍ ESTÁ LA NUEVA LÓGICA DE BÚSQUEDA CORREGIDA
  Producto? _buscarProductoParaIngrediente(String nombreIngrediente) {
    final nombreBuscado = nombreIngrediente.toLowerCase().trim();
    if (nombreBuscado.isEmpty) return null;

    // 1. Búsqueda EXACTA: Como vienen de la base de datos cruzada, lo normal es que coincidan 100%
    for (final producto in widget.productos) {
      if (producto.nombre.toLowerCase().trim() == nombreBuscado) {
        return producto;
      }
    }

    // 2. Búsqueda SEGURA: Si falla la exacta, buscamos usando límites de palabra (RegExp)
    // Esto evita que "sal" encuentre "salmón". Solo encontrará "sal" si es una palabra aislada.
    final regex = RegExp(r'\b' + RegExp.escape(nombreBuscado) + r'\b');
    for (final producto in widget.productos) {
      if (regex.hasMatch(producto.nombre.toLowerCase())) {
        return producto;
      }
    }

    return null;
  }

  void _toggleProducto(Producto producto, bool seleccionado) {
    setState(() {
      if (seleccionado) {
        _seleccionados.add(producto.id);
      } else {
        _seleccionados.remove(producto.id);
      }
    });
  }

  void _addSelectedProducts() {
    final productos = widget.productos
        .where((producto) => _seleccionados.contains(producto.id))
        .toList();

    widget.onAddProducts(productos);

    if (productos.isNotEmpty) {
      setState(_seleccionados.clear);
    }
  }
}

// Widget auxiliar para los datos clave debajo del título
class _DatoClave extends StatelessWidget {
  final IconData icon;
  final String valor;

  const _DatoClave({required this.icon, required this.valor});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.green, size: 22),
        const SizedBox(height: 4),
        Text(
          valor,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppTheme.black),
        ),
      ],
    );
  }
}

class _IngredienteComprable {
  final IngredienteReceta ingrediente;
  final Producto producto;

  const _IngredienteComprable({
    required this.ingrediente,
    required this.producto,
  });
}

class _MissingIngredientsBox extends StatelessWidget {
  final List<_IngredienteComprable> ingredientes;
  final Set<String> seleccionados;
  final Map<String, int> carrito;
  final void Function(Producto producto, bool seleccionado) onToggle;
  final VoidCallback onAddSelected;

  const _MissingIngredientsBox({
    required this.ingredientes,
    required this.seleccionados,
    required this.carrito,
    required this.onToggle,
    required this.onAddSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (ingredientes.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.greenLight,
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Row(
          children: [
            Icon(Icons.info_outline_rounded, color: AppTheme.green),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'No hay productos vinculados en la tienda para esta receta.',
                style: TextStyle(color: AppTheme.green, fontWeight: FontWeight.w800, height: 1.35),
              ),
            ),
          ],
        ),
      );
    }

    // CALCULAMOS EL AHORRO TOTAL
    double ahorroTotal = 0;
    for (final item in ingredientes) {
      if (item.producto.mostrarOferta && item.producto.precioAnterior != null) {
        ahorroTotal += (item.producto.precioAnterior! - item.producto.precio);
      }
    }
    final String ahorroTexto = ahorroTotal.toStringAsFixed(2).replaceAll('.', ',');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.green.withOpacity(0.3), width: 1.5),
        boxShadow: const [
          BoxShadow(color: Color(0x0A000000), blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Comprar ingredientes',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppTheme.green),
          ),
          const SizedBox(height: 4),
          const Text(
            'Selecciona lo que te falte y añádelo a tu carrito.',
            style: TextStyle(color: AppTheme.gray, height: 1.3, fontSize: 13),
          ),
          const SizedBox(height: 16),
          
          ...ingredientes.map((item) {
            final yaEnCarrito = carrito.containsKey(item.producto.id);
            final checked = seleccionados.contains(item.producto.id) || yaEnCarrito;
            final esOferta = item.producto.mostrarOferta;

            return CheckboxListTile(
              value: checked,
              onChanged: yaEnCarrito
                  ? null
                  : (value) => onToggle(item.producto, value ?? false),
              activeColor: AppTheme.green,
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              title: Text(
                item.ingrediente.nombre,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: yaEnCarrito ? AppTheme.green : AppTheme.black,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Cantidad
                    Expanded(
                      child: Text(
                        item.ingrediente.cantidad.isEmpty 
                          ? 'Cantidad: 1 ud.' 
                          : 'Cantidad: ${item.ingrediente.cantidad}',
                        style: const TextStyle(color: AppTheme.gray, fontSize: 13),
                      ),
                    ),
                    
                    // Lógica de Precios
                    if (esOferta && item.producto.precioAnterior != null) ...[
                      Text(
                        item.producto.precioAnteriorTexto,
                        style: const TextStyle(
                          color: AppTheme.gray,
                          decoration: TextDecoration.lineThrough,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          item.producto.precioTexto,
                          style: TextStyle(
                            color: Colors.red.shade700,
                            fontWeight: FontWeight.w900,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ] else ...[
                      Text(
                        item.producto.precioTexto,
                        style: const TextStyle(
                          color: AppTheme.black,
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }),
          
          // CARTEL DE AHORRO LLAMATIVO
          if (ahorroTotal > 0) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFF3E0), Color(0xFFFFE0B2)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.shade300),
              ),
              child: Row(
                children: [
                  const Text('🔥', style: TextStyle(fontSize: 24)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '¡Aprovecha! Te ahorras $ahorroTexto € llevando los productos en oferta.',
                      style: TextStyle(
                        color: Colors.orange.shade900,
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                        height: 1.25,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: seleccionados.isEmpty ? null : onAddSelected,
              icon: const Icon(Icons.add_shopping_cart_rounded),
              label: const Text('Añadir al carrito'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}