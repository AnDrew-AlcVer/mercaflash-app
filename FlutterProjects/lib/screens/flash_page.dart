import 'package:flutter/material.dart';
import '../models/producto_model.dart';
import '../theme/app_theme.dart';
import '../widgets/ui_components.dart';
import '../widgets/product_cards.dart';

class FlashPage extends StatelessWidget {
  final List<Producto> productos;
  final List<Receta> recetas;
  final Map<String, int> carrito;
  final ValueChanged<Producto> onAdd;
  final ValueChanged<Producto> onRemove;
  final VoidCallback onBack;
  final ValueChanged<Receta> onOpenRecipe;

  const FlashPage({
    super.key,
    required this.productos,
    required this.recetas,
    required this.carrito,
    required this.onAdd,
    required this.onRemove,
    required this.onBack,
    required this.onOpenRecipe,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SimpleHeader(title: 'Próximos a caducar', onBack: onBack),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 24),
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.greenLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    Text('⚡', style: TextStyle(fontSize: 34)),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Aprovecha productos con descuento antes de que caduquen y añádelos al carrito.',
                        style: TextStyle(
                          color: AppTheme.green,
                          fontWeight: FontWeight.w900,
                          height: 1.25,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              const SectionTitle.compact(title: 'Productos destacados'),
              ...productos.map(
                (producto) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: ExpiryProductCard(
                    producto: producto,
                    cantidad: carrito[producto.id] ?? 0,
                    onAdd: () => onAdd(producto),
                    onRemove: () => onRemove(producto),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const SectionTitle.compact(title: 'Recetas para aprovechar'),
              ...recetas.map(
                (receta) => RecipeCard(
                  receta: receta,
                  onTap: () => onOpenRecipe(receta),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}