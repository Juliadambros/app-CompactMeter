import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/medicao_model.dart';

class MedicaoService {
  final CollectionReference _collection =
      FirebaseFirestore.instance.collection('medicoes');

  Future<void> salvarMedicao(MedicaoModel medicao) async {
    await _collection.doc(medicao.id).set(medicao.toMap());
  }

  Future<MedicaoModel?> buscarPorId(String id) async {
    final doc = await _collection.doc(id).get();

    if (!doc.exists) return null;

    return MedicaoModel.fromMap(
      doc.data() as Map<String, dynamic>,
      doc.id,
    );
  }

  Future<List<MedicaoModel>> listarPorUsuario(String usuarioId) async {
  final query = await _collection
      .where('usuarioId', isEqualTo: usuarioId)
      .get();

  return query.docs
      .map(
        (doc) => MedicaoModel.fromMap(
          doc.data() as Map<String, dynamic>,
          doc.id,
        ),
      )
      .toList();
}


  Future<List<MedicaoModel>> listarPorPropriedade(String propriedadeId) async {
    final query = await _collection
        .where('propriedadeId', isEqualTo: propriedadeId)
        .orderBy('data', descending: true)
        .get();

    return query.docs
        .map(
          (doc) => MedicaoModel.fromMap(
            doc.data() as Map<String, dynamic>,
            doc.id,
          ),
        )
        .toList();
  }

  Future<void> excluirMedicao(String id) async {
    await _collection.doc(id).delete();
  }
}
