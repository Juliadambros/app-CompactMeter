import 'package:cloud_firestore/cloud_firestore.dart';

class MedicaoModel {
  final String id;
  final String nome;
  final String propriedade;
  final String veiculoId;
  final double distanciaReal;
  final int rotacoes;
  final double patinagem;
  final DateTime data;
  final String usuarioId;

  MedicaoModel({
    required this.id,
    required this.nome,
    required this.propriedade,
    required this.veiculoId,
    required this.distanciaReal,
    required this.rotacoes,
    required this.patinagem,
    required this.data,
    required this.usuarioId,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'nome': nome,
    'propriedade': propriedade,
    'veiculoId': veiculoId,
    'distanciaReal': distanciaReal,
    'rotacoes': rotacoes,
    'patinagem': patinagem,
    'data': Timestamp.fromDate(data),
    'usuarioId': usuarioId,
  };

  factory MedicaoModel.fromMap(Map<String, dynamic> map) {
    DateTime dataConvertida;

    final rawData = map['data'];

    if (rawData is Timestamp) {
      dataConvertida = rawData.toDate();
    } else if (rawData is String) {
      dataConvertida = DateTime.parse(rawData);
    } else {
      dataConvertida = DateTime.now(); // fallback
    }

    return MedicaoModel(
      id: map['id'],
      nome: map['nome'],
      propriedade: map['propriedade'],
      veiculoId: map['veiculoId'],
      distanciaReal: (map['distanciaReal'] as num).toDouble(),
      rotacoes: (map['rotacoes'] as num).toInt(),
      patinagem: (map['patinagem'] as num).toDouble(),
      data: dataConvertida,
      usuarioId: map['usuarioId'],
    );
  }
}
