import 'package:flutter_modular/flutter_modular.dart';
import 'package:votacao_uniodonto/app/modules/auth/auth_store.dart';
import 'package:votacao_uniodonto/app/modules/auth/pages/otp_page.dart';
import 'pages/splash_page.dart';
import 'pages/login_page.dart';

class AuthModule extends Module {
  @override
  void binds(i) {
    i.addSingleton(AuthStore.new);
  }

  @override
void routes(RouteManager r) {
  r.child('/', child: (context) => const SplashPage()); // rota padrão
  r.child('/login', child: (context) => const LoginPage());
  r.child('/otp', child: (context) => const OtpPage());
}
}