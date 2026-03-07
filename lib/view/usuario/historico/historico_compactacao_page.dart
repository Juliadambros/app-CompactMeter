import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import '../../../models/compactacao_model.dart';
import '../../../service/compactacao_service.dart';
import '../../../theme/app_colors.dart';
import '../../../components/loading.dart';
import '../../../components/delete_button.dart';
import '../compactacao/resultado_compactacao_page.dart';

enum FiltroHistoricoCompactacao {
  maisRecentes,
  maisAntigas,
  maiorIndice,
  menorIndice,
}

class HistoricoCompactacaoPage extends StatefulWidget {
  const HistoricoCompactacaoPage({super.key});

  @override
  State<HistoricoCompactacaoPage> createState() =>
      _HistoricoCompactacaoPageState();
}

class _HistoricoCompactacaoPageState extends State<HistoricoCompactacaoPage> {
  late Future<List<CompactacaoModel>> _futureCompactacoes;

  FiltroHistoricoCompactacao _filtroAtual =
      FiltroHistoricoCompactacao.maisRecentes;
  DateTime? _dataSelecionada;

  @override
  void initState() {
    super.initState();
    _carregarHistorico();
  }

  void _carregarHistorico() {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    _futureCompactacoes = CompactacaoService().listarPorUsuario(uid);
  }

  Future<void> _excluirCompactacao(String id) async {
    await CompactacaoService().excluir(id);

    if (!mounted) return;

    setState(_carregarHistorico);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Medição de compactação excluída com sucesso')),
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

  void _aplicarFiltros(List<CompactacaoModel> compactacoes) {
    if (_dataSelecionada != null) {
      compactacoes.removeWhere(
        (c) =>
            c.data.year != _dataSelecionada!.year ||
            c.data.month != _dataSelecionada!.month ||
            c.data.day != _dataSelecionada!.day,
      );
    }

    switch (_filtroAtual) {
      case FiltroHistoricoCompactacao.maisRecentes:
        compactacoes.sort((a, b) => b.data.compareTo(a.data));
        break;
      case FiltroHistoricoCompactacao.maisAntigas:
        compactacoes.sort((a, b) => a.data.compareTo(b.data));
        break;
      case FiltroHistoricoCompactacao.maiorIndice:
        compactacoes.sort((a, b) {
          final va = a.indiceCompactacao ?? -999999;
          final vb = b.indiceCompactacao ?? -999999;
          return vb.compareTo(va);
        });
        break;
      case FiltroHistoricoCompactacao.menorIndice:
        compactacoes.sort((a, b) {
          final va = a.indiceCompactacao ?? 999999;
          final vb = b.indiceCompactacao ?? 999999;
          return va.compareTo(vb);
        });
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fundo,
      appBar: AppBar(
        title: const Text('Histórico de Compactação'),
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
          PopupMenuButton<FiltroHistoricoCompactacao>(
            icon: const Icon(Icons.filter_list),
            onSelected: (filtro) {
              setState(() => _filtroAtual = filtro);
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: FiltroHistoricoCompactacao.maisRecentes,
                child: Text('Mais recentes'),
              ),
              PopupMenuItem(
                value: FiltroHistoricoCompactacao.maisAntigas,
                child: Text('Mais antigas'),
              ),
              PopupMenuItem(
                value: FiltroHistoricoCompactacao.maiorIndice,
                child: Text('Maior índice'),
              ),
              PopupMenuItem(
                value: FiltroHistoricoCompactacao.menorIndice,
                child: Text('Menor índice'),
              ),
            ],
          ),
        ],
      ),
      body: FutureBuilder<List<CompactacaoModel>>(
        future: _futureCompactacoes,
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
            return const Center(
              child: Text('Nenhuma medição de compactação encontrada'),
            );
          }

          final compactacoes = List<CompactacaoModel>.from(snapshot.data!);
          _aplicarFiltros(compactacoes);

          if (compactacoes.isEmpty) {
            return const Center(
              child: Text('Nenhuma medição encontrada para a data selecionada'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: compactacoes.length,
            itemBuilder: (context, index) {
              final compactacao = compactacoes[index];
              final data = DateFormat('dd/MM/yyyy HH:mm').format(compactacao.data);

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
                              compactacao.nome,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          DeleteButton(
                            mensagem:
                                'Deseja excluir esta medição de compactação?',
                            onConfirm: () =>
                                _excluirCompactacao(compactacao.id),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _linha('Data', data),
                      _linha(
                        'Índice de compactação',
                        compactacao.indiceCompactacao == null
                            ? 'Não calculado'
                            : compactacao.indiceCompactacao!.toStringAsFixed(2),
                        destaque: true,
                      ),
                      _linha(
                        'Patinagem de referência',
                        compactacao.patinagemReferencia == null
                            ? '—'
                            : '${compactacao.patinagemReferencia!.toStringAsFixed(2)} %',
                      ),
                      _linha(
                        'Calibragem realizada',
                        compactacao.calibragemRealizada ? 'Sim' : 'Não',
                      ),
                      _linha('Status', compactacao.statusCalculo),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          icon: const Icon(Icons.arrow_forward),
                          label: const Text('Detalhes'),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ResultadoCompactacaoPage(
                                  compactacao: compactacao,
                                ),
                              ),
                            );
                          },
                        ),
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