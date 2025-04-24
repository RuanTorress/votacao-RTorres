import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:votacao_uniodonto/app/modules/voting/models/pauta_model.dart';
import 'package:votacao_uniodonto/app/modules/voting/voting_store.dart';

class VotingPage extends StatefulWidget {
  const VotingPage({super.key});

  @override
  State<VotingPage> createState() => _VotingPageState();
}

class _VotingPageState extends State<VotingPage> {
  final store = Modular.get<VotingStore>();

  @override
  void initState() {
    super.initState();
    store.loadPautas();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildCustomAppBar(),
      body: Observer(
  builder: (_) {
    final pautas = store.pautas; // ✅ acesso direto ao observable

    if (store.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (store.error != null) {
      return Center(child: Text(store.error!));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: pautas.length,
      itemBuilder: (_, index) {
        final pauta = pautas[index];
        return _buildPautaCard(pauta);},
    );
  },

      ),
    );
  }

  Widget _buildPautaCard(PautaModel pauta) {
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
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
            _voteButton('Aprovo', const Color(0xFF4CAF50)),
            _voteButton('Reprovo', const Color(0xFFF44336)),
            _voteButton('Abstenho', const Color(0xFF9E9E9E)),
          ],
        ),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton.icon(
            onPressed: () {
              // Confirmar voto
            },
            icon: const Icon(Icons.check_circle_outline),
            label: const Text('Confirmar Voto'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF9F2E75),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 3,
            ),
          ).animate().scale().fadeIn(delay: 200.ms),
        ),
      ],
    ),
  ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05);
}


  Widget _voteButton(String label, Color color) {
  return OutlinedButton(
    onPressed: () {
      // Guardar voto no store futuramente
    },
    style: OutlinedButton.styleFrom(
      side: BorderSide(color: color.withOpacity(0.6)),
      foregroundColor: color,
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
      color: Colors.white, // Sem gradiente, agora é fundo branco
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo à esquerda
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/logo_complete.png', // Substitua com o caminho correto da sua logo
                height: 40, // Ajuste o tamanho da logo conforme necessário
              ),
              const SizedBox(width: 16),
              Text(
                'Votação Uniodonto',
                style: const TextStyle(
                  color: Color(0xFF9F2E75), // Cor principal roxa
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Linha animada
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            width: double.infinity,
            height: 2,
            color: const Color(0xFF9F2E75), // Cor da linha
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