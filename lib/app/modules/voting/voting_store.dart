import 'package:mobx/mobx.dart';
import 'package:votacao_uniodonto/app/modules/voting/models/pauta_model.dart';
import 'package:votacao_uniodonto/app/modules/voting/voting_service.dart';

part 'voting_store.g.dart';

class VotingStore = _VotingStoreBase with _$VotingStore;

abstract class _VotingStoreBase with Store {
  final VotingService _service = VotingService();

  @observable
  ObservableList<PautaModel> pautas = ObservableList<PautaModel>();

  @observable
  bool isLoading = false;

  @observable
  String? error;

  // Lista de seleções de votos para cada pauta
  @observable
  ObservableMap<int, String?> selectedVotes = ObservableMap<int, String?>();

  @action
  Future<void> loadPautas() async {
    isLoading = true;
    error = null;

    try {
      final resultado = await _service.getPautas();

      print('✅ Resultado: ${resultado.data}');

      if (resultado.success && resultado.data != null) {
        pautas
          ..clear()
          ..addAll(resultado.data!); // ✅ funciona com ObservableList          
      } else {
        error = resultado.message ?? 'Erro desconhecido ao carregar pautas';
      }
    } catch (e) {
      error = 'Erro de conexão: $e';
    } finally {
      isLoading = false;
    }
  }

  // Ação para selecionar o voto
  @action
  void selectVote(int pautaId, String vote) {
    selectedVotes[pautaId] = vote;
  }

  // Verifica se o voto foi selecionado para habilitar o botão
  bool isVoteSelected(int pautaId) {
    return selectedVotes[pautaId] != null;
  }
}