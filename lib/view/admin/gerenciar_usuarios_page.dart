import 'package:app_compactmeter/components/usuario_tile.dart';
import 'package:flutter/material.dart';
import '../../models/usuario_model.dart';
import '../../service/usuario_service.dart';
import '../../theme/app_colors.dart';

class GerenciarUsuariosPage extends StatelessWidget {
  GerenciarUsuariosPage({super.key});

  final UsuarioService usuarioService = UsuarioService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fundo,
      appBar: AppBar(
        title: const Text('Gerenciar Usuários'),
        backgroundColor: AppColors.azul,
      ),
      body: FutureBuilder<List<UsuarioModel>>(
        future: usuarioService.listarUsuarios(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text('Erro ao carregar usuários'),
            );
          }

          final usuarios = snapshot.data ?? [];

          if (usuarios.isEmpty) {
            return const Center(
              child: Text('Nenhum usuário cadastrado'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: usuarios.length,
            itemBuilder: (context, index) {
              final usuario = usuarios[index];
              return UsuarioTile(usuario: usuario);
            },
          );
        },
      ),
    );
  }
}

