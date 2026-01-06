import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AppHeader extends StatelessWidget {
  final String titulo;
  final String? subtitulo;

  const AppHeader({
    super.key,
    required this.titulo,
    this.subtitulo,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          titulo,
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: AppColors.azul,
          ),
        ),
        if (subtitulo != null) ...[
          const SizedBox(height: 8),
          Text(
            subtitulo!,
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ],
    );
  }
}
