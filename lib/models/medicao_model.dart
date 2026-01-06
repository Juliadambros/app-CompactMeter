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
        'data': data.toIso8601String(),
        'usuarioId': usuarioId,
      };

  factory MedicaoModel.fromMap(Map<String, dynamic> map) => MedicaoModel(
        id: map['id'],
        nome: map['nome'],
        propriedade: map['propriedade'],
        veiculoId: map['veiculoId'],
        distanciaReal: (map['distanciaReal'] as num).toDouble(),
        rotacoes: map['rotacoes'],
        patinagem: (map['patinagem'] as num).toDouble(),
        data: DateTime.parse(map['data']),
        usuarioId: map['usuarioId'],
      );
}
