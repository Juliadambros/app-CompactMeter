class RodaModel {
  final String posicao;
  final double? circunferencia;

  RodaModel({
    required this.posicao,
    this.circunferencia,
  });

  Map<String, dynamic> toMap() => {
        'posicao': posicao,
        'circunferencia': circunferencia,
      };

  factory RodaModel.fromMap(Map<String, dynamic> map) => RodaModel(
        posicao: map['posicao'],
        circunferencia: map['circunferencia'] != null
            ? (map['circunferencia'] as num).toDouble()
            : null,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RodaModel && other.posicao == posicao;

  @override
  int get hashCode => posicao.hashCode;
}