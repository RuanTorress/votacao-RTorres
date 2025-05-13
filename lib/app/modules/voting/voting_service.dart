import 'dart:convert';
import 'package:geolocator/geolocator.dart';
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

  Future<String> getIp() async {
    final response = await http.get(Uri.parse('https://api.ipify.org'));
    return response.body;
  }

  Future<Map<String, dynamic>> getGeolocation() async {
    final location = await Geolocator.getCurrentPosition();
    return {
      'latitude': location.latitude,
      'longitude': location.longitude,
    };
  }

  Future<ServiceResponse<void>> registrarVoto(Map<String, dynamic> voto) async {
    final url = Uri.parse('$baseUrl/votos');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(voto),
      );

      if (response.statusCode == 201) {
        print('✅ Voto registrado com sucesso');
        return ServiceResponse(
            success: true, message: 'Voto registrado com sucesso');
      } else {
        print('❌ Falha ao registrar voto: ${response.statusCode}');
        print(response.body);

        String? errorMessage;
        try {
          final body = jsonDecode(response.body);
          errorMessage =
              body['error'] ?? body['message'] ?? 'Erro ao registrar voto';
        } catch (_) {
          errorMessage = 'Erro desconhecido ao registrar voto';
        }

        return ServiceResponse(success: false, message: errorMessage);
      }
    } catch (e) {
      print('❌ Erro de conexão ao enviar voto: $e');
      return ServiceResponse(success: false, message: 'Erro de conexão: $e');
    }
  }
}
