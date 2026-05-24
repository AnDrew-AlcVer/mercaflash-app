import 'dart:math';
import 'package:flutter/material.dart';

import '../models/producto_model.dart';
import '../widgets/product_cards.dart';
import '../widgets/ui_components.dart';

// ==========================================
// 1. APP TOP BAR MODIFICADO (CON LA IMAGEN)
// ==========================================
class AppTopBar extends StatelessWidget {
  final int totalUnidades;
  final VoidCallback onOpenCart;
  final VoidCallback onOpenCategories;

  const AppTopBar({
    super.key,
    required this.totalUnidades,
    required this.onOpenCart,
    required this.onOpenCategories,
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
            // Botón de menú / categorías
            IconButton(
              icon: const Icon(Icons.menu, size: 28),
              onPressed: onOpenCategories,
            ),
            
            // ---> AQUÍ ESTÁ TU IMAGEN <---
            Image.asset(
              'assets/images/textmercadona.png',
              height: 32, // Puedes ajustar este número si la ves muy grande o pequeña
              fit: BoxFit.contain,
            ),
            
            // Botón del carrito con contador
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
                        color: Colors.green, // Color del circulito del carrito
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
// NUEVA PASTILLA VERDE DE RECETAS (BANNER)
// ==========================================
class RecipePromoBanner extends StatelessWidget {
  final VoidCallback onTap;

  const RecipePromoBanner({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 18),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF007A33), Color(0xFF00A045)], // Verdes estilo Mercadona
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF007A33).withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Pequeña etiqueta semitransparente superior
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.restaurant_menu_rounded, color: Colors.white, size: 14),
                        SizedBox(width: 4),
                        Text(
                          'RECETAS',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w800, // Menos pesado que w900
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Título principal
                  const Text(
                    'Ofertas que\ninspiran recetas',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold, // Cambiado a bold normal para que se lea mejor
                      height: 1.2, // Un poco más de espacio entre líneas
                      letterSpacing: -0.2, // Menos apretado
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Subtítulo
                  Text(
                    'Cocina más gastando menos con ingredientes rebajados.',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.95),
                      fontSize: 14,
                      height: 1.4, // Mejor legibilidad
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            
            // Decoración visual a la derecha (Emojis superpuestos y círculo)
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                ),
                const Text('🥘', style: TextStyle(fontSize: 42)),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Text('⚡', style: TextStyle(fontSize: 14)),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// TU HOMEPAGE EXACTAMENTE IGUAL
// ==========================================
class HomePage extends StatefulWidget {
  final List<Producto> productos;
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

  @override
  void initState() {
    super.initState();
    _seleccionarProductosAleatorios();
  }

  @override
  void didUpdateWidget(HomePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.productos != oldWidget.productos) {
      _seleccionarProductosAleatorios();
    }
  }

  void _seleccionarProductosAleatorios() {
    final random = Random();

    // 1. Ofertas Flash (10 aleatorios con mostrar_oferta == true)
    final flashOfertas = widget.productos.where((p) => p.mostrarOferta).toList();
    flashOfertas.shuffle(random);
    _flashMostrar = flashOfertas.take(10).toList();

    // 2. Recomendados (Categoría aleatoria, excluyendo los que son oferta flash)
    final productosSinOferta = widget.productos.where((p) => !p.mostrarOferta).toList();

    final categoriasUnicas = productosSinOferta
        .map((p) => p.categoria)
        .where((c) => c.isNotEmpty)
        .toSet()
        .toList();

    if (categoriasUnicas.isNotEmpty) {
      _categoriaAleatoria = categoriasUnicas[random.nextInt(categoriasUnicas.length)];
      
      final productosDeCategoria = productosSinOferta
          .where((p) => p.categoria == _categoriaAleatoria)
          .toList();
      
      productosDeCategoria.shuffle(random);
      _recomendados = productosDeCategoria;
    } else {
      _categoriaAleatoria = '';
      _recomendados = [];
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
          onOpenCategories: widget.onOpenCategories,
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.only(bottom: 28),
            children: [
              const DeliveryBanner(),
              const SizedBox(height: 8),
              
              // ---> AQUI COLOCAMOS LA NUEVA PASTILLA VERDE <---
              RecipePromoBanner(onTap: widget.onOpenFlashRecipes),

              const SizedBox(height: 18),
              
              // Título clicable para ir a la pestaña de Ofertas Flash
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
              
              // Título clicable para abrir la pantalla de productos de esa categoría
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