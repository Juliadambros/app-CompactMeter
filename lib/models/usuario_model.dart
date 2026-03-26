import 'package:cloud_firestore/cloud_firestore.dart';

class UsuarioModel {
  final String uid;
  final String nome;
  final String email;
  final String tipoUsuario;
  final bool excluido;
  final DateTime? dataExclusao;

  UsuarioModel({
    required this.uid,
    required this.nome,
    required this.email,
    required this.tipoUsuario,
    this.excluido = false,
    this.dataExclusao,
  });

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'nome': nome,
        'email': email,
        'tipoUsuario': tipoUsuario,
        'excluido': excluido,
        'dataExclusao': dataExclusao != null ? Timestamp.fromDate(dataExclusao!) : null,
      };

  factory UsuarioModel.fromMap(Map<String, dynamic> map) => UsuarioModel(
        uid: (map['uid'] ?? '').toString(),
        nome: (map['nome'] ?? '').toString(),
        email: (map['email'] ?? '').toString(),
        tipoUsuario: (map['tipoUsuario'] ?? 'usuario').toString(),
        excluido: map['excluido'] == true,
        dataExclusao: map['dataExclusao'] is Timestamp
            ? (map['dataExclusao'] as Timestamp).toDate()
            : null,
      );
}

