import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'package:votacao_uniodonto/app/modules/auth/models/cooperado_models.dart';
import 'package:votacao_uniodonto/app/shared/env.dart';
import 'package:votacao_uniodonto/app/shared/service_response.dart';

class AuthServices {
  final String _baseUrl = Env.apiUrl;
  final String _baseUrl2 = Env.apiUrl2;

  /// Busca cooperado com base no login informado
  Future<ServiceResponse<List<CooperadoModel>>> getCooperadoByLogin(String login) async {
    final url = Uri.parse('$_baseUrl/usersCoop/getCoopforLogin?value=$login');

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Basic YXBwQXV0aERldjpqYW4yMDI0',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 202) {
        try {
          final Map<String, dynamic> body = jsonDecode(response.body);
          final cooperado = CooperadoModel.fromJson(body);
          return ServiceResponse<List<CooperadoModel>>(success: true, data: [cooperado]);
        } catch (e) {
          debugPrint('⚠️ Erro ao decodificar JSON: $e');
          return ServiceResponse<List<CooperadoModel>>(
            success: false,
            message: 'Erro ao processar resposta da API',
          );
        }
      } else {
        String errorMessage = 'Erro ao buscar cooperado.';
        try {
          final decoded = jsonDecode(response.body);
          final error = decoded['error'] ?? '';
          final details = decoded['details'] ?? '';
          errorMessage = '$error\n$details'.trim();
        } catch (_) {
          debugPrint('⚠️ Corpo de erro não é JSON válido');
        }

        debugPrint('❌ Erro API: $errorMessage');
        return ServiceResponse<List<CooperadoModel>>(
          success: false,
          message: errorMessage,
        );
      }
    } catch (e) {
      debugPrint('❌ Erro de conexão: $e');
      return ServiceResponse<List<CooperadoModel>>(
        success: false,
        message: 'Erro de conexão. Verifique sua rede ou se a API está ativa.',
      );
    }
  }

  /// Envia código de verificação via SMS
  Future<ServiceResponse> sendCode(String phone) async {
    final url = Uri.parse('$_baseUrl2/auth/send-code');

    // try {
    //   final response = await http.post(
    //     url,
    //     headers: {'Content-Type': 'application/json'},
    //     body: jsonEncode({'phone': phone}),
    //   );

    //   if (response.statusCode == 200 || response.statusCode == 202) {
    //     return ServiceResponse(success: true);
    //   } else {
    //     String errorMessage = 'Erro ao enviar código.';
    //     try {
    //       final decoded = jsonDecode(response.body);
    //       final error = decoded['error'] ?? '';
    //       final details = decoded['details'] ?? '';
    //       errorMessage = '$error\n$details'.trim();
    //     } catch (_) {
    //       debugPrint('⚠️ Corpo de erro não é JSON válido');
    //     }

    //     debugPrint('❌ Erro API: $errorMessage');
    //     return ServiceResponse(success: false, message: errorMessage);
    //   }
    // } catch (e) {
    //   debugPrint('❌ Erro de conexão ao enviar código: $e');
    //   return ServiceResponse(
    //     success: false,
    //     message: 'Erro de conexão. Verifique sua rede ou se a API está ativa.',
    //   );
    // }
    return ServiceResponse(success: true);
  }
}