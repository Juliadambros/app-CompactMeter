import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:app_compactmeter/components/app_button.dart';
import 'package:app_compactmeter/components/app_text_field.dart';
import 'package:app_compactmeter/models/veiculo_model.dart';
import 'package:app_compactmeter/models/roda_model.dart';
import 'package:app_compactmeter/service/veiculo_service.dart';
import 'package:app_compactmeter/theme/app_colors.dart';

class CadastroVeiculoPage extends StatefulWidget {
  final VeiculoModel? veiculo;

  const CadastroVeiculoPage({super.key, this.veiculo});

  @override
  State<CadastroVeiculoPage> createState() => _CadastroVeiculoPageState();
}

class _CadastroVeiculoPageState extends State<CadastroVeiculoPage> {
  final _nomeController = TextEditingController();
  final _descricaoController = TextEditingController();

  String _tipoSelecionado = 'Trator';
  bool _salvando = false;

  final Map<String, bool> _sensores = {
    'Traseira Direita': false,
    'Traseira Esquerda': false,
    'Dianteira Direita': false,
    'Dianteira Esquerda': false,
  };

  final Map<String, TextEditingController> _circControllers = {};

  bool get _editando => widget.veiculo != null;

  @override
  void initState() {
    super.initState();

    for (final posicao in _sensores.keys) {
      _circControllers[posicao] = TextEditingController();
    }

    if (_editando) {
      _preencherDados();
    }
  }

  void _preencherDados() {
    final v = widget.veiculo!;

    _nomeController.text = v.nome;
    _descricaoController.text = v.descricao ?? '';
    _tipoSelecionado = v.tipo;

    for (final roda in v.rodas) {
      _sensores[roda.posicao] = roda.temSensor;
      if (roda.circunferencia != null) {
        _circControllers[roda.posicao]!.text =
            roda.circunferencia!.toString();
      }
    }
  }

  Future<void> _salvarVeiculo() async {
    if (_nomeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe o nome da máquina')),
      );
      return;
    }

    final usuario = FirebaseAuth.instance.currentUser;
    if (usuario == null) return;

    final List<RodaModel> rodas = [];

    for (final posicao in _sensores.keys) {
      final temSensor = _sensores[posicao]!;
      double? circ;

      if (temSensor) {
        circ = double.tryParse(
          _circControllers[posicao]!.text.replaceAll(',', '.'),
        );

        if (circ == null || circ <= 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Circunferência inválida na roda $posicao'),
            ),
          );
          return;
        }
      }

      rodas.add(
        RodaModel(
          posicao: posicao,
          temSensor: temSensor,
          circunferencia: circ,
          bluetoothId: temSensor ? 'PENDENTE' : null,
        ),
      );
    }

    setState(() => _salvando = true);

    final veiculo = VeiculoModel(
      id: _editando
          ? widget.veiculo!.id
          : FirebaseFirestore.instance.collection('veiculos').doc().id,
      nome: _nomeController.text.trim(),
      descricao:
          _descricaoController.text.trim().isEmpty ? null : _descricaoController.text.trim(),
      tipo: _tipoSelecionado,
      usuarioId: usuario.uid,
      rodas: rodas,
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
        title: Text(_editando ? 'Editar Máquina' : 'Cadastrar Máquina'),
        backgroundColor: AppColors.azul,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          AppTextField(
            controller: _nomeController,
            label: 'Nome da Máquina*',
          ),
          const SizedBox(height: 16),

          AppTextField(
            controller: _descricaoController,
            label: 'Descrição',
          ),
          const SizedBox(height: 16),

          DropdownButtonFormField<String>(
            value: _tipoSelecionado,
            decoration: const InputDecoration(
              labelText: 'Tipo do veículo',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: 'Colheitadeira', child: Text('Colheitadeira')),
              DropdownMenuItem(value: 'Pulverizador', child: Text('Pulverizador')),
              DropdownMenuItem(value: 'Semeadora', child: Text('Semeadora')),
              DropdownMenuItem(value: 'Plantadeira', child: Text('Plantadeira')),
              DropdownMenuItem(value: 'Trator', child: Text('Trator')),
              DropdownMenuItem(value: 'Outros', child: Text('Outros')),
            ],
            onChanged: (v) => setState(() => _tipoSelecionado = v!),
          ),

          const SizedBox(height: 24),
          const Text(
            'Rodas e sensores',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          ..._sensores.keys.map((posicao) {
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    SwitchListTile(
                      title: Text(posicao),
                      value: _sensores[posicao]!,
                      onChanged: (v) => setState(() => _sensores[posicao] = v),
                    ),
                    if (_sensores[posicao]!)
                      AppTextField(
                        controller: _circControllers[posicao]!,
                        label: 'Circunferência da roda (m)',
                        keyboardType: TextInputType.number,
                      ),
                  ],
                ),
              ),
            );
          }),

          const SizedBox(height: 32),
          AppButton(
            texto: _editando ? 'Salvar alterações' : 'Salvar veículo',
            loading: _salvando,
            onPressed: _salvarVeiculo,
          ),
        ],
      ),
    );
  }
}

