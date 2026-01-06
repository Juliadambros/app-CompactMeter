import 'package:flutter/material.dart';
import '../../models/usuario_model.dart';
import '../../models/veiculo_model.dart';
import '../../models/medicao_model.dart';
import '../../service/veiculo_service.dart';
import '../../service/medicao_service.dart';
import '../../theme/app_colors.dart';

class DetalhesUsuarioPage extends StatelessWidget {
  final UsuarioModel usuario;

  const DetalhesUsuarioPage({
    super.key,
    required this.usuario,
  });

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
            child: ListTile(
              title: Text(usuario.nome),
              subtitle: Text(usuario.email),
            ),
          ),

          const SizedBox(height: 24),

          const Text(
            'Veículos cadastrados',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 8),

          FutureBuilder<List<VeiculoModel>>(
            future: veiculoService.listarVeiculosPorUsuario(usuario.uid),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              }

              final veiculos = snapshot.data ?? [];

              if (veiculos.isEmpty) {
                return const Text('Nenhum veículo cadastrado');
              }

              return Column(
                children: veiculos
                    .map(
                      (v) => ListTile(
                        leading: const Icon(Icons.agriculture),
                        title: Text(v.nome),
                        subtitle: Text(
                          'Circunferência: ${v.circunferenciaRoda.toStringAsFixed(2)} m',
                        ),
                      ),
                    )
                    .toList(),
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
                return const CircularProgressIndicator();
              }

              final medicoes = snapshot.data ?? [];

              if (medicoes.isEmpty) {
                return const Text('Nenhuma medição realizada');
              }

              return Column(
                children: medicoes
                    .map(
                      (m) => ListTile(
                        leading: const Icon(Icons.calculate),
                        title: Text(m.nome),
                        subtitle: Text(
                          'Patinagem: ${m.patinagem.toStringAsFixed(2)}%',
                        ),
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
