import 'package:app_compactmeter/components/app_button.dart';
import 'package:app_compactmeter/components/app_text_field.dart';
import 'package:app_compactmeter/models/veiculo_model.dart';
import 'package:app_compactmeter/service/veiculo_service.dart';
import 'package:app_compactmeter/theme/app_colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CadastroVeiculoPage extends StatefulWidget {
  const CadastroVeiculoPage({super.key});

  @override
  State<CadastroVeiculoPage> createState() => _CadastroVeiculoPageState();
}

class _CadastroVeiculoPageState extends State<CadastroVeiculoPage> {
  final _nomeController = TextEditingController();
  final _circunferenciaController = TextEditingController();

  String? _tipoSelecionado;
  bool _salvando = false;

  Future<void> _salvarVeiculo() async {
    if (_nomeController.text.isEmpty ||
        _circunferenciaController.text.isEmpty ||
        _tipoSelecionado == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Preencha todos os campos')));
      return;
    }

    final circunferencia = double.tryParse(
      _circunferenciaController.text.replaceAll(',', '.'),
    );

    if (circunferencia == null || circunferencia <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Circunferência inválida')));
      return;
    }

    final usuario = FirebaseAuth.instance.currentUser;
    if (usuario == null) return;

    setState(() => _salvando = true);

    final veiculo = VeiculoModel(
      id: FirebaseFirestore.instance.collection('veiculos').doc().id,
      nome: _nomeController.text,
      circunferenciaRoda: circunferencia,
      tipo: _tipoSelecionado!,
      usuarioId: usuario.uid,
    );

    await VeiculoService().salvarVeiculo(veiculo);

    if (!mounted) return;

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fundo,
      appBar: AppBar(
        title: const Text('Cadastrar Veículo'),
        backgroundColor: AppColors.azul,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            AppTextField(controller: _nomeController, label: 'Nome do veículo'),
            const SizedBox(height: 16),
            AppTextField(
              controller: _circunferenciaController,
              label: 'Circunferência da roda (m)',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _tipoSelecionado,
              decoration: const InputDecoration(
                labelText: 'Tipo do veículo',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'Trator', child: Text('Trator')),
                DropdownMenuItem(
                  value: 'Colheitadeira',
                  child: Text('Colheitadeira'),
                ),
                DropdownMenuItem(
                  value: 'Pulverizador',
                  child: Text('Pulverizador'),
                ),
                DropdownMenuItem(
                  value: 'Plantadeira',
                  child: Text('Plantadeira'),
                ),
                DropdownMenuItem(
                  value: 'Distribuidor',
                  child: Text('Distribuidor de Fertilizante'),
                ),
                DropdownMenuItem(value: 'Outro', child: Text('Outro')),
              ],
              onChanged: (value) {
                setState(() => _tipoSelecionado = value);
              },
            ),

            const SizedBox(height: 32),
            AppButton(
              texto: 'Salvar veículo',
              loading: _salvando,
              onPressed: _salvarVeiculo,
            ),
          ],
        ),
      ),
    );
  }
}
