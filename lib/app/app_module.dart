import 'package:flutter_modular/flutter_modular.dart';
import 'package:votacao_uniodonto/app/global_store.dart';
import 'package:votacao_uniodonto/app/modules/auth/auth_store.dart';
import 'package:votacao_uniodonto/app/modules/voting/voting_module.dart';
import 'package:votacao_uniodonto/app/modules/voting/voting_store.dart';
import 'modules/auth/auth_module.dart';

class AppModule extends Module {
  @override
  void binds(i) {
    i.addSingleton(GlobalStore.new);
    i.addSingleton(AuthStore.new);
    i.addSingleton(VotingStore.new);
  }

  @override
  void routes(RouteManager r) {
    r.module('/', module: AuthModule());
    r.module('/votacao', module: VotingModule());
  }  
}