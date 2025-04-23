import 'package:flutter_modular/flutter_modular.dart';
import 'pages/splash_page.dart';
import 'pages/login_page.dart';

class AuthModule extends Module {
  @override
  void binds(i) {
  }

  @override
void routes(RouteManager r) {
  r.child('/', child: (context) => const SplashPage()); // rota padrão
  r.child('/login', child: (context) => const LoginPage());
}
}