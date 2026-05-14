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
    final novedades = productos.where((producto) => producto.esNovedad).toList();
    final bajadas = productos.where((producto) => producto.esBajadaPrecio).toList();
    final solares = productos
        .where((producto) => producto.categoria == 'Cuidado facial y corporal')
        .toList();
    final flash = productos.where((producto) => producto.esFlash).toList();

    return Column(
      children: [
        AppTopBar(
          totalUnidades: totalUnidades,
          onOpenCart: onOpenCart,
          onOpenCategories: onOpenCategories,
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.only(bottom: 22),
            children: [
              const DeliveryBanner(),
              PromoHeroCard(onTap: onOpenFlash),
              const SectionTitle(
                title: 'Novedades',
                subtitle: 'Productos recién añadidos o mejorados',
              ),
              ProductHorizontalList(
                productos: novedades,
                carrito: carrito,
                onAdd: onAdd,
                onRemove: onRemove,
              ),
              const SectionTitle(title: 'Bajadas de precio'),
              ProductHorizontalList(
                productos: bajadas,
                carrito: carrito,
                onAdd: onAdd,
                onRemove: onRemove,
              ),
              FlashEntryCard(productos: flash, onTap: onOpenFlash),
              const SectionTitle(title: 'El bronceado perfecto'),
              ProductHorizontalList(
                productos: solares,
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
