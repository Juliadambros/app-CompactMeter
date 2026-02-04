import 'package:app_compactmeter/theme/app_colors.dart';
import 'package:flutter/material.dart';

class ListaPropriedadesPage extends StatelessWidget {
  const ListaPropriedadesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Propriedades')),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.verde,
        onPressed: () {
          // navegar para cadastro de propriedade
        },
        child: const Icon(Icons.add),
      ),
      body: const Center(
        child: Text('Nenhuma propriedade cadastrada.'),
      ),
    );
  }
}
