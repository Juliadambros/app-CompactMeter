import 'package:flutter/material.dart';

import '../../components/delete_button.dart';
import '../../models/usuario_model.dart';
import '../../models/veiculo_model.dart';
import '../../models/medicao_model.dart';
import '../../service/usuario_service.dart';
import '../../service/veiculo_service.dart';
import '../../service/medicao_service.dart';
import '../../theme/app_colors.dart';

class DetalhesUsuarioPage extends StatelessWidget {
  final UsuarioModel usuario;

  const DetalhesUsuarioPage({
    super.key,
    required this.usuario,
  });

  Future<void> _excluirUsuario(BuildContext context) async {
    final usuarioService = UsuarioService();
    final veiculoService = VeiculoService();
    final medicaoService = MedicaoService();

    try {
      final medicoes = await medicaoService.listarPorUsuario(usuario.uid);
      for (final m in medicoes) {
        await medicaoService.excluirMedicao(m.id);
      }

      final veiculos =
          await veiculoService.listarVeiculosPorUsuario(usuario.uid);
      for (final v in veiculos) {
        await veiculoService.excluirVeiculo(v.id);
      }

      await usuarioService.excluirUsuario(usuario.uid);

      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuário excluído com sucesso')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao excluir usuário: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final veiculoService = VeiculoService();
    final medicaoService = MedicaoService();

    return Scaffold(
      backgroundColor: AppColors.fundo,
      appBar: AppBar(
        title: Text('Usuário: ${usuario.nome}'),
        backgroundColor: AppColors.azul,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: const Icon(Icons.person),
              title: Text(usuario.nome),
              subtitle: Text(usuario.email),
            ),
          ),

          const SizedBox(height: 24),

          const Text(
            'Máquinas cadastradas',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          FutureBuilder<List<VeiculoModel>>(
            future: veiculoService.listarVeiculosPorUsuario(usuario.uid),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(8),
                  child: CircularProgressIndicator(),
                );
              }

              final veiculos = snapshot.data ?? [];

              if (veiculos.isEmpty) {
                return const Text('Nenhuma máquinas cadastrado');
              }

              return Column(
                children: veiculos.map((v) {
                  final rodasComSensor =
                      v.rodas.where((r) => r.temSensor).toList();

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.agriculture),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  v.nome,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text('Tipo: ${v.tipo}'),

                          const SizedBox(height: 8),
                          if (rodasComSensor.isEmpty)
                            const Text('Nenhum sensor cadastrado'),
                          if (rodasComSensor.isNotEmpty)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: rodasComSensor.map((r) {
                                return Text(
                                  '• ${r.posicao} – '
                                  '${r.circunferencia?.toStringAsFixed(2)} m',
                                );
                              }).toList(),
                            ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),

          const SizedBox(height: 24),

          const Text(
            'Medições realizadas',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          FutureBuilder<List<MedicaoModel>>(
            future: medicaoService.listarPorUsuario(usuario.uid),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(8),
                  child: CircularProgressIndicator(),
                );
              }

              final medicoes = snapshot.data ?? [];

              if (medicoes.isEmpty) {
                return const Text('Nenhuma medição realizada');
              }

              return Column(
                children: medicoes.map((m) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.calculate),
                      title: Text(
                        m.nome,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        'Patinagem: ${m.patinagem.toStringAsFixed(2)}%',
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),

          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 16),

          DeleteButton(
            titulo: 'Excluir usuário',
            mensagem:
                'Este usuário será removido do sistema.\n'
                'Todos as máquinas e medições também serão excluídos.\n\n'
                'Essa ação não pode ser desfeita.',
            onConfirm: () => _excluirUsuario(context),
          ),
        ],
      ),
    );
  }
}

