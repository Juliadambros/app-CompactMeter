import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class DeleteButton extends StatelessWidget {
  final VoidCallback onConfirm;
  final String titulo;
  final String mensagem;

  const DeleteButton({
    super.key,
    required this.onConfirm,
    this.titulo = 'Confirmar exclusão',
    this.mensagem = 'Tem certeza que deseja excluir este item?',
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.delete),
      color: AppColors.vermelho,
      onPressed: () => _mostrarConfirmacao(context),
    );
  }

  void _mostrarConfirmacao(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(titulo),
        content: Text(mensagem),
        actions: [
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.vermelho,
            ),
            child: const Text('Excluir'),
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
          ),
        ],
      ),
    );
  }
}
