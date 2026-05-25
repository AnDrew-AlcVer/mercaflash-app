import 'package:flutter/material.dart';

import '../models/producto_model.dart';
import '../theme/app_theme.dart';
import '../widgets/product_cards.dart';
import '../widgets/ui_components.dart';

class FlashPage extends StatefulWidget {
  final List<Producto> productos;
  final List<Receta> recetas;
  final Map<String, int> carrito;
  final ValueChanged<Producto> onAdd;
  final ValueChanged<Producto> onRemove;
  final VoidCallback? onBack;
  final ValueChanged<Receta> onOpenRecipe;
  final int scrollTrigger; 

  const FlashPage({
    super.key,
    required this.productos,
    required this.recetas,
    required this.carrito,
    required this.onAdd,
    required this.onRemove,
    this.onBack,
    required this.onOpenRecipe,
    this.scrollTrigger = 0, 
  });

  @override
  State<FlashPage> createState() => _FlashPageState();
}

class _FlashPageState extends State<FlashPage> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _recetasKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    if (widget.scrollTrigger > 0) {
      _triggerScroll();
    }
  }

  @override
  void didUpdateWidget(FlashPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.scrollTrigger != oldWidget.scrollTrigger) {
      _triggerScroll();
    }
  }

  void _triggerScroll() {
    // Al usar SingleChildScrollView la pantalla ya está construida,
    // un pequeño delay hace que el usuario "vea" cómo baja.
    Future.delayed(const Duration(milliseconds: 150), () {
      if (!mounted) return;
      
      final context = _recetasKey.currentContext;
      if (context != null) {
        Scrollable.ensureVisible(
          context,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOutCubic,
          alignment: 0.02, // Deja un margen bonito por encima del título
        );
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productosAMostrar = widget.productos.where((p) => p.mostrarOferta).toList();
    final nombresOfertasActivas = productosAMostrar.map((p) => p.nombre.toLowerCase().trim()).toSet();

    final recetasAMostrar = widget.recetas.where((receta) {
      return receta.ingredientes.any((ingrediente) =>
          nombresOfertasActivas.contains(ingrediente.nombre.toLowerCase().trim()));
    }).toList();

    return Column(
      children: [
        SimpleHeader(title: 'Ofertas Flash', onBack: widget.onBack),
        Expanded(
          // SOLUCIÓN: Cambiamos ListView por SingleChildScrollView + Column
          // para que siempre encuentre el título "Recetas" sin importar si está fuera de pantalla.
          child: SingleChildScrollView(
            controller: _scrollController, 
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SectionTitle(
                  title: 'Productos con descuentos increíbles',
                  subtitle: 'Dales una segunda oportunidad y cuida tu bolsillo',
                ),
                
                if (productosAMostrar.isEmpty)
                  const EmptyState(
                    icon: Icons.flash_off_rounded,
                    title: 'No hay ofertas flash ahora mismo',
                    subtitle: 'Cuando haya productos próximos con oferta aparecerán aquí.',
                  )
                else
                  ...productosAMostrar.map(
                    (producto) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: ExpiryProductCard(
                        producto: producto,
                        cantidad: widget.carrito[producto.id] ?? 0,
                        onAdd: () => widget.onAdd(producto),
                        onRemove: () => widget.onRemove(producto),
                      ),
                    ),
                  ),
                
                const SizedBox(height: 12),
                
                SectionTitle(
                  key: _recetasKey, 
                  title: 'Recetas',
                  subtitle: 'Utiliza los productos rebajados en estas nuevas recetas recomendadas.',
                ),
                
                if (recetasAMostrar.isEmpty)
                  const EmptyState(
                    icon: Icons.restaurant_menu_rounded,
                    title: 'No hay recetas disponibles',
                    subtitle: 'Añadiremos recetas sugeridas cuando estén disponibles.',
                  )
                else
                  ...recetasAMostrar.map(
                    (receta) => RecipeCard(
                      receta: receta,
                      onTap: () => widget.onOpenRecipe(receta),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}