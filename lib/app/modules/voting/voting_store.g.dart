// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'voting_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$VotingStore on _VotingStoreBase, Store {
  late final _$pautasAtom =
      Atom(name: '_VotingStoreBase.pautas', context: context);

  @override
  ObservableList<PautaModel> get pautas {
    _$pautasAtom.reportRead();
    return super.pautas;
  }

  @override
  set pautas(ObservableList<PautaModel> value) {
    _$pautasAtom.reportWrite(value, super.pautas, () {
      super.pautas = value;
    });
  }

  late final _$isLoadingAtom =
      Atom(name: '_VotingStoreBase.isLoading', context: context);

  @override
  bool get isLoading {
    _$isLoadingAtom.reportRead();
    return super.isLoading;
  }

  @override
  set isLoading(bool value) {
    _$isLoadingAtom.reportWrite(value, super.isLoading, () {
      super.isLoading = value;
    });
  }

  late final _$errorAtom =
      Atom(name: '_VotingStoreBase.error', context: context);

  @override
  String? get error {
    _$errorAtom.reportRead();
    return super.error;
  }

  @override
  set error(String? value) {
    _$errorAtom.reportWrite(value, super.error, () {
      super.error = value;
    });
  }

  late final _$votosSelecionadosAtom =
      Atom(name: '_VotingStoreBase.votosSelecionados', context: context);

  @override
  ObservableMap<int, List<String>> get votosSelecionados {
    _$votosSelecionadosAtom.reportRead();
    return super.votosSelecionados;
  }

  @override
  set votosSelecionados(ObservableMap<int, List<String>> value) {
    _$votosSelecionadosAtom.reportWrite(value, super.votosSelecionados, () {
      super.votosSelecionados = value;
    });
  }

  late final _$confirmarVotoAsyncAction =
      AsyncAction('_VotingStoreBase.confirmarVoto', context: context);

  @override
  Future<void> confirmarVoto(
      {required int pautaId, required List<String> votos}) {
    return _$confirmarVotoAsyncAction
        .run(() => super.confirmarVoto(pautaId: pautaId, votos: votos));
  }

  late final _$loadPautasAsyncAction =
      AsyncAction('_VotingStoreBase.loadPautas', context: context);

  @override
  Future<void> loadPautas() {
    return _$loadPautasAsyncAction.run(() => super.loadPautas());
  }

  late final _$_VotingStoreBaseActionController =
      ActionController(name: '_VotingStoreBase', context: context);

  @override
  void selecionarVoto(int pautaId, String voto,
      {bool multiplaEscolha = false}) {
    final _$actionInfo = _$_VotingStoreBaseActionController.startAction(
        name: '_VotingStoreBase.selecionarVoto');
    try {
      return super
          .selecionarVoto(pautaId, voto, multiplaEscolha: multiplaEscolha);
    } finally {
      _$_VotingStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
pautas: ${pautas},
isLoading: ${isLoading},
error: ${error},
votosSelecionados: ${votosSelecionados}
    ''';
  }
}
