// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$AuthStore on _AuthStoreBase, Store {
  late final _$cooperadoAtom =
      Atom(name: '_AuthStoreBase.cooperado', context: context);

  @override
  CooperadoModel? get cooperado {
    _$cooperadoAtom.reportRead();
    return super.cooperado;
  }

  @override
  set cooperado(CooperadoModel? value) {
    _$cooperadoAtom.reportWrite(value, super.cooperado, () {
      super.cooperado = value;
    });
  }

  late final _$isLoadingAtom =
      Atom(name: '_AuthStoreBase.isLoading', context: context);

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

  late final _$errorAtom = Atom(name: '_AuthStoreBase.error', context: context);

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

  late final _$fetchCooperadoAsyncAction =
      AsyncAction('_AuthStoreBase.fetchCooperado', context: context);

  @override
  Future<bool> fetchCooperado(String login) {
    return _$fetchCooperadoAsyncAction.run(() => super.fetchCooperado(login));
  }

  late final _$_AuthStoreBaseActionController =
      ActionController(name: '_AuthStoreBase', context: context);

  @override
  void clear() {
    final _$actionInfo = _$_AuthStoreBaseActionController.startAction(
        name: '_AuthStoreBase.clear');
    try {
      return super.clear();
    } finally {
      _$_AuthStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
cooperado: ${cooperado},
isLoading: ${isLoading},
error: ${error}
    ''';
  }
}
