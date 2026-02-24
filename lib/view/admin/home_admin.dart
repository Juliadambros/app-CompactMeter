import 'package:app_compactmeter/service/relatorio_service.dart';
import 'package:flutter/material.dart';
import '../../components/action_card.dart';
import '../../service/auth_service.dart';
import '../../theme/app_colors.dart';
import 'gerenciar_usuarios_page.dart';

class HomeAdmin extends StatelessWidget {
  const HomeAdmin({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    return Scaffold(
      backgroundColor: AppColors.fundo,
      appBar: AppBar(
        title: const Text('Painel do Administrador'),
        backgroundColor: AppColors.azul,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authService.sair();
              if (!context.mounted) return;
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Bem-vindo(a), Administrador',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),

            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                ActionCard(
                  icon: Icons.people,
                  titulo: 'Gerenciar Usuários',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => GerenciarUsuariosPage(),
                      ),
                    );
                  },
                ),
                ActionCard(
                  icon: Icons.summarize,
                  titulo: 'Relatórios (Geral)',
                  onTap: () async {
                    final relatorio = RelatorioService();

                    showModalBottomSheet(
                      context: context,
                      builder: (_) => SafeArea(
                        child: Wrap(
                          children: [
                            ListTile(
                              leading: const Icon(Icons.picture_as_pdf),
                              title: const Text(
                                'Exportar PDF (todas as medições)',
                              ),
                              onTap: () async {
                                Navigator.pop(context);
                                await relatorio.compartilharPdfMedicoesGeral();
                              },
                            ),
                            ListTile(
                              leading: const Icon(Icons.table_chart),
                              title: const Text(
                                'Exportar CSV (todas as medições)',
                              ),
                              onTap: () async {
                                Navigator.pop(context);
                                final file = await relatorio
                                    .gerarCsvMedicoesGeral();
                                await relatorio.compartilharArquivo(file);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
