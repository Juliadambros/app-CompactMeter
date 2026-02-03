import 'package:app_compactmeter/components/delete_button.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../models/medicao_model.dart';
import '../../../service/medicao_service.dart';
import '../../../theme/app_colors.dart';
import '../../../components/loading.dart';
import '../medicoes/resultado_medicao_page.dart';

class HistoricoPage extends StatefulWidget {
  const HistoricoPage({super.key});

  @override
  State<HistoricoPage> createState() => _HistoricoPageState();
}

class _HistoricoPageState extends State<HistoricoPage> {
  late Future<List<MedicaoModel>> _futureMedicoes;

  @override
  void initState() {
    super.initState();
    _carregarHistorico();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _carregarHistorico();
  }

  void _carregarHistorico() {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    _futureMedicoes = MedicaoService().listarPorUsuario(uid);
  }

  Future<void> _excluirMedicao(String medicaoId) async {
    await MedicaoService().excluirMedicao(medicaoId);

    if (!mounted) return;

    setState(() => _carregarHistorico());

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Medição excluída com sucesso')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fundo,
      appBar: AppBar(
        title: const Text('Histórico de Medições'),
        backgroundColor: AppColors.azul,
      ),
      body: FutureBuilder<List<MedicaoModel>>(
        future: _futureMedicoes,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const AppLoading();
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Erro ao carregar histórico:\n${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Nenhuma medição encontrada'));
          }

          final medicoes = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: medicoes.length,
            itemBuilder: (context, index) {
              final medicao = medicoes[index];
              

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 3,
                child: ListTile(
                  leading: Icon(Icons.calculate, color: AppColors.verde),
                  title: Text(
                    medicao.nome,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        'Patinagem: ${medicao.patinagem.toStringAsFixed(2)}%',
                      ),
                      
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DeleteButton(
                        mensagem: 'Deseja excluir esta medição?',
                        onConfirm: () => _excluirMedicao(medicao.id),
                      ),
                      const Icon(Icons.arrow_forward_ios, size: 16),
                    ],
                  ),

                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ResultadoMedicaoPage(medicao: medicao),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
