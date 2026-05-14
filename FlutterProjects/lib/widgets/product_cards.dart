import 'package:flutter/material.dart';
import '../models/producto_model.dart';
import '../theme/app_theme.dart';
import 'ui_components.dart';
import 'cart_widgets.dart';

class ProductHorizontalList extends StatelessWidget {
  final List<Producto> productos;
  final Map<String, int> carrito;
  final ValueChanged<Producto> onAdd;
  final ValueChanged<Producto> onRemove;

  const ProductHorizontalList({
    super.key,
    required this.productos,
    required this.carrito,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 262,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        scrollDirection: Axis.horizontal,
        itemCount: productos.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final producto = productos[index];
          return SizedBox(
            width: 156,
            child: ProductGridCard(
              producto: producto,
              cantidad: carrito[producto.id] ?? 0,
              onAdd: () => onAdd(producto),
              onRemove: () => onRemove(producto),
            ),
          );
        },
      ),
    );
  }
}

class ProductGridCard extends StatelessWidget {
  final Producto producto;
  final int cantidad;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  const ProductGridCard({
    super.key,
    required this.producto,
    required this.cantidad,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedTap(
      onTap: onAdd,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [BoxShadow(color: Color(0x10000000), blurRadius: 8, offset: Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Center(
                // CAMBIO: Se sustituye el Emoji por la Imagen de la DB
                child: producto.imagenUrl != null 
                  ? Image.network(
                      producto.imagenUrl!,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => 
                        Text(producto.emoji, style: const TextStyle(fontSize: 54)),
                    )
                  : Text(producto.emoji, style: const TextStyle(fontSize: 54)),
              ),
            ),
            Text(
              producto.nombre,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, height: 1.15),
            ),
            const SizedBox(height: 5),
            Text(
              producto.cantidad,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11, color: AppTheme.gray),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 4,
              crossAxisAlignment: WrapCrossAlignment.end,
              children: [
                if (producto.precioAnterior != null)
                  Text(
                    producto.precioAnteriorTexto,
                    style: const TextStyle(
                      color: AppTheme.gray,
                      decoration: TextDecoration.lineThrough,
                      fontSize: 11,
                    ),
                  ),
                Text(
                  producto.precioTexto,
                  style: TextStyle(
                    color: producto.precioAnterior != null ? AppTheme.red : AppTheme.black,
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            QuantityButton(cantidad: cantidad, onAdd: onAdd, onRemove: onRemove),
          ],
        ),
      ),
    );
  }
}

class CompactProductTile extends StatelessWidget {
  final Producto producto;
  final int cantidad;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  const CompactProductTile({
    super.key,
    required this.producto,
    required this.cantidad,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Container(
            height: 62,
            width: 62,
            decoration: BoxDecoration(
              color: const Color(0xFFF7F7F7),
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            // CAMBIO: Se sustituye el Emoji por la Imagen en formato compacto
            child: producto.imagenUrl != null 
              ? Image.network(
                  producto.imagenUrl!,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => 
                    Text(producto.emoji, style: const TextStyle(fontSize: 30)),
                )
              : Text(producto.emoji, style: const TextStyle(fontSize: 30)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  producto.nombre,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, height: 1.15),
                ),
                const SizedBox(height: 3),
                Text(producto.precioTexto, style: const TextStyle(fontWeight: FontWeight.w900)),
              ],
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(width: 100, child: QuantityButton(cantidad: cantidad, onAdd: onAdd, onRemove: onRemove)),
        ],
      ),
    );
  }
}

class FlashEntryCard extends StatelessWidget {
  final List<Producto> productos;
  final VoidCallback onTap;

  const FlashEntryCard({super.key, required this.productos, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 18, 14, 8),
      child: AnimatedTap(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.yellowLight,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFFFDF99)),
          ),
          child: Row(
            children: [
              const Text('⚡', style: TextStyle(fontSize: 36)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Próximos a caducar',
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${productos.length} productos con descuento y recetas sugeridas',
                      style: const TextStyle(color: AppTheme.gray, fontSize: 13),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppTheme.black),
            ],
          ),
        ),
      ),
    );
  }
}

class ExpiryProductCard extends StatelessWidget {
  final Producto producto;
  final int cantidad;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  const ExpiryProductCard({
    super.key,
    required this.producto,
    required this.cantidad,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final badgeColor = producto.caducaHoy
        ? AppTheme.red
        : producto.caducaPronto
            ? AppTheme.orange
            : AppTheme.green;

    return AnimatedTap(
      onTap: onAdd,
      child: Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [BoxShadow(color: Color(0x12000000), blurRadius: 14, offset: Offset(0, 6))],
        ),
        child: Row(
          children: [
            Container(
              height: 78,
              width: 82,
              decoration: BoxDecoration(
                color: AppTheme.greenLight,
                borderRadius: BorderRadius.circular(14),
              ),
              alignment: Alignment.center,
              // CAMBIO: Imagen para la lista de productos próximos a caducar
              child: producto.imagenUrl != null 
                ? Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: Image.network(
                        producto.imagenUrl!,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => 
                          Text(producto.emoji, style: const TextStyle(fontSize: 38)),
                      ),
                  )
                : Text(producto.emoji, style: const TextStyle(fontSize: 38)),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(producto.nombre, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w900)),
                  const SizedBox(height: 4),
                  Text(producto.cantidad, style: const TextStyle(color: AppTheme.gray, fontSize: 12)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 3,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      if (producto.precioAnterior != null)
                        Text(
                          producto.precioAnteriorTexto,
                          style: const TextStyle(color: AppTheme.gray, decoration: TextDecoration.lineThrough, fontSize: 12),
                        ),
                      Text(producto.precioTexto, style: const TextStyle(color: AppTheme.red, fontWeight: FontWeight.w900)),
                      Text(producto.caducidadTexto, style: TextStyle(color: badgeColor, fontWeight: FontWeight.w900, fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(width: 96, child: QuantityButton(cantidad: cantidad, onAdd: onAdd, onRemove: onRemove)),
          ],
        ),
      ),
    );
  }
}

class RecipeCard extends StatelessWidget {
  final Receta receta;
  final VoidCallback onTap;

  const RecipeCard({super.key, required this.receta, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AnimatedTap(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: const [BoxShadow(color: Color(0x10000000), blurRadius: 12, offset: Offset(0, 5))],
          ),
          child: Row(
            children: [
              // CAMBIO: Las recetas también pueden usar imagenUrl si la tienen
              SizedBox(
                width: 50,
                height: 50,
                child: receta.imagenUrl != null 
                  ? Image.network(
                      receta.imagenUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => 
                        Text(receta.emoji, style: const TextStyle(fontSize: 42)),
                    )
                  : Text(receta.emoji, style: const TextStyle(fontSize: 42)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(receta.titulo, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 4),
                    Text(receta.etiqueta, style: const TextStyle(color: AppTheme.green, fontWeight: FontWeight.w800, fontSize: 12)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        InfoChip(icon: Icons.schedule_rounded, label: '${receta.tiempoMinutos} min'),
                        const SizedBox(width: 8),
                        InfoChip(icon: Icons.restaurant_rounded, label: receta.dificultad),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}