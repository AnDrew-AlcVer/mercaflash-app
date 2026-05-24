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
// 2. TU HOMEPAGE EXACTAMENTE IGUAL
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
              
              // Pastilla verde interactiva que lleva a las recetas en Flash
              PromoHeroCard(onTap: widget.onOpenFlashRecipes),

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