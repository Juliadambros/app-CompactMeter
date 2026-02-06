import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

import '../../../models/propriedade_model.dart';
import '../../../service/propriedade_service.dart';
import '../../../theme/app_colors.dart';

class CadastroPropriedadePage extends StatefulWidget {
  const CadastroPropriedadePage({super.key, this.propriedade});

  final PropriedadeModel? propriedade;

  @override
  State<CadastroPropriedadePage> createState() =>
      _CadastroPropriedadePageState();
}

class _CadastroPropriedadePageState extends State<CadastroPropriedadePage> {
  final nomeCtrl = TextEditingController();
  final donoCtrl = TextEditingController();
  final enderecoCtrl = TextEditingController();

  final service = PropriedadeService();

  @override
  void initState() {
    super.initState();

    if (widget.propriedade != null) {
      nomeCtrl.text = widget.propriedade!.nome;
      donoCtrl.text = widget.propriedade!.dono;
      enderecoCtrl.text = widget.propriedade!.endereco;
    }
  }

  void salvar() async {
    if (nomeCtrl.text.trim().isEmpty ||
        donoCtrl.text.trim().isEmpty ||
        enderecoCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha todos os campos')),
      );
      return;
    }

    final uid = FirebaseAuth.instance.currentUser!.uid;

    final propriedade = PropriedadeModel(
      id: widget.propriedade?.id ?? const Uuid().v4(),
      nome: nomeCtrl.text.trim(),
      dono: donoCtrl.text.trim(),
      usuarioId: uid,
      endereco: enderecoCtrl.text.trim(),
    );

    if (widget.propriedade == null) {
      await service.salvar(propriedade);
    } else {
      await service.atualizar(propriedade);
    }

    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.propriedade == null
              ? 'Cadastrar Propriedade'
              : 'Editar Propriedade',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: nomeCtrl,
              decoration:
                  const InputDecoration(labelText: 'Nome da propriedade *'),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: donoCtrl,
              decoration: const InputDecoration(labelText: 'Nome do dono *'),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: enderecoCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Localização da propriedade *',
                hintText:
                    'Informe o endereço ou uma referência.\n'
                    'Exemplo: Linha São José, interior de Guarapuava - PR\n'
                    'ou: Rua das Araucárias, nº 120, Centro',
              ),
            ),

            const SizedBox(height: 24),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.verde,
              ),
              onPressed: salvar,
              child: const Text('Salvar'),
            ),
          ],
        ),
      ),
    );
  }
}
