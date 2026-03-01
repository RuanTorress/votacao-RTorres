import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobx/mobx.dart';
import 'package:votacao_uniodonto/app/modules/voting/models/pauta_model.dart';
import 'package:votacao_uniodonto/app/modules/voting/voting_store.dart';
import 'package:votacao_uniodonto/app/global_store.dart';

class VotingPage extends StatefulWidget {
  const VotingPage({super.key});

  @override
  State<VotingPage> createState() => _VotingPageState();
}

class _VotingPageState extends State<VotingPage> {
  final store = Modular.get<VotingStore>();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    final cooperado = Modular.get<GlobalStore>().cooperado;
    if (cooperado == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cooperado não encontrado. Faça login novamente.'),
            backgroundColor: Colors.red,
          ),
        );
        Modular.to.navigate('/');
      });
    } else {
      // Carrega pautas e votos, e só depois faz o teste de redirecionamento
      store.votosEnviados.clear();
      store.loadPautas().then((_) => store.loadVotosEnviados()).then((_) {
        // Depois de carregado, se já votou em todas ou tem votos enviados
        if (store.todosVotosSelecionados || store.votosEnviados.isNotEmpty) {
          final votosConfirmados =
              Map<int, List<String>>.from(store.votosEnviados);
          Modular.to.pushReplacementNamed(
            '/votacao/confirmacao',
            arguments: votosConfirmados,
          );
        }
      }).catchError((e) {
        print('Erro ao carregar dados iniciais: $e');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildCustomAppBar(),
      body: Observer(
        builder: (_) {
          if (store.isLoading)
            return const Center(child: CircularProgressIndicator());
          if (store.error != null) return Center(child: Text(store.error!));

          // 1) Ordena aqui
          final pautas = List<PautaModel>.from(store.pautas)
            ..sort((a, b) => a.numeroPauta.compareTo(b.numeroPauta));

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: pautas.length,
                  itemBuilder: (_, index) {
                    final pauta = pautas[index];
                    return _buildPautaCard(pauta);
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton.icon(
                  onPressed: store.todosVotosSelecionados
                      ? () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => _buildConfirmationDialog(ctx),
                          );
                          if (confirm == true) {
                            try {
                              final votosConfirmados =
                                  Map<int, List<String>>.from(
                                      store.votosSelecionados);
                              await store.confirmarTodosVotos();
                              store.votosSelecionados.clear();
                              await store.loadVotosEnviados();
                              Modular.to.pushNamed(
                                '/votacao/confirmacao',
                                arguments: votosConfirmados,
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content:
                                      Text('❌ Erros ao registrar votos:\n$e'),
                                  backgroundColor: Colors.red,
                                  duration: const Duration(seconds: 6),
                                ),
                              );
                            }
                          }
                        }
                      : () {
                          final id = pautas
                              .firstWhere(
                                (p) =>
                                    !store.votosSelecionados.containsKey(p.id),
                                orElse: () => pautas.first,
                              )
                              .id;
                          final idx = pautas.indexWhere((p) => p.id == id);
                          _scrollController.animateTo(
                            idx * 300.0,
                            duration: const Duration(milliseconds: 600),
                            curve: Curves.easeInOut,
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  '⚠️ Você precisa votar em todas as pautas.'),
                              backgroundColor: Colors.orange,
                            ),
                          );
                        },
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Confirmar Todos os Votos'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF9F2E75),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey.shade300,
                    disabledForegroundColor: Colors.grey.shade600,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                    elevation: 3,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  AlertDialog _buildConfirmationDialog(BuildContext ctx) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      actionsPadding: const EdgeInsets.only(bottom: 16, right: 16),
      title: Row(
        children: [
          Icon(Icons.verified_user_rounded,
              color: const Color(0xFF9F2E75), size: 32),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              'Autorização Final de Voto',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF9F2E75),
              ),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Ao prosseguir, você autoriza a assinatura digital do seu conjunto de votos para esta Assembleia Geral Ordinária.',
            textAlign: TextAlign.justify,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 16),
          Text(
            'Essa assinatura criptográfica é única e vinculada à sua identidade como cooperado(a), garantindo integridade, autenticidade e validade jurídica do registro.',
            textAlign: TextAlign.justify,
            style: TextStyle(fontSize: 16, color: Colors.black87),
          ),
          SizedBox(height: 20),
          Text(
            'Após confirmada, esta ação NÃO poderá ser desfeita.',
            style: TextStyle(
                fontSize: 18,
                color: Colors.redAccent,
                fontWeight: FontWeight.bold),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: const Text('Cancelar', style: TextStyle(fontSize: 16)),
        ),
        ElevatedButton.icon(
          onPressed: () => Navigator.of(ctx).pop(true),
          icon: const Icon(Icons.lock_outline, size: 20),
          label: const Text('Assinar e Confirmar',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF9F2E75),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }

  Widget _buildPautaCard(PautaModel pauta) {
    return Observer(
      builder: (_) {
        final pautaId = pauta.id;
        final jaVotou = store.votosEnviados.containsKey(pautaId);
        final selecionados = jaVotou
            ? store.votosEnviados[pautaId]!
            : store.votosSelecionados[pautaId] ?? [];

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF9F2E75).withOpacity(0.2)),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4))
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    '${pauta.numeroPauta}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF9F2E75),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      pauta.titulo,
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2B2B2B)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                pauta.descricao,
                style: const TextStyle(
                    fontSize: 14, color: Color(0xFF666666), height: 1.4),
              ),
              const SizedBox(height: 12),
              if (pauta.multiplaEscolha)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF9F2E75).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Múltipla escolha',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color: Color(0xFF9F2E75),
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: pauta.respostas.map((resposta) {
                  return _voteButton(
                    resposta,
                    pautaId,
                    pauta.multiplaEscolha,
                    jaVotou,
                    selecionados,
                  );
                }).toList(),
              ),
              if (jaVotou)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    '✔ Você já votou nesta pauta.',
                    style: TextStyle(
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.w600),
                  ),
                ),
            ],
          ),
        ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05);
      },
    );
  }

  Widget _voteButton(
    String label,
    int pautaId,
    bool multiplaEscolha,
    bool jaVotou,
    List<String> selecionados,
  ) {
    final isSelecionado = selecionados.contains(label);
    return OutlinedButton(
      onPressed: jaVotou
          ? null
          : () {
              // 3) Limite de 3 escolhas
              if (multiplaEscolha &&
                  !isSelecionado &&
                  selecionados.length >= 3) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Você só pode escolher até 3 opções.'),
                    backgroundColor: Colors.orange,
                  ),
                );
                return;
              }
              store.selecionarVoto(
                pautaId,
                label,
                multiplaEscolha: multiplaEscolha,
              );
            },
      style: OutlinedButton.styleFrom(
        side: BorderSide(
            color: isSelecionado
                ? const Color(0xFF9F2E75)
                : const Color(0xFF9F2E75).withOpacity(0.5)),
        backgroundColor: isSelecionado
            ? const Color(0xFF9F2E75).withOpacity(0.9)
            : Colors.transparent,
        foregroundColor: isSelecionado ? Colors.white : const Color(0xFF9F2E75),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
    );
  }

  PreferredSizeWidget _buildCustomAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(120),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF9F2E75),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Text(
                      'RT',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                const Text(
                  'Votação RTorres',
                  style: TextStyle(
                      color: Color(0xFF9F2E75),
                      fontSize: 26,
                      fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 16),
            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              width: double.infinity,
              height: 2,
              color: const Color(0xFF9F2E75),
              margin: const EdgeInsets.only(top: 8),
              curve: Curves.easeInOut,
            ),
          ],
        ),
      ),
    );
  }
}
