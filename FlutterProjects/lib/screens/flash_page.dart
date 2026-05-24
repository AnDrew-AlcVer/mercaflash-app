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
  final bool scrollToRecipes;
  final VoidCallback? onScrollDone; // <--- Callback para avisar al padre

  const FlashPage({
    super.key,
    required this.productos,
    required this.recetas,
    required this.carrito,
    required this.onAdd,
    required this.onRemove,
    this.onBack,
    required this.onOpenRecipe,
    this.scrollToRecipes = false, 
    this.onScrollDone,
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
    if (widget.scrollToRecipes) {
      _triggerScroll();
    }
  }

  @override
  void didUpdateWidget(FlashPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.scrollToRecipes && !oldWidget.scrollToRecipes) {
      _triggerScroll();
    }
  }

  void _triggerScroll() {
    Future.delayed(const Duration(milliseconds: 200), () {
      if (!mounted) return;
      _scrollToRecetas();
    });
  }

  void _scrollToRecetas() {
    final context = _recetasKey.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOutCubic,
        alignment: 0.05,
      ).then((_) {
        // Al terminar el scroll, avisamos al padre para limpiar el estado
        if (widget.onScrollDone != null) widget.onScrollDone!();
      });
    }
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
          child: ListView(
            controller: _scrollController, 
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 24),
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
      ],
    );
  }
}