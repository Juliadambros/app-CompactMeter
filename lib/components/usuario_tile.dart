import 'package:app_compactmeter/view/admin/detalhes_usuario_page.dart';
import 'package:flutter/material.dart';
import '../models/usuario_model.dart';

class UsuarioTile extends StatelessWidget {
  final UsuarioModel usuario;

  const UsuarioTile({super.key, required this.usuario});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(usuario.nome),
        subtitle: Text(usuario.email),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DetalhesUsuarioPage(usuario: usuario),
            ),
          );
        },
      ),
    );
  }
}

