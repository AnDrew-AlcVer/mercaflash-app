import 'package:flutter/material.dart';
import '../models/producto_model.dart';
import '../theme/app_theme.dart';
import 'ui_components.dart';

class CartItemTile extends StatelessWidget {
  final Producto producto;
  final int cantidad;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  const CartItemTile({
    super.key,
    required this.producto,
    required this.cantidad,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final bool esOferta = producto.mostrarOferta;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(14),
        // Si está en oferta, le ponemos un borde rojizo sutil para destacarlo en el carrito
        border: Border.all(color: esOferta ? AppTheme.red.withOpacity(0.3) : Colors.transparent, width: esOferta ? 1.5 : 0),
        boxShadow: const [BoxShadow(color: Color(0x0D000000), blurRadius: 8, offset: Offset(0, 4))],
      ),
      child: Row(
        children: [
          // Imagen del producto
          Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            clipBehavior: Clip.antiAlias,
            alignment: Alignment.center,
            child: producto.imagenUrl != null 
              ? Image.network(
                  producto.imagenUrl!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  errorBuilder: (context, error, stackTrace) => 
                    Text(producto.emoji, style: const TextStyle(fontSize: 34)),
                )
              : Text(producto.emoji, style: const TextStyle(fontSize: 34)),
          ),
          const SizedBox(width: 12),
          
          // Detalles del producto
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        producto.nombre, 
                        maxLines: 1, 
                        overflow: TextOverflow.ellipsis, 
                        style: const TextStyle(fontWeight: FontWeight.w900)
                      )
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
                          style: TextStyle(color: AppTheme.red, fontWeight: FontWeight.w900, fontSize: 9),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 3),
                
                // Zona de precios (Original vs Oferta)
                Row(
                  children: [
                    if (esOferta && producto.precioAnterior != null) ...[
                      Text(
                        '${producto.precioAnterior!.toStringAsFixed(2).replaceAll('.', ',')} €',
                        style: const TextStyle(
                          color: AppTheme.gray,
                          decoration: TextDecoration.lineThrough,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 6),
                    ],
                    Text(
                      '${producto.precioTexto} / ud.', 
                      style: TextStyle(
                        color: esOferta ? AppTheme.red : AppTheme.gray, 
                        fontWeight: esOferta ? FontWeight.w800 : FontWeight.normal,
                        fontSize: 12
                      )
                    ),
                  ],
                ),
                
                // Alertas de alérgenos
                if (producto.tieneAlertaAlergenos) ...[
                  const SizedBox(height: 5),
                  AllergenWarningBanner(
                    text: 'Contiene ${producto.alertaAlergenosTexto}',
                    compact: true,
                  ),
                ] else if (producto.tieneAlergenos) ...[
                  const SizedBox(height: 5),
                  AllergenTextLine(text: 'Alérgenos: ${producto.alergenosTexto}'),
                ],
              ],
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(width: 96, child: QuantityButton(cantidad: cantidad, onAdd: onAdd, onRemove: onRemove)),
        ],
      ),
    );
  }
}

// BARRA DE CHECKOUT CON DOBLE PRECIO
class CheckoutBar extends StatelessWidget {
  final double totalSinDescuentos;
  final double ahorroTotal;
  final double totalNeto;
  final VoidCallback onCheckout;

  const CheckoutBar({
    super.key,
    required this.totalSinDescuentos,
    required this.ahorroTotal,
    required this.totalNeto,
    required this.onCheckout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
      decoration: const BoxDecoration(
        color: AppTheme.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 18,
            offset: Offset(0, -6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total estimado:',
                    style: TextStyle(color: AppTheme.gray, fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  if (ahorroTotal > 0) ...[
                    const SizedBox(height: 2),
                    Text(
                      'Sin oferta: ${totalSinDescuentos.toStringAsFixed(2).replaceAll('.', ',')} €',
                      style: const TextStyle(
                        color: AppTheme.gray,
                        decoration: TextDecoration.lineThrough,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (ahorroTotal > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      margin: const EdgeInsets.only(bottom: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.greenLight,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Ahorras ${ahorroTotal.toStringAsFixed(2).replaceAll('.', ',')} €',
                        style: const TextStyle(color: AppTheme.green, fontWeight: FontWeight.w900, fontSize: 12),
                      ),
                    ),
                  Text(
                    '${totalNeto.toStringAsFixed(2).replaceAll('.', ',')} €',
                    style: const TextStyle(color: AppTheme.black, fontWeight: FontWeight.w900, fontSize: 24, height: 1.1),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          AnimatedTap(
            onTap: onCheckout,
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                color: AppTheme.green,
                borderRadius: BorderRadius.circular(26),
              ),
              alignment: Alignment.center,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Tramitar pedido',
                    style: TextStyle(
                      color: AppTheme.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.receipt_long_rounded, color: Colors.white, size: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

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

class CartNavIcon extends StatelessWidget {
  final int count;
  final bool selected;

  const CartNavIcon({super.key, required this.count, required this.selected});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(selected ? Icons.list_alt_rounded : Icons.list_alt_outlined),
        if (count > 0)
          Positioned(right: -8, top: -8, child: CartBubble(count: count)),
      ],
    );
  }
}

class CartBubble extends StatelessWidget {
  final int count;

  const CartBubble({super.key, required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 18,
      constraints: const BoxConstraints(minWidth: 18),
      padding: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(color: AppTheme.red, borderRadius: BorderRadius.circular(9)),
      alignment: Alignment.center,
      child: Text(
        count > 9 ? '9+' : '$count',
        style: const TextStyle(color: AppTheme.white, fontSize: 10, fontWeight: FontWeight.w900),
      ),
    );
  }
}