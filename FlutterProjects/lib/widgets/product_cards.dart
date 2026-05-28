import 'package:flutter/material.dart';

import '../models/producto_model.dart';
import '../theme/app_theme.dart';
import '../widgets/ui_components.dart';
import 'cart_widgets.dart'; // Asegúrate de tener esta importación si usas QuantityButton

class FlashPage extends StatelessWidget {
  final List<Producto> productos;
  final List<Receta> recetas;
  final Map<String, int> carrito;
  final ValueChanged<Producto> onAdd;
  final ValueChanged<Producto> onRemove;
  final VoidCallback? onBack;
  final ValueChanged<Receta> onOpenRecipe;

  const FlashPage({
    super.key,
    required this.productos,
    required this.recetas,
    required this.carrito,
    required this.onAdd,
    required this.onRemove,
    this.onBack,
    required this.onOpenRecipe,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SimpleHeader(title: 'Ofertas Flash', onBack: onBack),
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
              const SectionTitle.compact(title: 'Productos próximos a caducar'),
              if (productos.isEmpty)
                const EmptyState(
                  icon: Icons.flash_off_rounded,
                  title: 'No hay ofertas flash ahora mismo',
                  subtitle: 'Cuando haya productos próximos a caducar aparecerán aquí.',
                )
              else
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
              if (recetas.isEmpty)
                const EmptyState(
                  icon: Icons.restaurant_menu_rounded,
                  title: 'No hay recetas disponibles',
                  subtitle: 'Añadiremos recetas sugeridas cuando estén disponibles en la base de datos.',
                )
              else
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
      height: 300,
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
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(4),
                ),
                clipBehavior: Clip.antiAlias,
                alignment: Alignment.center,
                child: producto.imagenUrl != null 
                  ? Image.network(
                      producto.imagenUrl!,
                      fit: BoxFit.cover, // Imagen a sangre completa
                      width: double.infinity,
                      height: double.infinity,
                      errorBuilder: (context, error, stackTrace) => 
                        Text(producto.emoji, style: const TextStyle(fontSize: 54)),
                    )
                  : Text(producto.emoji, style: const TextStyle(fontSize: 54)),
              ),
            ),
            const SizedBox(height: 8), // Separador extra por quitar el Center anterior
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
            if (producto.tieneAlertaAlergenos) ...[
              const SizedBox(height: 4),
              AllergenWarningBanner(
                text: 'Contiene ${producto.alertaAlergenosTexto}',
                compact: true,
              ),
            ] else if (producto.tieneAlergenos) ...[
              const SizedBox(height: 4),
              AllergenTextLine(text: 'Alérgenos: ${producto.alergenosTexto}'),
            ],
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
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            clipBehavior: Clip.antiAlias,
            alignment: Alignment.center,
            child: producto.imagenUrl != null 
              ? Image.network(
                  producto.imagenUrl!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
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
                if (producto.tieneAlertaAlergenos) ...[
                  const SizedBox(height: 4),
                  AllergenWarningBanner(
                    text: 'Contiene ${producto.alertaAlergenosTexto}',
                    compact: true,
                  ),
                ] else if (producto.tieneAlergenos) ...[
                  const SizedBox(height: 4),
                  AllergenTextLine(text: 'Alérgenos: ${producto.alergenosTexto}'),
                ],
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
                color: Colors.transparent, // CAMBIO: Sin fondo gris/verde
                borderRadius: BorderRadius.circular(14), // CAMBIO: Bordes redondeados a 14
              ),
              clipBehavior: Clip.antiAlias, // CAMBIO: Recorta la imagen a la forma del borde
              alignment: Alignment.center,
              child: producto.imagenUrl != null 
                ? Image.network(
                    producto.imagenUrl!,
                    fit: BoxFit.cover, // CAMBIO: Ocupa todo el espacio, adiós bordes
                    width: double.infinity,
                    height: double.infinity,
                    errorBuilder: (context, error, stackTrace) => 
                      Text(producto.emoji, style: const TextStyle(fontSize: 38)),
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
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(producto.caducidadTexto, style: const TextStyle(color: AppTheme.green, fontWeight: FontWeight.w600, fontSize: 12)),
                  if (producto.tieneAlertaAlergenos) ...[
                    const SizedBox(height: 6),
                    AllergenWarningBanner(
                      text: 'Contiene ${producto.alertaAlergenosTexto}',
                      compact: true,
                    ),
                  ] else if (producto.tieneAlergenos) ...[
                    const SizedBox(height: 6),
                    AllergenTextLine(text: 'Alérgenos: ${producto.alergenosTexto}'),
                  ],
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
              Container(
                width: 70, // Ajustado para hacer match visual con la ExpiryCard
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.transparent, // CAMBIO: Sin fondo
                  borderRadius: BorderRadius.circular(14), // CAMBIO: Bordes redondeados a 14 (Igual que ExpiryCard)
                ),
                clipBehavior: Clip.antiAlias, // CAMBIO: Recorte de imagen activo
                alignment: Alignment.center,
                child: receta.imagenUrl != null 
                  ? Image.network(
                      receta.imagenUrl!,
                      fit: BoxFit.cover, // CAMBIO: Ocupa todo el espacio
                      width: double.infinity,
                      height: double.infinity,
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
                    Text(
                      receta.etiqueta,
                      style: TextStyle(
                        color: receta.tieneAlertaAlergenos ? AppTheme.orange : AppTheme.green,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                    if (receta.tieneAlertaAlergenos) ...[
                      const SizedBox(height: 6),
                      AllergenWarningBanner(
                        text: 'Contiene ${receta.alertaAlergenosTexto}',
                        compact: true,
                      ),
                    ] else if (receta.tieneAlergenos) ...[
                      const SizedBox(height: 6),
                      AllergenTextLine(text: 'Alérgenos: ${receta.alergenosTexto}'),
                    ],
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