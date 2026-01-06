import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../components/app_button.dart';
import '../../../components/app_text_field.dart';
import '../../../models/veiculo_model.dart';
import '../../../service/veiculo_service.dart';
import '../../../theme/app_colors.dart';

class CadastroVeiculoPage extends StatefulWidget {
  const CadastroVeiculoPage({super.key});

  @override
  State<CadastroVeiculoPage> createState() => _CadastroVeiculoPageState();
}

class _CadastroVeiculoPageState extends State<CadastroVeiculoPage> {
  final _nomeController = TextEditingController();
  final _circunferenciaController = TextEditingController();

  bool _salvando = false;

  void _salvarVeiculo() async {
    if (_nomeController.text.isEmpty ||
        _circunferenciaController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha todos os campos')),
      );
      return;
    }

    final circunferencia =
        double.tryParse(_circunferenciaController.text.replaceAll(',', '.'));

    if (circunferencia == null || circunferencia <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Circunferência inválida')),
      );
      return;
    }

    final usuario = FirebaseAuth.instance.currentUser;
    if (usuario == null) return;

    setState(() => _salvando = true);

    final veiculo = VeiculoModel(
      id: FirebaseFirestore.instance.collection('veiculos').doc().id,
      nome: _nomeController.text,
      circunferenciaRoda: circunferencia,
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
            AppTextField(
              controller: _nomeController,
              label: 'Nome do veículo',
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _circunferenciaController,
              label: 'Circunferência da roda (m)',
              keyboardType: TextInputType.number,
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
