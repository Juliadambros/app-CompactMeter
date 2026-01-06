class UsuarioModel {
  final String uid;
  final String nome;
  final String email;
  final String tipoUsuario;

  UsuarioModel({required this.uid, required this.nome, required this.email, required this.tipoUsuario});

   Map<String, dynamic> toMap() => {
    'uid': uid,
    'nome': nome,
    'email': email,
    'tipoUsuario': tipoUsuario,
  };

  factory UsuarioModel.fromMap(Map<String, dynamic> map) => UsuarioModel(
    uid: map['uid'],
    nome: map['nome'],
    email: map['email'],
    tipoUsuario: map['tipoUsuario'],
  );
}
