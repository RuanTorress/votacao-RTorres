import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:intl/intl.dart';
import 'package:votacao_uniodonto/app/global_store.dart';
import 'package:votacao_uniodonto/app/shared/crypto_service.dart';

class VotingConfirmationPage extends StatefulWidget {
  final Map<int, List<String>> votos;

  const VotingConfirmationPage({super.key, required this.votos});

  @override
  State<VotingConfirmationPage> createState() => _VotingConfirmationPageState();
}

class _VotingConfirmationPageState extends State<VotingConfirmationPage> {
  @override
  void initState() {
    super.initState();

    if (widget.votos.isEmpty) {
      Future.delayed(Duration.zero, () {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content:
                  Text('Nenhum voto encontrado. Redirecionando para o início.'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 2),
            ),
          );
          Modular.to.navigate('/');
        }
      });
    }
  }

  String gerarHashVerificacao(Map<String, dynamic> voto) {
    final json = jsonEncode(voto);
    final digest = sha256.convert(utf8.encode(json));
    return digest.toString();
  }

  Future<String> getChavePublica() async {
    return await CryptoService().getPublicKeyBase64() ?? 'Indisponível';
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
      ),
      body: FutureBuilder<String>(
        future: getChavePublica(),
        builder: (context, snapshot) {
          final chavePublica = snapshot.data ?? 'Carregando...';
          return Padding(
            padding: const EdgeInsets.all(16),
            child: ListView(
              children: [
                const Text(
                  'Resumo da Votação',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ...widget.votos.entries.map((entry) {
                  final pautaId = entry.key;
                  final respostas = entry.value;

                  final voto = {
                    'pauta_id': pautaId,
                    'votos': {
                      'resposta':
                          respostas.length == 1 ? respostas.first : respostas,
                    },
                    'data_hora': DateTime.now().toIso8601String(),
                  };

                  final hash = gerarHashVerificacao(voto);

                  return Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('📋 Pauta ID: $pautaId',
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text('🗳️ Voto: ${respostas.join(", ")}',
                              style: const TextStyle(fontSize: 16)),
                          const SizedBox(height: 8),
                          Text(
                            '🕒 Data/Hora: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(voto['data_hora'] as String))}',
                            style: const TextStyle(
                                fontSize: 15, color: Colors.black54),
                          ),
                          const SizedBox(height: 12),
                          const Text('🔏 Código de Verificação:',
                              style: TextStyle(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          SelectableText(hash,
                              style: const TextStyle(
                                  fontFamily: 'monospace', fontSize: 13)),
                        ],
                      ),
                    ),
                  );
                }).toList(),
                const SizedBox(height: 12),
                const Text('🔐 Chave Pública do Cooperado:',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                SelectableText(
                  chavePublica,
                  style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 13,
                      color: Colors.black87),
                ),
                const SizedBox(height: 24),
                const Text(
                  '✅ Esta votação foi assinada digitalmente com uma chave criptográfica exclusiva do cooperado, garantindo integridade, autenticidade e transparência no processo.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: () => Modular.to.navigate('/'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF9F2E75),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text('Voltar ao início', style: TextStyle(fontSize: 16)),
        ),
      ),
    );
  }
}
