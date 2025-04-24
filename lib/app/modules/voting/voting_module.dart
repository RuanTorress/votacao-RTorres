import 'package:flutter_modular/flutter_modular.dart';
import 'package:votacao_uniodonto/app/modules/voting/pages/voting_page.dart';

class VotingModule extends Module {
  @override
  void binds(i) {
  }

  @override
void routes(RouteManager r) {
  r.child('/', child: (context) => const VotingPage()); 
}
}