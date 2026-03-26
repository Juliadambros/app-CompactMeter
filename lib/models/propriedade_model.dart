import 'package:cloud_firestore/cloud_firestore.dart';

class PropriedadeModel {
  final String id;
  final String nome;
  final String dono;
  final String usuarioId;
  final String endereco;
  final bool excluido;
  final DateTime? dataExclusao;

  PropriedadeModel({
    required this.id,
    required this.nome,
    required this.dono,
    required this.usuarioId,
    required this.endereco,
    this.excluido = false,
    this.dataExclusao,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'nome': nome,
        'dono': dono,
        'usuarioId': usuarioId,
        'endereco': endereco,
        'excluido': excluido,
        'dataExclusao': dataExclusao != null ? Timestamp.fromDate(dataExclusao!) : null,
      };

  factory PropriedadeModel.fromMap(Map<String, dynamic> map) {
    return PropriedadeModel(
      id: (map['id'] ?? '').toString(),
      nome: (map['nome'] ?? '').toString(),
      dono: (map['dono'] ?? '').toString(),
      usuarioId: (map['usuarioId'] ?? '').toString(),
      endereco: (map['endereco'] ?? '').toString(),
      excluido: map['excluido'] == true,
      dataExclusao: map['dataExclusao'] is Timestamp
          ? (map['dataExclusao'] as Timestamp).toDate()
          : null,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is PropriedadeModel && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

