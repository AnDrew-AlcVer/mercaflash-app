import 'package:flutter/material.dart';

import '../models/producto_model.dart';
import '../widgets/product_cards.dart';
import '../widgets/ui_components.dart';

class HomePage extends StatelessWidget {
  final List<Producto> productos;
  final Map<String, int> carrito;
  final int totalUnidades;
  final ValueChanged<Producto> onAdd;
  final ValueChanged<Producto> onRemove;
  final VoidCallback onOpenFlash;
  final VoidCallback onOpenCart;
  final VoidCallback onOpenCategories;

  const HomePage({
    super.key,
    required this.productos,
    required this.carrito,
    required this.totalUnidades,
    required this.onAdd,
    required this.onRemove,
    required this.onOpenFlash,
    required this.onOpenCart,
    required this.onOpenCategories,
  });


  @override
  Widget build(BuildContext context) {
    final flash = productos.where((producto) => producto.esFlash).toList();
    final categorias = productos.map((producto) => producto.categoria).toSet().toList();
    final categoriaRecomendada = categorias.isNotEmpty
        ? (List<String>.from(categorias)..shuffle()).first
        : '';
    final recomendados = productos
        .where((producto) => producto.categoria == categoriaRecomendada)
        .toList();

    return Column(
      children: [
        AppTopBar(
          totalUnidades: totalUnidades,
          onOpenCart: onOpenCart,
          onOpenCategories: onOpenCategories,
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.only(bottom: 28),
            children: [
              const DeliveryBanner(),

              const SizedBox(height: 8),
              PromoHeroCard(onTap: onOpenFlash),

              const SizedBox(height: 18),
              const SectionTitle(
                title: 'Ofertas Flash',
                subtitle: 'Productos próximos a caducar',
              ),
              ProductHorizontalList(
                productos: flash,
                carrito: carrito,
                onAdd: onAdd,
                onRemove: onRemove,
              ),

              const SizedBox(height: 18),
              SectionTitle(
                title: 'Recomendados',
                subtitle: categoriaRecomendada.isNotEmpty
                    ? 'Productos de la categoría $categoriaRecomendada'
                    : null,
              ),
              ProductHorizontalList(
                productos: recomendados,
                carrito: carrito,
                onAdd: onAdd,
                onRemove: onRemove,
              ),
            ],
          ),
        ),
      ],
    );
  }

}
