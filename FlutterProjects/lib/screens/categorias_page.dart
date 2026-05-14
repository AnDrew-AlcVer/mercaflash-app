import 'package:flutter/material.dart';

import '../models/producto_model.dart';
import '../theme/app_theme.dart';
import '../widgets/product_cards.dart';
import '../widgets/ui_components.dart';

class CategoriasPage extends StatefulWidget {
  final List<CategoriaMercadona> categorias;
  final List<Producto> productos;
  final Map<String, int> carrito;
  final ValueChanged<CategoriaMercadona> onOpenCategory;
  final ValueChanged<Producto> onAdd;
  final ValueChanged<Producto> onRemove;

  const CategoriasPage({
    super.key,
    required this.categorias,
    required this.productos,
    required this.carrito,
    required this.onOpenCategory,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  State<CategoriasPage> createState() => _CategoriasPageState();
}

class _CategoriasPageState extends State<CategoriasPage> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final productosFiltrados = widget.productos.where((producto) {
      final texto = '${producto.nombre} ${producto.categoria} ${producto.subcategoria}'
          .toLowerCase();
      return texto.contains(_query.toLowerCase());
    }).toList();

    return Column(
      children: [
        const SimpleHeader(title: 'Categorías'),
        _SearchBox(
          query: _query,
          onChanged: (value) => setState(() => _query = value),
          onClear: () => setState(() => _query = ''),
        ),
        Expanded(
          child: _query.trim().isEmpty
              ? _CategoryList(
                  categorias: widget.categorias,
                  onOpenCategory: widget.onOpenCategory,
                )
              : _SearchResults(
                  productos: productosFiltrados,
                  carrito: widget.carrito,
                  onAdd: widget.onAdd,
                  onRemove: widget.onRemove,
                ),
        ),
      ],
    );
  }
}

class _SearchBox extends StatelessWidget {
  final String query;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const _SearchBox({
    required this.query,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      child: TextField(
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: 'Buscar productos',
          prefixIcon: const Icon(Icons.search_rounded),
          suffixIcon: query.isEmpty
              ? null
              : IconButton(
                  onPressed: onClear,
                  icon: const Icon(Icons.close_rounded),
                ),
          filled: true,
          fillColor: const Color(0xFFF1F1F1),
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(12),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        ),
      ),
    );
  }
}

class _CategoryList extends StatelessWidget {
  final List<CategoriaMercadona> categorias;
  final ValueChanged<CategoriaMercadona> onOpenCategory;

  const _CategoryList({
    required this.categorias,
    required this.onOpenCategory,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
      itemCount: categorias.length,
      separatorBuilder: (_, __) => const Divider(height: 1, color: AppTheme.border),
      itemBuilder: (context, index) {
        final categoria = categorias[index];
        final esFlash = categoria.id == 'flash';

        return AnimatedTap(
          onTap: () => onOpenCategory(categoria),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            color: AppTheme.white,
            child: Row(
              children: [
                Text(categoria.emoji, style: const TextStyle(fontSize: 24)),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    categoria.nombre,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: esFlash ? FontWeight.w900 : FontWeight.w600,
                      color: esFlash ? AppTheme.green : AppTheme.black,
                    ),
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: AppTheme.gray),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SearchResults extends StatelessWidget {
  final List<Producto> productos;
  final Map<String, int> carrito;
  final ValueChanged<Producto> onAdd;
  final ValueChanged<Producto> onRemove;

  const _SearchResults({
    required this.productos,
    required this.carrito,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    if (productos.isEmpty) {
      return const EmptyState(
        icon: Icons.search_off_rounded,
        title: 'No hemos encontrado productos',
        subtitle: 'Prueba con otro nombre o revisa las categorías disponibles.',
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Text(
            '${productos.length} resultados',
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
          ),
        ),
        ...productos.map(
          (producto) => CompactProductTile(
            producto: producto,
            cantidad: carrito[producto.id] ?? 0,
            onAdd: () => onAdd(producto),
            onRemove: () => onRemove(producto),
          ),
        ),
      ],
    );
  }
}
