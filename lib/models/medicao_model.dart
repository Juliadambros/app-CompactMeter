class MedicaoModel {
  final String id;
  final String nome;
  final String propriedade;
  final String veiculoId;

  final double distanciaInformada; // metros
  final double grausAcumulados;    // sensor
  final double patinagem;          

  final String usuarioId;

  MedicaoModel({
    required this.id,
    required this.nome,
    required this.propriedade,
    required this.veiculoId,
    required this.distanciaInformada,
    required this.grausAcumulados,
    required this.patinagem,
    required this.usuarioId,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'nome': nome,
        'propriedade': propriedade,
        'veiculoId': veiculoId,
        'distanciaInformada': distanciaInformada,
        'grausAcumulados': grausAcumulados,
        'patinagem': patinagem,
        'usuarioId': usuarioId,
      };

  factory MedicaoModel.fromMap(Map<String, dynamic> map) {

    return MedicaoModel(
      id: map['id'],
      nome: map['nome'],
      propriedade: map['propriedade'],
      veiculoId: map['veiculoId'],
      distanciaInformada: (map['distanciaInformada'] as num).toDouble(),
      grausAcumulados: (map['grausAcumulados'] as num).toDouble(),
      patinagem: (map['patinagem'] as num).toDouble(),
      usuarioId: map['usuarioId'],
    );
  }

}
