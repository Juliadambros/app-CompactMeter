import 'package:app_compactmeter/view/usuario/propriedades/cadastro_propriedade_page.dart';
import 'package:app_compactmeter/view/usuario/veiculos/cadastro_veiculo_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../models/medicao_model.dart';
import '../../../models/propriedade_model.dart';
import '../../../models/veiculo_model.dart';
import '../../../models/roda_model.dart';

import '../../../service/medicao_service.dart';
import '../../../service/propriedade_service.dart';
import '../../../service/veiculo_service.dart';

import 'resultado_medicao_page.dart';

class NovaMedicaoPage extends StatefulWidget {
  const NovaMedicaoPage({super.key});

  @override
  State<NovaMedicaoPage> createState() => _NovaMedicaoPageState();
}

class _NovaMedicaoPageState extends State<NovaMedicaoPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomeCtrl = TextEditingController();
  final _raioCtrl = TextEditingController();

  PropriedadeModel? _propriedadeSelecionada;
  VeiculoModel? _veiculoSelecionado;
  RodaModel? _rodaSelecionada;

  bool _carregando = false;

  //Simulação Bluetooth
  double _distanciaSensor = 120.0;
  int _voltasSensor = 35;

  void _recarregar() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nova Medição')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _campoNome(),
              const SizedBox(height: 16),
              _secaoPropriedade(),
              const SizedBox(height: 16),
              _secaoVeiculo(),
              const SizedBox(height: 16),
              _dropdownRodas(),
              const SizedBox(height: 16),
              _campoRaio(),
              const SizedBox(height: 32),
              _botaoCalcular(),
            ],
          ),
        ),
      ),
    );
  }


  Widget _campoNome() {
    return TextFormField(
      controller: _nomeCtrl,
      decoration: const InputDecoration(
        labelText: 'Nome da medição',
        border: OutlineInputBorder(),
      ),
      validator: (v) => v == null || v.isEmpty ? 'Informe o nome da medição' : null,
    );
  }

  Widget _campoRaio() {
    return TextFormField(
      controller: _raioCtrl,
      keyboardType: TextInputType.number,
      decoration: const InputDecoration(
        labelText: 'Raio do eixo mecânico (m)',
        border: OutlineInputBorder(),
      ),
      validator: (v) {
        if (v == null || v.isEmpty) return 'Informe o raio do eixo';
        if (double.tryParse(v) == null) return 'Valor inválido';
        return null;
      },
    );
  }


  Widget _secaoPropriedade() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _dropdownPropriedades(),
        const SizedBox(height: 8),
        _botaoAdicionar(
          texto: 'Adicionar nova propriedade',
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const CadastroPropriedadePage(),
              ),
            );
            _recarregar();
          },
        ),
      ],
    );
  }

  Widget _dropdownPropriedades() {
    return FutureBuilder<List<PropriedadeModel>>(
      future: PropriedadeService()
          .listarPorUsuario(FirebaseAuth.instance.currentUser!.uid),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const CircularProgressIndicator();
        }

        return DropdownButtonFormField<PropriedadeModel>(
          value: _propriedadeSelecionada,
          items: snapshot.data!
              .map((p) => DropdownMenuItem(value: p, child: Text(p.nome)))
              .toList(),
          onChanged: (v) => setState(() => _propriedadeSelecionada = v),
          decoration: const InputDecoration(
            labelText: 'Propriedade',
            border: OutlineInputBorder(),
          ),
          validator: (v) => v == null ? 'Selecione uma propriedade' : null,
        );
      },
    );
  }


  Widget _secaoVeiculo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _dropdownVeiculos(),
        const SizedBox(height: 8),
        _botaoAdicionar(
          texto: 'Adicionar nova Máquina',
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const CadastroVeiculoPage(),
              ),
            );
            _recarregar();
          },
        ),
      ],
    );
  }

  Widget _dropdownVeiculos() {
    return FutureBuilder<List<VeiculoModel>>(
      future: VeiculoService()
          .listarVeiculosPorUsuario(FirebaseAuth.instance.currentUser!.uid),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const CircularProgressIndicator();
        }

        return DropdownButtonFormField<VeiculoModel>(
          value: _veiculoSelecionado,
          items: snapshot.data!
              .map((v) => DropdownMenuItem(value: v, child: Text(v.nome)))
              .toList(),
          onChanged: (v) {
            setState(() {
              _veiculoSelecionado = v;
              _rodaSelecionada = null;
            });
          },
          decoration: const InputDecoration(
            labelText: 'Máquina',
            border: OutlineInputBorder(),
          ),
          validator: (v) => v == null ? 'Selecione uma Máquina' : null,
        );
      },
    );
  }


  Widget _dropdownRodas() {
    if (_veiculoSelecionado == null) return const SizedBox();

    final rodas = _veiculoSelecionado!.rodas
        .where((r) => r.temSensor)
        .toList();

    if (rodas.isEmpty) {
      return const Text(
        'Esta Máquina não possui rodas com sensor',
        style: TextStyle(color: Colors.red),
      );
    }

    return DropdownButtonFormField<RodaModel>(
      value: _rodaSelecionada,
      items: rodas
          .map((r) => DropdownMenuItem(value: r, child: Text(r.posicao)))
          .toList(),
      onChanged: (v) => setState(() => _rodaSelecionada = v),
      decoration: const InputDecoration(
        labelText: 'Roda com sensor',
        border: OutlineInputBorder(),
      ),
      validator: (v) => v == null ? 'Selecione a roda' : null,
    );
  }


  Widget _botaoAdicionar({
    required String texto,
    required VoidCallback onPressed,
  }) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.add),
      label: Text(texto),
    );
  }

  Widget _botaoCalcular() {
    return ElevatedButton(
      onPressed: _carregando ? null : _calcularMedicao,
      child: _carregando
          ? const CircularProgressIndicator(color: Colors.white)
          : const Text('Calcular medição de patinagem'),
    );
  }


  Future<void> _calcularMedicao() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _carregando = true);

    final uid = FirebaseAuth.instance.currentUser!.uid;

    final medicao = MedicaoModel.criar(
      id: FirebaseFirestore.instance.collection('medicoes').doc().id,
      usuarioId: uid,
      propriedadeId: _propriedadeSelecionada!.id,
      veiculoId: _veiculoSelecionado!.id,
      rodaId: _rodaSelecionada!.posicao,
      nome: _nomeCtrl.text.trim(),
      raioEixo: double.parse(_raioCtrl.text),
      distancia: _distanciaSensor,
      voltas: _voltasSensor,
    );

    await MedicaoService().salvarMedicao(medicao);

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ResultadoMedicaoPage(medicao: medicao),
      ),
    );
  }
}
