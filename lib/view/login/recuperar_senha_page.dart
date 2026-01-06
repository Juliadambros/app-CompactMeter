import 'package:flutter/material.dart';
import '../../components/app_button.dart';
import '../../components/app_header.dart';
import '../../components/app_text_field.dart';
import '../../service/auth_service.dart';

class RecuperarSenhaPage extends StatefulWidget {
  const RecuperarSenhaPage({super.key});

  @override
  State<RecuperarSenhaPage> createState() => _RecuperarSenhaPageState();
}

class _RecuperarSenhaPageState extends State<RecuperarSenhaPage> {
  final emailCtrl = TextEditingController();
  final authService = AuthService();
  bool loading = false;

  Future<void> enviarEmail() async {
    setState(() => loading = true);

    final erro = await authService.recuperarSenha(emailCtrl.text);

    setState(() => loading = false);

    if (erro != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(erro)));
      return;
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Email enviado! Verifique sua caixa de entrada.'),
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recuperar senha')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const AppHeader(
              titulo: 'Esqueceu a senha?',
              subtitulo: 'Informe seu email para recuperar o acesso',
            ),
            const SizedBox(height: 24),

            AppTextField(
              controller: emailCtrl,
              label: 'Email',
              keyboardType: TextInputType.emailAddress,
            ),

            const SizedBox(height: 24),

            AppButton(
              texto: 'Enviar email',
              loading: loading,
              onPressed: enviarEmail,
            ),
          ],
        ),
      ),
    );
  }
}
