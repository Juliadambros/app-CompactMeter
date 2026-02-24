import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

class MedicaoModel {
  final String id;

  final String usuarioId;
  final String propriedadeId;
  final String veiculoId;
  final String rodaId;

  final String nome;
  final DateTime data;

  final double raioEixo;
  final double distancia;
  final int voltas;

  final double perimetro;
  final double patinagem;

  MedicaoModel({
    required this.id,
    required this.usuarioId,
    required this.propriedadeId,
    required this.veiculoId,
    required this.rodaId,
    required this.nome,
    required this.data,
    required this.raioEixo,
    required this.distancia,
    required this.voltas,
    required this.perimetro,
    required this.patinagem,
  });

  factory MedicaoModel.criar({
    required String id,
    required String usuarioId,
    required String propriedadeId,
    required String veiculoId,
    required String rodaId,
    required String nome,
    required double raioEixo,
    required double distancia,
    required int voltas,
  }) {
    final perimetro = 2 * pi * raioEixo;

    final patinagem = voltas == 0
        ? 0.0
        : 100 - (((distancia / voltas) * 100) / perimetro);

    return MedicaoModel(
      id: id,
      usuarioId: usuarioId,
      propriedadeId: propriedadeId,
      veiculoId: veiculoId,
      rodaId: rodaId,
      nome: nome,
      data: DateTime.now(),
      raioEixo: raioEixo,
      distancia: distancia,
      voltas: voltas,
      perimetro: perimetro,
      patinagem: patinagem,
    );
  }

  factory MedicaoModel.fromMap(Map<String, dynamic> map, String id) {
    String readString(String key, {String fallback = ''}) {
      final v = map[key];
      if (v == null) return fallback;
      if (v is String) return v;
      return v.toString();
    }

    double readDouble(String key, {double fallback = 0.0}) {
      final v = map[key];
      if (v == null) return fallback;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString()) ?? fallback;
    }

    int readInt(String key, {int fallback = 0}) {
      final v = map[key];
      if (v == null) return fallback;
      if (v is num) return v.toInt();
      return int.tryParse(v.toString()) ?? fallback;
    }

    DateTime readDate(String key) {
      final v = map[key];
      if (v is Timestamp) return v.toDate();
      return DateTime.now();
    }

    return MedicaoModel(
      id: id,
      usuarioId: readString('usuarioId', fallback: 'DESCONHECIDO'),
      propriedadeId: readString('propriedadeId', fallback: ''),
      veiculoId: readString('veiculoId', fallback: ''),
      rodaId: readString('rodaId', fallback: ''),
      nome: readString('nome', fallback: 'Medição sem nome'),
      data: readDate('data'),
      raioEixo: readDouble('raioEixo'),
      distancia: readDouble('distancia'),
      voltas: readInt('voltas'),
      perimetro: readDouble('perimetro'),
      patinagem: readDouble('patinagem'),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'usuarioId': usuarioId,
      'propriedadeId': propriedadeId,
      'veiculoId': veiculoId,
      'rodaId': rodaId,
      'nome': nome,
      'data': Timestamp.fromDate(data),
      'raioEixo': raioEixo,
      'distancia': distancia,
      'voltas': voltas,
      'perimetro': perimetro,
      'patinagem': patinagem,
    };
  }
}
