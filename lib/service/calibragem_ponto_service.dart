import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/calibragem_ponto_model.dart';

class CalibragemPontoService {
  final CollectionReference _collection =
      FirebaseFirestore.instance.collection('calibragem_pontos');

  Future<void> salvarPonto(CalibragemPontoModel ponto) async {
    await _collection.doc(ponto.id).set(ponto.toMap());
  }

  Future<List<CalibragemPontoModel>> listarPorMedicao(String medicaoId) async {
    final query = await _collection
        .where('medicaoId', isEqualTo: medicaoId)
        .orderBy('distancia')
        .get();

    return query.docs
        .map((doc) => CalibragemPontoModel.fromMap(
              doc.data() as Map<String, dynamic>,
              doc.id,
            ))
        .toList();
  }

  Future<void> excluirPorMedicao(String medicaoId) async {
    final pontos = await listarPorMedicao(medicaoId);
    for (final p in pontos) {
      await _collection.doc(p.id).delete();
    }
  }
}