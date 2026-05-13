import 'package:flutter/material.dart';
import '../models/producto_model.dart';
import '../widgets/product_cards.dart';

class BuscarPage extends StatefulWidget {
  final List<Producto> productos;
  final Map<String, int> carrito;
  final ValueChanged<Producto> onAdd;
  final ValueChanged<Producto> onRemove;

  const BuscarPage({
    super.key,
    required this.productos,
    required this.carrito,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  State<BuscarPage> createState() => _BuscarPageState();
}

class _BuscarPageState extends State<BuscarPage> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final filtrados = widget.productos.where((producto) {
      final texto = '${producto.nombre} ${producto.categoria}'.toLowerCase();
      return texto.contains(_query.toLowerCase());
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  autofocus: false,
                  onChanged: (value) => setState(() => _query = value),
                  decoration: InputDecoration(
                    hintText: 'Buscar productos',
                    prefixIcon: const Icon(Icons.search_rounded),
                    filled: true,
                    fillColor: const Color(0xFFF1F1F1),
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                ),
              ),
              if (_query.isNotEmpty)
                TextButton(
                  onPressed: () => setState(() => _query = ''),
                  child: const Text('Cancelar'),
                ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              const Text(
                'Descubrir',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 12),
              ...filtrados.map(
                (producto) => CompactProductTile(
                  producto: producto,
                  cantidad: widget.carrito[producto.id] ?? 0,
                  onAdd: () => widget.onAdd(producto),
                  onRemove: () => widget.onRemove(producto),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}