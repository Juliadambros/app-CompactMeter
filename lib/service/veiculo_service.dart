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
        .toList();
  }

  Future<void> excluirVeiculo(String id) async {
    await _col.doc(id).delete();
  }
}
