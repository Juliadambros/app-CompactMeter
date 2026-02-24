import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../components/delete_button.dart';
import '../../models/medicao_model.dart';
import '../../models/propriedade_model.dart';
import '../../models/usuario_model.dart';
import '../../models/veiculo_model.dart';
import '../../service/medicao_service.dart';
import '../../service/propriedade_service.dart';
import '../../service/relatorio_service.dart';
import '../../service/usuario_service.dart';
import '../../service/veiculo_service.dart';
import '../../theme/app_colors.dart';
import 'editar_usuario_page.dart';
import '../usuario/propriedades/cadastro_propriedade_page.dart';
import '../usuario/veiculos/cadastro_veiculo_page.dart';

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

  final _df = DateFormat('dd/MM/yyyy HH:mm');

  Map<String, PropriedadeModel> _propsById = {};
  Map<String, VeiculoModel> _veiculosById = {};
  bool _cacheCarregado = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // carrega uma vez por tela
    if (!_cacheCarregado) {
      _cacheCarregado = true;
      _carregarCaches();
    }
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
    } catch (_) {
      // se falhar
    }
  }

  Future<void> _excluirUsuario() async {
    try {
      final medicoes = await medicaoService.listarPorUsuario(usuario.uid);
      for (final m in medicoes) {
        await medicaoService.excluirMedicao(m.id);
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

  Widget _infoLinha(String titulo, String valor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fundo,
      appBar: AppBar(
        title: Text('Usuário: ${usuario.nome}'),
        backgroundColor: AppColors.azul,
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: 'Exportar PDF (medições)',
            onPressed: () async {
              final relatorio = RelatorioService();
              await relatorio.compartilharPdfMedicoesUsuario(
                usuario.uid,
                titulo: 'Medições - ${usuario.nome}',
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.table_chart),
            tooltip: 'Exportar CSV (medições)',
            onPressed: () async {
              final relatorio = RelatorioService();
              final file = await relatorio.gerarCsvMedicoesUsuario(usuario.uid);
              await relatorio.compartilharArquivo(file);
            },
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
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: const Icon(Icons.person),
              title: Text(usuario.nome),
              subtitle: Text(usuario.email),
            ),
          ),

          const SizedBox(height: 24),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Propriedades cadastradas',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              IconButton(
                tooltip: 'Cadastrar propriedade',
                icon: const Icon(Icons.add),
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          CadastroPropriedadePage(uidAlvo: usuario.uid),
                    ),
                  );
                  if (!mounted) return;
                  await _carregarCaches();
                  setState(() {});
                },
              ),
            ],
          ),
          const SizedBox(height: 8),

          FutureBuilder<List<PropriedadeModel>>(
            future: propriedadeService.listarPorUsuario(usuario.uid),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(8),
                  child: CircularProgressIndicator(),
                );
              }

              final propriedades = snapshot.data ?? [];

              if (propriedades.isEmpty) {
                return const Text('Nenhuma propriedade cadastrada');
              }

              return Column(
                children: propriedades.map((p) {
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
                      subtitle: Text(
                        'Dono: ${p.dono}\nEndereço: ${p.endereco}',
                      ),
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
                }).toList(),
              );
            },
          ),

          const SizedBox(height: 24),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Máquinas cadastradas',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              IconButton(
                tooltip: 'Cadastrar máquina',
                icon: const Icon(Icons.add),
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CadastroVeiculoPage(uidAlvo: usuario.uid),
                    ),
                  );
                  if (!mounted) return;
                  await _carregarCaches();
                  setState(() {});
                },
              ),
            ],
          ),
          const SizedBox(height: 8),

          FutureBuilder<List<VeiculoModel>>(
            future: veiculoService.listarVeiculosPorUsuario(usuario.uid),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(8),
                  child: CircularProgressIndicator(),
                );
              }

              final veiculos = snapshot.data ?? [];

              if (veiculos.isEmpty) {
                return const Text('Nenhuma máquina cadastrada');
              }

              return Column(
                children: veiculos.map((v) {
                  final rodasComSensor = v.rodas
                      .where((r) => r.temSensor)
                      .toList();

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
                          if (rodasComSensor.isEmpty)
                            const Text('Nenhum sensor cadastrado'),
                          if (rodasComSensor.isNotEmpty)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: rodasComSensor.map((r) {
                                return Text(
                                  '• ${r.posicao} – ${r.circunferencia?.toStringAsFixed(2)} m',
                                );
                              }).toList(),
                            ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),

          const SizedBox(height: 24),

          const Text(
            'Medições realizadas',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          FutureBuilder<List<MedicaoModel>>(
            future: medicaoService.listarPorUsuario(usuario.uid),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(8),
                  child: CircularProgressIndicator(),
                );
              }

              final medicoes = snapshot.data ?? [];

              if (medicoes.isEmpty) {
                return const Text('Nenhuma medição realizada');
              }

              return Column(
                children: medicoes.map((m) {
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
                                tooltip: 'Excluir medição',
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
                            'Raio do eixo',
                            m.raioEixo.toStringAsFixed(2),
                          ),
                          _infoLinha(
                            'Distância',
                            '${m.distancia.toStringAsFixed(2)} m',
                          ),
                          _infoLinha('Voltas', m.voltas.toString()),
                          _infoLinha(
                            'Perímetro',
                            m.perimetro.toStringAsFixed(2),
                          ),
                          _infoLinha(
                            'Patinagem',
                            '${m.patinagem.toStringAsFixed(2)}%',
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),

          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 16),

          DeleteButton(
            titulo: 'Excluir usuário',
            mensagem:
                'Este usuário será removido do sistema.\n'
                'Todas as máquinas, propriedades e medições também serão excluídas.\n\n'
                'Essa ação não pode ser desfeita.',
            onConfirm: _excluirUsuario,
          ),
        ],
      ),
    );
  }
}
