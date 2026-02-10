class RodaModel {
  final String posicao; 
  final bool temSensor;
  final double? circunferencia;
  final String? bluetoothId;

  RodaModel({
    required this.posicao,
    required this.temSensor,
    this.circunferencia,
    this.bluetoothId,
  });

  Map<String, dynamic> toMap() => {
        'posicao': posicao,
        'temSensor': temSensor,
        'circunferencia': circunferencia,
        'bluetoothId': bluetoothId,
      };

  factory RodaModel.fromMap(Map<String, dynamic> map) => RodaModel(
        posicao: map['posicao'],
        temSensor: map['temSensor'],
        circunferencia: map['circunferencia'] != null
            ? (map['circunferencia'] as num).toDouble()
            : null,
        bluetoothId: map['bluetoothId'],
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RodaModel && other.posicao == posicao;

  @override
  int get hashCode => posicao.hashCode;
}
