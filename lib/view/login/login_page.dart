import 'package:app_compactmeter/view/login/recuperar_senha_page.dart';
import 'package:flutter/material.dart';
import '../../components/app_button.dart';
import '../../components/app_header.dart';
import '../../components/app_text_field.dart';
import '../../service/auth_service.dart';
import '../../service/usuario_service.dart';
import '../admin/home_admin.dart';
import '../usuario/home_usuario.dart';
import '../../theme/app_colors.dart';

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

  bool loading = false;

  Future<void> login() async {
    setState(() => loading = true);

    try {
      final (user, erro) = await authService.entrar(
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

      final usuario = await usuarioService.buscarUsuario(user!.uid);

      if (!mounted) return;

      if (usuario == null) {
        setState(() => loading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Usuário não encontrado')));
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
    } catch (e) {
      setState(() => loading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Erro ao realizar login')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fundo,
      body: Center(
        child: Card(
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
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
                const SizedBox(height: 12),

                AppTextField(
                  controller: senhaCtrl,
                  label: 'Senha',
                  obscure: true,
                ),
                const SizedBox(height: 20),

                AppButton(texto: 'Entrar', loading: loading, onPressed: login),

                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/cadastro');
                  },
                  child: const Text('Criar conta'),
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
                  child: const Text('Esqueceu a senha?'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
