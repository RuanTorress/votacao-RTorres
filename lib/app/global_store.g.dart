// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'global_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$GlobalStore on _GlobalStoreBase, Store {
  late final _$cooperadoAtom =
      Atom(name: '_GlobalStoreBase.cooperado', context: context);

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

  late final _$isAuthenticatedAtom =
      Atom(name: '_GlobalStoreBase.isAuthenticated', context: context);

  @override
  bool get isAuthenticated {
    _$isAuthenticatedAtom.reportRead();
    return super.isAuthenticated;
  }

  @override
  set isAuthenticated(bool value) {
    _$isAuthenticatedAtom.reportWrite(value, super.isAuthenticated, () {
      super.isAuthenticated = value;
    });
  }

  late final _$_GlobalStoreBaseActionController =
      ActionController(name: '_GlobalStoreBase', context: context);

  @override
  void setCooperado(CooperadoModel cooperado) {
    final _$actionInfo = _$_GlobalStoreBaseActionController.startAction(
        name: '_GlobalStoreBase.setCooperado');
    try {
      return super.setCooperado(cooperado);
    } finally {
      _$_GlobalStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void clearCooperado() {
    final _$actionInfo = _$_GlobalStoreBaseActionController.startAction(
        name: '_GlobalStoreBase.clearCooperado');
    try {
      return super.clearCooperado();
    } finally {
      _$_GlobalStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
cooperado: ${cooperado},
isAuthenticated: ${isAuthenticated}
    ''';
  }
}
