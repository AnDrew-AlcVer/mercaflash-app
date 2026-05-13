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
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [BoxShadow(color: Color(0x0D000000), blurRadius: 8, offset: Offset(0, 4))],
      ),
      child: Row(
        children: [
          Text(producto.emoji, style: const TextStyle(fontSize: 34)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(producto.nombre, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w900)),
                const SizedBox(height: 3),
                Text('${producto.precioTexto} / ud.', style: const TextStyle(color: AppTheme.gray, fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(width: 104, child: QuantityButton(cantidad: cantidad, onAdd: onAdd, onRemove: onRemove)),
        ],
      ),
    );
  }
}

class CheckoutBar extends StatelessWidget {
  final double total;

  const CheckoutBar({super.key, required this.total});

  @override
  Widget build(BuildContext context) {
    final totalTexto = '${total.toStringAsFixed(2).replaceAll('.', ',')} €';
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
      decoration: const BoxDecoration(
        color: AppTheme.white,
        boxShadow: [BoxShadow(color: Color(0x1A000000), blurRadius: 18, offset: Offset(0, -6))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Text('Total', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
              const Spacer(),
              Text(totalTexto, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
            ],
          ),
          const SizedBox(height: 10),
          AnimatedTap(
            onTap: () {},
            child: Container(
              height: 52,
              decoration: BoxDecoration(color: AppTheme.green, borderRadius: BorderRadius.circular(26)),
              alignment: Alignment.center,
              child: const Text(
                'Tramitar pedido',
                style: TextStyle(color: AppTheme.white, fontWeight: FontWeight.w900, fontSize: 16),
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