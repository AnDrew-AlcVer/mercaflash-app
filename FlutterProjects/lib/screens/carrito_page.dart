import 'package:flutter/material.dart';

import '../models/producto_model.dart';
import '../theme/app_theme.dart';
import '../widgets/ui_components.dart';

class CarritoPage extends StatelessWidget {
  final List<Producto> productos;
  final Map<String, int> carrito;
  final double total;
  final bool sesionIniciada;
  final ValueChanged<Producto> onAdd;
  final ValueChanged<Producto> onRemove;
  final VoidCallback onClear;
  final VoidCallback onContinueShopping;
  final VoidCallback onRequireLogin;
  final VoidCallback onGoToProducts;

  const CarritoPage({
    super.key,
    required this.productos,
    required this.carrito,
    required this.total,
    required this.sesionIniciada,
    required this.onAdd,
    required this.onRemove,
    required this.onClear,
    required this.onContinueShopping,
    required this.onRequireLogin,
    required this.onGoToProducts,
  });

  // TICKET DE COMPRA REDISEÑADO Y SIN DESBORDAMIENTOS
  void _mostrarTicketCompra(BuildContext context, List<Producto> productosCarrito, double totalSinDescuentos, double ahorroTotal) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Colors.white,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min, // Se ajusta al contenido
              children: [
                // 1. Cabecera del ticket
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(color: AppTheme.greenLight, shape: BoxShape.circle),
                  child: const Icon(Icons.receipt_long_rounded, color: AppTheme.green, size: 32),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Resumen de tu pedido',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: AppTheme.black),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Revisa los artículos antes de pagar',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppTheme.gray, fontSize: 13),
                ),
                const SizedBox(height: 20),
                const _DashedLine(),
                const SizedBox(height: 16),
                
                // 2. Lista de productos (con Flexible y Scroll para evitar overflows)
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      children: productosCarrito.map((producto) {
                        final cantidad = carrito[producto.id] ?? 0;
                        final precioTotalItem = producto.precio * cantidad;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${cantidad}x', style: const TextStyle(fontWeight: FontWeight.w800, color: AppTheme.green)),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      producto.nombre,
                                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'A ${producto.precioTexto} / ud.',
                                      style: const TextStyle(color: AppTheme.gray, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                '${precioTotalItem.toStringAsFixed(2).replaceAll('.', ',')} €',
                                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                
                const SizedBox(height: 4),
                const _DashedLine(),
                const SizedBox(height: 16),

                // 3. Desglose de totales
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Subtotal:', style: TextStyle(color: AppTheme.gray, fontSize: 14)),
                    Text('${totalSinDescuentos.toStringAsFixed(2).replaceAll('.', ',')} €', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  ],
                ),
                if (ahorroTotal > 0) ...[
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Descuento aplicado:', style: TextStyle(color: AppTheme.red, fontWeight: FontWeight.w600, fontSize: 14)),
                      Text('- ${ahorroTotal.toStringAsFixed(2).replaceAll('.', ',')} €', style: const TextStyle(color: AppTheme.red, fontWeight: FontWeight.w800, fontSize: 14)),
                    ],
                  ),
                ],
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: AppTheme.greenLight, borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total a pagar', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppTheme.green)),
                      Text('${total.toStringAsFixed(2).replaceAll('.', ',')} €', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: AppTheme.green)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // 4. Botón de pago
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // Cierra el ticket
                      onClear(); // <--- AQUÍ VACIAR EL CARRITO TRAS "PAGAR"
                      ScaffoldMessenger.of(context)
                        ..hideCurrentSnackBar()
                        ..showSnackBar(
                          SnackBar(
                            content: const Text('¡Pedido realizado con éxito!', style: TextStyle(fontWeight: FontWeight.bold)),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: AppTheme.green,
                            duration: const Duration(seconds: 2),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                        );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.green,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    child: const Text('Pagar ahora', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _tramitarPedido(BuildContext context, List<Producto> productosCarrito, double totalSinDescuentos, double ahorroTotal) {
    if (!sesionIniciada) {
      onRequireLogin();
      return;
    }
    _mostrarTicketCompra(context, productosCarrito, totalSinDescuentos, ahorroTotal);
  }

  @override
  Widget build(BuildContext context) {
    final productosCarrito = productos
        .where((producto) => carrito.containsKey(producto.id))
        .toList();

    // Lógica dinámica para totales
    double totalSinDescuentos = 0.0;
    for (final producto in productosCarrito) {
      final cantidad = carrito[producto.id] ?? 0;
      final precioOriginalBase = producto.precioAnterior ?? producto.precio;
      totalSinDescuentos += precioOriginalBase * cantidad;
    }
    final double ahorroTotal = totalSinDescuentos - total;

    return Column(
      children: [
        const SimpleHeader(title: 'Mi Carrito'),
        Expanded(
          child: productosCarrito.isEmpty
              ? EmptyState(
                  icon: Icons.shopping_basket_outlined,
                  title: 'Tu carrito está vacío',
                  subtitle: 'Descubre nuestros productos y añade lo que necesites.',
                  actionText: 'Ir a la tienda',
                  onAction: onGoToProducts,
                )
              : ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${productosCarrito.length} artículos',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                        ),
                        TextButton.icon(
                          onPressed: onClear,
                          icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppTheme.gray),
                          label: const Text('Vaciar', style: TextStyle(color: AppTheme.gray)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    
                    ...productosCarrito.map(
                      (producto) => _CustomCartItemTile(
                        producto: producto,
                        cantidad: carrito[producto.id] ?? 0,
                        onAdd: () => onAdd(producto),
                        onRemove: () => onRemove(producto),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    AnimatedTap(
                      onTap: onContinueShopping,
                      child: Container(
                        height: 52,
                        decoration: BoxDecoration(
                          color: AppTheme.greenLight,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          'Añadir más productos',
                          style: TextStyle(color: AppTheme.green, fontWeight: FontWeight.w800, fontSize: 15),
                        ),
                      ),
                    ),
                  ],
                ),
        ),
        
        // BARRA INFERIOR DE PAGO (Limpia y moderna)
        if (productosCarrito.isNotEmpty)
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5))],
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Total a pagar', style: TextStyle(color: AppTheme.gray, fontSize: 13, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 2),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${total.toStringAsFixed(2).replaceAll('.', ',')} €',
                              style: const TextStyle(color: AppTheme.black, fontWeight: FontWeight.w900, fontSize: 26, height: 1.1),
                            ),
                          ],
                        ),
                        if (ahorroTotal > 0) ...[
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                            decoration: BoxDecoration(color: AppTheme.green.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                            child: Text(
                              'Te ahorras ${ahorroTotal.toStringAsFixed(2).replaceAll('.', ',')} €',
                              style: const TextStyle(color: AppTheme.green, fontWeight: FontWeight.w800, fontSize: 11),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  
                  ElevatedButton(
                    onPressed: () => _tramitarPedido(context, productosCarrito, totalSinDescuentos, ahorroTotal),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.green,
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: const Text('Tramitar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

// =========================================================================
// CELDAS DEL CARRITO 
// =========================================================================
class _CustomCartItemTile extends StatelessWidget {
  final Producto producto;
  final int cantidad;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  const _CustomCartItemTile({
    required this.producto,
    required this.cantidad,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final bool esOferta = producto.mostrarOferta;
    final double precioTotalArticulo = producto.precio * cantidad;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: esOferta ? AppTheme.border.withOpacity(0.8) : AppTheme.border.withOpacity(0.4), width: 1.5),
        boxShadow: const [BoxShadow(color: Color(0x05000000), blurRadius: 10, offset: Offset(0, 4))],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Imagen del producto
              Container(
                height: 55,
                width: 55,
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(10),
                ),
                clipBehavior: Clip.antiAlias,
                child: producto.imagenUrl != null && producto.imagenUrl!.isNotEmpty
                    ? Image.network(
                        producto.imagenUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Center(child: Text(producto.emoji, style: const TextStyle(fontSize: 28))),
                      )
                    : Center(child: Text(producto.emoji, style: const TextStyle(fontSize: 28))),
              ),
              const SizedBox(width: 14),
              
              // Textos y etiqueta de oferta
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            producto.nombre,
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppTheme.black, height: 1.2),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (esOferta)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            margin: const EdgeInsets.only(left: 6),
                            decoration: BoxDecoration(
                              color: AppTheme.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'OFERTA',
                              style: TextStyle(color: AppTheme.red, fontWeight: FontWeight.w900, fontSize: 10),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    
                    // Precios unitarios y totales
                    Row(
                      children: [
                        if (esOferta && producto.precioAnterior != null) ...[
                          Text(
                            producto.precioAnteriorTexto,
                            style: const TextStyle(color: AppTheme.gray, decoration: TextDecoration.lineThrough, fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(width: 6),
                        ],
                        Text(
                          '${producto.precioTexto} / ud.',
                          style: TextStyle(color: esOferta ? AppTheme.red : AppTheme.gray, fontWeight: esOferta ? FontWeight.w800 : FontWeight.w600, fontSize: 13),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Divider(color: AppTheme.border, height: 1),
          ),
          
          // Fila inferior con el botón de cantidad y el total del artículo
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total: ${precioTotalArticulo.toStringAsFixed(2).replaceAll('.', ',')} €',
                style: const TextStyle(color: AppTheme.black, fontWeight: FontWeight.w900, fontSize: 14),
              ),
              // RECUPERADO: Usamos exactamente tu QuantityButton horizontal
              SizedBox(
                width: 96, 
                child: QuantityButton(
                  cantidad: cantidad, 
                  onAdd: onAdd, 
                  onRemove: onRemove
                )
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// =========================================================================
// WIDGET AUXILIAR: LÍNEA PUNTEADA PARA EL TICKET
// =========================================================================
class _DashedLine extends StatelessWidget {
  const _DashedLine();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final boxWidth = constraints.constrainWidth();
        const dashWidth = 6.0;
        const dashHeight = 1.5;
        final dashCount = (boxWidth / (2 * dashWidth)).floor();
        return Flex(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          direction: Axis.horizontal,
          children: List.generate(dashCount, (_) {
            return const SizedBox(
              width: dashWidth,
              height: dashHeight,
              child: DecoratedBox(decoration: BoxDecoration(color: AppTheme.border)),
            );
          }),
        );
      },
    );
  }
}

// =========================================================================
// WIDGET QUANTITY BUTTON (Recuperado de tu diseño original)
// =========================================================================
class QuantityButton extends StatelessWidget {
  final int cantidad;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  const QuantityButton({
    super.key,
    required this.cantidad,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    if (cantidad == 0) {
      return AnimatedTap(
        onTap: onAdd,
        child: Container(
          height: 32,
          decoration: BoxDecoration(
            color: AppTheme.white,
            border: Border.all(color: AppTheme.greenDark),
            borderRadius: BorderRadius.circular(18),
          ),
          alignment: Alignment.center,
          child: const Text(
            'Añadir',
            style: TextStyle(color: AppTheme.greenDark, fontWeight: FontWeight.w900, fontSize: 13),
          ),
        ),
      );
    }

    return Container(
      height: 32,
      decoration: BoxDecoration(
        color: AppTheme.green,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: onRemove,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints.tightFor(width: 34, height: 32),
            icon: const Icon(Icons.remove_rounded, color: AppTheme.white, size: 18),
          ),
          Text(
            cantidad.toString(),
            style: const TextStyle(color: AppTheme.white, fontWeight: FontWeight.w900),
          ),
          IconButton(
            onPressed: onAdd,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints.tightFor(width: 34, height: 32),
            icon: const Icon(Icons.add_rounded, color: AppTheme.white, size: 18),
          ),
        ],
      ),
    );
  }
}