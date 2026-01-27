import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/veiculo_model.dart';

class VeiculoService {
  final CollectionReference veiculos = FirebaseFirestore.instance.collection(
    'veiculos',
  );

  Future<void> salvarVeiculo(VeiculoModel veiculo) async {
    await veiculos.doc(veiculo.id).set(veiculo.toMap());
  }

  Future<List<VeiculoModel>> listarVeiculos() async {
    final snapshot = await veiculos.get();
    return snapshot.docs
        .map((d) => VeiculoModel.fromMap(d.data() as Map<String, dynamic>))
        .toList();
  }

  Future<List<VeiculoModel>> listarVeiculosPorUsuario(String uid) async {
    final snapshot = await veiculos.where('usuarioId', isEqualTo: uid).get();

    return snapshot.docs
        .map((d) => VeiculoModel.fromMap(d.data() as Map<String, dynamic>))
        .toList();
  }

  Future<VeiculoModel?> buscarPorId(String id) async {
    final doc = await veiculos.doc(id).get();
    if (!doc.exists) return null;

    return VeiculoModel.fromMap(doc.data() as Map<String, dynamic>);
  }

  Future<void> excluirVeiculo(String id) async {
    await veiculos.doc(id).delete();
  }
}
