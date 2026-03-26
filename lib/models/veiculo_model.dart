import 'package:cloud_firestore/cloud_firestore.dart';

import 'roda_model.dart';

class VeiculoModel {
  final String id;
  final String nome;
  final String? descricao;
  final String tipo;
  final String usuarioId;
  final List<RodaModel> rodas;
  final bool excluido;
  final DateTime? dataExclusao;

  VeiculoModel({
    required this.id,
    required this.nome,
    this.descricao,
    required this.tipo,
    required this.usuarioId,
    required this.rodas,
    this.excluido = false,
    this.dataExclusao,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'nome': nome,
        'descricao': descricao,
        'tipo': tipo,
        'usuarioId': usuarioId,
        'rodas': rodas.map((r) => r.toMap()).toList(),
        'excluido': excluido,
        'dataExclusao': dataExclusao != null ? Timestamp.fromDate(dataExclusao!) : null,
      };

  factory VeiculoModel.fromMap(Map<String, dynamic> map) => VeiculoModel(
        id: (map['id'] ?? '').toString(),
        nome: (map['nome'] ?? '').toString(),
        descricao: map['descricao']?.toString(),
        tipo: (map['tipo'] ?? '').toString(),
        usuarioId: (map['usuarioId'] ?? '').toString(),
        rodas: ((map['rodas'] as List?) ?? const [])
            .map((r) => RodaModel.fromMap(Map<String, dynamic>.from(r as Map)))
            .toList(),
        excluido: map['excluido'] == true,
        dataExclusao: map['dataExclusao'] is Timestamp
            ? (map['dataExclusao'] as Timestamp).toDate()
            : null,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is VeiculoModel && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
