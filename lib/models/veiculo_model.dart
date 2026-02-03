class VeiculoModel {
  final String id;
  final String nome;
  final double circunferenciaRoda;
  final String tipo; 
  final String usuarioId; 

  VeiculoModel({
    required this.id,
    required this.nome,
    required this.circunferenciaRoda,
    required this.tipo,
    required this.usuarioId,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'nome': nome,
        'circunferenciaRoda': circunferenciaRoda,
        'tipo': tipo,
        'usuarioId': usuarioId,
      };

  factory VeiculoModel.fromMap(Map<String, dynamic> map) => VeiculoModel(
        id: map['id'],
        nome: map['nome'],
        circunferenciaRoda: (map['circunferenciaRoda'] as num).toDouble(),
        tipo: map['tipo'],
        usuarioId: map['usuarioId'],
      );
}


