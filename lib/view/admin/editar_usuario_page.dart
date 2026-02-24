import 'package:flutter/material.dart';
import '../../models/usuario_model.dart';
import '../../service/usuario_service.dart';
import '../../theme/app_colors.dart';

class EditarUsuarioPage extends StatefulWidget {
  final UsuarioModel usuario;
  const EditarUsuarioPage({super.key, required this.usuario});

  @override
  State<EditarUsuarioPage> createState() => _EditarUsuarioPageState();
}

class _EditarUsuarioPageState extends State<EditarUsuarioPage> {
  final _formKey = GlobalKey<FormState>();
  final _usuarioService = UsuarioService();

  late final TextEditingController _nomeCtrl;
  late final TextEditingController _emailCtrl;

  String _tipo = 'usuario';
  bool _salvando = false;

  @override
  void initState() {
    super.initState();
    _nomeCtrl = TextEditingController(text: widget.usuario.nome);
    _emailCtrl = TextEditingController(text: widget.usuario.email);
    _tipo = widget.usuario.tipoUsuario;
  }

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _salvando = true);

    try {
      await _usuarioService.atualizarUsuario(
        widget.usuario.uid,
        nome: _nomeCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        tipoUsuario: _tipo,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuário atualizado com sucesso')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao salvar: $e')));
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fundo,
      appBar: AppBar(
        title: const Text('Editar Usuário'),
        backgroundColor: AppColors.azul,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nomeCtrl,
                decoration: const InputDecoration(labelText: 'Nome'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Informe o nome' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailCtrl,
                decoration: const InputDecoration(labelText: 'Email (perfil)'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Informe o email' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _tipo,
                decoration: const InputDecoration(labelText: 'Tipo de usuário'),
                items: const [
                  DropdownMenuItem(value: 'usuario', child: Text('Usuário')),
                  DropdownMenuItem(
                    value: 'admin',
                    child: Text('Administrador'),
                  ),
                ],
                onChanged: (v) => setState(() => _tipo = v ?? 'usuario'),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _salvando ? null : _salvar,
                icon: _salvando
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save),
                label: Text(_salvando ? 'Salvando...' : 'Salvar'),
              ),
              const SizedBox(height: 12),
              const Text(
                'Obs.: isso altera os dados no Firestore. '
                'O e-mail do login (FirebaseAuth) não muda pelo app sem backend/Cloud Function.',
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
