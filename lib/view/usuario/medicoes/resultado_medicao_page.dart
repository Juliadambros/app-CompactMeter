import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../models/medicao_model.dart';

class ResultadoMedicaoPage extends StatelessWidget {
  final MedicaoModel medicao;

  const ResultadoMedicaoPage({super.key, required this.medicao});

  @override
  Widget build(BuildContext context) {
    final dataFormatada = DateFormat('dd/MM/yyyy HH:mm').format(medicao.data);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Resultado da Calibragem'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: 'Gerar PDF',
            onPressed: () => gerarPdf(context, medicao),
          ),
          IconButton(
            icon: const Icon(Icons.table_chart),
            tooltip: 'Gerar CSV',
            onPressed: () => gerarCsv(context, medicao),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            _cardResultado(),
            const SizedBox(height: 16),
            _cardDetalhes(dataFormatada),
            const SizedBox(height: 24),
            _botaoVoltar(context),
          ],
        ),
      ),
    );
  }

  Widget _cardResultado() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text(
              'Patinagem calibrada',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              '${medicao.patinagem.toStringAsFixed(2)} %',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: medicao.patinagem > 20 ? Colors.red : Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cardDetalhes(String dataFormatada) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _linha('Nome', medicao.nome),
            _linha('Data', dataFormatada),
            _linha('Distância (m)', medicao.distancia.toStringAsFixed(2)),
            _linha('Voltas', medicao.voltas.toString()),
            _linha(
              'Perímetro / Circunferência (m)',
              medicao.perimetro.toStringAsFixed(2),
            ),
            _linha('Patinagem (%)', medicao.patinagem.toStringAsFixed(2)),
            const Divider(height: 20),
            _linha(
              'Coordenada inicial X',
              medicao.coordenadaInicialX?.toStringAsFixed(6) ?? '—',
            ),
            _linha(
              'Coordenada inicial Y',
              medicao.coordenadaInicialY?.toStringAsFixed(6) ?? '—',
            ),
            _linha(
              'Coordenada final X',
              medicao.coordenadaFinalX?.toStringAsFixed(6) ?? '—',
            ),
            _linha(
              'Coordenada final Y',
              medicao.coordenadaFinalY?.toStringAsFixed(6) ?? '—',
            ),
            _linha(
              'Altitude inicial (m)',
              medicao.altitudeInicial?.toStringAsFixed(2) ?? '—',
            ),
            _linha(
              'Altitude final (m)',
              medicao.altitudeFinal?.toStringAsFixed(2) ?? '—',
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              titulo,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(valor, textAlign: TextAlign.right)),
        ],
      ),
    );
  }

  Widget _botaoVoltar(BuildContext context) {
    return ElevatedButton(
      onPressed: () => Navigator.pop(context),
      child: const Text('Voltar'),
    );
  }

  static Future<void> gerarPdf(
    BuildContext context,
    MedicaoModel medicao,
  ) async {
    final pdf = pw.Document();
    final data = DateFormat('dd/MM/yyyy HH:mm').format(medicao.data);

    pdf.addPage(
      pw.Page(
        build: (_) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'Resultado da Calibragem',
              style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 16),
            pw.Text('Nome: ${medicao.nome}'),
            pw.Text('Data: $data'),
            pw.Text('Patinagem: ${medicao.patinagem.toStringAsFixed(2)} %'),
            pw.Text('Distância: ${medicao.distancia.toStringAsFixed(2)} m'),
            pw.Text('Voltas: ${medicao.voltas}'),
            pw.Text(
              'Perímetro / Circunferência: ${medicao.perimetro.toStringAsFixed(2)} m',
            ),
            pw.Text(
              'Coordenada inicial: ${medicao.coordenadaInicialY?.toStringAsFixed(6) ?? '—'}, ${medicao.coordenadaInicialX?.toStringAsFixed(6) ?? '—'}',
            ),
            pw.Text(
              'Coordenada final: ${medicao.coordenadaFinalY?.toStringAsFixed(6) ?? '—'}, ${medicao.coordenadaFinalX?.toStringAsFixed(6) ?? '—'}',
            ),
            pw.Text(
              'Altitude inicial: ${medicao.altitudeInicial?.toStringAsFixed(2) ?? '—'} m',
            ),
            pw.Text(
              'Altitude final: ${medicao.altitudeFinal?.toStringAsFixed(2) ?? '—'} m',
            ),
          ],
        ),
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  static Future<void> gerarCsv(
    BuildContext context,
    MedicaoModel medicao,
  ) async {
    final data = DateFormat('dd/MM/yyyy HH:mm').format(medicao.data);

    final csv = StringBuffer()
      ..writeln('Campo,Valor')
      ..writeln('Nome,${medicao.nome}')
      ..writeln('Data,$data')
      ..writeln('Patinagem,${medicao.patinagem.toStringAsFixed(2)}')
      ..writeln('Distância,${medicao.distancia.toStringAsFixed(2)}')
      ..writeln('Voltas,${medicao.voltas}')
      ..writeln(
        'Perímetro/Circunferência,${medicao.perimetro.toStringAsFixed(2)}',
      )
      ..writeln(
        'CoordenadaInicialX,${medicao.coordenadaInicialX?.toStringAsFixed(6) ?? ''}',
      )
      ..writeln(
        'CoordenadaInicialY,${medicao.coordenadaInicialY?.toStringAsFixed(6) ?? ''}',
      )
      ..writeln(
        'CoordenadaFinalX,${medicao.coordenadaFinalX?.toStringAsFixed(6) ?? ''}',
      )
      ..writeln(
        'CoordenadaFinalY,${medicao.coordenadaFinalY?.toStringAsFixed(6) ?? ''}',
      )
      ..writeln(
        'AltitudeInicial,${medicao.altitudeInicial?.toStringAsFixed(2) ?? ''}',
      )
      ..writeln(
        'AltitudeFinal,${medicao.altitudeFinal?.toStringAsFixed(2) ?? ''}',
      );

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/calibragem_${medicao.id}.csv');

    await file.writeAsString(csv.toString());

    await Printing.sharePdf(
      bytes: file.readAsBytesSync(),
      filename: 'calibragem_${medicao.id}.csv',
    );
  }
}
