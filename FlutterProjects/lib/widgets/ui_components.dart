import 'package:flutter/material.dart';
import '../models/producto_model.dart';
import '../theme/app_theme.dart';
import 'cart_widgets.dart';

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
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      color: AppTheme.white,
      child: Row(
        children: [
          IconButton(
            onPressed: onOpenCategories,
            icon: const Icon(Icons.menu_rounded, color: AppTheme.black),
          ),
          const Expanded(
            child: Text(
              'MERCADONA',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.green,
                fontWeight: FontWeight.w900,
                fontSize: 22,
                letterSpacing: 0.5,
              ),
            ),
          ),
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                onPressed: onOpenCart,
                icon: const Icon(Icons.shopping_cart_outlined, color: AppTheme.black),
              ),
              if (totalUnidades > 0)
                Positioned(
                  right: 5,
                  top: 5,
                  child: CartBubble(count: totalUnidades),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class SimpleHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onBack;

  const SimpleHeader({super.key, required this.title, this.onBack});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: const BoxDecoration(
        color: AppTheme.white,
        border: Border(bottom: BorderSide(color: AppTheme.border)),
      ),
      child: Row(
        children: [
          if (onBack != null)
            IconButton(
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.green),
            )
          else
            const SizedBox(width: 48),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}

class DeliveryBanner extends StatelessWidget {
  const DeliveryBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
      child: AnimatedTap(
        onTap: () {},
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F1F1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Row(
            children: [
              Icon(Icons.location_on_outlined, color: AppTheme.green, size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Añade tu dirección para conocer la próxima entrega disponible',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: AppTheme.gray),
            ],
          ),
        ),
      ),
    );
  }
}

class PromoHeroCard extends StatelessWidget {
  final VoidCallback onTap;

  const PromoHeroCard({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 14),
      child: AnimatedTap(
        onTap: onTap,
        child: Container(
          height: 154,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: const LinearGradient(
              colors: [Color(0xFF009639), Color(0xFF0BBF61)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: const [
              BoxShadow(color: Color(0x22009639), blurRadius: 18, offset: Offset(0, 8)),
            ],
          ),
          child: Stack(
            children: [
              const Positioned(
                right: 12,
                bottom: 8,
                child: Text('🥛🥬🍗', style: TextStyle(fontSize: 52)),
              ),
              Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppTheme.white.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Text(
                        'Nuevo apartado',
                        style: TextStyle(color: AppTheme.white, fontWeight: FontWeight.w900),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Ahorra antes de que caduque',
                      style: TextStyle(
                        color: AppTheme.white,
                        fontSize: 23,
                        fontWeight: FontWeight.w900,
                        height: 1.05,
                      ),
                    ),
                    const Spacer(),
                    const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Ver productos próximos a caducar',
                          style: TextStyle(color: AppTheme.white, fontWeight: FontWeight.w900),
                        ),
                        SizedBox(width: 4),
                        Icon(Icons.arrow_forward_rounded, color: AppTheme.white, size: 18),
                      ],
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

class SectionTitle extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool compact;

  const SectionTitle({super.key, required this.title, this.subtitle}) : compact = false;

  const SectionTitle.compact({super.key, required this.title})
      : subtitle = null,
        compact = true;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(18, compact ? 8 : 18, 18, compact ? 12 : 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right_rounded, size: 22),
            ],
          ),
          if (subtitle != null)
            Text(
              subtitle!,
              style: const TextStyle(color: AppTheme.gray, fontSize: 13),
            ),
        ],
      ),
    );
  }
}

class InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const InfoChip({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppTheme.gray),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(color: AppTheme.gray, fontSize: 12, fontWeight: FontWeight.w700)),
      ],
    );
  }
}

class AccountRow extends StatelessWidget {
  final IconData icon;
  final String title;

  const AccountRow({super.key, required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return AnimatedTap(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 17),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppTheme.border)),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.gray, size: 21),
            const SizedBox(width: 14),
            Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w700))),
            const Icon(Icons.chevron_right_rounded, color: AppTheme.gray),
          ],
        ),
      ),
    );
  }
}

class LoginField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool obscure;

  const LoginField({
    super.key,
    required this.controller,
    required this.label,
    this.obscure = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: AppTheme.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppTheme.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppTheme.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppTheme.green, width: 1.5),
          ),
        ),
      ),
    );
  }
}

class IngredientRow extends StatelessWidget {
  final IngredienteReceta ingrediente;

  const IngredientRow({super.key, required this.ingrediente});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            ingrediente.disponible ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
            color: ingrediente.disponible ? AppTheme.green : AppTheme.gray,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              ingrediente.cantidad.isEmpty ? ingrediente.nombre : '${ingrediente.nombre} (${ingrediente.cantidad})',
              style: TextStyle(
                fontWeight: ingrediente.disponible ? FontWeight.w900 : FontWeight.w600,
                color: ingrediente.disponible ? AppTheme.green : AppTheme.black,
              ),
            ),
          ),
          if (ingrediente.caducidadTexto != null)
            Text(
              ingrediente.caducidadTexto!,
              style: const TextStyle(color: AppTheme.orange, fontWeight: FontWeight.w900, fontSize: 12),
            ),
        ],
      ),
    );
  }
}

class StepRow extends StatelessWidget {
  final int numero;
  final String texto;

  const StepRow({super.key, required this.numero, required this.texto});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 15,
            backgroundColor: AppTheme.greenLight,
            child: Text('$numero', style: const TextStyle(color: AppTheme.green, fontWeight: FontWeight.w900)),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(texto, style: const TextStyle(height: 1.35))),
        ],
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionText;
  final VoidCallback? onAction;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionText,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 58, color: AppTheme.green),
            const SizedBox(height: 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppTheme.gray, height: 1.35),
            ),
            if (actionText != null && onAction != null) ...[
              const SizedBox(height: 18),
              AnimatedTap(
                onTap: onAction,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
                  decoration: BoxDecoration(
                    color: AppTheme.green,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Text(
                    actionText!,
                    style: const TextStyle(
                      color: AppTheme.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class AnimatedTap extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;

  const AnimatedTap({super.key, required this.child, this.onTap});

  @override
  State<AnimatedTap> createState() => _AnimatedTapState();
}

class _AnimatedTapState extends State<AnimatedTap> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap?.call();
      },
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1,
        duration: const Duration(milliseconds: 110),
        curve: Curves.easeOut,
        child: AnimatedOpacity(
          opacity: _pressed ? 0.82 : 1,
          duration: const Duration(milliseconds: 110),
          child: widget.child,
        ),
      ),
    );
  }
}