import 'package:flutter_modular/flutter_modular.dart';
import 'package:mobx/mobx.dart';
import 'package:votacao_uniodonto/app/modules/auth/auth_service.dart';
import 'package:votacao_uniodonto/app/global_store.dart';

part 'auth_store.g.dart';

class AuthStore = _AuthStoreBase with _$AuthStore;

abstract class _AuthStoreBase with Store {
  final AuthServices _authServices = AuthServices();
  final GlobalStore _globalStore = Modular.get<GlobalStore>();

  // ======================
  // 🧍‍♂️ Cooperado & Login
  // ======================

  @observable
  bool isLoading = false;

  @observable
  String? error;

  /// Busca o cooperado com base no login informado
  @action
  Future<bool> fetchCooperado(String login) async {
    isLoading = true;
    error = null;
      // Garante que o login comece com "UGGO"
  final normalizedLogin = login.startsWith('UGGO') ? login : 'UGGO$login';

    final result = await _authServices.getCooperadoByLogin(normalizedLogin);

    if (result.success && result.data != null && result.data!.isNotEmpty) {
      final cooperado = result.data!.first;
      _globalStore.setCooperado(cooperado); // Salva o cooperado no GlobalStore
      isLoading = false;
      return true;
    } else {
      error = result.message ?? 'Erro desconhecido ao buscar cooperado.';
      isLoading = false;
      return false;
    }
  }

  // ======================
  // 📲 Envio e verificação de código SMS
  // ======================

  @observable
  bool smsSent = false;

  @observable
  bool isVerifying = false;

  @observable
  String? verificationError;

  /// Envia código de verificação via SMS
  @action
  Future<bool> sendCode() async {
    isLoading = true;
    error = null;

    final celular = _globalStore.cooperado?.celular; // Usando cooperado do GlobalStore
    if (celular == null || celular.isEmpty) {
      error = 'Telefone não encontrado.';
      isLoading = false;
      return false;
    }

    final result = await _authServices.sendCode(celular);

    isLoading = false;

    if (result.success) {
      smsSent = true;
      return true;
    } else {
      error = result.message ?? 'Erro ao enviar código.';
      return false;
    }
  }

  /// Simula verificação do código
  @action
  Future<bool> verifyCode(String code) async {
    isVerifying = true;
    verificationError = null;

    try {
      // TODO: Substituir por verificação real no backend
      await Future.delayed(const Duration(seconds: 2));
      if (code == '123456') {
        return true;
      } else {
        verificationError = 'Código inválido.';
        return false;
      }
    } catch (e) {
      verificationError = 'Erro ao verificar código.';
      return false;
    } finally {
      isVerifying = false;
    }
  }

  // ======================
  // ♻️ Limpeza de estado
  // ======================

  @action
  void clear() {
    _globalStore.clearCooperado(); // Limpa o cooperado no GlobalStore
    error = null;
    smsSent = false;
    isVerifying = false;
    verificationError = null;
  }
}