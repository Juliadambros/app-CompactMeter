import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'view/login/login_page.dart';
import 'view/login/cadastro_page.dart';
import 'view/admin/home_admin.dart';
import 'view/usuario/home_usuario.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CompactMeter',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (_) => const LoginPage(),
        '/cadastro': (_) => const CadastroPage(),
        '/home_admin': (_) => const HomeAdmin(),
        '/home_usuario': (_) => const HomeUsuario(),
      },
    );
  }
}



