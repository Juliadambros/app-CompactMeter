import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/propriedade_model.dart';

class PropriedadeService {
  final CollectionReference propriedades = FirebaseFirestore.instance
      .collection('propriedades');

  Future<void> salvar(PropriedadeModel propriedade) async {
    await propriedades.doc(propriedade.id).set(propriedade.toMap());
  }

  Future<void> atualizar(PropriedadeModel propriedade) async {
    await propriedades.doc(propriedade.id).update(propriedade.toMap());
  }

  Future<void> excluir(String id) async {
    await moverParaLixeira(id);
  }

  Future<void> moverParaLixeira(String id) async {
    await propriedades.doc(id).update({
      'excluido': true,
      'dataExclusao': Timestamp.now(),
    });
  }

  Future<void> restaurar(String id) async {
    await propriedades.doc(id).update({
      'excluido': false,
      'dataExclusao': null,
    });
  }

  Future<void> excluirPermanentemente(String id) async {
    await propriedades.doc(id).delete();
  }

  Future<List<PropriedadeModel>> listarPorUsuario(String uid) async {
    final snapshot = await propriedades.where('usuarioId', isEqualTo: uid).get();

    return snapshot.docs
        .map((d) => PropriedadeModel.fromMap(d.data() as Map<String, dynamic>))
        .where((p) => !p.excluido)
        .toList();
  }



  Future<List<PropriedadeModel>> listarTodas() async {
    final snapshot = await propriedades.get();
    return snapshot.docs
        .map((d) => PropriedadeModel.fromMap(d.data() as Map<String, dynamic>))
        .toList();
  }

  Future<List<PropriedadeModel>> listarExcluidas() async {
    final snapshot = await propriedades.get();

    return snapshot.docs
        .map((d) => PropriedadeModel.fromMap(d.data() as Map<String, dynamic>))
        .where((p) => p.excluido)
        .toList();
  }
}

