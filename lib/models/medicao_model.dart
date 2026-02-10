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
    return MedicaoModel(
      id: id,
      usuarioId: map['usuarioId'],
      propriedadeId: map['propriedadeId'],
      veiculoId: map['veiculoId'],
      rodaId: map['rodaId'],
      nome: map['nome'],
      data: (map['data'] as Timestamp).toDate(),
      raioEixo: (map['raioEixo'] as num).toDouble(),
      distancia: (map['distancia'] as num).toDouble(),
      voltas: map['voltas'],
      perimetro: (map['perimetro'] as num).toDouble(),
      patinagem: (map['patinagem'] as num).toDouble(),
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

