import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../components/delete_button.dart';
import '../../models/compactacao_model.dart';
import '../../models/medicao_model.dart';
import '../../models/propriedade_model.dart';
import '../../models/usuario_model.dart';
import '../../models/veiculo_model.dart';
import '../../service/compactacao_service.dart';
import '../../service/medicao_service.dart';
import '../../service/propriedade_service.dart';
import '../../service/relatorio_service.dart';
import '../../service/usuario_service.dart';
import '../../service/veiculo_service.dart';
import '../../theme/app_colors.dart';

import 'editar_usuario_page.dart';
import '../usuario/propriedades/cadastro_propriedade_page.dart';
import '../usuario/veiculos/cadastro_veiculo_page.dart';

enum SecaoUsuarioAdmin { propriedades, maquinas, patinagens, compactacoes }

enum OrdenacaoAdmin { nomeAZ, nomeZA, dataRecente, dataAntiga }

class DetalhesUsuarioPage extends StatefulWidget {
  final UsuarioModel usuario;

  const DetalhesUsuarioPage({super.key, required this.usuario});

  @override
  State<DetalhesUsuarioPage> createState() => _DetalhesUsuarioPageState();
}

class _DetalhesUsuarioPageState extends State<DetalhesUsuarioPage> {
  UsuarioModel get usuario => widget.usuario;

  final usuarioService = UsuarioService();
  final veiculoService = VeiculoService();
  final medicaoService = MedicaoService();
  final propriedadeService = PropriedadeService();
  final compactacaoService = CompactacaoService();

  final TextEditingController _pesquisaCtrl = TextEditingController();

  final _df = DateFormat('dd/MM/yyyy HH:mm');

  SecaoUsuarioAdmin _secaoAtual = SecaoUsuarioAdmin.propriedades;
  OrdenacaoAdmin _ordenacao = OrdenacaoAdmin.nomeAZ;
  DateTime? _dataFiltro;
  String _termoPesquisa = '';

  Map<String, PropriedadeModel> _propsById = {};
  Map<String, VeiculoModel> _veiculosById = {};
  bool _cacheCarregado = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_cacheCarregado) {
      _cacheCarregado = true;
      _carregarCaches();
    }
  }

  @override
  void dispose() {
    _pesquisaCtrl.dispose();
    super.dispose();
  }

  Future<void> _carregarCaches() async {
    try {
      final props = await propriedadeService.listarPorUsuario(usuario.uid);
      final veiculos = await veiculoService.listarVeiculosPorUsuario(
        usuario.uid,
      );

      if (!mounted) return;

      setState(() {
        _propsById = {for (final p in props) p.id: p};
        _veiculosById = {for (final v in veiculos) v.id: v};
      });
    } catch (_) {}
  }

  Future<void> _excluirUsuario() async {
    try {
      final medicoes = await medicaoService.listarPorUsuario(usuario.uid);
      for (final m in medicoes) {
        await medicaoService.excluirMedicao(m.id);
      }

      final compactacoes = await compactacaoService.listarPorUsuario(
        usuario.uid,
      );
      for (final c in compactacoes) {
        await compactacaoService.excluir(c.id);
      }

      final veiculos = await veiculoService.listarVeiculosPorUsuario(
        usuario.uid,
      );
      for (final v in veiculos) {
        await veiculoService.excluirVeiculo(v.id);
      }

      final propriedades = await propriedadeService.listarPorUsuario(
        usuario.uid,
      );
      for (final p in propriedades) {
        await propriedadeService.excluir(p.id);
      }

      await usuarioService.excluirUsuario(usuario.uid);

      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuário excluído com sucesso')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao excluir usuário: $e')));
    }
  }

  String _normalize(String input) {
    final s = input.toLowerCase().trim();
    const comAcento = 'áàâãäéèêëíìîïóòôõöúùûüçñ';
    const semAcento = 'aaaaaeeeeiiiiooooouuuucn';
    var out = s;
    for (int i = 0; i < comAcento.length; i++) {
      out = out.replaceAll(comAcento[i], semAcento[i]);
    }
    return out;
  }

  void _trocarSecao(SecaoUsuarioAdmin secao) {
    setState(() {
      _secaoAtual = secao;
      _pesquisaCtrl.clear();
      _termoPesquisa = '';
      _dataFiltro = null;
      _ordenacao = OrdenacaoAdmin.nomeAZ;
    });
  }

  Future<void> _abrirOrdenacao() async {
    final selecionado = await showModalBottomSheet<OrdenacaoAdmin>(
      context: context,
      showDragHandle: true,
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const ListTile(title: Text('Ordenar')),
              ListTile(
                title: const Text('Nome (A → Z)'),
                onTap: () => Navigator.pop(context, OrdenacaoAdmin.nomeAZ),
              ),
              ListTile(
                title: const Text('Nome (Z → A)'),
                onTap: () => Navigator.pop(context, OrdenacaoAdmin.nomeZA),
              ),
              ListTile(
                title: const Text('Mais recentes'),
                onTap: () => Navigator.pop(context, OrdenacaoAdmin.dataRecente),
              ),
              ListTile(
                title: const Text('Mais antigas'),
                onTap: () => Navigator.pop(context, OrdenacaoAdmin.dataAntiga),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );

    if (selecionado != null && mounted) {
      setState(() => _ordenacao = selecionado);
    }
  }

  Future<void> _selecionarData() async {
    final hoje = DateTime.now();

    final data = await showDatePicker(
      context: context,
      initialDate: _dataFiltro ?? hoje,
      firstDate: DateTime(2020),
      lastDate: DateTime(hoje.year + 1),
      locale: const Locale('pt', 'BR'),
    );

    if (data != null && mounted) {
      setState(() => _dataFiltro = data);
    }
  }

  bool get _secaoSuportaFiltroData =>
      _secaoAtual == SecaoUsuarioAdmin.patinagens ||
      _secaoAtual == SecaoUsuarioAdmin.compactacoes;

  String _nomePropriedade(String propriedadeId) {
    final p = _propsById[propriedadeId];
    return p?.nome ?? '—';
  }

  String _nomeVeiculo(String veiculoId) {
    final v = _veiculosById[veiculoId];
    return v?.nome ?? '—';
  }

  String _posicaoRoda(String veiculoId, String rodaId) {
    final v = _veiculosById[veiculoId];
    if (v == null) return '—';

    for (final r in v.rodas) {
      if (r.posicao == rodaId) return r.posicao;
    }

    return rodaId.isEmpty ? '—' : rodaId;
  }

  String _formatCoord(double? y, double? x) {
    if (y == null || x == null) return '—';
    return '${y.toStringAsFixed(6)}, ${x.toStringAsFixed(6)}';
  }

  String _formatAlt(double? altitude) {
    if (altitude == null) return '—';
    return '${altitude.toStringAsFixed(2)} m';
  }

  String _labelSecao(SecaoUsuarioAdmin secao) {
    switch (secao) {
      case SecaoUsuarioAdmin.propriedades:
        return 'Propriedades';
      case SecaoUsuarioAdmin.maquinas:
        return 'Máquinas';
      case SecaoUsuarioAdmin.patinagens:
        return 'Patinagem';
      case SecaoUsuarioAdmin.compactacoes:
        return 'Compactação';
    }
  }

  Widget _infoLinha(String titulo, String valor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              titulo,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(valor)),
        ],
      ),
    );
  }

  Widget _cardUsuario() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: const Icon(Icons.person),
        title: Text(usuario.nome),
        subtitle: Text(usuario.email),
      ),
    );
  }

  Widget _chipsSecoes() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ChoiceChip(
          label: const Text('Propriedades'),
          selected: _secaoAtual == SecaoUsuarioAdmin.propriedades,
          onSelected: (_) => _trocarSecao(SecaoUsuarioAdmin.propriedades),
        ),
        ChoiceChip(
          label: const Text('Máquinas'),
          selected: _secaoAtual == SecaoUsuarioAdmin.maquinas,
          onSelected: (_) => _trocarSecao(SecaoUsuarioAdmin.maquinas),
        ),
        ChoiceChip(
          label: const Text('Patinagem'),
          selected: _secaoAtual == SecaoUsuarioAdmin.patinagens,
          onSelected: (_) => _trocarSecao(SecaoUsuarioAdmin.patinagens),
        ),
        ChoiceChip(
          label: const Text('Compactação'),
          selected: _secaoAtual == SecaoUsuarioAdmin.compactacoes,
          onSelected: (_) => _trocarSecao(SecaoUsuarioAdmin.compactacoes),
        ),
      ],
    );
  }

  Widget _campoPesquisa() {
    return TextField(
      controller: _pesquisaCtrl,
      decoration: InputDecoration(
        labelText: 'Pesquisar em ${_labelSecao(_secaoAtual).toLowerCase()}',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _pesquisaCtrl.text.isEmpty
            ? null
            : IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  setState(() {
                    _pesquisaCtrl.clear();
                    _termoPesquisa = '';
                  });
                },
              ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onChanged: (v) {
        setState(() {
          _termoPesquisa = _normalize(v);
        });
      },
    );
  }

  Widget _barraInfoSecao(int quantidade) {
    final dataTexto = _dataFiltro == null
        ? 'Sem filtro de data'
        : 'Data: ${DateFormat('dd/MM/yyyy').format(_dataFiltro!)}';

    return Row(
      children: [
        Expanded(
          child: Text(
            'Itens encontrados: $quantidade',
            style: const TextStyle(fontSize: 13),
          ),
        ),
        if (_secaoSuportaFiltroData)
          Text(dataTexto, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Future<void> _exportarCsvSecao() async {
    final relatorio = RelatorioService();

    try {
      switch (_secaoAtual) {
        case SecaoUsuarioAdmin.patinagens:
          final file = await relatorio.gerarCsvMedicoesUsuario(usuario.uid);
          await relatorio.compartilharArquivo(file);
          break;
        case SecaoUsuarioAdmin.propriedades:
        case SecaoUsuarioAdmin.maquinas:
        case SecaoUsuarioAdmin.compactacoes:
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Exportação CSV desta seção ainda não foi implementada',
              ),
            ),
          );
          break;
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao exportar CSV: $e')));
    }
  }

  Future<void> _exportarPdfSecao() async {
    final relatorio = RelatorioService();

    try {
      switch (_secaoAtual) {
        case SecaoUsuarioAdmin.patinagens:
          await relatorio.compartilharPdfMedicoesUsuario(
            usuario.uid,
            titulo: 'Calibragens - ${usuario.nome}',
          );
          break;
        case SecaoUsuarioAdmin.propriedades:
        case SecaoUsuarioAdmin.maquinas:
        case SecaoUsuarioAdmin.compactacoes:
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Exportação PDF desta seção ainda não foi implementada',
              ),
            ),
          );
          break;
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao exportar PDF: $e')));
    }
  }

  List<PropriedadeModel> _filtrarOrdenarPropriedades(
    List<PropriedadeModel> lista,
  ) {
    var out = [...lista];

    if (_termoPesquisa.isNotEmpty) {
      out = out.where((p) {
        final nome = _normalize(p.nome);
        final dono = _normalize(p.dono);
        final end = _normalize(p.endereco);
        return nome.contains(_termoPesquisa) ||
            dono.contains(_termoPesquisa) ||
            end.contains(_termoPesquisa);
      }).toList();
    }

    switch (_ordenacao) {
      case OrdenacaoAdmin.nomeAZ:
        out.sort(
          (a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()),
        );
        break;
      case OrdenacaoAdmin.nomeZA:
        out.sort(
          (a, b) => b.nome.toLowerCase().compareTo(a.nome.toLowerCase()),
        );
        break;
      case OrdenacaoAdmin.dataRecente:
      case OrdenacaoAdmin.dataAntiga:
        break;
    }

    return out;
  }

  List<VeiculoModel> _filtrarOrdenarVeiculos(List<VeiculoModel> lista) {
    var out = [...lista];

    if (_termoPesquisa.isNotEmpty) {
      out = out.where((v) {
        final nome = _normalize(v.nome);
        final tipo = _normalize(v.tipo);
        final desc = _normalize(v.descricao ?? '');
        return nome.contains(_termoPesquisa) ||
            tipo.contains(_termoPesquisa) ||
            desc.contains(_termoPesquisa);
      }).toList();
    }

    switch (_ordenacao) {
      case OrdenacaoAdmin.nomeAZ:
        out.sort(
          (a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()),
        );
        break;
      case OrdenacaoAdmin.nomeZA:
        out.sort(
          (a, b) => b.nome.toLowerCase().compareTo(a.nome.toLowerCase()),
        );
        break;
      case OrdenacaoAdmin.dataRecente:
      case OrdenacaoAdmin.dataAntiga:
        break;
    }

    return out;
  }

  List<MedicaoModel> _filtrarOrdenarMedicoes(List<MedicaoModel> lista) {
    var out = [...lista];

    if (_dataFiltro != null) {
      out = out.where((m) {
        return m.data.year == _dataFiltro!.year &&
            m.data.month == _dataFiltro!.month &&
            m.data.day == _dataFiltro!.day;
      }).toList();
    }

    if (_termoPesquisa.isNotEmpty) {
      out = out.where((m) {
        final nome = _normalize(m.nome);
        final prop = _normalize(_nomePropriedade(m.propriedadeId));
        final maq = _normalize(_nomeVeiculo(m.veiculoId));
        final roda = _normalize(_posicaoRoda(m.veiculoId, m.rodaId));
        return nome.contains(_termoPesquisa) ||
            prop.contains(_termoPesquisa) ||
            maq.contains(_termoPesquisa) ||
            roda.contains(_termoPesquisa);
      }).toList();
    }

    switch (_ordenacao) {
      case OrdenacaoAdmin.nomeAZ:
        out.sort(
          (a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()),
        );
        break;
      case OrdenacaoAdmin.nomeZA:
        out.sort(
          (a, b) => b.nome.toLowerCase().compareTo(a.nome.toLowerCase()),
        );
        break;
      case OrdenacaoAdmin.dataRecente:
        out.sort((a, b) => b.data.compareTo(a.data));
        break;
      case OrdenacaoAdmin.dataAntiga:
        out.sort((a, b) => a.data.compareTo(b.data));
        break;
    }

    return out;
  }

  List<CompactacaoModel> _filtrarOrdenarCompactacoes(
    List<CompactacaoModel> lista,
  ) {
    var out = [...lista];

    if (_dataFiltro != null) {
      out = out.where((c) {
        return c.data.year == _dataFiltro!.year &&
            c.data.month == _dataFiltro!.month &&
            c.data.day == _dataFiltro!.day;
      }).toList();
    }

    if (_termoPesquisa.isNotEmpty) {
      out = out.where((c) {
        final nome = _normalize(c.nome);
        final prop = _normalize(_nomePropriedade(c.propriedadeId));
        final maq = _normalize(_nomeVeiculo(c.veiculoId));
        final status = _normalize(c.statusCalculo);
        return nome.contains(_termoPesquisa) ||
            prop.contains(_termoPesquisa) ||
            maq.contains(_termoPesquisa) ||
            status.contains(_termoPesquisa);
      }).toList();
    }

    switch (_ordenacao) {
      case OrdenacaoAdmin.nomeAZ:
        out.sort(
          (a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()),
        );
        break;
      case OrdenacaoAdmin.nomeZA:
        out.sort(
          (a, b) => b.nome.toLowerCase().compareTo(a.nome.toLowerCase()),
        );
        break;
      case OrdenacaoAdmin.dataRecente:
        out.sort((a, b) => b.data.compareTo(a.data));
        break;
      case OrdenacaoAdmin.dataAntiga:
        out.sort((a, b) => a.data.compareTo(b.data));
        break;
    }

    return out;
  }

  Widget _secaoPropriedades() {
    return FutureBuilder<List<PropriedadeModel>>(
      future: propriedadeService.listarPorUsuario(usuario.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(8),
            child: CircularProgressIndicator(),
          );
        }

        final lista = _filtrarOrdenarPropriedades(snapshot.data ?? []);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _barraInfoSecao(lista.length),
            const SizedBox(height: 12),
            if (lista.isEmpty)
              const Text('Nenhuma propriedade encontrada')
            else
              ...lista.map((p) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.home_work),
                    title: Text(
                      p.nome,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('Dono: ${p.dono}\nEndereço: ${p.endereco}'),
                    isThreeLine: true,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          tooltip: 'Editar',
                          onPressed: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => CadastroPropriedadePage(
                                  propriedade: p,
                                  uidAlvo: usuario.uid,
                                ),
                              ),
                            );
                            if (!mounted) return;
                            await _carregarCaches();
                            setState(() {});
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          tooltip: 'Excluir',
                          onPressed: () async {
                            await propriedadeService.excluir(p.id);
                            if (!mounted) return;
                            await _carregarCaches();
                            setState(() {});
                          },
                        ),
                      ],
                    ),
                  ),
                );
              }),
          ],
        );
      },
    );
  }

  Widget _secaoMaquinas() {
    return FutureBuilder<List<VeiculoModel>>(
      future: veiculoService.listarVeiculosPorUsuario(usuario.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(8),
            child: CircularProgressIndicator(),
          );
        }

        final lista = _filtrarOrdenarVeiculos(snapshot.data ?? []);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _barraInfoSecao(lista.length),
            const SizedBox(height: 12),
            if (lista.isEmpty)
              const Text('Nenhuma máquina encontrada')
            else
              ...lista.map((v) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.agriculture),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                v.nome,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit),
                              tooltip: 'Editar máquina',
                              onPressed: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => CadastroVeiculoPage(
                                      veiculo: v,
                                      uidAlvo: usuario.uid,
                                    ),
                                  ),
                                );
                                if (!mounted) return;
                                await _carregarCaches();
                                setState(() {});
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              tooltip: 'Excluir máquina',
                              onPressed: () async {
                                await veiculoService.excluirVeiculo(v.id);
                                if (!mounted) return;
                                await _carregarCaches();
                                setState(() {});
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text('Tipo: ${v.tipo}'),
                        if ((v.descricao ?? '').trim().isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text('Descrição: ${v.descricao}'),
                          ),
                        const SizedBox(height: 8),
                        const Text(
                          'Circunferência das rodas:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: v.rodas.map((r) {
                            final circ = r.circunferencia;
                            return Text(
                              '• ${r.posicao} – ${circ != null ? '${circ.toStringAsFixed(2)} m' : 'Não informada'}',
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                );
              }),
          ],
        );
      },
    );
  }

  Widget _secaoPatinagens() {
    return FutureBuilder<List<MedicaoModel>>(
      future: medicaoService.listarPorUsuario(usuario.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(8),
            child: CircularProgressIndicator(),
          );
        }

        final lista = _filtrarOrdenarMedicoes(snapshot.data ?? []);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _barraInfoSecao(lista.length),
            const SizedBox(height: 12),
            if (lista.isEmpty)
              const Text('Nenhuma calibragem encontrada')
            else
              ...lista.map((m) {
                final propNome = _nomePropriedade(m.propriedadeId);
                final veicNome = _nomeVeiculo(m.veiculoId);
                final rodaNome = _posicaoRoda(m.veiculoId, m.rodaId);

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                m.nome,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              tooltip: 'Excluir calibragem',
                              onPressed: () async {
                                await medicaoService.excluirMedicao(m.id);
                                if (!mounted) return;
                                setState(() {});
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        _infoLinha('Data', _df.format(m.data)),
                        _infoLinha('Propriedade', propNome),
                        _infoLinha('Máquina', veicNome),
                        _infoLinha('Roda', rodaNome),
                        const Divider(height: 20),
                        _infoLinha(
                          'Distância',
                          '${m.distancia.toStringAsFixed(2)} m',
                        ),
                        _infoLinha('Voltas', m.voltas.toString()),
                        _infoLinha(
                          'Circunferência da roda',
                          '${m.perimetro.toStringAsFixed(2)} m',
                        ),
                        _infoLinha(
                          'Patinagem',
                          '${m.patinagem.toStringAsFixed(2)} %',
                        ),
                        _infoLinha(
                          'Coordenada inicial',
                          _formatCoord(
                            m.coordenadaInicialY,
                            m.coordenadaInicialX,
                          ),
                        ),
                        _infoLinha(
                          'Coordenada final',
                          _formatCoord(m.coordenadaFinalY, m.coordenadaFinalX),
                        ),
                        _infoLinha(
                          'Altitude inicial',
                          _formatAlt(m.altitudeInicial),
                        ),
                        _infoLinha(
                          'Altitude final',
                          _formatAlt(m.altitudeFinal),
                        ),
                      ],
                    ),
                  ),
                );
              }),
          ],
        );
      },
    );
  }

  Widget _secaoCompactacoes() {
    return FutureBuilder<List<CompactacaoModel>>(
      future: compactacaoService.listarPorUsuario(usuario.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(8),
            child: CircularProgressIndicator(),
          );
        }

        final lista = _filtrarOrdenarCompactacoes(snapshot.data ?? []);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _barraInfoSecao(lista.length),
            const SizedBox(height: 12),
            if (lista.isEmpty)
              const Text('Nenhuma medição de compactação encontrada')
            else
              ...lista.map((c) {
                final propNome = _nomePropriedade(c.propriedadeId);
                final veicNome = _nomeVeiculo(c.veiculoId);

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                c.nome,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              tooltip: 'Excluir medição de compactação',
                              onPressed: () async {
                                await compactacaoService.excluir(c.id);
                                if (!mounted) return;
                                setState(() {});
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        _infoLinha('Data', _df.format(c.data)),
                        _infoLinha('Propriedade', propNome),
                        _infoLinha('Máquina', veicNome),
                        const Divider(height: 20),
                        _infoLinha(
                          'Calibragem realizada',
                          c.calibragemRealizada ? 'Sim' : 'Não',
                        ),
                        _infoLinha(
                          'Patinagem de referência',
                          c.patinagemReferencia == null
                              ? '—'
                              : '${c.patinagemReferencia!.toStringAsFixed(2)} %',
                        ),
                        _infoLinha(
                          'Índice de compactação',
                          c.indiceCompactacao == null
                              ? 'Não calculado'
                              : c.indiceCompactacao!.toStringAsFixed(2),
                        ),
                        _infoLinha('Status', c.statusCalculo),
                        _infoLinha(
                          'Observações',
                          (c.observacoes == null ||
                                  c.observacoes!.trim().isEmpty)
                              ? '—'
                              : c.observacoes!,
                        ),
                      ],
                    ),
                  ),
                );
              }),
          ],
        );
      },
    );
  }

  Widget _buildSecaoAtual() {
    switch (_secaoAtual) {
      case SecaoUsuarioAdmin.propriedades:
        return _secaoPropriedades();
      case SecaoUsuarioAdmin.maquinas:
        return _secaoMaquinas();
      case SecaoUsuarioAdmin.patinagens:
        return _secaoPatinagens();
      case SecaoUsuarioAdmin.compactacoes:
        return _secaoCompactacoes();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fundo,
      appBar: AppBar(
        title: Text('Usuário: ${usuario.nome}'),
        backgroundColor: AppColors.azul,
        actions: [
          if (_secaoSuportaFiltroData)
            IconButton(
              icon: const Icon(Icons.calendar_today),
              tooltip: 'Filtrar por data',
              onPressed: _selecionarData,
            ),
          IconButton(
            icon: const Icon(Icons.sort),
            tooltip: 'Ordenar',
            onPressed: _abrirOrdenacao,
          ),
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: 'Exportar PDF da seção atual',
            onPressed: _exportarPdfSecao,
          ),
          IconButton(
            icon: const Icon(Icons.table_chart),
            tooltip: 'Exportar CSV da seção atual',
            onPressed: _exportarCsvSecao,
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Editar perfil',
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditarUsuarioPage(usuario: usuario),
                ),
              );
              if (!mounted) return;
              setState(() {});
              await _carregarCaches();
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _cardUsuario(),
          const SizedBox(height: 16),
          _chipsSecoes(),
          const SizedBox(height: 16),
          _campoPesquisa(),
          const SizedBox(height: 16),
          _buildSecaoAtual(),
          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 16),
          DeleteButton(
            titulo: 'Excluir usuário',
            mensagem:
                'Este usuário será removido do sistema.\n'
                'Todas as máquinas, propriedades, calibragens e medições de compactação também serão excluídas.\n\n'
                'Essa ação não pode ser desfeita.',
            onConfirm: _excluirUsuario,
          ),
        ],
      ),
    );
  }
}
