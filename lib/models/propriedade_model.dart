class PropriedadeModel {
  final String id;
  final String nome;
  final String dono;
  final String usuarioId;
  final String endereco;

  PropriedadeModel({
    required this.id,
    required this.nome,
    required this.dono,
    required this.usuarioId,
    required this.endereco,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'nome': nome,
        'dono': dono,
        'usuarioId': usuarioId,
        'endereco': endereco,
      };

  factory PropriedadeModel.fromMap(Map<String, dynamic> map) {
    return PropriedadeModel(
      id: map['id'],
      nome: map['nome'],
      dono: map['dono'],
      usuarioId: map['usuarioId'],
      endereco: map['endereco'],
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PropriedadeModel && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
