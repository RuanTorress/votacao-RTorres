import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:votacao_uniodonto/app/global_store.dart';
import 'package:votacao_uniodonto/app/modules/auth/auth_store.dart';

class OtpPage extends StatefulWidget {
  const OtpPage({super.key});

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  final AuthStore store = Modular.get<AuthStore>();
  final GlobalStore globalStore = Modular.get<GlobalStore>();
  final TextEditingController _codeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 142, 22, 158),
              Color(0xFF9F2E75),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              width: size.width > 400 ? 400 : size.width * 0.9,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    'Verificação por SMS',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF9F2E75),
                    ),
                  ).animate().fadeIn().slideY(begin: 0.2),
                  const SizedBox(height: 16),
                  Text(
                    'Enviamos um código para o número:\n${globalStore.cooperado?.celular ?? 'SEM TELEFONE CADASTRADO'}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ).animate().fadeIn().slideY(begin: 0.3),
                  const SizedBox(height: 12),
                  const Text(
                    '⚠️ Se você não tem acesso ao telefone informado, por favor entre em contato com o suporte RTorres.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.redAccent,
                    ),
                  ).animate().fadeIn().slideY(begin: 0.3),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _codeController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    maxLength: 6,
                    decoration: InputDecoration(
                      hintText: 'Digite o código (ex: 123456)',
                      counterText: '',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ).animate().fadeIn().slideY(begin: 0.4),
                  const SizedBox(height: 20),
                  store.isVerifying
                      ? const CircularProgressIndicator()
                      : SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () async {
                              final success =
                                  await store.verifyCode(_codeController.text);
                              if (success) {
                                Modular.to.navigate('/votacao');
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(store.verificationError ??
                                        'Erro ao verificar código'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF9F2E75),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Verificar',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                ],
              ),
            ).animate().fadeIn().scale(),
          ),
        ),
      ),
    );
  }
}
