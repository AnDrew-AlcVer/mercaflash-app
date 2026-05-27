import 'dart:math';
import 'package:flutter/material.dart';

import '../models/producto_model.dart';
import '../widgets/product_cards.dart';
import '../widgets/ui_components.dart';
import '../theme/app_theme.dart';

// ==========================================
// 1. APP TOP BAR MODIFICADO (SIN MENÚ)
// ==========================================
class AppTopBar extends StatelessWidget {
  final int totalUnidades;
  final VoidCallback onOpenCart;

  const AppTopBar({
    super.key,
    required this.totalUnidades,
    required this.onOpenCart,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(width: 48),
            Image.asset(
              'assets/images/textmercadona.png',
              height: 32,
              fit: BoxFit.contain,
            ),
            Stack(
              clipBehavior: Clip.none,
              children: [
                IconButton(
                  icon: const Icon(Icons.shopping_cart_outlined, size: 28),
                  onPressed: onOpenCart,
                ),
                if (totalUnidades > 0)
                  Positioned(
                    right: 4,
                    top: 4,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.green, 
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '$totalUnidades',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// NUEVO BANNER DE RECETAS (Estilo Mercadona Moderno)
// ==========================================
class RecipePromoBanner extends StatelessWidget {
  final String? imageUrl;
  final VoidCallback onTap;

  const RecipePromoBanner({super.key, required this.imageUrl, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // 1. Sustituimos GestureDetector por Material + InkWell
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        splashColor: AppTheme.green.withOpacity(0.2), // Efecto onda color verde
        highlightColor: Colors.black.withOpacity(0.05),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sobre-título pequeño
              const Text(
                'NUEVA SECCIÓN',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                  color: Color(0xFF5A5A5A),
                ),
              ),
              const SizedBox(height: 4),
              
              // Título principal grande
              const Text(
                'Ofertas que inspiran recetas',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.black,
                  height: 1.1,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 6),
              
              // Subtítulo gris
              const Text(
                'Pulsa aquí para cocinar más, gastando menos',
                style: TextStyle(
                  fontSize: 15,
                  color: AppTheme.gray,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              
              // Imagen grande a borde completo
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F0F0),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                // 2. Envolvemos la imagen en un Stack para añadir el botón flotante
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Imagen de fondo
                    imageUrl != null && imageUrl!.isNotEmpty
                        ? Image.network(
                            imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Center(child: Icon(Icons.restaurant_menu_rounded, size: 40, color: Colors.grey)),
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return const Center(child: CircularProgressIndicator(color: AppTheme.green));
                            },
                          )
                        : const Center(child: Icon(Icons.restaurant_menu_rounded, size: 40, color: Colors.grey)),
                    
                    // Indicador visual de clic (botón flotante inferior derecho)
                    Positioned(
                      bottom: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            )
                          ],
                        ),
                        child: const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 16,
                          color: AppTheme.green,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// HOMEPAGE
// ==========================================
class HomePage extends StatefulWidget {
  final List<Producto> productos;
  final List<Receta> recetas; 
  final Map<String, int> carrito;
  final int totalUnidades;
  final ValueChanged<Producto> onAdd;
  final ValueChanged<Producto> onRemove;
  final VoidCallback onOpenFlash;
  final VoidCallback onOpenFlashRecipes; 
  final VoidCallback onOpenCart;
  final VoidCallback onOpenCategories;
  final ValueChanged<String> onOpenCategory;

  const HomePage({
    super.key,
    required this.productos,
    required this.recetas, 
    required this.carrito,
    required this.totalUnidades,
    required this.onAdd,
    required this.onRemove,
    required this.onOpenFlash,
    required this.onOpenFlashRecipes, 
    required this.onOpenCart,
    required this.onOpenCategories,
    required this.onOpenCategory,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Producto> _flashMostrar = [];
  List<Producto> _recomendados = [];
  String _categoriaAleatoria = '';
  String? _imagenRecetaRandom; 

  @override
  void initState() {
    super.initState();
    _seleccionarDatosAleatorios();
  }

  @override
  void didUpdateWidget(HomePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.productos != oldWidget.productos || widget.recetas != oldWidget.recetas) {
      _seleccionarDatosAleatorios();
    }
  }

  void _seleccionarDatosAleatorios() {
    final random = Random();

    // 1. Ofertas Flash
    final flashOfertas = widget.productos.where((p) => p.mostrarOferta).toList();
    flashOfertas.shuffle(random);
    _flashMostrar = flashOfertas.take(10).toList();

    // 2. Recomendados
    final productosSinOferta = widget.productos.where((p) => !p.mostrarOferta).toList();
    final categoriasUnicas = productosSinOferta
        .map((p) => p.categoria)
        .where((c) => c.isNotEmpty)
        .toSet()
        .toList();

    if (categoriasUnicas.isNotEmpty) {
      _categoriaAleatoria = categoriasUnicas[random.nextInt(categoriasUnicas.length)];
      final productosDeCategoria = productosSinOferta.where((p) => p.categoria == _categoriaAleatoria).toList();
      productosDeCategoria.shuffle(random);
      _recomendados = productosDeCategoria;
    } else {
      _categoriaAleatoria = '';
      _recomendados = [];
    }

    // 3. RECETA RANDOM PARA LA IMAGEN DEL BANNER
    final recetasConImagen = widget.recetas
        .where((r) => r.imagenUrl != null && r.imagenUrl!.trim().isNotEmpty)
        .toList();

    if (recetasConImagen.isNotEmpty) {
      recetasConImagen.shuffle(random);
      _imagenRecetaRandom = recetasConImagen.first.imagenUrl;
    } else {
      _imagenRecetaRandom = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final novedades = widget.productos.where((producto) => producto.esNovedad).toList();

    return Column(
      children: [
        AppTopBar(
          totalUnidades: widget.totalUnidades,
          onOpenCart: widget.onOpenCart,
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.only(bottom: 28),
            children: [
              const DeliveryBanner(),
              const SizedBox(height: 24), 
              
              // BANNER DE RECETAS ACTUALIZADO
              RecipePromoBanner(
                imageUrl: _imagenRecetaRandom, 
                onTap: widget.onOpenFlashRecipes,
              ),

              const SizedBox(height: 32),
              
              GestureDetector(
                onTap: widget.onOpenFlash,
                behavior: HitTestBehavior.opaque,
                child: const SectionTitle(
                  title: 'Ofertas Flash',
                  subtitle: 'Aprovecha estos descuentos antes de que vuelen',
                ),
              ),
              
              ProductHorizontalList(
                productos: _flashMostrar,
                carrito: widget.carrito,
                onAdd: widget.onAdd,
                onRemove: widget.onRemove,
              ),

              const SizedBox(height: 18),
              
              GestureDetector(
                onTap: () {
                  if (_categoriaAleatoria.isNotEmpty) {
                    widget.onOpenCategory(_categoriaAleatoria);
                  }
                },
                behavior: HitTestBehavior.opaque,
                child: SectionTitle(
                  title: 'Recomendados',
                  subtitle: _categoriaAleatoria.isNotEmpty 
                      ? 'Descubre nuestra selección de $_categoriaAleatoria'
                      : 'Nuestra mejor selección para ti',
                ),
              ),
              
              ProductHorizontalList(
                productos: _recomendados,
                carrito: widget.carrito,
                onAdd: widget.onAdd,
                onRemove: widget.onRemove,
              ),

              if (novedades.isNotEmpty) ...[
                const SizedBox(height: 18),
                const SectionTitle(
                  title: 'Novedades',
                  subtitle: 'Productos recién añadidos o mejorados',
                ),
                ProductHorizontalList(
                  productos: novedades,
                  carrito: widget.carrito,
                  onAdd: widget.onAdd,
                  onRemove: widget.onRemove,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}