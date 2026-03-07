import 'package:cloud_firestore/cloud_firestore.dart';

class CompactacaoModel {
  final String id;
  final String usuarioId;
  final String propriedadeId;
  final String veiculoId;

  final String nome;
  final DateTime data;

  final bool calibragemRealizada;
  final String? medicaoPatinagemId;
  final double? patinagemReferencia;

  final double? indiceCompactacao;
  final String statusCalculo;
  final String? observacoes;

  CompactacaoModel({
    required this.id,
    required this.usuarioId,
    required this.propriedadeId,
    required this.veiculoId,
    required this.nome,
    required this.data,
    required this.calibragemRealizada,
    this.medicaoPatinagemId,
    this.patinagemReferencia,
    this.indiceCompactacao,
    required this.statusCalculo,
    this.observacoes,
  });

  factory CompactacaoModel.criar({
    required String id,
    required String usuarioId,
    required String propriedadeId,
    required String veiculoId,
    required String nome,
    required bool calibragemRealizada,
    String? medicaoPatinagemId,
    double? patinagemReferencia,
    double? indiceCompactacao,
    String? observacoes,
  }) {
    return CompactacaoModel(
      id: id,
      usuarioId: usuarioId,
      propriedadeId: propriedadeId,
      veiculoId: veiculoId,
      nome: nome,
      data: DateTime.now(),
      calibragemRealizada: calibragemRealizada,
      medicaoPatinagemId: medicaoPatinagemId,
      patinagemReferencia: patinagemReferencia,
      indiceCompactacao: indiceCompactacao,
      statusCalculo: indiceCompactacao == null
          ? 'Aguardando definição da fórmula'
          : 'Calculado',
      observacoes: observacoes,
    );
  }

  factory CompactacaoModel.fromMap(Map<String, dynamic> map, String id) {
    String readString(String key, {String fallback = ''}) {
      final v = map[key];
      if (v == null) return fallback;
      if (v is String) return v;
      return v.toString();
    }

    double? readNullableDouble(String key) {
      final v = map[key];
      if (v == null) return null;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString());
    }

    bool readBool(String key, {bool fallback = false}) {
      final v = map[key];
      if (v == null) return fallback;
      if (v is bool) return v;
      if (v is String) return v.toLowerCase() == 'true';
      return fallback;
    }

    DateTime readDate(String key) {
      final v = map[key];
      if (v is Timestamp) return v.toDate();
      return DateTime.now();
    }

    return CompactacaoModel(
      id: id,
      usuarioId: readString('usuarioId'),
      propriedadeId: readString('propriedadeId'),
      veiculoId: readString('veiculoId'),
      nome: readString('nome', fallback: 'Medição de compactação'),
      data: readDate('data'),
      calibragemRealizada: readBool('calibragemRealizada'),
      medicaoPatinagemId: map['medicaoPatinagemId'],
      patinagemReferencia: readNullableDouble('patinagemReferencia'),
      indiceCompactacao: readNullableDouble('indiceCompactacao'),
      statusCalculo: readString(
        'statusCalculo',
        fallback: 'Aguardando definição da fórmula',
      ),
      observacoes: map['observacoes'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'usuarioId': usuarioId,
      'propriedadeId': propriedadeId,
      'veiculoId': veiculoId,
      'nome': nome,
      'data': Timestamp.fromDate(data),
      'calibragemRealizada': calibragemRealizada,
      'medicaoPatinagemId': medicaoPatinagemId,
      'patinagemReferencia': patinagemReferencia,
      'indiceCompactacao': indiceCompactacao,
      'statusCalculo': statusCalculo,
      'observacoes': observacoes,
    };
  }
}