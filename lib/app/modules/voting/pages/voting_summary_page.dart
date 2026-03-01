import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:votacao_uniodonto/app/modules/voting/voting_service.dart';
import 'package:votacao_uniodonto/app/global_store.dart';

class VotingSummaryPage extends StatefulWidget {
  const VotingSummaryPage({super.key});

  @override
  State<VotingSummaryPage> createState() => _VotingSummaryPageState();
}

class _VotingSummaryPageState extends State<VotingSummaryPage> {
  final _service = VotingService();
  int? _cooperadoId;
  List<Map<String, dynamic>> votos = [];
  bool loading = true;
  String? error;

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
      _cooperadoId = cooperado.id;
      _loadVotos();
    }
  }

  Future<void> _loadVotos() async {
    final result = await _service.getVotosPorCooperado(_cooperadoId!);
    if (result.success && result.data != null) {
      setState(() {
        votos = result.data!;
        loading = false;
      });
    } else {
      setState(() {
        error = result.message ?? 'Erro ao carregar votos';
        loading = false;
      });
    }
  }

  Color _corDoVoto(String voto) {
    switch (voto.toLowerCase()) {
      case 'aprovo':
        return Colors.green;
      case 'reprovo':
        return Colors.red;
      case 'abstenho':
        return Colors.grey;
      default:
        return Colors.blueGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
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
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: Text(error!))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: votos.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = votos[index];
                    final resposta = item['votos']['resposta'];
                    final votosList = resposta is List ? resposta : [resposta];
                    final votosStr = votosList.join(', ');
                    final titulo = item['pauta_titulo'] ?? 'Pauta';
                    final pautaId = item['pauta_id'];

                    final dataHora = item['data_hora'] != null
                        ? DateFormat('dd/MM/yyyy HH:mm')
                            .format(DateTime.parse(item['data_hora']))
                        : '-';

                    return Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Pauta #$pautaId',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF9F2E75),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              titulo,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2B2B2B),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Data do voto: $dataHora',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF888888),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              children: votosList.map<Widget>((voto) {
                                final cor = _corDoVoto(voto);
                                return Chip(
                                  label: Text(
                                    voto,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  backgroundColor: cor,
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05);
                  },
                ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '✅ Esta votação foi assinada digitalmente e está autenticada com segurança.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Colors.black54,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => Modular.to.navigate('/'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9F2E75),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Voltar ao Início',
                  style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
