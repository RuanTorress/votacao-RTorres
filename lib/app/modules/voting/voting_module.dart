import 'package:flutter_modular/flutter_modular.dart';
import 'package:votacao_uniodonto/app/modules/voting/pages/voting_confirmation_page.dart';
import 'package:votacao_uniodonto/app/modules/voting/pages/voting_page.dart';
import 'package:votacao_uniodonto/app/modules/voting/pages/voting_summary_page.dart';
import 'package:votacao_uniodonto/app/modules/voting/voting_store.dart';

class VotingModule extends Module {
  @override
  void binds(i) {
    i.addSingleton(VotingStore.new);
  }

  @override
  void routes(RouteManager r) {
    r.child('/', child: (_) => const VotingPage());
    r.child('/resumo', child: (_) => VotingSummaryPage());
    r.child('/confirmacao', child: (context) {
  final data = Modular.args.data;
  final votos = data is Map<int, List<String>> ? data : <int, List<String>>{};
  return VotingConfirmationPage(votos: votos);
});
  }
}