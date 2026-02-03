import 'package:app_compactmeter/components/delete_button.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../models/veiculo_model.dart';
import '../../../service/veiculo_service.dart';
import '../../../theme/app_colors.dart';
import '../../../components/loading.dart';
import 'cadastro_veiculo_page.dart';

class ListaVeiculosPage extends StatefulWidget {
  const ListaVeiculosPage({super.key});

  @override
  State<ListaVeiculosPage> createState() => _ListaVeiculosPageState();
}

class _ListaVeiculosPageState extends State<ListaVeiculosPage> {
  late Future<List<VeiculoModel>> _futureVeiculos;

  @override
  void initState() {
    super.initState();
    _carregarVeiculos();
  }

  void _carregarVeiculos() {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    _futureVeiculos = VeiculoService().listarVeiculosPorUsuario(uid);
  }

  Future<void> _abrirCadastro() async {
    final atualizado = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CadastroVeiculoPage()),
    );

    if (atualizado == true) {
      setState(() => _carregarVeiculos());
    }
  }

  Future<void> _excluirVeiculo(String veiculoId) async {
    await VeiculoService().excluirVeiculo(veiculoId);

    if (!mounted) return;

    setState(() => _carregarVeiculos());

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Veículo excluído com sucesso')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fundo,
      appBar: AppBar(
        title: const Text('Veículos'),
        backgroundColor: AppColors.azul,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.verde,
        onPressed: _abrirCadastro,
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<VeiculoModel>>(
        future: _futureVeiculos,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const AppLoading();
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Nenhum veículo cadastrado'));
          }

          final veiculos = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: veiculos.length,
            itemBuilder: (context, index) {
              final veiculo = veiculos[index];

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 3,
                child: ListTile(
                  leading: Icon(Icons.agriculture, color: AppColors.verde),
                  title: Text(veiculo.nome),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Tipo: ${veiculo.tipo}'),
                      Text(
                        'Circunferência: ${veiculo.circunferenciaRoda.toStringAsFixed(2)} m',
                      ),
                    ],
                  ),

                  trailing: DeleteButton(
                    mensagem: 'Deseja excluir este veículo?',
                    onConfirm: () => _excluirVeiculo(veiculo.id),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
