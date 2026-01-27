import 'package:app_compactmeter/components/delete_button.dart';
import 'package:app_compactmeter/service/medicao_service.dart';
import 'package:flutter/material.dart';
import '../../../models/medicao_model.dart';
import '../../../models/veiculo_model.dart';
import '../../../service/veiculo_service.dart';
import '../../../theme/app_colors.dart';
import '../../../components/app_button.dart';

class ResultadoMedicaoPage extends StatefulWidget {
  final MedicaoModel medicao;

  const ResultadoMedicaoPage({super.key, required this.medicao});

  @override
  State<ResultadoMedicaoPage> createState() => _ResultadoMedicaoPageState();
}

class _ResultadoMedicaoPageState extends State<ResultadoMedicaoPage> {
  VeiculoModel? _veiculo;
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarVeiculo();
  }

  Future<void> _carregarVeiculo() async {
    final veiculo = await VeiculoService().buscarPorId(
      widget.medicao.veiculoId,
    );

    setState(() {
      _veiculo = veiculo;
      _carregando = false;
    });
  }

  Future<void> _excluirMedicao() async {
    await MedicaoService().excluirMedicao(widget.medicao.id);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Medição excluída com sucesso')),
    );

    Navigator.popUntil(context, (route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fundo,
      appBar: AppBar(
        title: const Text('Resultado da Medição'),
        backgroundColor: AppColors.azul,
      ),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(24),
              child: ListView(
                children: [
                  Text(
                    widget.medicao.nome,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  Text('Veículo: ${_veiculo?.nome ?? '-'}'),
                  const SizedBox(height: 8),
                  Text(
                    'Patinagem: ${widget.medicao.patinagem.toStringAsFixed(2)} %',
                    style: TextStyle(color: AppColors.verde, fontSize: 20),
                  ),
                  const SizedBox(height: 24),

                  DeleteButton(
                    mensagem: 'Deseja excluir esta medição?',
                    onConfirm: _excluirMedicao,
                  ),

                  const SizedBox(height: 16),

                  const SizedBox(height: 32),
                  AppButton(
                    texto: 'Voltar para Home',
                    onPressed: () {
                      Navigator.popUntil(context, (route) => route.isFirst);
                    },
                  ),
                ],
              ),
            ),
    );
  }
}
