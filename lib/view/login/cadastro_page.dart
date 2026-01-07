import 'package:app_compactmeter/theme/app_colors.dart';
import 'package:flutter/material.dart';
import '../../components/app_button.dart';
import '../../components/app_header.dart';
import '../../components/app_text_field.dart';
import '../../models/usuario_model.dart';
import '../../service/auth_service.dart';
import '../../service/usuario_service.dart';

class CadastroPage extends StatefulWidget {
  const CadastroPage({super.key});

  @override
  State<CadastroPage> createState() => _CadastroPageState();
}

class _CadastroPageState extends State<CadastroPage> {
  final nomeCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final senhaCtrl = TextEditingController();

  final authService = AuthService();
  final usuarioService = UsuarioService();

  bool loading = false;

  Future<void> cadastrar() async {
    setState(() => loading = true);

    try {
      final (user, erro) = await authService.cadastrar(
        emailCtrl.text,
        senhaCtrl.text,
      );

      if (erro != null) {
        setState(() => loading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(erro)));
        return;
      }

      final usuario = UsuarioModel(
        uid: user!.uid,
        nome: nomeCtrl.text,
        email: emailCtrl.text,
        tipoUsuario: 'usuario',
      );

      await usuarioService.salvarUsuario(usuario);

      if (!mounted) return;

      setState(() => loading = false);
      Navigator.pop(context);
    } catch (e) {
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao cadastrar usuário')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fundo,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 420),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const AppHeader(
                    titulo: 'Criar conta',
                    subtitulo: 'Preencha os dados abaixo',
                  ),
                  const SizedBox(height: 24),

                  AppTextField(controller: nomeCtrl, label: 'Nome'),
                  const SizedBox(height: 16),

                  AppTextField(
                    controller: emailCtrl,
                    label: 'Email',
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),

                  AppTextField(
                    controller: senhaCtrl,
                    label: 'Senha',
                    obscure: true,
                  ),
                  const SizedBox(height: 24),

                  AppButton(
                    texto: 'Cadastrar',
                    loading: loading,
                    onPressed: cadastrar,
                  ),

                  const SizedBox(height: 16),

                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Voltar'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
