import 'package:flutter/material.dart';
import '../../components/app_button.dart';
import '../../components/app_header.dart';
import '../../components/app_text_field.dart';
import '../../service/auth_service.dart';
import '../../service/usuario_service.dart';
import '../admin/home_admin.dart';
import '../usuario/home_usuario.dart';
import '../../theme/app_colors.dart';
import 'recuperar_senha_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailCtrl = TextEditingController();
  final senhaCtrl = TextEditingController();

  final authService = AuthService();
  final usuarioService = UsuarioService();

  bool emailNaoVerificado = false;
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

  Future<void> login() async {
    if (emailCtrl.text.trim().isEmpty) {
      mostrarPopup(titulo: 'Campo obrigatório', mensagem: 'Informe o email.');
      return;
    }

    if (senhaCtrl.text.isEmpty) {
      mostrarPopup(titulo: 'Campo obrigatório', mensagem: 'Informe a senha.');
      return;
    }
    setState(() => loading = true);

    final (user, erro) = await authService.entrar(
      emailCtrl.text,
      senhaCtrl.text,
    );

    if (erro != null) {
      setState(() => loading = false);
      mostrarPopup(titulo: 'Erro ao entrar', mensagem: erro);
      return;
    }

    final usuario = await usuarioService.buscarUsuario(user!.uid);

    if (!mounted) return;

    if (usuario == null) {
      setState(() => loading = false);
      mostrarPopup(
        titulo: 'Usuário não encontrado',
        mensagem: 'Não foi possível localizar os dados do usuário.',
      );
      return;
    }

    if (!user.emailVerified) {
      setState(() {
        loading = false;
        emailNaoVerificado = true;
      });

      mostrarPopup(
        titulo: 'E-mail não verificado',
        mensagem: 'Verifique sua caixa de entrada para ativar a conta.',
        icone: Icons.mail_outline,
        cor: Colors.orange,
      );
      return;
    }

    setState(() => loading = false);

    if (usuario.tipoUsuario == 'admin') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeAdmin()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeUsuario()),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Image.asset(
                          'assets/imgs/nmap.jpg',
                          height: 50,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Flexible(
                        child: Image.asset(
                          'assets/imgs/unicentro.png',
                          height: 50,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),
                  const AppHeader(
                    titulo: 'CompactMeter',
                    subtitulo: 'Acesse sua conta',
                  ),

                  const SizedBox(height: 24),

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
                    texto: 'Entrar',
                    loading: loading,
                    onPressed: login,
                  ),

                  if (emailNaoVerificado)
                    TextButton(
                      onPressed: () async {
                        final erro = await authService
                            .reenviarEmailVerificacao();

                        if (erro != null) {
                          mostrarPopup(titulo: 'Erro', mensagem: erro);
                        } else {
                          mostrarPopup(
                            titulo: 'E-mail reenviado',
                            mensagem:
                                'O e-mail de verificação foi enviado novamente.',
                            icone: Icons.check_circle_outline,
                            cor: Colors.green,
                          );
                        }
                      },
                      child: Text(
                        'Reenviar e-mail de verificação',
                        style: TextStyle(color: AppColors.azul),
                      ),
                    ),

                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/cadastro'),
                    child: Text(
                      'Criar conta',
                      style: TextStyle(color: AppColors.azul),
                    ),
                  ),

                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const RecuperarSenhaPage(),
                        ),
                      );
                    },
                    child: const Text(
                      'Esqueceu a senha?',
                      style: TextStyle(color: Colors.grey),
                    ),
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
