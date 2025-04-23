import 'package:flutter_modular/flutter_modular.dart';
import 'package:votacao_uniodonto/app/modules/auth/auth_store.dart';
import 'package:votacao_uniodonto/app/modules/auth/pages/splash_page.dart';
import 'modules/auth/auth_module.dart';

class AppModule extends Module {
  @override
  void binds(i) {
    i.addSingleton(AuthStore.new);
  }

  @override
  void routes(RouteManager r) {
    r.module('/', module: AuthModule());
  }  
}