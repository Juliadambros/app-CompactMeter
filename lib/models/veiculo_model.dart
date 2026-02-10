import 'roda_model.dart';

class VeiculoModel {
  final String id;
  final String nome;
  final String? descricao;
  final String tipo;
  final String usuarioId;
  final List<RodaModel> rodas;

  VeiculoModel({
    required this.id,
    required this.nome,
    this.descricao,
    required this.tipo,
    required this.usuarioId,
    required this.rodas,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'nome': nome,
        'descricao': descricao,
        'tipo': tipo,
        'usuarioId': usuarioId,
        'rodas': rodas.map((r) => r.toMap()).toList(),
      };

  factory VeiculoModel.fromMap(Map<String, dynamic> map) => VeiculoModel(
        id: map['id'],
        nome: map['nome'],
        descricao: map['descricao'],
        tipo: map['tipo'],
        usuarioId: map['usuarioId'],
        rodas: (map['rodas'] as List)
            .map((r) => RodaModel.fromMap(r))
            .toList(),
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VeiculoModel && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
