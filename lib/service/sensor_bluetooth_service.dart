import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bluetooth_classic_serial/flutter_bluetooth_classic.dart';

class SensorLeitura {
  final double grausAcumulados;
  final int voltas;
  final String linhaOriginal;
  final DateTime recebidaEm;

  const SensorLeitura({
    required this.grausAcumulados,
    required this.voltas,
    required this.linhaOriginal,
    required this.recebidaEm,
  });

  @override
  String toString() {
    return 'SensorLeitura(graus: $grausAcumulados, voltas: $voltas, linha: $linhaOriginal)';
  }
}

class SensorBluetoothService {
  final FlutterBluetoothClassic _bluetooth = FlutterBluetoothClassic();

  StreamSubscription<BluetoothConnectionState>? _connectionSub;
  StreamSubscription<BluetoothData>? _dataSub;
  StreamSubscription<BluetoothState>? _stateSub;

  final StreamController<SensorLeitura> _leiturasController =
      StreamController<SensorLeitura>.broadcast();

  final StreamController<String> _linhasController =
      StreamController<String>.broadcast();

  final StreamController<String> _statusController =
      StreamController<String>.broadcast();

  SensorLeitura? _ultimaLeitura;
  bool _bluetoothLigado = false;
  bool _conectado = false;
  String? _deviceAddressAtual;

  Stream<SensorLeitura> get leituras => _leiturasController.stream;
  Stream<String> get linhasBrutas => _linhasController.stream;
  Stream<String> get status => _statusController.stream;

  SensorLeitura? get ultimaLeitura => _ultimaLeitura;
  bool get bluetoothLigado => _bluetoothLigado;
  bool get conectado => _conectado;
  String? get deviceAddressAtual => _deviceAddressAtual;

  Future<void> inicializar() async {
    try {
      final supported = await _bluetooth.isBluetoothSupported();
      if (!supported) {
        _emitStatus('Bluetooth não suportado neste dispositivo');
        return;
      }

      _bluetoothLigado = await _bluetooth.isBluetoothEnabled();
      _emitStatus(
        _bluetoothLigado ? 'Bluetooth ligado' : 'Bluetooth desligado',
      );

      _setupListeners();
    } catch (e) {
      _emitStatus('Erro ao inicializar Bluetooth: $e');
    }
  }

  void _setupListeners() {
    _stateSub?.cancel();
    _connectionSub?.cancel();
    _dataSub?.cancel();

    _stateSub = _bluetooth.onStateChanged.listen(
      (state) {
        _bluetoothLigado = state.isEnabled;
        _emitStatus(
          state.isEnabled ? 'Bluetooth ligado' : 'Bluetooth desligado',
        );
      },
      onError: (e) {
        _emitStatus('Erro no estado do Bluetooth: $e');
      },
    );

    _connectionSub = _bluetooth.onConnectionChanged.listen(
      (connectionState) {
        _conectado = connectionState.isConnected;
        _deviceAddressAtual = connectionState.deviceAddress;

        if (_conectado) {
          _emitStatus('Conectado em ${connectionState.deviceAddress}');
        } else {
          _emitStatus('Desconectado: ${connectionState.status}');
        }
      },
      onError: (e) {
        _emitStatus('Erro de conexão: $e');
      },
    );

    _dataSub = _bluetooth.onDataReceived.listen(
      (data) {
        final texto = data.asString();
        if (texto.isEmpty) return;

        final linhas = texto
            .split(RegExp(r'[\r\n]+'))
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty);

        for (final linha in linhas) {
          _linhasController.add(linha);

          final leitura = _parseLinhaSensor(linha);
          if (leitura != null) {
            _ultimaLeitura = leitura;
            _leiturasController.add(leitura);
          }
        }
      },
      onError: (e) {
        _emitStatus('Erro ao receber dados: $e');
      },
    );
  }

  Future<List<BluetoothDevice>> listarDispositivosPareados() async {
    try {
      return await _bluetooth.getPairedDevices();
    } catch (e) {
      _emitStatus('Erro ao buscar dispositivos pareados: $e');
      return [];
    }
  }

  Future<bool> conectar(String address) async {
    try {
      _emitStatus('Conectando em $address...');
      final ok = await _bluetooth.connect(address);

      if (ok) {
        _conectado = true;
        _deviceAddressAtual = address;
        _emitStatus('Conectado em $address');
      } else {
        _conectado = false;
        _emitStatus('Falha ao conectar em $address');
      }

      return ok;
    } catch (e) {
      _conectado = false;
      _emitStatus('Erro ao conectar: $e');
      return false;
    }
  }

  Future<bool> desconectar() async {
    try {
      final ok = await _bluetooth.disconnect();
      _conectado = false;
      _deviceAddressAtual = null;
      _emitStatus(ok ? 'Desconectado' : 'Falha ao desconectar');
      return ok;
    } catch (e) {
      _emitStatus('Erro ao desconectar: $e');
      return false;
    }
  }

  Future<bool> enviarString(String texto) async {
    try {
      final ok = await _bluetooth.sendString(texto);
      if (!ok) {
        _emitStatus('Falha ao enviar texto');
      }
      return ok;
    } catch (e) {
      _emitStatus('Erro ao enviar texto: $e');
      return false;
    }
  }

  Future<bool> bluetoothDisponivelEAtivo() async {
    try {
      final supported = await _bluetooth.isBluetoothSupported();
      final enabled = await _bluetooth.isBluetoothEnabled();
      return supported && enabled;
    } catch (_) {
      return false;
    }
  }

  SensorLeitura? _parseLinhaSensor(String linha) {

    final regex = RegExp(
      r'Graus\s+acumulados\s*\(horario\):\s*([0-9]+(?:[.,][0-9]+)?)°\s*\|\s*Voltas:\s*([0-9]+)',
      caseSensitive: false,
    );

    final match = regex.firstMatch(linha);
    if (match == null) return null;

    final grausTxt = (match.group(1) ?? '').replaceAll(',', '.');
    final voltasTxt = match.group(2) ?? '';

    final graus = double.tryParse(grausTxt);
    final voltas = int.tryParse(voltasTxt);

    if (graus == null || voltas == null) {
      return null;
    }

    return SensorLeitura(
      grausAcumulados: graus,
      voltas: voltas,
      linhaOriginal: linha,
      recebidaEm: DateTime.now(),
    );
  }

  void _emitStatus(String mensagem) {
    debugPrint('[SensorBluetoothService] $mensagem');
    if (!_statusController.isClosed) {
      _statusController.add(mensagem);
    }
  }

  Future<void> dispose() async {
    await _connectionSub?.cancel();
    await _dataSub?.cancel();
    await _stateSub?.cancel();
    await _leiturasController.close();
    await _linhasController.close();
    await _statusController.close();
  }
}