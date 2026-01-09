import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/medicao_model.dart';

class MedicaoService {
  final CollectionReference medicoes = FirebaseFirestore.instance.collection(
    'medicoes',
  );

  Future<void> salvarMedicao(MedicaoModel medicao) async {
    await medicoes.doc(medicao.id).set(medicao.toMap());
  }

  Future<List<MedicaoModel>> listarTodas() async {
    final snapshot = await medicoes.orderBy('data', descending: true).get();

    return snapshot.docs
        .map((d) => MedicaoModel.fromMap(d.data() as Map<String, dynamic>))
        .toList();
  }

  Future<List<MedicaoModel>> listarPorUsuario(String uid) async {
    final snapshot = await medicoes.where('usuarioId', isEqualTo: uid).get();

    return snapshot.docs
        .map((d) => MedicaoModel.fromMap(d.data() as Map<String, dynamic>))
        .toList();
  }

  static double calcularPatinagem({
    required double distanciaReal,
    required int rotacoes,
    required double circunferenciaRoda,
  }) {
    final distanciaTeorica = rotacoes * circunferenciaRoda;
    return ((distanciaTeorica - distanciaReal) / distanciaTeorica) * 100;
  }
}
