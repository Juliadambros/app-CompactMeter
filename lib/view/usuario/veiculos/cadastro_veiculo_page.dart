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
  final String? uidAlvo;

  const CadastroVeiculoPage({
    super.key,
    this.veiculo,
    this.uidAlvo,
  });

  @override
  State<CadastroVeiculoPage> createState() => _CadastroVeiculoPageState();
}

class _CadastroVeiculoPageState extends State<CadastroVeiculoPage> {
  final _nomeController = TextEditingController();
  final _descricaoController = TextEditingController();

  String _tipoSelecionado = 'Trator';
  bool _salvando = false;

  final List<String> _posicoes = const [
    'Traseira Direita',
    'Traseira Esquerda',
    'Dianteira Direita',
    'Dianteira Esquerda',
  ];

  final Map<String, TextEditingController> _circControllers = {};

  bool get _editando => widget.veiculo != null;

  @override
  void initState() {
    super.initState();

    for (final posicao in _posicoes) {
      _circControllers[posicao] = TextEditingController();
    }

    if (_editando) {
      _preencherDados();
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _descricaoController.dispose();
    for (final c in _circControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _preencherDados() {
    final v = widget.veiculo!;

    _nomeController.text = v.nome;
    _descricaoController.text = v.descricao ?? '';
    _tipoSelecionado = v.tipo;

    for (final roda in v.rodas) {
      if (roda.circunferencia != null) {
        _circControllers[roda.posicao]?.text = roda.circunferencia!.toString();
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

    final usuarioAtual = FirebaseAuth.instance.currentUser;
    final uidDono = widget.uidAlvo ?? usuarioAtual?.uid;

    if (uidDono == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuário não autenticado')),
      );
      return;
    }

    final List<RodaModel> rodas = [];

    for (final posicao in _posicoes) {
      final texto = _circControllers[posicao]!.text.trim();

      double? circ;
      if (texto.isNotEmpty) {
        circ = double.tryParse(texto.replaceAll(',', '.'));
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
          circunferencia: circ,
        ),
      );
    }

    setState(() => _salvando = true);

    try {
      final veiculo = VeiculoModel(
        id: _editando
            ? widget.veiculo!.id
            : FirebaseFirestore.instance.collection('veiculos').doc().id,
        nome: _nomeController.text.trim(),
        descricao: _descricaoController.text.trim().isEmpty
            ? null
            : _descricaoController.text.trim(),
        tipo: _tipoSelecionado,
        usuarioId: uidDono,
        rodas: rodas,
      );

      await VeiculoService().salvarVeiculo(veiculo);

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar máquina: $e')),
      );
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  Widget _cardRoda(String posicao) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                posicao,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 10),
            AppTextField(
              controller: _circControllers[posicao]!,
              label: 'Circunferência da roda (m)',
              keyboardType: TextInputType.number,
            ),
          ],
        ),
      ),
    );
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
              labelText: 'Tipo da máquina',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(
                value: 'Colhedora',
                child: Text('Colhedora'),
              ),
              DropdownMenuItem(
                value: 'Pulverizador',
                child: Text('Pulverizador'),
              ),
              DropdownMenuItem(
                value: 'Semeadora',
                child: Text('Semeadora'),
              ),
              DropdownMenuItem(
                value: 'Plantadora',
                child: Text('Plantadora'),
              ),
              DropdownMenuItem(
                value: 'Trator',
                child: Text('Trator'),
              ),
              DropdownMenuItem(
                value: 'Outros',
                child: Text('Outros'),
              ),
            ],
            onChanged: (v) => setState(() => _tipoSelecionado = v ?? 'Trator'),
          ),
          const SizedBox(height: 24),
          const Text(
            'Circunferência das rodas',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ..._posicoes.map(_cardRoda),
          const SizedBox(height: 32),
          AppButton(
            texto: _editando ? 'Salvar alterações' : 'Salvar máquina',
            loading: _salvando,
            onPressed: _salvarVeiculo,
          ),
        ],
      ),
    );
  }
}