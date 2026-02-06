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

  void mostrarPopup({
    required String titulo,
    required String mensagem,
    IconData icone = Icons.error_outline,
    Color cor = Colors.red,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(icone, color: cor),
            const SizedBox(width: 8),
            Expanded(child: Text(titulo)),
          ],
        ),
        content: Text(mensagem),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> cadastrar() async {
    if (nomeCtrl.text.trim().isEmpty) {
      mostrarPopup(titulo: 'Campo obrigatório', mensagem: 'Informe o nome.');
      return;
    }

    if (emailCtrl.text.trim().isEmpty) {
      mostrarPopup(titulo: 'Campo obrigatório', mensagem: 'Informe o email.');
      return;
    }

    if (senhaCtrl.text.isEmpty) {
      mostrarPopup(titulo: 'Campo obrigatório', mensagem: 'Informe a senha.');
      return;
    }

    if (senhaCtrl.text.length < 6) {
      mostrarPopup(
        titulo: 'Senha fraca',
        mensagem: 'A senha deve ter no mínimo 6 caracteres.',
      );
      return;
    }

    setState(() => loading = true);

    try {
      final (user, erro) = await authService.cadastrar(
        emailCtrl.text.trim(),
        senhaCtrl.text,
      );

      if (erro != null) {
        setState(() => loading = false);

        mostrarPopup(
          titulo: 'Erro no cadastro',
          mensagem: erro,
          icone: Icons.warning_amber_rounded,
          cor: Colors.orange,
        );
        return;
      }

      final usuario = UsuarioModel(
        uid: user!.uid,
        nome: nomeCtrl.text.trim(),
        email: emailCtrl.text.trim(),
        tipoUsuario: 'usuario',
      );

      await usuarioService.salvarUsuario(usuario);

      if (!mounted) return;

      setState(() => loading = false);

      mostrarPopup(
        titulo: 'Cadastro realizado',
        mensagem:
            'Conta criada com sucesso.\nVerifique seu e-mail para ativar a conta.',
        icone: Icons.check_circle_outline,
        cor: Colors.green,
      );

      Navigator.pop(context);
    } catch (e) {
      setState(() => loading = false);

      mostrarPopup(
        titulo: 'Erro inesperado',
        mensagem: 'Erro ao cadastrar usuário.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fundo,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const SizedBox(height: 24),

              Center(
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

              const SizedBox(height: 32),

              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset('assets/imgs/nmap.png', height: 50),
                      const SizedBox(width: 20),
                      Image.asset('assets/imgs/unicentro.png', height: 50),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/imgs/logo_CienciaComputacao.png',
                        height: 40,
                      ),
                      const SizedBox(width: 16),
                      Image.asset('assets/imgs/logobigdata.png', height: 30),
                      const SizedBox(width: 16),
                      Image.asset('assets/imgs/agronomia.png', height: 40),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
