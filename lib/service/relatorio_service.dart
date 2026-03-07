import 'dart:io';

import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/medicao_model.dart';
import 'medicao_service.dart';
import 'calibragem_ponto_service.dart';

class RelatorioService {
  final MedicaoService _medicaoService = MedicaoService();
  final CalibragemPontoService _pontoService = CalibragemPontoService();

  Future<File> gerarCsvMedicoesUsuario(String uid) async {
    final medicoes = await _medicaoService.listarPorUsuario(uid);

    final csv = StringBuffer()
      ..writeln(
        'id,nome,data,patinagem,distancia,voltas,perimetro,usuarioId,propriedadeId,veiculoId,rodaId,coordenadaInicialX,coordenadaInicialY,coordenadaFinalX,coordenadaFinalY,altitudeInicial,altitudeFinal',
      );

    for (final m in medicoes) {
      final data = DateFormat('yyyy-MM-dd HH:mm').format(m.data);
      csv.writeln(
        '${m.id},'
        '"${_escape(m.nome)}",'
        '$data,'
        '${m.patinagem.toStringAsFixed(2)},'
        '${m.distancia.toStringAsFixed(2)},'
        '${m.voltas},'
        '${m.perimetro.toStringAsFixed(2)},'
        '${m.usuarioId},'
        '${m.propriedadeId},'
        '${m.veiculoId},'
        '${m.rodaId},'
        '${m.coordenadaInicialX ?? ''},'
        '${m.coordenadaInicialY ?? ''},'
        '${m.coordenadaFinalX ?? ''},'
        '${m.coordenadaFinalY ?? ''},'
        '${m.altitudeInicial ?? ''},'
        '${m.altitudeFinal ?? ''}',
      );
    }

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/calibragens_usuario_$uid.csv');
    await file.writeAsString(csv.toString(), flush: true);
    return file;
  }

  Future<File> gerarCsvMedicoesGeral() async {
    final medicoes = await _medicaoService.listarTodas();

    final csv = StringBuffer()
      ..writeln(
        'id,nome,data,patinagem,distancia,voltas,perimetro,usuarioId,propriedadeId,veiculoId,rodaId,coordenadaInicialX,coordenadaInicialY,coordenadaFinalX,coordenadaFinalY,altitudeInicial,altitudeFinal',
      );

    for (final m in medicoes) {
      final data = DateFormat('yyyy-MM-dd HH:mm').format(m.data);
      csv.writeln(
        '${m.id},'
        '"${_escape(m.nome)}",'
        '$data,'
        '${m.patinagem.toStringAsFixed(2)},'
        '${m.distancia.toStringAsFixed(2)},'
        '${m.voltas},'
        '${m.perimetro.toStringAsFixed(2)},'
        '${m.usuarioId},'
        '${m.propriedadeId},'
        '${m.veiculoId},'
        '${m.rodaId},'
        '${m.coordenadaInicialX ?? ''},'
        '${m.coordenadaInicialY ?? ''},'
        '${m.coordenadaFinalX ?? ''},'
        '${m.coordenadaFinalY ?? ''},'
        '${m.altitudeInicial ?? ''},'
        '${m.altitudeFinal ?? ''}',
      );
    }

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/calibragens_geral.csv');
    await file.writeAsString(csv.toString(), flush: true);
    return file;
  }

  Future<File> gerarCsvPontosMedicao(String medicaoId) async {
    final pontos = await _pontoService.listarPorMedicao(medicaoId);

    final csv = StringBuffer()
      ..writeln(
        'distancia,numeroVoltas,coordenadaX,coordenadaY,altitude,patinagem,indiceCompactacao,coordenadaInicialX,coordenadaInicialY,coordenadaFinalX,coordenadaFinalY,data',
      );

    for (final p in pontos) {
      final data = DateFormat('yyyy-MM-dd HH:mm:ss').format(p.data);
      csv.writeln(
        '${p.distancia.toStringAsFixed(2)},'
        '${p.numeroVoltas},'
        '${p.coordenadaX.toStringAsFixed(6)},'
        '${p.coordenadaY.toStringAsFixed(6)},'
        '${p.altitude.toStringAsFixed(2)},'
        '${p.patinagem.toStringAsFixed(2)},'
        '${p.indiceCompactacao ?? ''},'
        '${p.coordenadaInicialX ?? ''},'
        '${p.coordenadaInicialY ?? ''},'
        '${p.coordenadaFinalX ?? ''},'
        '${p.coordenadaFinalY ?? ''},'
        '$data',
      );
    }

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/pontos_calibragem_$medicaoId.csv');
    await file.writeAsString(csv.toString(), flush: true);
    return file;
  }

  Future<void> compartilharPdfMedicoesUsuario(
    String uid, {
    String? titulo,
  }) async {
    final medicoes = await _medicaoService.listarPorUsuario(uid);
    await _compartilharPdf(
      titulo: titulo ?? 'Relatório de Calibragens (Usuário)',
      medicoes: medicoes,
      nomeArquivo: 'calibragens_usuario_$uid.pdf',
    );
  }

  Future<void> compartilharPdfMedicoesGeral() async {
    final medicoes = await _medicaoService.listarTodas();
    await _compartilharPdf(
      titulo: 'Relatório de Calibragens (Geral)',
      medicoes: medicoes,
      nomeArquivo: 'calibragens_geral.pdf',
    );
  }

  Future<void> compartilharArquivo(File file) async {
    final bytes = await file.readAsBytes();
    await Printing.sharePdf(
      bytes: bytes,
      filename: file.path.split('/').last,
    );
  }

  Future<void> _compartilharPdf({
    required String titulo,
    required List<MedicaoModel> medicoes,
    required String nomeArquivo,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        build: (_) => [
          pw.Text(
            titulo,
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 12),
          pw.Table.fromTextArray(
            headers: const [
              'Data',
              'Nome',
              'Patinagem (%)',
              'Distância (m)',
              'Voltas',
              'Perímetro (m)',
              'Coord. Inicial',
              'Coord. Final',
            ],
            data: medicoes.map((m) {
              final coordInicial =
                  '${m.coordenadaInicialY?.toStringAsFixed(6) ?? '—'}, ${m.coordenadaInicialX?.toStringAsFixed(6) ?? '—'}';
              final coordFinal =
                  '${m.coordenadaFinalY?.toStringAsFixed(6) ?? '—'}, ${m.coordenadaFinalX?.toStringAsFixed(6) ?? '—'}';

              return [
                DateFormat('dd/MM/yyyy HH:mm').format(m.data),
                m.nome,
                m.patinagem.toStringAsFixed(2),
                m.distancia.toStringAsFixed(2),
                m.voltas.toString(),
                m.perimetro.toStringAsFixed(2),
                coordInicial,
                coordFinal,
              ];
            }).toList(),
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            cellStyle: const pw.TextStyle(fontSize: 9),
            cellAlignment: pw.Alignment.centerLeft,
          ),
        ],
      ),
    );

    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: nomeArquivo,
    );
  }

  String _escape(String s) => s.replaceAll('"', '""');
}
