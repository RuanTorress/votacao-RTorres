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
  late final ReactionDisposer _votedDisposer;

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
    store.loadPautas()
      .then((_) => store.loadVotosEnviados())
      .then((_) {
        // Agora sim, depois de tudo carregado...
        if (store.todosVotosSelecionados || store.votosEnviados.isNotEmpty) {
          final votosConfirmados = Map<int, List<String>>.from(store.votosEnviados);
          Modular.to.pushReplacementNamed(
            '/votacao/confirmacao',
            arguments: votosConfirmados,
          );
        }
      })
      .catchError((e) {
        // opcional: lide com erros de rede/carregamento aqui
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
          if (store.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (store.error != null) {
            return Center(child: Text(store.error!));
          }

          final pautas = store.pautas;

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
                            builder: (ctx) => AlertDialog(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              titlePadding:
                                  const EdgeInsets.fromLTRB(24, 24, 24, 12),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 16),
                              actionsPadding:
                                  const EdgeInsets.only(bottom: 16, right: 16),
                              title: Row(
                                children: const [
                                  Icon(Icons.verified_user_rounded,
                                      color: Color(0xFF9F2E75)),
                                  SizedBox(width: 12),
                                  Text(
                                    'Autorização Final de Voto',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Text(
                                    'Ao prosseguir, você autoriza a assinatura digital do seu conjunto de votos para esta Assembleia Geral Ordinária.',
                                    textAlign: TextAlign.justify,
                                    style: TextStyle(fontSize: 15),
                                  ),
                                  SizedBox(height: 12),
                                  Text(
                                    'Essa assinatura criptográfica é única e vinculada à sua identidade como cooperado(a), garantindo integridade, autenticidade e validade jurídica do registro.',
                                    textAlign: TextAlign.justify,
                                    style: TextStyle(
                                        fontSize: 13, color: Colors.black54),
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'Após confirmada, esta ação não poderá ser desfeita.',
                                    style: TextStyle(
                                        color: Colors.redAccent,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(ctx).pop(false),
                                  child: const Text('Cancelar'),
                                ),
                                ElevatedButton.icon(
                                  onPressed: () => Navigator.of(ctx).pop(true),
                                  icon: const Icon(Icons.lock_outline),
                                  label: const Text('Assinar e Confirmar'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF9F2E75),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 12),
                                    textStyle: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
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
                          final id = store.pautas
                              .firstWhere(
                                (p) =>
                                    !store.votosSelecionados.containsKey(p.id),
                                orElse: () => store.pautas.first,
                              )
                              .id;

                          final index =
                              store.pautas.indexWhere((p) => p.id == id);

                          _scrollController.animateTo(
                            index * 300.0,
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
                      borderRadius: BorderRadius.circular(30),
                    ),
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
                offset: const Offset(0, 4),
              )
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.how_to_vote, color: Color(0xFF9F2E75)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      pauta.titulo,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF2B2B2B),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                pauta.descricao,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF666666),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 12),
              if (pauta.respostaMultipla == true)
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
                children: [
                  _voteButton('Aprovo', const Color(0xFF4CAF50), pauta.id,
                      pauta.respostaMultipla ?? false, jaVotou, selecionados),
                  _voteButton('Reprovo', const Color(0xFFF44336), pauta.id,
                      pauta.respostaMultipla ?? false, jaVotou, selecionados),
                  _voteButton('Abstenho', const Color(0xFF9E9E9E), pauta.id,
                      pauta.respostaMultipla ?? false, jaVotou, selecionados),
                ],
              ),
              if (jaVotou)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    '✔ Você já votou nesta pauta.',
                    style: TextStyle(
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
            ],
          ),
        ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05);
      },
    );
  }

  Widget _voteButton(
    String label,
    Color color,
    int pautaId,
    bool multiplaEscolha,
    bool jaVotou,
    List<String> selecionados,
  ) {
    final isSelecionado = selecionados.contains(label);

    return OutlinedButton(
      onPressed: jaVotou
          ? null
          : () => store.selecionarVoto(pautaId, label,
              multiplaEscolha: multiplaEscolha),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: isSelecionado ? color : color.withOpacity(0.5)),
        backgroundColor:
            isSelecionado ? color.withOpacity(0.9) : Colors.transparent,
        foregroundColor: isSelecionado ? Colors.white : color,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
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
                Image.asset(
                  'assets/images/logo_complete.png',
                  height: 40,
                ),
                const SizedBox(width: 16),
                const Text(
                  'Votação Uniodonto',
                  style: TextStyle(
                    color: Color(0xFF9F2E75),
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                  ),
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
              child: AnimatedOpacity(
                opacity: 1.0,
                duration: const Duration(milliseconds: 700),
                child: Container(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
