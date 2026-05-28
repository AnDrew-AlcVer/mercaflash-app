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
  final int scrollTrigger; // <-- Volvemos a pedir el trigger

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
  final GlobalKey _recetasKey = GlobalKey(); // <-- Clave para saber dónde están las recetas

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
    if (widget.scrollTrigger != oldWidget.scrollTrigger && widget.scrollTrigger > 0) {
      _triggerScroll();
    }
  }

  void _triggerScroll() {
    Future.delayed(const Duration(milliseconds: 150), () {
      if (!mounted) return;
      
      // 1. Accedemos al almacenamiento interno de la página
      final bucket = PageStorage.of(context);
      
      // 2. Creamos un ID único para este clic del banner en concreto
      final String triggerId = 'animacion_hecha_${widget.scrollTrigger}';
      
      // 3. Comprobamos si ya hemos ejecutado la animación para este trigger
      final bool animacionCompletada = bucket.readState(context, identifier: triggerId) as bool? ?? false;
      
      // 4. Si ya se hizo (porque el usuario viene de darle a "atrás" en una receta), cancelamos
      if (animacionCompletada) return;
      
      // 5. Si es la primera vez, guardamos en memoria que ya hemos ejecutado el salto
      bucket.writeState(context, true, identifier: triggerId);
      
      final contextTarget = _recetasKey.currentContext;
      if (contextTarget != null) {
        Scrollable.ensureVisible(
          contextTarget,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOutCubic,
          alignment: 0.02, 
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
          child: SingleChildScrollView(
            // IMPRESCINDIBLE: Guarda el pixel exacto del scroll al cambiar de pantalla
            key: const PageStorageKey<String>('flash_page_scroll_key'), 
            controller: _scrollController, 
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SectionTitle(
                  title: 'Productos con descuentos',
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
                  key: _recetasKey, // <-- Asignamos la clave aquí para que el scroll sepa dónde ir
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