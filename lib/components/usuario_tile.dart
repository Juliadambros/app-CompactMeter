import 'package:flutter/material.dart';
import '../models/usuario_model.dart';
import '../theme/app_colors.dart';

class UsuarioTile extends StatelessWidget {
  final UsuarioModel usuario;

  const UsuarioTile({super.key, required this.usuario});

  @override
  Widget build(BuildContext context) {
    final bool isAdmin = usuario.tipoUsuario == 'admin';

    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor:
              isAdmin ? AppColors.azul : AppColors.verde,
          child: Icon(
            isAdmin ? Icons.admin_panel_settings : Icons.person,
            color: Colors.white,
          ),
        ),
        title: Text(usuario.nome),
        subtitle: Text(usuario.email),
        trailing: Chip(
          label: Text(
            isAdmin ? 'Administrador' : 'Usuário',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor:
              isAdmin ? AppColors.azul : AppColors.verde,
        ),
      ),
    );
  }
}
