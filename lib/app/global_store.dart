import 'package:mobx/mobx.dart';
import 'package:votacao_uniodonto/app/modules/auth/models/cooperado_models.dart';

part 'global_store.g.dart';

class GlobalStore = _GlobalStoreBase with _$GlobalStore;

abstract class _GlobalStoreBase with Store {
  // Estado global para o cooperado
  @observable
  CooperadoModel? cooperado;

  @observable
  bool isAuthenticated = false;

  @action
  void setCooperado(CooperadoModel cooperado) {
    this.cooperado = cooperado;
    isAuthenticated = true;
  }

  @action
  void clearCooperado() {
    cooperado = null;
    isAuthenticated = false;
  }
}