import 'package:flutter/material.dart';
import '../models/producto_model.dart';
import '../widgets/ui_components.dart';
import '../widgets/cart_widgets.dart';

class CarritoPage extends StatelessWidget {
  final List<Producto> productos;
  final Map<String, int> carrito;
  final double total;
  final ValueChanged<Producto> onAdd;
  final ValueChanged<Producto> onRemove;
  final VoidCallback onClear;

  const CarritoPage({
    super.key,
    required this.productos,
    required this.carrito,
    required this.total,
    required this.onAdd,
    required this.onRemove,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final productosCarrito = productos
        .where((producto) => carrito.containsKey(producto.id))
        .toList();

    return Column(
      children: [
        const SimpleHeader(title: 'Lista'),
        Expanded(
          child: productosCarrito.isEmpty
              ? const EmptyState(
                  icon: Icons.shopping_cart_outlined,
                  title: 'Tu carrito está vacío',
                  subtitle: 'Añade productos desde Inicio, Categorías, Buscar o Próximos a caducar.',
                )
              : ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                  children: [
                    Row(
                      children: [
                        Text(
                          '${productosCarrito.length} productos',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: onClear,
                          child: const Text('Vaciar'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ...productosCarrito.map(
                      (producto) => CartItemTile(
                        producto: producto,
                        cantidad: carrito[producto.id] ?? 0,
                        onAdd: () => onAdd(producto),
                        onRemove: () => onRemove(producto),
                      ),
                    ),
                  ],
                ),
        ),
        if (productosCarrito.isNotEmpty)
          CheckoutBar(total: total),
      ],
    );
  }
}