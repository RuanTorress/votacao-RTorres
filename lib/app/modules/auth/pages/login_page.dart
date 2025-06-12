import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:votacao_uniodonto/app/global_store.dart';
import 'package:votacao_uniodonto/app/modules/auth/auth_store.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final AuthStore store = Modular.get<AuthStore>();
  final GlobalStore globalStore = Modular.get<GlobalStore>();

  final TextEditingController _croController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

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
              Color.fromARGB(255, 142, 22, 158), // Roxo
              Color(0xFF9F2E75), // Magenta
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo
                Image.asset(
                  'assets/images/logo_white.png',
                  height: 100,
                ).animate().fadeIn(duration: 800.ms).slideY(begin: -0.3),

                const SizedBox(height: 40),

                // Card
                Container(
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
                        'Entrar com seu CRO e senha',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF9F2E75),
                        ),
                      ).animate().fadeIn(duration: 800.ms).slideY(begin: 0.3),

                      const SizedBox(height: 20),

                      // CRO
                      TextField(
                        controller: _croController,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          hintText: 'Digite seu CRO (ex: 12345)',
                          prefixIcon: const Icon(Icons.badge),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.3),

                      const SizedBox(height: 16),

                      // Senha
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          hintText: 'Digite sua senha',
                          prefixIcon: const Icon(Icons.lock),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ).animate().fadeIn(delay: 200.ms).slideX(begin: 0.3),

                      const SizedBox(height: 24),

                      // Botão Entrar
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            final cro = _croController.text.trim();
                            final pwd = _passwordController.text;
                            bool ok = await store.handleCoopLogin(cro, pwd);
                            if (ok) {
                              await store.fetchCooperado(cro);
                              Modular.to.navigate('/votacao');
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      store.error ?? 'Falha na autenticação'),
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
                            'Entrar',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.3),
                      ),

                      const SizedBox(height: 12),

                      // Esqueci minha senha
                      TextButton(
                        onPressed: () async {
                          final cro = _croController.text.trim();
                          if (cro.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Por favor, preencha seu CRO.'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }
                          // Tenta buscar o cooperado pelo CRO
                          bool exists = await store.fetchCooperado(cro);
                          if (exists) {
                            Modular.to.navigate('/otp');
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content:
                                    Text('CRO não encontrado'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                        child: const Text(
                          'Esqueci minha senha / não tenho acesso',
                          style: TextStyle(
                            color: Color(0xFF9F2E75),
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ).animate().fadeIn(delay: 600.ms),
                    ],
                  ),
                ).animate().fadeIn(duration: 1000.ms).scale(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
