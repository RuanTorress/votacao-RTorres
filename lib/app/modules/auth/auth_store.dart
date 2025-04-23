import 'package:mobx/mobx.dart';
import 'package:votacao_uniodonto/app/modules/auth/auth_service.dart';
import 'package:votacao_uniodonto/app/modules/auth/models/cooperado_models.dart';

part 'auth_store.g.dart';

class AuthStore = _AuthStoreBase with _$AuthStore;

abstract class _AuthStoreBase with Store {
  final AuthServices _authServices = AuthServices();  

  @observable
  CooperadoModel? cooperado;

  @observable
  bool isLoading = false;

  @observable
  String? error;

  @action
  Future<bool> fetchCooperado(String login) async {
    isLoading = true;
    error = null;

    final result = await _authServices.getCooperadoByLogin(login);

    if (result.success && result.data != null && result.data!.isNotEmpty) {
      cooperado = result.data!.first;
      isLoading = false;
      return true;
    } else {
      error = result.message ?? 'Erro desconhecido ao buscar cooperado.';
      isLoading = false;
      return false;
    }
  }

  @action
  void clear() {
    cooperado = null;
    error = null;
  }
}