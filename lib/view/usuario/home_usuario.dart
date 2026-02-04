import 'package:app_compactmeter/view/usuario/historico/historico_page.dart';
import 'package:app_compactmeter/view/usuario/informacoes/como_funciona_page.dart';
import 'package:app_compactmeter/view/usuario/medicoes/nova_medicao_page.dart';
import 'package:app_compactmeter/view/usuario/propriedades/lista_propriedades_page.dart';
import 'package:app_compactmeter/view/usuario/sobre/sobre_page.dart';
import 'package:app_compactmeter/view/usuario/veiculos/lista_veiculos_page.dart';
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
              'Gerencie propriedades, máquinas e medições de forma simples e organizada.',
            ),

            const SizedBox(height: 32),

            _CardFuncionalidade(
              icon: Icons.home_work,
              titulo: 'Propriedades',
              descricao: 'Cadastrar e gerenciar propriedades',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ListaPropriedadesPage(),
                  ),
                );
              },
            ),

            _CardFuncionalidade(
              icon: Icons.agriculture,
              titulo: 'Máquinas agrícolas',
              descricao: 'Visualizar/Cadastrar veículos',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ListaVeiculosPage()),
                );
              },
            ),

            _CardFuncionalidade(
              icon: Icons.calculate,
              titulo: 'Nova medição de patinagem',
              descricao: 'Solicitar medições',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const NovaMedicaoPage()),
                );
              },
            ),

            _CardFuncionalidade(
              icon: Icons.history,
              titulo: 'Histórico',
              descricao: 'Ver registros anteriores',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const HistoricoPage()),
                );
              },
            ),

            _CardFuncionalidade(
              icon: Icons.info_outline,
              titulo: 'Como funciona',
              descricao: 'Fórmulas e metodologia utilizada',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ComoFuncionaPage()),
                );
              },
            ),

            _CardFuncionalidade(
              icon: Icons.groups_outlined,
              titulo: 'Sobre o projeto',
              descricao: 'Informações sobre o CompactMeter',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SobrePage()),
                );
              },
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
  final VoidCallback onTap;

  const _CardFuncionalidade({
    required this.icon,
    required this.titulo,
    required this.descricao,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: ListTile(
        leading: Icon(icon, size: 32, color: AppColors.verde),
        title: Text(titulo),
        subtitle: Text(descricao),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
