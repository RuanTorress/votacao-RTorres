import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:votacao_uniodonto/app/modules/voting/models/pauta_model.dart';
import 'package:votacao_uniodonto/app/shared/env.dart';
import 'package:votacao_uniodonto/app/shared/service_response.dart';

class VotingService {
  final String baseUrl = Env.apiUrl2;

  Future<ServiceResponse<List<PautaModel>>> getPautas() async {
    final url = Uri.parse('$baseUrl/pautas');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> body = jsonDecode(response.body);
        final pautas = body.map((e) => PautaModel.fromJson(e)).toList();
        return ServiceResponse(success: true, data: pautas);
      } else {
        return ServiceResponse(
          success: false,
          message: 'Erro ao buscar pautas: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('❌ Erro de conexão: $e');
      return ServiceResponse(success: false, message: 'Erro de conexão: $e');
    }
  }
}