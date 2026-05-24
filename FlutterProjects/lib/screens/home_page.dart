import 'dart:math';
import 'package:flutter/material.dart';

import '../models/producto_model.dart';
import '../widgets/product_cards.dart';
import '../widgets/ui_components.dart';

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
  
  // NUEVO: Callback para navegar a la categoría específica
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
    required this.onOpenCategory, // Lo añadimos al constructor
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

    final flashOfertas = widget.productos.where((p) => p.mostrarOferta).toList();
    flashOfertas.shuffle(random);
    _flashMostrar = flashOfertas.take(10).toList();

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
              
              PromoHeroCard(onTap: widget.onOpenFlashRecipes),

              const SizedBox(height: 18),
              
              // Hacemos el título clicable para ir arriba del todo a Flash
              GestureDetector(
                onTap: widget.onOpenFlash,
                behavior: HitTestBehavior.opaque, // Para que funcione el click en todo el área
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
              
              // Hacemos el título clicable para abrir la pantalla de esta categoría específica
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