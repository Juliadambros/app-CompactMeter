import 'package:app_compactmeter/view/usuario/compactacao/nova_medicao_compactacao_page.dart';
import 'package:app_compactmeter/view/usuario/historico/historico_page.dart';
import 'package:app_compactmeter/view/usuario/historico/historico_patinagem_page.dart';
import 'package:app_compactmeter/view/usuario/medicoes/calibrar_patinagem_page.dart';
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
      body: SingleChildScrollView(
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
              'Gerencie a patinagem e avalie a compactação do solo de forma simples e organizada.',
            ),

            const SizedBox(height: 32),

            _CardFuncionalidade(
              icon: Icons.home_work,
              titulo: 'Propriedades',
              descricao: 'Cadastrar Propriedades',
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
              descricao: 'Cadastrar/Visualizar máquinas agrícolas',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ListaVeiculosPage(),
                  ),
                );
              },
            ),

            _CardFuncionalidade(
              icon: Icons.calculate,
              titulo: 'Calibragem da Patinagem',
              descricao: 'Iniciar calibração da patinagem',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CalibrarPatinagemPage(),
                  ),
                );
              },
            ),

            _CardFuncionalidade(
              icon: Icons.calculate,
              titulo: 'Nova medição de Índice de Compactação',
              descricao: 'Iniciar medição de compactação',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const NovaMedicaoCompactacaoPage(),
                  ),
                );
              },
            ),

            _CardFuncionalidade(
              icon: Icons.history,
              titulo: 'Histórico',
              descricao: 'Ver medições anteriores',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const HistoricoPage(),
                  ),
                );
              },
            ),

            _CardFuncionalidade(
              icon: Icons.info_outline,
              titulo: 'Sobre o CompactMeter',
              descricao: 'Informações gerais',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const  SobreProjetoPage(),
                  ),
                );
              },
            ),

            const SizedBox(height: 16),
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
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

