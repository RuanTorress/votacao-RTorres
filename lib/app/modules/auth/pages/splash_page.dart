import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:votacao_uniodonto/app/modules/auth/auth_store.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {

  AuthStore store = AuthStore();
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _showText = false;
  bool isLoading = false;
  late String param;


  @override
  void initState() {
    super.initState();     
    
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _scaleAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _controller.forward();

    Future.delayed(const Duration(milliseconds: 1400), () {
      setState(() {
        _showText = true;
      });
    });

    Future.delayed(const Duration(seconds: 5), () {
      Modular.to.navigate('/login');
    });
  }  

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ScaleTransition(
                scale: _scaleAnimation,
                child: Image.asset(
                  'assets/images/logo_white.png',
                  width: 180,
                ),
              ),
              const SizedBox(height: 20),
              AnimatedOpacity(
                duration: const Duration(milliseconds: 800),
                opacity: _showText ? 1 : 0,
                child: const Text(
                  'Bem-vindo à Votação Uniodonto',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
