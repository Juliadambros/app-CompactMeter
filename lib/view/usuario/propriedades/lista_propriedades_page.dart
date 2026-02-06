import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../models/propriedade_model.dart';
import '../../../service/propriedade_service.dart';
import '../../../theme/app_colors.dart';
import '../../../components/loading.dart';
import '../../../components/delete_button.dart';
import 'cadastro_propriedade_page.dart';

class ListaPropriedadesPage extends StatefulWidget {
  const ListaPropriedadesPage({super.key});

  @override
  State<ListaPropriedadesPage> createState() =>
      _ListaPropriedadesPageState();
}

class _ListaPropriedadesPageState extends State<ListaPropriedadesPage> {
  late Future<List<PropriedadeModel>> _futurePropriedades;

  @override
  void initState() {
    super.initState();
    _carregarPropriedades();
  }

  void _carregarPropriedades() {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    _futurePropriedades =
        PropriedadeService().listarPorUsuario(uid);
  }

  Future<void> _abrirCadastro([PropriedadeModel? propriedade]) async {
    final atualizado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            CadastroPropriedadePage(propriedade: propriedade),
      ),
    );

    if (atualizado == true) {
      setState(() => _carregarPropriedades());
    }
  }

  Future<void> _excluir(String id) async {
    await PropriedadeService().excluir(id);

    if (!mounted) return;

    setState(() => _carregarPropriedades());

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Propriedade excluída')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fundo,
      appBar: AppBar(
        title: const Text('Propriedades'),
        backgroundColor: AppColors.azul,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.verde,
        onPressed: () => _abrirCadastro(),
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<PropriedadeModel>>(
        future: _futurePropriedades,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const AppLoading();
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('Nenhuma propriedade cadastrada'),
            );
          }

          final propriedades = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: propriedades.length,
            itemBuilder: (context, index) {
              final p = propriedades[index];

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListTile(
                  leading: Icon(
                    Icons.location_on,
                    color: AppColors.verde,
                  ),
                  title: Text(p.nome),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Dono: ${p.dono}'),
                      Text(
                        '📍 ${p.endereco}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _abrirCadastro(p),
                      ),
                      DeleteButton(
                        mensagem:
                            'Deseja excluir esta propriedade?',
                        onConfirm: () => _excluir(p.id),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
