import 'package:app_compactmeter/view/usuario/propriedades/cadastro_propriedade_page.dart';
import 'package:app_compactmeter/view/usuario/veiculos/cadastro_veiculo_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bluetooth_classic_serial/flutter_bluetooth_classic.dart';

import '../../../models/medicao_model.dart';
import '../../../models/propriedade_model.dart';
import '../../../models/veiculo_model.dart';
import '../../../models/roda_model.dart';

import '../../../service/medicao_service.dart';
import '../../../service/propriedade_service.dart';
import '../../../service/veiculo_service.dart';
import '../../../service/sensor_bluetooth_service.dart';

import 'resultado_medicao_page.dart';

class CalibrarPatinagemPage extends StatefulWidget {
  const CalibrarPatinagemPage({super.key});

  @override
  State<CalibrarPatinagemPage> createState() => _CalibrarPatinagemPageState();
}

class _CalibrarPatinagemPageState extends State<CalibrarPatinagemPage> {
  final _formKey = GlobalKey<FormState>();

  final _nomeCtrl = TextEditingController();
  final _distanciaCtrl = TextEditingController();

  final SensorBluetoothService _sensorService = SensorBluetoothService();

  PropriedadeModel? _propriedadeSelecionada;
  VeiculoModel? _veiculoSelecionado;
  RodaModel? _rodaSelecionada;
  BluetoothDevice? _dispositivoSelecionado;

  bool _carregando = false;
  bool _carregandoBluetooth = true;
  bool _sensorConectado = false;

  double _grausSensor = 0;
  int _voltasSensor = 0;
  String _statusSensor = 'Desconectado';

  List<BluetoothDevice> _dispositivosPareados = [];

  void _recarregar() => setState(() {});

  @override
  void initState() {
    super.initState();
    _inicializarBluetooth();
  }

  Future<void> _inicializarBluetooth() async {
    await _sensorService.inicializar();

    _sensorService.status.listen((msg) {
      if (!mounted) return;
      setState(() {
        _statusSensor = msg;
      });
    });

    _sensorService.leituras.listen((leitura) {
      if (!mounted) return;
      setState(() {
        _grausSensor = leitura.grausAcumulados;
        _voltasSensor = leitura.voltas;
      });
    });

    await _carregarDispositivosPareados();
  }

  Future<void> _carregarDispositivosPareados() async {
    setState(() => _carregandoBluetooth = true);

    final dispositivos = await _sensorService.listarDispositivosPareados();

    if (!mounted) return;

    setState(() {
      _dispositivosPareados = dispositivos;
      _carregandoBluetooth = false;

      if (_dispositivoSelecionado != null) {
        final aindaExiste = dispositivos.any(
          (d) => d.address == _dispositivoSelecionado!.address,
        );
        if (!aindaExiste) {
          _dispositivoSelecionado = null;
        }
      }
    });
  }

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _distanciaCtrl.dispose();
    _sensorService.dispose();
    super.dispose();
  }

  Future<void> _conectarSensor() async {
    if (_dispositivoSelecionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione um sensor Bluetooth')),
      );
      return;
    }

    final address = _dispositivoSelecionado!.address;
    if (address.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Endereço Bluetooth inválido')),
      );
      return;
    }

    final ok = await _sensorService.conectar(address);

    if (!mounted) return;

    setState(() {
      _sensorConectado = ok;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok ? 'Sensor conectado com sucesso' : 'Falha ao conectar no sensor',
        ),
      ),
    );
  }

  Future<void> _desconectarSensor() async {
    await _sensorService.desconectar();

    if (!mounted) return;

    setState(() {
      _sensorConectado = false;
      _statusSensor = 'Desconectado';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Calibrar Patinagem')),
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
              _campoDistancia(),
              const SizedBox(height: 16),
              _secaoBluetooth(),
              const SizedBox(height: 16),
              _secaoLeituraSensor(),
              const SizedBox(height: 24),
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
        labelText: 'Nome da calibragem',
        border: OutlineInputBorder(),
      ),
      validator: (v) {
        if (v == null || v.trim().isEmpty) {
          return 'Informe o nome da calibragem';
        }
        return null;
      },
    );
  }

  Widget _campoDistancia() {
    return TextFormField(
      controller: _distanciaCtrl,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: const InputDecoration(
        labelText: 'Distância percorrida (m)',
        border: OutlineInputBorder(),
      ),
      validator: (v) {
        if (v == null || v.trim().isEmpty) return 'Informe a distância';
        final valor = double.tryParse(v.replaceAll(',', '.'));
        if (valor == null || valor <= 0) return 'Distância inválida';
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
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return FutureBuilder<List<PropriedadeModel>>(
      future: PropriedadeService().listarPorUsuario(uid),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final propriedades = snapshot.data ?? [];

        return DropdownButtonFormField<PropriedadeModel>(
          value: _propriedadeSelecionada,
          items: propriedades
              .map((p) => DropdownMenuItem(value: p, child: Text(p.nome)))
              .toList(),
          onChanged: (v) {
            setState(() {
              _propriedadeSelecionada = v;
            });
          },
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
          texto: 'Adicionar nova máquina',
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
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return FutureBuilder<List<VeiculoModel>>(
      future: VeiculoService().listarVeiculosPorUsuario(uid),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final veiculos = snapshot.data ?? [];

        return DropdownButtonFormField<VeiculoModel>(
          value: _veiculoSelecionado,
          items: veiculos
              .map((v) => DropdownMenuItem(value: v, child: Text(v.nome)))
              .toList(),
          onChanged: (v) {
            setState(() {
              _veiculoSelecionado = v;
              _rodaSelecionada = null;
              _resetarLeituraSensor();
            });
          },
          decoration: const InputDecoration(
            labelText: 'Máquina',
            border: OutlineInputBorder(),
          ),
          validator: (v) => v == null ? 'Selecione uma máquina' : null,
        );
      },
    );
  }

  Widget _dropdownRodas() {
    if (_veiculoSelecionado == null) {
      return const SizedBox();
    }

    final rodas = _veiculoSelecionado!.rodas
        .where((r) => r.circunferencia != null && r.circunferencia! > 0)
        .toList();

    if (rodas.isEmpty) {
      return const Text(
        'Esta máquina não possui rodas com circunferência cadastrada',
        style: TextStyle(color: Colors.red),
      );
    }

    return DropdownButtonFormField<RodaModel>(
      value: _rodaSelecionada,
      items: rodas
          .map(
            (r) => DropdownMenuItem(
              value: r,
              child: Text(
                '${r.posicao} (${r.circunferencia!.toStringAsFixed(2)} m)',
              ),
            ),
          )
          .toList(),
      onChanged: (v) {
        setState(() {
          _rodaSelecionada = v;
          _resetarLeituraSensor();
        });
      },
      decoration: const InputDecoration(
        labelText: 'Roda usada na calibragem',
        border: OutlineInputBorder(),
      ),
      validator: (v) => v == null ? 'Selecione a roda' : null,
    );
  }

  Widget _secaoBluetooth() {
  return Card(
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Sensor Bluetooth',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          if (_carregandoBluetooth)
            const Center(child: CircularProgressIndicator())
          else if (_dispositivosPareados.isEmpty)
            const Text(
              'Nenhum dispositivo Bluetooth pareado encontrado.\n'
              'Pareie o sensor nas configurações do celular e toque em "Atualizar lista".',
              style: TextStyle(color: Colors.red),
            )
          else
            DropdownButtonFormField<BluetoothDevice>(
              value: _dispositivoSelecionado,
              isExpanded: true,
              items: _dispositivosPareados.map((d) {
                final texto = d.name?.trim().isNotEmpty == true
                    ? '${d.name} (${d.address})'
                    : d.address;

                return DropdownMenuItem<BluetoothDevice>(
                  value: d,
                  child: Text(
                    texto,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              onChanged: (v) {
                setState(() {
                  _dispositivoSelecionado = v;
                  _resetarLeituraSensor();
                });
              },
              decoration: const InputDecoration(
                labelText: 'Dispositivo pareado',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  v == null ? 'Selecione um sensor Bluetooth' : null,
            ),

          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _carregarDispositivosPareados,
              icon: const Icon(Icons.refresh),
              label: const Text('Atualizar lista'),
            ),
          ),

          const SizedBox(height: 12),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed:
                      _dispositivoSelecionado == null ? null : _conectarSensor,
                  icon: const Icon(Icons.bluetooth),
                  label: const Text('Conectar sensor'),
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _sensorConectado ? _desconectarSensor : null,
                  icon: const Icon(Icons.bluetooth_disabled),
                  label: const Text('Desconectar'),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

  Widget _secaoLeituraSensor() {
    final circ = _rodaSelecionada?.circunferencia;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Leitura do sensor',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Status: $_statusSensor'),
            const SizedBox(height: 4),
            Text('Graus acumulados: ${_grausSensor.toStringAsFixed(1)}°'),
            const SizedBox(height: 4),
            Text('Voltas detectadas: $_voltasSensor'),
            const SizedBox(height: 4),
            Text(
              'Circunferência da roda: ${circ != null ? '${circ.toStringAsFixed(2)} m' : '—'}',
            ),
          ],
        ),
      ),
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
      onPressed: _carregando ? null : _calcularPatinagem,
      child: _carregando
          ? const SizedBox(
              height: 22,
              width: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : const Text('Calcular patinagem'),
    );
  }

  void _resetarLeituraSensor() {
    _sensorConectado = false;
    _grausSensor = 0;
    _voltasSensor = 0;
    _statusSensor = 'Desconectado';
  }

  Future<void> _calcularPatinagem() async {
    if (!_formKey.currentState!.validate()) return;

    if (_propriedadeSelecionada == null ||
        _veiculoSelecionado == null ||
        _rodaSelecionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha todos os campos da calibragem')),
      );
      return;
    }

    final circunferencia = _rodaSelecionada!.circunferencia;
    if (circunferencia == null || circunferencia <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('A roda selecionada não possui circunferência válida'),
        ),
      );
      return;
    }

    if (!_sensorConectado) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Conecte o sensor antes de calcular')),
      );
      return;
    }

    if (_voltasSensor <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nenhuma leitura válida de voltas foi recebida'),
        ),
      );
      return;
    }

    setState(() => _carregando = true);

    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final distancia =
          double.parse(_distanciaCtrl.text.trim().replaceAll(',', '.'));

      final medicao = MedicaoModel.criar(
        id: FirebaseFirestore.instance.collection('medicoes').doc().id,
        usuarioId: uid,
        propriedadeId: _propriedadeSelecionada!.id,
        veiculoId: _veiculoSelecionado!.id,
        rodaId: _rodaSelecionada!.posicao,
        nome: _nomeCtrl.text.trim(),
        circunferencia: circunferencia,
        distancia: distancia,
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
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao calcular a patinagem: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _carregando = false);
      }
    }
  }
}