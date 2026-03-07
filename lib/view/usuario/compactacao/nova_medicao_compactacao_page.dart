import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../models/compactacao_model.dart';
import '../../../models/medicao_model.dart';
import '../../../models/propriedade_model.dart';
import '../../../models/veiculo_model.dart';

import '../../../service/compactacao_service.dart';
import '../../../service/medicao_service.dart';
import '../../../service/propriedade_service.dart';
import '../../../service/veiculo_service.dart';

import '../medicoes/calibrar_patinagem_page.dart';
import '../propriedades/cadastro_propriedade_page.dart';
import '../veiculos/cadastro_veiculo_page.dart';
import 'resultado_compactacao_page.dart';

class NovaMedicaoCompactacaoPage extends StatefulWidget {
  const NovaMedicaoCompactacaoPage({super.key});

  @override
  State<NovaMedicaoCompactacaoPage> createState() =>
      _NovaMedicaoCompactacaoPageState();
}

class _NovaMedicaoCompactacaoPageState
    extends State<NovaMedicaoCompactacaoPage> {
  final _formKey = GlobalKey<FormState>();

  final _nomeCtrl = TextEditingController();
  final _observacoesCtrl = TextEditingController();

  bool _jaCalibrouPatinagem = true;
  bool _salvando = false;

  PropriedadeModel? _propriedadeSelecionada;
  VeiculoModel? _veiculoSelecionado;
  MedicaoModel? _medicaoSelecionada;

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _observacoesCtrl.dispose();
    super.dispose();
  }

  void _recarregar() => setState(() {});

  Future<void> _irParaCalibragem() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CalibrarPatinagemPage()),
    );

    if (!mounted) return;
    setState(() {});
  }

  Future<void> _medir() async {
    if (!_formKey.currentState!.validate()) return;

    if (_propriedadeSelecionada == null || _veiculoSelecionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione a propriedade e a máquina')),
      );
      return;
    }

    if (_jaCalibrouPatinagem && _medicaoSelecionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione uma calibragem de patinagem')),
      );
      return;
    }

    setState(() => _salvando = true);

    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;

      final compactacao = CompactacaoModel.criar(
        id: FirebaseFirestore.instance.collection('compactacoes').doc().id,
        usuarioId: uid,
        propriedadeId: _propriedadeSelecionada!.id,
        veiculoId: _veiculoSelecionado!.id,
        nome: _nomeCtrl.text.trim(),
        calibragemRealizada: _jaCalibrouPatinagem,
        medicaoPatinagemId: _medicaoSelecionada?.id,
        patinagemReferencia: _medicaoSelecionada?.patinagem,
        indiceCompactacao: null,
        observacoes: _observacoesCtrl.text.trim().isEmpty
            ? null
            : _observacoesCtrl.text.trim(),
      );

      await CompactacaoService().salvar(compactacao);

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ResultadoCompactacaoPage(compactacao: compactacao),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao medir: $e')));
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  String _formatarCoord(double? y, double? x) {
    if (y == null || x == null) return '—';
    return '${y.toStringAsFixed(6)}, ${x.toStringAsFixed(6)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nova Medição de Índice de Compactação'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nomeCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nome da medição',
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Informe o nome da medição';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              _secaoPropriedade(),
              const SizedBox(height: 16),

              _secaoVeiculo(),
              const SizedBox(height: 16),

              const Text(
                'Já calibrou a patinagem?',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),

              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(_jaCalibrouPatinagem ? 'Sim' : 'Não'),
                value: _jaCalibrouPatinagem,
                onChanged: (v) {
                  setState(() {
                    _jaCalibrouPatinagem = v;
                    if (!v) {
                      _medicaoSelecionada = null;
                    }
                  });
                },
              ),

              const SizedBox(height: 8),

              if (_jaCalibrouPatinagem) ...[
                _dropdownCalibragemPatinagem(),
                if (_medicaoSelecionada != null) ...[
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Calibragem selecionada',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _linhaInfo('Nome', _medicaoSelecionada!.nome),
                          _linhaInfo(
                            'Patinagem',
                            '${_medicaoSelecionada!.patinagem.toStringAsFixed(2)} %',
                          ),
                          _linhaInfo(
                            'Distância',
                            '${_medicaoSelecionada!.distancia.toStringAsFixed(2)} m',
                          ),
                          _linhaInfo(
                            'Voltas',
                            _medicaoSelecionada!.voltas.toString(),
                          ),
                          _linhaInfo(
                            'Coord. inicial',
                            _formatarCoord(
                              _medicaoSelecionada!.coordenadaInicialY,
                              _medicaoSelecionada!.coordenadaInicialX,
                            ),
                          ),
                          _linhaInfo(
                            'Coord. final',
                            _formatarCoord(
                              _medicaoSelecionada!.coordenadaFinalY,
                              _medicaoSelecionada!.coordenadaFinalX,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],

              if (!_jaCalibrouPatinagem)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        const Text(
                          'Para continuar, faça a calibragem da patinagem primeiro.',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _irParaCalibragem,
                            icon: const Icon(Icons.speed),
                            label: const Text('Fazer calibragem'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _observacoesCtrl,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Observações',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _salvando ? null : _medir,
                  icon: const Icon(Icons.analytics),
                  label: _salvando
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Medir'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _secaoPropriedade() {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FutureBuilder<List<PropriedadeModel>>(
          future: PropriedadeService().listarPorUsuario(uid),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final propriedades = snapshot.data ?? [];

            return DropdownButtonFormField<PropriedadeModel>(
              value: _propriedadeSelecionada,
              isExpanded: true,
              items: propriedades
                  .map(
                    (p) => DropdownMenuItem(
                      value: p,
                      child: Text(p.nome, overflow: TextOverflow.ellipsis),
                    ),
                  )
                  .toList(),
              onChanged: (v) {
                setState(() {
                  _propriedadeSelecionada = v;
                  _medicaoSelecionada = null;
                });
              },
              decoration: const InputDecoration(
                labelText: 'Propriedade',
                border: OutlineInputBorder(),
              ),
              validator: (v) => v == null ? 'Selecione uma propriedade' : null,
            );
          },
        ),
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const CadastroPropriedadePage(),
              ),
            );
            _recarregar();
          },
          icon: const Icon(Icons.add),
          label: const Text('Adicionar nova propriedade'),
        ),
      ],
    );
  }

  Widget _secaoVeiculo() {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FutureBuilder<List<VeiculoModel>>(
          future: VeiculoService().listarVeiculosPorUsuario(uid),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final veiculos = snapshot.data ?? [];

            return DropdownButtonFormField<VeiculoModel>(
              value: _veiculoSelecionado,
              isExpanded: true,
              items: veiculos
                  .map(
                    (v) => DropdownMenuItem(
                      value: v,
                      child: Text(v.nome, overflow: TextOverflow.ellipsis),
                    ),
                  )
                  .toList(),
              onChanged: (v) {
                setState(() {
                  _veiculoSelecionado = v;
                  _medicaoSelecionada = null;
                });
              },
              decoration: const InputDecoration(
                labelText: 'Máquina',
                border: OutlineInputBorder(),
              ),
              validator: (v) => v == null ? 'Selecione uma máquina' : null,
            );
          },
        ),
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CadastroVeiculoPage()),
            );
            _recarregar();
          },
          icon: const Icon(Icons.add),
          label: const Text('Adicionar nova máquina'),
        ),
      ],
    );
  }

  Widget _dropdownCalibragemPatinagem() {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return FutureBuilder<List<MedicaoModel>>(
      future: MedicaoService().listarPorUsuario(uid),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        var medicoes = snapshot.data ?? [];

        if (_propriedadeSelecionada != null) {
          medicoes = medicoes
              .where((m) => m.propriedadeId == _propriedadeSelecionada!.id)
              .toList();
        }

        if (_veiculoSelecionado != null) {
          medicoes = medicoes
              .where((m) => m.veiculoId == _veiculoSelecionado!.id)
              .toList();
        }

        if (medicoes.isEmpty) {
          return const Text(
            'Nenhuma calibragem encontrada para a propriedade/máquina selecionada.',
            style: TextStyle(color: Colors.red),
          );
        }

        return DropdownButtonFormField<MedicaoModel>(
          value: _medicaoSelecionada,
          isExpanded: true,
          selectedItemBuilder: (context) {
            return medicoes.map((m) {
              return Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '${m.nome} - ${m.patinagem.toStringAsFixed(2)}%',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList();
          },
          items: medicoes.map((m) {
            return DropdownMenuItem<MedicaoModel>(
              value: m,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    m.nome,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    'Patinagem: ${m.patinagem.toStringAsFixed(2)}%',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (v) {
            setState(() {
              _medicaoSelecionada = v;
            });
          },
          decoration: const InputDecoration(
            labelText: 'Calibragem de patinagem',
            border: OutlineInputBorder(),
          ),
          validator: (v) {
            if (_jaCalibrouPatinagem && v == null) {
              return 'Selecione uma calibragem';
            }
            return null;
          },
        );
      },
    );
  }

  Widget _linhaInfo(String titulo, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              titulo,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(valor)),
        ],
      ),
    );
  }
}
