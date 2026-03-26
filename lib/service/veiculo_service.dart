import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/veiculo_model.dart';

class VeiculoService {
  final _col = FirebaseFirestore.instance.collection('veiculos');

  Future<void> salvarVeiculo(VeiculoModel v) async {
    await _col.doc(v.id).set(v.toMap());
  }

  Future<List<VeiculoModel>> listarVeiculosPorUsuario(String uid) async {
    final snap = await _col.where('usuarioId', isEqualTo: uid).get();
    return snap.docs
        .map((d) => VeiculoModel.fromMap(d.data()))
        .where((v) => !v.excluido)
        .toList();
  }



  Future<List<VeiculoModel>> listarTodos() async {
    final snap = await _col.get();
    return snap.docs.map((d) => VeiculoModel.fromMap(d.data())).toList();
  }

  Future<List<VeiculoModel>> listarExcluidos() async {
    final snap = await _col.get();
    return snap.docs
        .map((d) => VeiculoModel.fromMap(d.data()))
        .where((v) => v.excluido)
        .toList();
  }

  Future<void> moverParaLixeira(String id) async {
    await _col.doc(id).update({
      'excluido': true,
      'dataExclusao': Timestamp.now(),
    });
  }

  Future<void> restaurarVeiculo(String id) async {
    await _col.doc(id).update({
      'excluido': false,
      'dataExclusao': null,
    });
  }

  Future<void> excluirVeiculo(String id) async {
    await moverParaLixeira(id);
  }

  Future<void> excluirPermanentemente(String id) async {
    await _col.doc(id).delete();
  }
}

