import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/compactacao_model.dart';

class CompactacaoService {
  final CollectionReference _collection =
      FirebaseFirestore.instance.collection('compactacoes');

  Future<void> salvar(CompactacaoModel compactacao) async {
    await _collection.doc(compactacao.id).set(compactacao.toMap());
  }

  Future<void> excluir(String id) async {
    await _collection.doc(id).delete();
  }

  Future<List<CompactacaoModel>> listarPorUsuario(String usuarioId) async {
    final query = await _collection
        .where('usuarioId', isEqualTo: usuarioId)
        .get();

    return query.docs
        .map(
          (doc) => CompactacaoModel.fromMap(
            doc.data() as Map<String, dynamic>,
            doc.id,
          ),
        )
        .toList();
  }

  Future<List<CompactacaoModel>> listarTodas() async {
    final query = await _collection.orderBy('data', descending: true).get();

    return query.docs
        .map(
          (doc) => CompactacaoModel.fromMap(
            doc.data() as Map<String, dynamic>,
            doc.id,
          ),
        )
        .toList();
  }
}