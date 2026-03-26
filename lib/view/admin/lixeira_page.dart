import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/compactacao_model.dart';
import '../../models/medicao_model.dart';
import '../../models/propriedade_model.dart';
import '../../models/usuario_model.dart';
import '../../models/veiculo_model.dart';
import '../../service/compactacao_service.dart';
import '../../service/medicao_service.dart';
import '../../service/propriedade_service.dart';
import '../../service/usuario_service.dart';
import '../../service/veiculo_service.dart';
import '../../theme/app_colors.dart';

enum SecaoLixeira {
  usuarios,
  patinagens,
  compactacoes,
  maquinas,
  propriedades,
}

class LixeiraPage extends StatefulWidget {
  const LixeiraPage({super.key});

  @override
  State<LixeiraPage> createState() => _LixeiraPageState();
}

class _LixeiraPageState extends State<LixeiraPage> {
  final _usuarioService = UsuarioService();
  final _medicaoService = MedicaoService();
  final _compactacaoService = CompactacaoService();
  final _veiculoService = VeiculoService();
  final _propriedadeService = PropriedadeService();
  final _df = DateFormat('dd/MM/yyyy HH:mm');

  SecaoLixeira _secaoAtual = SecaoLixeira.usuarios;
  int _refreshKey = 0;

  bool _refsCarregadas = false;
  Map<String, UsuarioModel> _usuariosById = {};
  Map<String, VeiculoModel> _veiculosById = {};
  Map<String, PropriedadeModel> _propriedadesById = {};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_refsCarregadas) {
      _refsCarregadas = true;
      _carregarReferencias();
    }
  }

  Future<void> _carregarReferencias() async {
    try {
      final usuariosAtivos = await _usuarioService.listarUsuarios();
      final usuariosExcluidos = await _usuarioService.listarExcluidos();
      final veiculos = await _veiculoService.listarTodos();
      final propriedades = await _propriedadeService.listarTodas();

      if (!mounted) return;
      setState(() {
        _usuariosById = {
          for (final u in [...usuariosAtivos, ...usuariosExcluidos]) u.uid: u,
        };
        _veiculosById = {for (final v in veiculos) v.id: v};
        _propriedadesById = {for (final p in propriedades) p.id: p};
      });
    } catch (_) {}
  }

  void _refresh() {
    setState(() {
      _refreshKey++;
    });
    _carregarReferencias();
  }

  String _formatarData(DateTime? data) {
    if (data == null) return 'Data de exclusão não informada';
    return _df.format(data);
  }

  String _nomeUsuario(String usuarioId) {
    if (usuarioId.isEmpty) return 'Usuário não informado';
    final usuario = _usuariosById[usuarioId];
    if (usuario == null) return 'Usuário não encontrado';
    if (usuario.email.trim().isEmpty) return usuario.nome;
    return '${usuario.nome} (${usuario.email})';
  }

  String _nomeVeiculo(String veiculoId) {
    if (veiculoId.isEmpty) return 'Máquina não informada';
    final veiculo = _veiculosById[veiculoId];
    return veiculo?.nome ?? 'Máquina não encontrada';
  }

  String _nomePropriedade(String propriedadeId) {
    if (propriedadeId.isEmpty) return 'Propriedade não informada';
    final propriedade = _propriedadesById[propriedadeId];
    return propriedade?.nome ?? 'Propriedade não encontrada';
  }

  Future<void> _restaurarUsuario(String id) async {
    await _usuarioService.restaurarUsuario(id);
    if (!mounted) return;
    _refresh();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Usuário restaurado com sucesso')),
    );
  }

  Future<void> _excluirUsuarioPermanentemente(String id) async {
    await _usuarioService.excluirPermanentemente(id);
    if (!mounted) return;
    _refresh();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Usuário excluído permanentemente')),
    );
  }

  Future<void> _restaurarPatinagem(String id) async {
    await _medicaoService.restaurarMedicao(id);
    if (!mounted) return;
    _refresh();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Patinagem restaurada com sucesso')),
    );
  }

  Future<void> _excluirPatinagemPermanentemente(String id) async {
    await _medicaoService.excluirPermanentemente(id);
    if (!mounted) return;
    _refresh();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Patinagem excluída permanentemente')),
    );
  }

  Future<void> _restaurarCompactacao(String id) async {
    await _compactacaoService.restaurar(id);
    if (!mounted) return;
    _refresh();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Compactação restaurada com sucesso')),
    );
  }

  Future<void> _excluirCompactacaoPermanentemente(String id) async {
    await _compactacaoService.excluirPermanentemente(id);
    if (!mounted) return;
    _refresh();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Compactação excluída permanentemente')),
    );
  }

  Future<void> _restaurarVeiculo(String id) async {
    await _veiculoService.restaurarVeiculo(id);
    if (!mounted) return;
    _refresh();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Máquina restaurada com sucesso')),
    );
  }

  Future<void> _excluirVeiculoPermanentemente(String id) async {
    await _veiculoService.excluirPermanentemente(id);
    if (!mounted) return;
    _refresh();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Máquina excluída permanentemente')),
    );
  }

  Future<void> _restaurarPropriedade(String id) async {
    await _propriedadeService.restaurar(id);
    if (!mounted) return;
    _refresh();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Propriedade restaurada com sucesso')),
    );
  }

  Future<void> _excluirPropriedadePermanentemente(String id) async {
    await _propriedadeService.excluirPermanentemente(id);
    if (!mounted) return;
    _refresh();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Propriedade excluída permanentemente')),
    );
  }

  Widget _chip(SecaoLixeira secao, String texto) {
    return ChoiceChip(
      label: Text(texto),
      selected: _secaoAtual == secao,
      onSelected: (_) => setState(() => _secaoAtual = secao),
    );
  }

  Future<bool?> _confirmarExclusaoPermanente(String label) {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Excluir permanentemente'),
        content: Text(
          'Deseja excluir $label permanentemente? Essa ação não poderá ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  Widget _acaoes({
    required VoidCallback onRestaurar,
    required Future<void> Function() onExcluir,
    required String label,
  }) {
    return Wrap(
      spacing: 4,
      children: [
        IconButton(
          icon: const Icon(Icons.restore),
          tooltip: 'Restaurar',
          onPressed: onRestaurar,
        ),
        IconButton(
          icon: const Icon(Icons.delete_forever),
          tooltip: 'Excluir permanentemente',
          onPressed: () async {
            final confirmar = await _confirmarExclusaoPermanente(label);
            if (confirmar == true) {
              await onExcluir();
            }
          },
        ),
      ],
    );
  }

  Widget _cardBase({
    required IconData icon,
    required String titulo,
    required String subtitulo,
    required Widget trailing,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: AppColors.azul),
        title: Text(titulo),
        subtitle: Text(subtitulo),
        trailing: trailing,
      ),
    );
  }

  Widget _listaVazia(String texto) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(texto, textAlign: TextAlign.center),
      ),
    );
  }

  Widget _secaoUsuarios() {
    return FutureBuilder<List<UsuarioModel>>(
      key: ValueKey('usuarios-$_refreshKey'),
      future: _usuarioService.listarExcluidos(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return _listaVazia('Erro ao carregar usuários excluídos.');
        }
        final lista = snapshot.data ?? [];
        if (lista.isEmpty) return _listaVazia('Nenhum usuário na lixeira.');
        return ListView.builder(
          itemCount: lista.length,
          itemBuilder: (_, index) {
            final u = lista[index];
            return _cardBase(
              icon: Icons.person_off,
              titulo: u.nome,
              subtitulo: '${u.email} Excluído em: ${_formatarData(u.dataExclusao)}',
              trailing: _acaoes(
                label: 'este usuário',
                onRestaurar: () => _restaurarUsuario(u.uid),
                onExcluir: () => _excluirUsuarioPermanentemente(u.uid),
              ),
            );
          },
        );
      },
    );
  }

  Widget _secaoPatinagens() {
    return FutureBuilder<List<MedicaoModel>>(
      key: ValueKey('patinagens-$_refreshKey'),
      future: _medicaoService.listarExcluidas(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return _listaVazia('Erro ao carregar patinagens excluídas.');
        }
        final lista = snapshot.data ?? [];
        if (lista.isEmpty) return _listaVazia('Nenhuma patinagem na lixeira.');
        return ListView.builder(
          itemCount: lista.length,
          itemBuilder: (_, index) {
            final m = lista[index];
            return _cardBase(
              icon: Icons.speed,
              titulo: m.nome,
              subtitulo:
                  'Usuário: ${_nomeUsuario(m.usuarioId)}'
                  'Propriedade: ${_nomePropriedade(m.propriedadeId)}'
                  'Máquina: ${_nomeVeiculo(m.veiculoId)}'
                  'Patinagem: ${m.patinagem.toStringAsFixed(2)}%'
                  'Excluído em: ${_formatarData(m.dataExclusao)}',
              trailing: _acaoes(
                label: 'esta patinagem',
                onRestaurar: () => _restaurarPatinagem(m.id),
                onExcluir: () => _excluirPatinagemPermanentemente(m.id),
              ),
            );
          },
        );
      },
    );
  }

  Widget _secaoCompactacoes() {
    return FutureBuilder<List<CompactacaoModel>>(
      key: ValueKey('compactacoes-$_refreshKey'),
      future: _compactacaoService.listarExcluidas(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return _listaVazia('Erro ao carregar compactações excluídas.');
        }
        final lista = snapshot.data ?? [];
        if (lista.isEmpty) return _listaVazia('Nenhuma compactação na lixeira.');
        return ListView.builder(
          itemCount: lista.length,
          itemBuilder: (_, index) {
            final c = lista[index];
            final indice = c.indiceCompactacao == null
                ? 'Não calculado'
                : c.indiceCompactacao!.toStringAsFixed(2);
            return _cardBase(
              icon: Icons.straighten,
              titulo: c.nome,
              subtitulo:
                  'Usuário: ${_nomeUsuario(c.usuarioId)}'
                  'Propriedade: ${_nomePropriedade(c.propriedadeId)}'
                  'Máquina: ${_nomeVeiculo(c.veiculoId)}'
                  'Índice: $indice'
                  'Excluído em: ${_formatarData(c.dataExclusao)}',
              trailing: _acaoes(
                label: 'esta compactação',
                onRestaurar: () => _restaurarCompactacao(c.id),
                onExcluir: () => _excluirCompactacaoPermanentemente(c.id),
              ),
            );
          },
        );
      },
    );
  }

  Widget _secaoMaquinas() {
    return FutureBuilder<List<VeiculoModel>>(
      key: ValueKey('maquinas-$_refreshKey'),
      future: _veiculoService.listarExcluidos(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return _listaVazia('Erro ao carregar máquinas excluídas.');
        }
        final lista = snapshot.data ?? [];
        if (lista.isEmpty) return _listaVazia('Nenhuma máquina na lixeira.');
        return ListView.builder(
          itemCount: lista.length,
          itemBuilder: (_, index) {
            final v = lista[index];
            return _cardBase(
              icon: Icons.agriculture,
              titulo: v.nome,
              subtitulo:
                  'Usuário: ${_nomeUsuario(v.usuarioId)}'
                  'Tipo: ${v.tipo}'
                  'Excluído em: ${_formatarData(v.dataExclusao)}',
              trailing: _acaoes(
                label: 'esta máquina',
                onRestaurar: () => _restaurarVeiculo(v.id),
                onExcluir: () => _excluirVeiculoPermanentemente(v.id),
              ),
            );
          },
        );
      },
    );
  }

  Widget _secaoPropriedades() {
    return FutureBuilder<List<PropriedadeModel>>(
      key: ValueKey('propriedades-$_refreshKey'),
      future: _propriedadeService.listarExcluidas(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return _listaVazia('Erro ao carregar propriedades excluídas.');
        }
        final lista = snapshot.data ?? [];
        if (lista.isEmpty) return _listaVazia('Nenhuma propriedade na lixeira.');
        return ListView.builder(
          itemCount: lista.length,
          itemBuilder: (_, index) {
            final p = lista[index];
            return _cardBase(
              icon: Icons.location_on,
              titulo: p.nome,
              subtitulo:
                  'Usuário: ${_nomeUsuario(p.usuarioId)}'
                  'Dono: ${p.dono}'
                  'Excluído em: ${_formatarData(p.dataExclusao)}',
              trailing: _acaoes(
                label: 'esta propriedade',
                onRestaurar: () => _restaurarPropriedade(p.id),
                onExcluir: () => _excluirPropriedadePermanentemente(p.id),
              ),
            );
          },
        );
      },
    );
  }

  Widget _secaoAtualWidget() {
    switch (_secaoAtual) {
      case SecaoLixeira.usuarios:
        return _secaoUsuarios();
      case SecaoLixeira.patinagens:
        return _secaoPatinagens();
      case SecaoLixeira.compactacoes:
        return _secaoCompactacoes();
      case SecaoLixeira.maquinas:
        return _secaoMaquinas();
      case SecaoLixeira.propriedades:
        return _secaoPropriedades();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fundo,
      appBar: AppBar(
        title: const Text('Lixeira do administrador'),
        backgroundColor: AppColors.azul,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Itens excluídos',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _chip(SecaoLixeira.usuarios, 'Usuários'),
                _chip(SecaoLixeira.patinagens, 'Patinagens'),
                _chip(SecaoLixeira.compactacoes, 'Compactações'),
                _chip(SecaoLixeira.maquinas, 'Máquinas'),
                _chip(SecaoLixeira.propriedades, 'Propriedades'),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(child: _secaoAtualWidget()),
          ],
        ),
      ),
    );
  }
}
