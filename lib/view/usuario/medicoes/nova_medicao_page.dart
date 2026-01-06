import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../components/app_button.dart';
import '../../../components/app_text_field.dart';
import '../../../models/veiculo_model.dart';
import '../../../models/medicao_model.dart';
import '../../../service/veiculo_service.dart';
import '../../../service/medicao_service.dart';
import '../../../theme/app_colors.dart';
import 'resultado_medicao_page.dart';

class NovaMedicaoPage extends StatefulWidget {
  const NovaMedicaoPage({super.key});

  @override
  State<NovaMedicaoPage> createState() => _NovaMedicaoPageState();
}

class _NovaMedicaoPageState extends State<NovaMedicaoPage> {
  final _nomeController = TextEditingController();
  final _propriedadeController = TextEditingController();

  VeiculoModel? _veiculoSelecionado;
  List<VeiculoModel> _veiculos = [];

  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarVeiculos();
  }

  Future<void> _carregarVeiculos() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final lista =
        await VeiculoService().listarVeiculosPorUsuario(uid);

    setState(() {
      _veiculos = lista;
      _carregando = false;
    });
  }

  void _iniciarMedicao() async {
    if (_nomeController.text.isEmpty ||
        _propriedadeController.text.isEmpty ||
        _veiculoSelecionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha todos os campos')),
      );
      return;
    }

    final usuario = FirebaseAuth.instance.currentUser!;
    final random = Random();

    final distanciaReal = 100 + random.nextDouble() * 50;
    final rotacoes = 80 + random.nextInt(40);

    final patinagem = MedicaoService.calcularPatinagem(
      distanciaReal: distanciaReal,
      rotacoes: rotacoes,
      circunferenciaRoda: _veiculoSelecionado!.circunferenciaRoda,
    );

    final medicao = MedicaoModel(
      id: FirebaseFirestore.instance.collection('medicoes').doc().id,
      nome: _nomeController.text,
      propriedade: _propriedadeController.text,
      veiculoId: _veiculoSelecionado!.id,
      distanciaReal: distanciaReal,
      rotacoes: rotacoes,
      patinagem: patinagem,
      data: DateTime.now(),
      usuarioId: usuario.uid,
    );

    await MedicaoService().salvarMedicao(medicao);

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ResultadoMedicaoPage(medicao: medicao),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fundo,
      appBar: AppBar(
        title: const Text('Nova Medição'),
        backgroundColor: AppColors.azul,
      ),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(24),
              child: ListView(
                children: [
                  AppTextField(
                    controller: _nomeController,
                    label: 'Nome da medição',
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: _propriedadeController,
                    label: 'Propriedade',
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<VeiculoModel>(
                    decoration: const InputDecoration(
                      labelText: 'Veículo',
                      border: OutlineInputBorder(),
                    ),
                    items: _veiculos
                        .map(
                          (v) => DropdownMenuItem(
                            value: v,
                            child: Text(v.nome),
                          ),
                        )
                        .toList(),
                    onChanged: (v) {
                      setState(() => _veiculoSelecionado = v);
                    },
                  ),
                  const SizedBox(height: 32),
                  AppButton(
                    texto: 'Iniciar medição',
                    onPressed: _iniciarMedicao,
                  ),
                ],
              ),
            ),
    );
  }
}

