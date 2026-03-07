import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import 'historico_patinagem_page.dart';
import 'historico_compactacao_page.dart';

class HistoricoPage extends StatelessWidget {
  const HistoricoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fundo,
      appBar: AppBar(
        title: const Text('Históricos'),
        backgroundColor: AppColors.azul,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              child: ListTile(
                leading: const Icon(Icons.speed),
                title: const Text('Histórico de Patinagem'),
                subtitle: const Text('Visualizar calibragens realizadas'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const HistoricoPatinagemPage(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                leading: const Icon(Icons.terrain),
                title: const Text('Histórico de Compactação'),
                subtitle: const Text('Visualizar medições de compactação'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const HistoricoCompactacaoPage(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}