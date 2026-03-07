import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../models/compactacao_model.dart';

class ResultadoCompactacaoPage extends StatelessWidget {
  final CompactacaoModel compactacao;

  const ResultadoCompactacaoPage({
    super.key,
    required this.compactacao,
  });

  @override
  Widget build(BuildContext context) {
    final data = DateFormat('dd/MM/yyyy HH:mm').format(compactacao.data);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Resultado do Índice de Compactação'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const Text(
                      'Índice de Compactação',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      compactacao.indiceCompactacao == null
                          ? 'Não calculado'
                          : compactacao.indiceCompactacao!.toStringAsFixed(2),
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      compactacao.statusCalculo,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _linha('Nome', compactacao.nome),
                    _linha('Data', data),
                    _linha(
                      'Calibragem realizada',
                      compactacao.calibragemRealizada ? 'Sim' : 'Não',
                    ),
                    _linha(
                      'Patinagem de referência',
                      compactacao.patinagemReferencia == null
                          ? '—'
                          : '${compactacao.patinagemReferencia!.toStringAsFixed(2)} %',
                    ),
                    _linha(
                      'Observações',
                      (compactacao.observacoes == null ||
                              compactacao.observacoes!.trim().isEmpty)
                          ? '—'
                          : compactacao.observacoes!,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Voltar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _linha(String titulo, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              titulo,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 6,
            child: Text(
              valor,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}