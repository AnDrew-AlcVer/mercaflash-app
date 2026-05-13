import 'package:flutter/material.dart';
import '../models/producto_model.dart';
import '../widgets/ui_components.dart';
import '../widgets/product_cards.dart';

class ProductosCategoriaPage extends StatelessWidget {
  final String categoria;
  final List<Producto> productos;
  final Map<String, int> carrito;
  final ValueChanged<Producto> onAdd;
  final ValueChanged<Producto> onRemove;
  final VoidCallback onBack;

  const ProductosCategoriaPage({
    super.key,
    required this.categoria,
    required this.productos,
    required this.carrito,
    required this.onAdd,
    required this.onRemove,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SimpleHeader(title: categoria, onBack: onBack),
        Expanded(
          child: productos.isEmpty
              ? const EmptyState(
                  icon: Icons.inventory_2_outlined,
                  title: 'No hay productos todavía',
                  subtitle: 'Esta categoría está preparada para cargarse desde la base de datos.',
                )
              : GridView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.61,
                  ),
                  itemCount: productos.length,
                  itemBuilder: (context, index) {
                    final producto = productos[index];
                    return ProductGridCard(
                      producto: producto,
                      cantidad: carrito[producto.id] ?? 0,
                      onAdd: () => onAdd(producto),
                      onRemove: () => onRemove(producto),
                    );
                  },
                ),
        ),
      ],
    );
  }
}