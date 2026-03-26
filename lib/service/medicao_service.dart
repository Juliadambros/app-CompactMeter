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
    return MedicaoModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
  }

  Future<List<MedicaoModel>> listarPorUsuario(String usuarioId) async {
    final query = await _collection.where('usuarioId', isEqualTo: usuarioId).get();

    return query.docs
        .map((doc) => MedicaoModel.fromMap(
              doc.data() as Map<String, dynamic>,
              doc.id,
            ))
        .where((m) => !m.excluido)
        .toList();
  }

  Future<List<MedicaoModel>> listarExcluidas() async {
    final query = await _collection.get();

    return query.docs
        .map((doc) => MedicaoModel.fromMap(
              doc.data() as Map<String, dynamic>,
              doc.id,
            ))
        .where((m) => m.excluido)
        .toList();
  }

  Future<List<MedicaoModel>> listarPorPropriedade(String propriedadeId) async {
    final query = await _collection
        .where('propriedadeId', isEqualTo: propriedadeId)
        .orderBy('data', descending: true)
        .get();

    return query.docs
        .map((doc) => MedicaoModel.fromMap(
              doc.data() as Map<String, dynamic>,
              doc.id,
            ))
        .where((m) => !m.excluido)
        .toList();
  }

  Future<void> moverParaLixeira(String id) async {
    await _collection.doc(id).update({
      'excluido': true,
      'dataExclusao': Timestamp.now(),
    });
  }

  Future<List<MedicaoModel>> listarTodas() async {
    final query = await _collection.orderBy('data', descending: true).get();

    final List<MedicaoModel> out = [];

    for (final doc in query.docs) {
      try {
        out.add(
          MedicaoModel.fromMap(doc.data() as Map<String, dynamic>, doc.id),
        );
      } catch (_) {}
    }

    return out;
  }

  Future<void> restaurarMedicao(String id) async {
    await _collection.doc(id).update({
      'excluido': false,
      'dataExclusao': null,
    });
  }

  Future<void> excluirPermanentemente(String id) async {
    await _collection.doc(id).delete();
  }
}
