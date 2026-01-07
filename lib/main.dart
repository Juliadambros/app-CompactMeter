import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'view/login/login_page.dart';
import 'view/login/cadastro_page.dart';
import 'view/admin/home_admin.dart';
import 'view/usuario/home_usuario.dart';
import 'theme/app_colors.dart';

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
        useMaterial3: true,

        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.azul,
          primary: AppColors.azul,
          background: AppColors.fundo,
        ),

        scaffoldBackgroundColor: AppColors.fundo,

        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.azul,
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 0,
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.azul,
            foregroundColor: Colors.white,
          ),
        ),

        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.azul,
          ),
        ),

        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.azul, width: 2),
          ),
          labelStyle: TextStyle(color: Colors.grey[700]),
        ),
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




