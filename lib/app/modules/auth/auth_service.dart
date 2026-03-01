import 'package:flutter/foundation.dart';
import 'package:votacao_uniodonto/app/modules/auth/models/cooperado_models.dart';
import 'package:votacao_uniodonto/app/shared/service_response.dart';

class AuthServices {
  // ─── DADOS MOCK DE COOPERADOS ───────────────────────────────────────
  static final List<Map<String, dynamic>> _cooperadosMock = [
    {
      'id': 1,
      'login': 'UGGO12345',
      'senha': '123456',
      'nome_completo': 'João Silva de Oliveira',
      'cpf': '123.456.789-00',
      'celular': '(62) 99999-0001',
      'email': 'joao.silva@email.com',
      'dt_nascimento': '1985-03-15T00:00:00.000Z',
    },
    {
      'id': 2,
      'login': 'UGGO67890',
      'senha': '123456',
      'nome_completo': 'Maria Fernanda Costa',
      'cpf': '987.654.321-00',
      'celular': '(62) 98888-0002',
      'email': 'maria.costa@email.com',
      'dt_nascimento': '1990-07-22T00:00:00.000Z',
    },
    {
      'id': 3,
      'login': 'UGGO11111',
      'senha': '123456',
      'nome_completo': 'Carlos Eduardo Pereira',
      'cpf': '111.222.333-44',
      'celular': '(62) 97777-0003',
      'email': 'carlos.pereira@email.com',
      'dt_nascimento': '1978-11-05T00:00:00.000Z',
    },
    {
      'id': 4,
      'login': 'UGGO22222',
      'senha': '123456',
      'nome_completo': 'Ana Paula Rodrigues',
      'cpf': '555.666.777-88',
      'celular': '(62) 96666-0004',
      'email': 'ana.rodrigues@email.com',
      'dt_nascimento': '1992-01-30T00:00:00.000Z',
    },
    {
      'id': 5,
      'login': 'UGGO33333',
      'senha': '123456',
      'nome_completo': 'Roberto Mendes Lima',
      'cpf': '999.888.777-66',
      'celular': '(62) 95555-0005',
      'email': 'roberto.lima@email.com',
      'dt_nascimento': '1980-06-18T00:00:00.000Z',
    },
  ];

  /// Busca cooperado com base no login informado (MOCK)
  Future<ServiceResponse<List<CooperadoModel>>> getCooperadoByLogin(
      String login) async {
    // Simula um pequeno delay de rede
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      final normalizedLogin = login.toUpperCase();
      final found = _cooperadosMock.where(
        (c) => (c['login'] as String).toUpperCase() == normalizedLogin,
      );

      if (found.isNotEmpty) {
        final cooperado = CooperadoModel.fromJson(found.first);
        debugPrint('✅ [MOCK] Cooperado encontrado: ${cooperado.nomeCompleto}');
        return ServiceResponse<List<CooperadoModel>>(
            success: true, data: [cooperado]);
      } else {
        debugPrint('❌ [MOCK] Cooperado não encontrado para login: $login');
        return ServiceResponse<List<CooperadoModel>>(
          success: false,
          message: 'Cooperado não encontrado para o login informado.',
        );
      }
    } catch (e) {
      debugPrint('❌ [MOCK] Erro ao buscar cooperado: $e');
      return ServiceResponse<List<CooperadoModel>>(
        success: false,
        message: 'Erro ao processar dados do cooperado.',
      );
    }
  }

  /// Envia código de verificação via SMS (MOCK - sempre sucesso)
  Future<ServiceResponse> sendCode(String phone) async {
    await Future.delayed(const Duration(milliseconds: 300));
    debugPrint('📲 [MOCK] Código SMS enviado para: $phone');
    return ServiceResponse(success: true);
  }

  /// Autentica cooperado usando token (MOCK - valida login/senha da lista)
  Future<ServiceResponse<Map<String, dynamic>>> coopLogin(String token) async {
    await Future.delayed(const Duration(milliseconds: 500));

    // No mock, aceitamos qualquer token como válido
    debugPrint('✅ [MOCK] Login aceito com token');
    return ServiceResponse<Map<String, dynamic>>(
      success: true,
      data: {'authenticated': true},
    );
  }
}
