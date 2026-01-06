import 'package:flutter/material.dart';
import '../../service/auth_service.dart';
import '../../theme/app_colors.dart';

class HomeUsuario extends StatelessWidget {
  const HomeUsuario({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();

    return Scaffold(
      backgroundColor: AppColors.fundo,
      appBar: AppBar(
        title: const Text('CompactMeter'),
        backgroundColor: AppColors.azul,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
            onPressed: () async {
              await authService.sair();
              if (!context.mounted) return;
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bem-vindo 👋',
              style: Theme.of(context).textTheme.headlineSmall,
            ),

            const SizedBox(height: 8),

            const Text(
              'Aqui será possível acompanhar os dados coletados pelo CompactMeter.',
            ),

            const SizedBox(height: 32),

            _CardFuncionalidade(
              icon: Icons.agriculture,
              titulo: 'Dados do Trator',
              descricao: 'Visualizar medições do sensor',
            ),

            _CardFuncionalidade(
              icon: Icons.calculate,
              titulo: 'Cálculos',
              descricao: 'Solicitar cálculos',
            ),

            _CardFuncionalidade(
              icon: Icons.history,
              titulo: 'Histórico',
              descricao: 'Ver registros anteriores',
            ),
          ],
        ),
      ),
    );
  }
}

class _CardFuncionalidade extends StatelessWidget {
  final IconData icon;
  final String titulo;
  final String descricao;

  const _CardFuncionalidade({
    required this.icon,
    required this.titulo,
    required this.descricao,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 3,
      child: ListTile(
        leading: Icon(
          icon,
          size: 32,
          color: AppColors.verde,
        ),
        title: Text(titulo),
        subtitle: Text(descricao),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
        ),
        onTap: () {
          // navegação futura
        },
      ),
    );
  }
}


