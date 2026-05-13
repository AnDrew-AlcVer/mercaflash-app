import 'package:flutter/material.dart';
import '../models/producto_model.dart';
import '../theme/app_theme.dart';
import '../widgets/ui_components.dart';

class DetalleRecetaPage extends StatelessWidget {
  final Receta receta;
  final VoidCallback onBack;

  const DetalleRecetaPage({
    super.key,
    required this.receta,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SimpleHeader(title: 'Receta', onBack: onBack),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
            children: [
              Container(
                height: 170,
                decoration: BoxDecoration(
                  color: AppTheme.greenLight,
                  borderRadius: BorderRadius.circular(22),
                ),
                alignment: Alignment.center,
                child: Text(receta.emoji, style: const TextStyle(fontSize: 76)),
              ),
              const SizedBox(height: 18),
              Text(
                receta.titulo,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              Text(
                receta.descripcion,
                style: const TextStyle(color: AppTheme.gray, height: 1.35),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  InfoChip(icon: Icons.schedule_rounded, label: '${receta.tiempoMinutos} min'),
                  InfoChip(icon: Icons.people_outline_rounded, label: '${receta.raciones} raciones'),
                  InfoChip(icon: Icons.local_fire_department_outlined, label: receta.dificultad),
                ],
              ),
              const SizedBox(height: 24),
              const Text('Ingredientes', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              ...receta.ingredientes.map((ingrediente) => IngredientRow(ingrediente: ingrediente)),
              const SizedBox(height: 22),
              const Text('Pasos', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
              const SizedBox(height: 12),
              ...receta.pasos.asMap().entries.map(
                    (entry) => StepRow(numero: entry.key + 1, texto: entry.value),
                  ),
            ],
          ),
        ),
      ],
    );
  }
}