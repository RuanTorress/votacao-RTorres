import 'dart:convert';

import 'package:flutter/material.dart';
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
  int? interactionId;

  @observable
  bool isLoading = false;

  @observable
  String? error;

  @observable
  ObservableList<VotoModel> votosPendentes = ObservableList<VotoModel>();

  @observable
  ObservableMap<int, List<String>> votosSelecionados =
      ObservableMap<int, List<String>>();

  @observable
  ObservableMap<int, List<String>> votosEnviados =
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

  /// 1) chama a API de “open” e armazena o id retornado
  @action
  Future<void> registrarInteracaoOpen() async {
    try {
      final cooperadoId = globalStore.cooperado!.id;
      final ip = await _service.getIp();
      final geo = await _service.getGeolocation();
      final resp = await _service.openInteraction(
        cooperadoId: cooperadoId,
        ip: ip,
        latitude: geo['latitude'],
        longitude: geo['longitude'],
      );
      if (resp.success && resp.data != null) {
        interactionId = resp.data;
      }
    } catch (e) {
      debugPrint('Erro ao abrir interação: $e');
    }
  }

  /// 2) chama a API de “complete” usando o id que salvamos antes
  @action
  Future<void> registrarInteracaoComplete() async {
    if (interactionId == null) return;
    final resp = await _service.completeInteraction(interactionId!);
    if (!resp.success) {
      debugPrint('Falha ao concluir interação: ${resp.message}');
    }
  }

  @action
  Future<void> loadPautas() async {
    isLoading = true;
    error = null;
    try {
      final resultado = await _service.getPautas();
      if (resultado.success && resultado.data != null) {
        pautas
          ..clear()
          ..addAll(resultado.data!);
        // assim que carregar as pautas, registramos a “open”
        await registrarInteracaoOpen();
      } else {
        error = resultado.message;
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

        final result = await _service.registrarVotoAssinado(voto.toJson());
        await registrarInteracaoComplete();

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

  @action
Future<void> loadVotosEnviados() async {
  final id = globalStore.cooperado!.id;
  final result = await _service.getVotosPorCooperado(id);

  if (result.success && result.data != null) {
    for (final item in result.data!) {
      final pautaId = item['pauta_id'];
      final resposta = item['votos']['resposta'];

      if (resposta is List) {
        votosEnviados[pautaId] = List<String>.from(resposta);
      } else {
        votosEnviados[pautaId] = [resposta.toString()];
      }
    }
  } else {
    print('❌ Erro ao carregar votos enviados: ${result.message}');
  }
}

@action
Future<void> limparVotosSelecionados()async{
  votosSelecionados.clear();
  votosPendentes.clear();
  votosEnviados.clear();
  globalStore.cooperado = null;
  
}

bool get votouEmTodasAsPautas {
  final totalPautas = pautas.length;
  final votadas = votosSelecionados.keys.length + votosEnviados.keys.length;
  return votadas >= totalPautas;
}

int? get primeiraPautaNaoVotadaId {
  for (final pauta in pautas) {
    if (!votosSelecionados.containsKey(pauta.id) &&
        !votosEnviados.containsKey(pauta.id)) {
      return pauta.id;
    }
  }
  return null;
}

bool get todosVotosSelecionados {
  return votosSelecionados.length == pautas.length;
}

}
