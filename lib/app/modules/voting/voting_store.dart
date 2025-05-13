import 'dart:convert';

import 'package:flutter_modular/flutter_modular.dart';
import 'package:mobx/mobx.dart';
import 'package:votacao_uniodonto/app/global_store.dart';
import 'package:votacao_uniodonto/app/modules/auth/models/cooperado_models.dart';
import 'package:votacao_uniodonto/app/modules/auth/models/voto_model.dart';
import 'package:votacao_uniodonto/app/modules/voting/models/pauta_model.dart';
import 'package:votacao_uniodonto/app/modules/voting/voting_service.dart';

part 'voting_store.g.dart';

class VotingStore = _VotingStoreBase with _$VotingStore;

abstract class _VotingStoreBase with Store {
  final VotingService _service = VotingService();
  final GlobalStore globalStore = Modular.get<GlobalStore>();

  @observable
  ObservableList<PautaModel> pautas = ObservableList<PautaModel>();

  @observable
  bool isLoading = false;

  @observable
  String? error;

  @observable
  ObservableList<VotoModel> votosPendentes = ObservableList<VotoModel>();

  @observable
  ObservableMap<int, List<String>> votosSelecionados =
      ObservableMap<int, List<String>>();

  @action
  Future<void> confirmarVoto({
    required int pautaId,
    required List<String> votos,
  }) async {
    try {
      final ip = await _service.getIp();
      final location = await _service.getGeolocation();
      final now = DateTime.now();

      final voto = VotoModel(
        pautaId: pautaId,
        votos: votos,
        ip: ip,
        dataHora: now,
        geolocalizacao: location,
        cooperadoId: globalStore.cooperado!.id,
        cooperadoName: globalStore.cooperado!.nomeCompleto,
      );

      votosPendentes.add(voto);
      print('✅ Voto salvo localmente: ${voto.toJson()}');
    } catch (e) {
      print('Erro ao registrar voto local: $e');
    }
  }

  @action
  void selecionarVoto(int pautaId, String voto,
      {bool multiplaEscolha = false}) {
    final votos = votosSelecionados[pautaId] ?? [];

    if (multiplaEscolha) {
      if (votos.contains(voto)) {
        votos.remove(voto);
      } else if (votos.length < 2) {
        votos.add(voto);
      }
    } else {
      votosSelecionados[pautaId] = [voto];
      return;
    }

    votosSelecionados[pautaId] = [...votos];
  }

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

  @action
Future<void> confirmarTodosVotos() async {
  List<String> falhas = [];

  for (var entry in votosSelecionados.entries) {
    final pautaId = entry.key;
    final votos = entry.value;

    try {
      final ip = await _service.getIp();
      final location = await _service.getGeolocation();
      final now = DateTime.now();

      final voto = VotoModel(
        pautaId: pautaId,
        votos: votos,
        ip: ip,
        dataHora: now,
        geolocalizacao: location,
        cooperadoId: globalStore.cooperado!.id,
        cooperadoName: globalStore.cooperado!.nomeCompleto,
      );

      final result = await _service.registrarVoto(voto.toJson());

      if (!result.success) {
        falhas.add('Pauta $pautaId: ${result.message}');
      }

      print('📤 Voto JSON: ${jsonEncode(voto.toJson())}');
    } catch (e) {
      falhas.add('Pauta $pautaId: erro inesperado');
    }
  }

  votosSelecionados.clear();

  if (falhas.isNotEmpty) {
    throw Exception(falhas.join('\n'));
  }
}
}
