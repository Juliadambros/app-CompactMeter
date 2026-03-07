import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../models/veiculo_model.dart';
import '../../../service/veiculo_service.dart';
import '../../../theme/app_colors.dart';
import '../../../components/loading.dart';
import '../../../components/delete_button.dart';
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

  Future<void> _abrirCadastro({VeiculoModel? veiculo}) async {
    final atualizado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CadastroVeiculoPage(veiculo: veiculo),
      ),
    );

    if (atualizado == true) {
      setState(_carregarVeiculos);
    }
  }

  Future<void> _excluirVeiculo(String veiculoId) async {
    await VeiculoService().excluirVeiculo(veiculoId);

    if (!mounted) return;

    setState(_carregarVeiculos);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Máquina excluída com sucesso')),
    );
  }

  int _rodasComCircunferencia(VeiculoModel veiculo) {
    return veiculo.rodas.where((r) => r.circunferencia != null && r.circunferencia! > 0).length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fundo,
      appBar: AppBar(
        title: const Text('Máquinas'),
        backgroundColor: AppColors.azul,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.verde,
        onPressed: () => _abrirCadastro(),
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<VeiculoModel>>(
        future: _futureVeiculos,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const AppLoading();
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Nenhuma máquina cadastrada'));
          }

          final veiculos = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: veiculos.length,
            itemBuilder: (context, index) {
              final veiculo = veiculos[index];
              final rodasPreenchidas = _rodasComCircunferencia(veiculo);

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 3,
                child: ListTile(
                  leading: Icon(
                    Icons.agriculture,
                    color: AppColors.verde,
                  ),
                  title: Text(veiculo.nome),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Tipo: ${veiculo.tipo}'),
                      Text('Rodas com circunferência cadastrada: $rodasPreenchidas/4'),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        tooltip: 'Editar',
                        onPressed: () => _abrirCadastro(veiculo: veiculo),
                      ),
                      DeleteButton(
                        mensagem: 'Deseja excluir esta máquina?',
                        onConfirm: () => _excluirVeiculo(veiculo.id),
                      ),
                    ],
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