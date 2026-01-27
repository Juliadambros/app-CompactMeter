import 'package:app_compactmeter/models/usuario_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UsuarioService {
  final CollectionReference usuarios = FirebaseFirestore.instance.collection(
    'usuarios',
  );

  Future<void> salvarUsuario(UsuarioModel usuario) async {
    await usuarios.doc(usuario.uid).set(usuario.toMap());
  }

  Future<UsuarioModel?> buscarUsuario(String uid) async {
    final doc = await usuarios.doc(uid).get();
    if (!doc.exists) return null;
    return UsuarioModel.fromMap(doc.data() as Map<String, dynamic>);
  }

  Future<List<UsuarioModel>> listarUsuarios() async {
    final snapshot = await usuarios.get();
    return snapshot.docs
        .map((d) => UsuarioModel.fromMap(d.data() as Map<String, dynamic>))
        .toList();
  }

  Stream<List<UsuarioModel>> streamUsuarios() {
    return usuarios.snapshots().map(
      (snapshot) {
        return snapshot.docs
            .map(
              (d) => UsuarioModel.fromMap(d.data() as Map<String, dynamic>),
            )
            .toList();
      },
    );
  }

  Future<void> excluirUsuario(String uid) async {
    await usuarios.doc(uid).delete();
  }
}
