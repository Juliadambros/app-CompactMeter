import 'package:cloud_firestore/cloud_firestore.dart';

class CalibragemPontoModel {
  final String id;
  final String medicaoId;
  final DateTime data;

  final double distancia;
  final int numeroVoltas;

  final double coordenadaX;
  final double coordenadaY;
  final double altitude;

  final double patinagem;
  final double? indiceCompactacao;

  final double? coordenadaInicialX;
  final double? coordenadaInicialY;
  final double? coordenadaFinalX;
  final double? coordenadaFinalY;

  CalibragemPontoModel({
    required this.id,
    required this.medicaoId,
    required this.data,
    required this.distancia,
    required this.numeroVoltas,
    required this.coordenadaX,
    required this.coordenadaY,
    required this.altitude,
    required this.patinagem,
    this.indiceCompactacao,
    this.coordenadaInicialX,
    this.coordenadaInicialY,
    this.coordenadaFinalX,
    this.coordenadaFinalY,
  });

  Map<String, dynamic> toMap() => {
        'medicaoId': medicaoId,
        'data': Timestamp.fromDate(data),
        'distancia': distancia,
        'numeroVoltas': numeroVoltas,
        'coordenadaX': coordenadaX,
        'coordenadaY': coordenadaY,
        'altitude': altitude,
        'patinagem': patinagem,
        'indiceCompactacao': indiceCompactacao,
        'coordenadaInicialX': coordenadaInicialX,
        'coordenadaInicialY': coordenadaInicialY,
        'coordenadaFinalX': coordenadaFinalX,
        'coordenadaFinalY': coordenadaFinalY,
      };

  factory CalibragemPontoModel.fromMap(Map<String, dynamic> map, String id) {
    double readDouble(String key, {double fallback = 0.0}) {
      final v = map[key];
      if (v == null) return fallback;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString()) ?? fallback;
    }

    double? readNullableDouble(String key) {
      final v = map[key];
      if (v == null) return null;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString());
    }

    int readInt(String key, {int fallback = 0}) {
      final v = map[key];
      if (v == null) return fallback;
      if (v is num) return v.toInt();
      return int.tryParse(v.toString()) ?? fallback;
    }

    return CalibragemPontoModel(
      id: id,
      medicaoId: map['medicaoId'] ?? '',
      data: (map['data'] as Timestamp).toDate(),
      distancia: readDouble('distancia'),
      numeroVoltas: readInt('numeroVoltas'),
      coordenadaX: readDouble('coordenadaX'),
      coordenadaY: readDouble('coordenadaY'),
      altitude: readDouble('altitude'),
      patinagem: readDouble('patinagem'),
      indiceCompactacao: readNullableDouble('indiceCompactacao'),
      coordenadaInicialX: readNullableDouble('coordenadaInicialX'),
      coordenadaInicialY: readNullableDouble('coordenadaInicialY'),
      coordenadaFinalX: readNullableDouble('coordenadaFinalX'),
      coordenadaFinalY: readNullableDouble('coordenadaFinalY'),
    );
  }
}