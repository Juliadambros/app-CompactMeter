import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import '../../../models/medicao_model.dart';
import '../../../service/medicao_service.dart';
import '../../../theme/app_colors.dart';
import '../../../components/loading.dart';
import '../../../components/delete_button.dart';
import '../medicoes/resultado_medicao_page.dart';

enum FiltroHistoricoPatinagem {
  maisRecentes,
  maisAntigas,
  maiorPatinagem,
  menorPatinagem,
}

class HistoricoPatinagemPage extends StatefulWidget {
  const HistoricoPatinagemPage({super.key});

  @override
  State<HistoricoPatinagemPage> createState() =>
      _HistoricoPatinagemPageState();
}

class _HistoricoPatinagemPageState extends State<HistoricoPatinagemPage> {
  late Future<List<MedicaoModel>> _futureMedicoes;

  FiltroHistoricoPatinagem _filtroAtual =
      FiltroHistoricoPatinagem.maisRecentes;
  DateTime? _dataSelecionada;

  @override
  void initState() {
    super.initState();
    _carregarHistorico();
  }

  void _carregarHistorico() {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    _futureMedicoes = MedicaoService().listarPorUsuario(uid);
  }

  Future<void> _excluirMedicao(String medicaoId) async {
    await MedicaoService().excluirMedicao(medicaoId);

    if (!mounted) return;

    setState(_carregarHistorico);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Calibragem excluída com sucesso')),
    );
  }

  Future<void> _selecionarData() async {
    final hoje = DateTime.now();

    final data = await showDatePicker(
      context: context,
      initialDate: _dataSelecionada ?? hoje,
      firstDate: DateTime(2020),
      lastDate: DateTime(hoje.year + 1),
      locale: const Locale('pt', 'BR'),
    );

    if (data != null) {
      setState(() {
        _dataSelecionada = data;
      });
    }
  }

  void _aplicarFiltros(List<MedicaoModel> medicoes) {
    if (_dataSelecionada != null) {
      medicoes.removeWhere(
        (m) =>
            m.data.year != _dataSelecionada!.year ||
            m.data.month != _dataSelecionada!.month ||
            m.data.day != _dataSelecionada!.day,
      );
    }

    switch (_filtroAtual) {
      case FiltroHistoricoPatinagem.maisRecentes:
        medicoes.sort((a, b) => b.data.compareTo(a.data));
        break;
      case FiltroHistoricoPatinagem.maisAntigas:
        medicoes.sort((a, b) => a.data.compareTo(b.data));
        break;
      case FiltroHistoricoPatinagem.maiorPatinagem:
        medicoes.sort((a, b) => b.patinagem.compareTo(a.patinagem));
        break;
      case FiltroHistoricoPatinagem.menorPatinagem:
        medicoes.sort((a, b) => a.patinagem.compareTo(b.patinagem));
        break;
    }
  }

  String _formatCoord(double? y, double? x) {
    if (y == null || x == null) return '—';
    return '${y.toStringAsFixed(6)}, ${x.toStringAsFixed(6)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fundo,
      appBar: AppBar(
        title: const Text('Histórico de Patinagem'),
        backgroundColor: AppColors.azul,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            tooltip: 'Filtrar por data',
            onPressed: _selecionarData,
          ),
          if (_dataSelecionada != null)
            IconButton(
              icon: const Icon(Icons.clear),
              tooltip: 'Limpar filtro de data',
              onPressed: () {
                setState(() => _dataSelecionada = null);
              },
            ),
          PopupMenuButton<FiltroHistoricoPatinagem>(
            icon: const Icon(Icons.filter_list),
            onSelected: (filtro) {
              setState(() => _filtroAtual = filtro);
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: FiltroHistoricoPatinagem.maisRecentes,
                child: Text('Mais recentes'),
              ),
              PopupMenuItem(
                value: FiltroHistoricoPatinagem.maisAntigas,
                child: Text('Mais antigas'),
              ),
              PopupMenuItem(
                value: FiltroHistoricoPatinagem.maiorPatinagem,
                child: Text('Maior patinagem'),
              ),
              PopupMenuItem(
                value: FiltroHistoricoPatinagem.menorPatinagem,
                child: Text('Menor patinagem'),
              ),
            ],
          ),
        ],
      ),
      body: FutureBuilder<List<MedicaoModel>>(
        future: _futureMedicoes,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const AppLoading();
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Erro ao carregar histórico:\n${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Nenhuma calibragem encontrada'));
          }

          final medicoes = List<MedicaoModel>.from(snapshot.data!);
          _aplicarFiltros(medicoes);

          if (medicoes.isEmpty) {
            return const Center(
              child: Text('Nenhuma calibragem encontrada para a data selecionada'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: medicoes.length,
            itemBuilder: (context, index) {
              final medicao = medicoes[index];
              final data = DateFormat('dd/MM/yyyy HH:mm').format(medicao.data);

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              medicao.nome,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          DeleteButton(
                            mensagem: 'Deseja excluir esta calibragem?',
                            onConfirm: () => _excluirMedicao(medicao.id),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _linha('Data', data),
                      _linha(
                        'Patinagem',
                        '${medicao.patinagem.toStringAsFixed(2)} %',
                        destaque: true,
                      ),
                      _linha(
                        'Distância',
                        '${medicao.distancia.toStringAsFixed(2)} m',
                      ),
                      _linha('Voltas', medicao.voltas.toString()),
                      _linha(
                        'Perímetro / Circunferência',
                        '${medicao.perimetro.toStringAsFixed(2)} m',
                      ),
                      _linha(
                        'Coordenada inicial',
                        _formatCoord(
                          medicao.coordenadaInicialY,
                          medicao.coordenadaInicialX,
                        ),
                      ),
                      _linha(
                        'Coordenada final',
                        _formatCoord(
                          medicao.coordenadaFinalY,
                          medicao.coordenadaFinalX,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        alignment: WrapAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.picture_as_pdf),
                            tooltip: 'Gerar PDF',
                            onPressed: () {
                              ResultadoMedicaoPage.gerarPdf(
                                context,
                                medicao,
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.table_chart),
                            tooltip: 'Gerar CSV',
                            onPressed: () {
                              ResultadoMedicaoPage.gerarCsv(
                                context,
                                medicao,
                              );
                            },
                          ),
                          TextButton.icon(
                            icon: const Icon(Icons.arrow_forward),
                            label: const Text('Detalhes'),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      ResultadoMedicaoPage(medicao: medicao),
                                ),
                              );
                            },
                          ),
                        ],
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

  Widget _linha(String titulo, String valor, {bool destaque = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(titulo),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 6,
            child: Text(
              valor,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontWeight: destaque ? FontWeight.bold : FontWeight.normal,
                color: destaque ? AppColors.verde : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}