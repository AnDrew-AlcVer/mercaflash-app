import 'package:flutter/material.dart';

import '../models/producto_model.dart';
import '../theme/app_theme.dart';
import '../widgets/ui_components.dart';

class DetalleRecetaPage extends StatefulWidget {
  final Receta receta;
  final List<Producto> productos;
  final Map<String, int> carrito;
  final VoidCallback onBack;
  final ValueChanged<List<Producto>> onAddProducts;

  const DetalleRecetaPage({
    super.key,
    required this.receta,
    required this.productos,
    required this.carrito,
    required this.onBack,
    required this.onAddProducts,
  });

  @override
  State<DetalleRecetaPage> createState() => _DetalleRecetaPageState();
}

class _DetalleRecetaPageState extends State<DetalleRecetaPage> {
  final Set<String> _seleccionados = {};

  @override
  Widget build(BuildContext context) {
    final ingredientesComprables = _ingredientesConProducto();

    return Column(
      children: [
        SimpleHeader(title: 'Receta', onBack: widget.onBack),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
            children: [
              // CABECERA CON IMAGEN (Sustituye al emoji)
              Container(
                height: 200, // Aumentado un poco para que luzca más la foto
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppTheme.greenLight,
                  borderRadius: BorderRadius.circular(22),
                ),
                clipBehavior: Clip.antiAlias, // Obliga a la imagen a ser redondeada
                alignment: Alignment.center,
                child: widget.receta.imagenUrl != null && widget.receta.imagenUrl!.isNotEmpty
                    ? Image.network(
                        widget.receta.imagenUrl!,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                        // Si la imagen falla por cualquier motivo, sale el emoji de respaldo
                        errorBuilder: (context, error, stackTrace) => 
                          Text(widget.receta.emoji, style: const TextStyle(fontSize: 76)),
                        // Indicador de carga mientras baja la foto
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const Center(child: CircularProgressIndicator());
                        },
                      )
                    : Text(widget.receta.emoji, style: const TextStyle(fontSize: 76)),
              ),
              const SizedBox(height: 18),
              Text(
                widget.receta.titulo,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              Text(
                widget.receta.descripcion,
                style: const TextStyle(color: AppTheme.gray, height: 1.35),
              ),
              if (widget.receta.tieneAlertaAlergenos) ...[
                const SizedBox(height: 12),
                AllergenWarningBanner(
                  text: 'Esta receta contiene ${widget.receta.alertaAlergenosTexto}, marcado en tu perfil.',
                ),
              ] else if (widget.receta.tieneAlergenos) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.greenLight,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: AllergenTextLine(text: 'Alérgenos de la receta: ${widget.receta.alergenosTexto}'),
                ),
              ],
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  InfoChip(icon: Icons.schedule_rounded, label: '${widget.receta.tiempoMinutos} min'),
                  InfoChip(icon: Icons.people_outline_rounded, label: '${widget.receta.raciones} raciones'),
                  InfoChip(icon: Icons.local_fire_department_outlined, label: widget.receta.dificultad),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Ingredientes',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              ...widget.receta.ingredientes.map(
                (ingrediente) => IngredientRow(ingrediente: ingrediente),
              ),
              const SizedBox(height: 24),
              _MissingIngredientsBox(
                ingredientes: ingredientesComprables,
                seleccionados: _seleccionados,
                carrito: widget.carrito,
                onToggle: _toggleProducto,
                onAddSelected: _addSelectedProducts,
              ),
              const SizedBox(height: 24),
              const Text(
                'Pasos',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 12),
              ...widget.receta.pasos.asMap().entries.map(
                    (entry) => StepRow(numero: entry.key + 1, texto: entry.value),
                  ),
            ],
          ),
        ),
      ],
    );
  }

  List<_IngredienteComprable> _ingredientesConProducto() {
    final resultado = <_IngredienteComprable>[];

    for (final ingrediente in widget.receta.ingredientes) {
      final producto = _buscarProductoParaIngrediente(ingrediente.nombre);
      if (producto != null) {
        resultado.add(_IngredienteComprable(ingrediente: ingrediente, producto: producto));
      }
    }

    return resultado;
  }

  Producto? _buscarProductoParaIngrediente(String nombreIngrediente) {
    final nombre = nombreIngrediente.toLowerCase().trim();
    if (nombre.isEmpty) return null;

    for (final producto in widget.productos) {
      final nombreProducto = producto.nombre.toLowerCase();
      if (nombreProducto.contains(nombre) || nombre.contains(nombreProducto)) {
        return producto;
      }
    }

    final primeraPalabra = nombre.split(' ').first;
    for (final producto in widget.productos) {
      if (producto.nombre.toLowerCase().contains(primeraPalabra)) {
        return producto;
      }
    }

    return null;
  }

  void _toggleProducto(Producto producto, bool seleccionado) {
    setState(() {
      if (seleccionado) {
        _seleccionados.add(producto.id);
      } else {
        _seleccionados.remove(producto.id);
      }
    });
  }

  void _addSelectedProducts() {
    final productos = widget.productos
        .where((producto) => _seleccionados.contains(producto.id))
        .toList();

    widget.onAddProducts(productos);

    if (productos.isNotEmpty) {
      setState(_seleccionados.clear);
    }
  }
}

class _IngredienteComprable {
  final IngredienteReceta ingrediente;
  final Producto producto;

  const _IngredienteComprable({
    required this.ingrediente,
    required this.producto,
  });
}

class _MissingIngredientsBox extends StatelessWidget {
  final List<_IngredienteComprable> ingredientes;
  final Set<String> seleccionados;
  final Map<String, int> carrito;
  final void Function(Producto producto, bool seleccionado) onToggle;
  final VoidCallback onAddSelected;

  const _MissingIngredientsBox({
    required this.ingredientes,
    required this.seleccionados,
    required this.carrito,
    required this.onToggle,
    required this.onAddSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (ingredientes.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.greenLight,
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Text(
          'No hemos encontrado productos vinculados a esta receta para añadirlos automáticamente al carrito.',
          style: TextStyle(color: AppTheme.green, fontWeight: FontWeight.w800, height: 1.35),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(color: Color(0x10000000), blurRadius: 12, offset: Offset(0, 5)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ingredientes que te faltan',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 4),
          const Text(
            'Márcalos y añádelos al carrito para hacer la receta más fácil.',
            style: TextStyle(color: AppTheme.gray, height: 1.3),
          ),
          const SizedBox(height: 12),
          ...ingredientes.map((item) {
            final yaEnCarrito = carrito.containsKey(item.producto.id);
            final checked = seleccionados.contains(item.producto.id) || yaEnCarrito;

            return CheckboxListTile(
              value: checked,
              onChanged: yaEnCarrito
                  ? null
                  : (value) => onToggle(item.producto, value ?? false),
              activeColor: AppTheme.green,
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              title: Text(
                item.ingrediente.nombre,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: yaEnCarrito ? AppTheme.green : AppTheme.black,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    yaEnCarrito
                        ? 'Ya está en tu carrito'
                        : item.ingrediente.cantidad.isEmpty
                            ? item.producto.precioTexto
                            : '${item.ingrediente.cantidad} · ${item.producto.precioTexto}',
                  ),
                  if (item.producto.tieneAlertaAlergenos) ...[
                    const SizedBox(height: 5),
                    AllergenWarningBanner(
                      text: 'Contiene ${item.producto.alertaAlergenosTexto}',
                      compact: true,
                    ),
                  ] else if (item.producto.tieneAlergenos) ...[
                    const SizedBox(height: 5),
                    AllergenTextLine(text: 'Alérgenos: ${item.producto.alergenosTexto}'),
                  ],
                ],
              ),
            );
          }),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: seleccionados.isEmpty ? null : onAddSelected,
              icon: const Icon(Icons.add_shopping_cart_rounded),
              label: const Text('Añadir productos seleccionados'),
            ),
          ),
        ],
      ),
    );
  }
}