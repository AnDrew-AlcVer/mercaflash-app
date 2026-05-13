import 'package:flutter/material.dart';
import '../models/producto_model.dart';
import '../theme/app_theme.dart';
import '../widgets/ui_components.dart';

class CategoriasPage extends StatelessWidget {
  final List<CategoriaMercadona> categorias;
  final ValueChanged<CategoriaMercadona> onOpenCategory;

  const CategoriasPage({
    super.key,
    required this.categorias,
    required this.onOpenCategory,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SimpleHeader(title: 'Categorías'),
        Expanded(
          child: ListView.separated(
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
          ),
        ),
      ],
    );
  }
}