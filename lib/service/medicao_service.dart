import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/medicao_model.dart';

class MedicaoService {
  final CollectionReference medicoes = FirebaseFirestore.instance.collection('medicoes');

  Future<void> salvarMedicao(MedicaoModel medicao) async {
    await medicoes.doc(medicao.id).set(medicao.toMap());
  }

  Future<List<MedicaoModel>> listarTodas() async {
    final snapshot = await medicoes.orderBy('data', descending: true).get();

    return snapshot.docs
        .map((d) =>
            MedicaoModel.fromMap(d.data() as Map<String, dynamic>))
        .toList();
  }

  Future<List<MedicaoModel>> listarPorUsuario(String uid) async {
    final snapshot =
        await medicoes.where('usuarioId', isEqualTo: uid).get();

    return snapshot.docs
        .map((d) =>
            MedicaoModel.fromMap(d.data() as Map<String, dynamic>))
        .toList();
  }

  static double calcularPatinagem({
    required double distanciaInformada,
    required double grausAcumulados,
    required double circunferenciaRoda,
  }) {
    final voltas = grausAcumulados / 360;
    final distanciaTeorica = voltas * circunferenciaRoda;

    if (distanciaTeorica == 0) return 0;

    return ((distanciaTeorica - distanciaInformada) /
            distanciaTeorica) *
        100;
  }

  Future<void> excluirMedicao(String id) async {
    await medicoes.doc(id).delete();
  }
}
