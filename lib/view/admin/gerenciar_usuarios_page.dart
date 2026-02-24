import 'dart:async';
import 'package:flutter/material.dart';
import '../../models/usuario_model.dart';
import '../../service/usuario_service.dart';
import '../../theme/app_colors.dart';
import '../../components/usuario_tile.dart';

enum OrdenacaoUsuarios { nomeAZ, nomeZA, emailAZ, emailZA, tipoAZ, tipoZA }

class GerenciarUsuariosPage extends StatefulWidget {
  const GerenciarUsuariosPage({super.key});

  @override
  State<GerenciarUsuariosPage> createState() => _GerenciarUsuariosPageState();
}

class _GerenciarUsuariosPageState extends State<GerenciarUsuariosPage> {
  final UsuarioService usuarioService = UsuarioService();

  final TextEditingController _pesquisaCtrl = TextEditingController();

  String _termoAplicado = '';

  String _filtroTipo = 'todos'; 

  OrdenacaoUsuarios _ordenacao = OrdenacaoUsuarios.nomeAZ;

  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _pesquisaCtrl.dispose();
    super.dispose();
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

  void _onChangePesquisa(String v) {
    _debounce?.cancel();

    // espera a pessoa parar de digitar
    _debounce = Timer(const Duration(milliseconds: 650), () {
      if (!mounted) return;
      setState(() {
        _termoAplicado = v;
      });
    });
  }

  int _cmp(String a, String b) => a.toLowerCase().compareTo(b.toLowerCase());

  List<UsuarioModel> _filtrarEOrdenar(List<UsuarioModel> usuarios) {
    final termo = _normalize(_termoAplicado);

    final filtradosTipo = _filtroTipo == 'todos'
        ? [...usuarios]
        : usuarios.where((u) => u.tipoUsuario == _filtroTipo).toList();

    // Filtra por nome ou email 
    final filtrados = termo.isEmpty
        ? [...filtradosTipo]
        : filtradosTipo.where((u) {
            final nome = _normalize(u.nome);
            final email = _normalize(u.email);
            return nome.contains(termo) || email.contains(termo);
          }).toList();

    filtrados.sort((a, b) {
      switch (_ordenacao) {
        case OrdenacaoUsuarios.nomeAZ:
          return _cmp(a.nome, b.nome);
        case OrdenacaoUsuarios.nomeZA:
          return _cmp(b.nome, a.nome);
        case OrdenacaoUsuarios.emailAZ:
          return _cmp(a.email, b.email);
        case OrdenacaoUsuarios.emailZA:
          return _cmp(b.email, a.email);
        case OrdenacaoUsuarios.tipoAZ:
          return _cmp(a.tipoUsuario, b.tipoUsuario);
        case OrdenacaoUsuarios.tipoZA:
          return _cmp(b.tipoUsuario, a.tipoUsuario);
      }
    });

    return filtrados;
  }

  String _labelOrdenacao(OrdenacaoUsuarios o) {
    switch (o) {
      case OrdenacaoUsuarios.nomeAZ:
        return 'Nome (A → Z)';
      case OrdenacaoUsuarios.nomeZA:
        return 'Nome (Z → A)';
      case OrdenacaoUsuarios.emailAZ:
        return 'Email (A → Z)';
      case OrdenacaoUsuarios.emailZA:
        return 'Email (Z → A)';
      case OrdenacaoUsuarios.tipoAZ:
        return 'Tipo (A → Z)';
      case OrdenacaoUsuarios.tipoZA:
        return 'Tipo (Z → A)';
    }
  }

  Future<void> _abrirOrdenacao() async {
    final selecionado = await showModalBottomSheet<OrdenacaoUsuarios>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: [
              const ListTile(
                title: Text('Ordenar usuários'),
                subtitle: Text('Escolha uma opção'),
              ),
              ...OrdenacaoUsuarios.values.map((o) {
                final isSel = o == _ordenacao;
                return ListTile(
                  leading: Icon(
                    isSel ? Icons.check_circle : Icons.circle_outlined,
                  ),
                  title: Text(_labelOrdenacao(o)),
                  onTap: () => Navigator.pop(context, o),
                );
              }),
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

  Future<void> _abrirFiltroTipo() async {
    final selecionado = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (_) {
        Widget item(String value, String label) {
          final isSel = value == _filtroTipo;
          return ListTile(
            leading: Icon(isSel ? Icons.check_circle : Icons.circle_outlined),
            title: Text(label),
            onTap: () => Navigator.pop(context, value),
          );
        }

        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const ListTile(title: Text('Filtrar por tipo')),
              item('todos', 'Todos'),
              item('usuario', 'Somente usuários'),
              item('admin', 'Somente administradores'),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );

    if (selecionado != null && mounted) {
      setState(() => _filtroTipo = selecionado);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fundo,
      appBar: AppBar(
        title: const Text('Gerenciar Usuários'),
        backgroundColor: AppColors.azul,
        actions: [
          IconButton(
            tooltip: 'Filtrar',
            icon: const Icon(Icons.filter_list),
            onPressed: _abrirFiltroTipo,
          ),
          IconButton(
            tooltip: 'Ordenar',
            icon: const Icon(Icons.sort),
            onPressed: _abrirOrdenacao,
          ),
        ],
      ),
      body: StreamBuilder<List<UsuarioModel>>(
        stream: usuarioService.streamUsuarios(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Erro ao carregar usuários'));
          }

          final usuarios = snapshot.data ?? [];
          final lista = _filtrarEOrdenar(usuarios);

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: TextField(
                  controller: _pesquisaCtrl,
                  decoration: InputDecoration(
                    labelText: 'Pesquisar por nome ou email',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _pesquisaCtrl.text.isEmpty
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _pesquisaCtrl.clear();
                              _debounce?.cancel();
                              setState(() => _termoAplicado = '');
                            },
                          ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: _onChangePesquisa,
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                child: Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  runSpacing: 4,
                  children: [
                    Text(
                      'Mostrando ${lista.length} de ${usuarios.length} usuários',
                      style: const TextStyle(fontSize: 12),
                    ),
                    Text(
                      'Tipo: ${_filtroTipo == 'todos' ? 'Todos' : _filtroTipo} | ${_labelOrdenacao(_ordenacao)}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              Expanded(
                child: lista.isEmpty
                    ? const Center(child: Text('Nenhum usuário encontrado'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: lista.length,
                        itemBuilder: (context, index) {
                          final usuario = lista[index];
                          return UsuarioTile(usuario: usuario);
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
