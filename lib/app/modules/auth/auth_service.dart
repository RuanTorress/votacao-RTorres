import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:votacao_uniodonto/app/modules/auth/models/cooperado_models.dart';
import 'package:votacao_uniodonto/app/shared/env.dart';
import 'package:votacao_uniodonto/app/shared/service_response.dart';

class AuthServices {
  final String _baseUrl = Env.apiUrl;

  Future<ServiceResponse<List<CooperadoModel>>> getCooperadoByLogin(
      String login) async {
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
        final Map<String, dynamic> body = jsonDecode(response.body);
        final cooperado = CooperadoModel.fromJson(body);
        return ServiceResponse(success: true, data: [cooperado]);
      } else {
        return ServiceResponse(
          success: false,
          message: 'Erro ao buscar cooperado: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('❌ Erro de conexão: $e');
      return ServiceResponse(success: false, message: 'Erro de conexão: $e');
    }
  }
}
