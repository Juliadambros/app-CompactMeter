import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/propriedade_model.dart';

class PropriedadeService {
  final CollectionReference propriedades =
      FirebaseFirestore.instance.collection('propriedades');

  Future<void> salvar(PropriedadeModel propriedade) async {
    await propriedades.doc(propriedade.id).set(propriedade.toMap());
  }

  Future<void> atualizar(PropriedadeModel propriedade) async {
    await propriedades.doc(propriedade.id).update(propriedade.toMap());
  }

  Future<void> excluir(String id) async {
    await propriedades.doc(id).delete();
  }

  Future<List<PropriedadeModel>> listarPorUsuario(String uid) async {
    final snapshot =
        await propriedades.where('usuarioId', isEqualTo: uid).get();

    return snapshot.docs
        .map(
          (d) => PropriedadeModel.fromMap(d.data() as Map<String, dynamic>),
        )
        .toList();
  }
}
