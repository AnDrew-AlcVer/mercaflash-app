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
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToRecetas();
      });
    }
  }

  // SOLUCIÓN AL SCROLL: Detecta cuando cambia la variable estando la pestaña ya iniciada
  @override
  void didUpdateWidget(FlashPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.scrollToRecipes && !oldWidget.scrollToRecipes) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToRecetas();
      });
    } else if (!widget.scrollToRecipes && oldWidget.scrollToRecipes) {
      // Si entramos sin scroll, nos aseguramos de estar arriba del todo
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(0);
      }
    }
  }

  void _scrollToRecetas() {
    if (_recetasKey.currentContext != null) {
      Scrollable.ensureVisible(
        _recetasKey.currentContext!,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
        alignment: 0.1, // Deja un poco de margen por arriba para que se vea bien el título
      );
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

    final nombresOfertasActivas = productosAMostrar
        .map((p) => p.nombre.toLowerCase().trim())
        .toSet();

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
              
              const SectionTitle(
                title: 'Productos próximos a caducar',
                subtitle: 'Dales una segunda oportunidad y cuida tu bolsillo',
              ),
              
              if (productosAMostrar.isEmpty)
                const EmptyState(
                  icon: Icons.flash_off_rounded,
                  title: 'No hay ofertas flash ahora mismo',
                  subtitle: 'Cuando haya productos próximos a caducar aparecerán aquí.',
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
                  subtitle: 'Añadiremos recetas sugeridas cuando estén disponibles en la base de datos.',
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