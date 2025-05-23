import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:votacao_uniodonto/app/modules/voting/models/pauta_model.dart';
import 'package:votacao_uniodonto/app/shared/crypto_service.dart';
import 'package:votacao_uniodonto/app/shared/env.dart';
import 'package:votacao_uniodonto/app/shared/service_response.dart';

class VotingService {
  final String baseUrl = Env.apiUrl2;
  final CryptoService _cryptoService = CryptoService();

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

  Future<ServiceResponse<List<Map<String, dynamic>>>> getVotosPorCooperado(int cooperadoId) async {
  final url = Uri.parse('$baseUrl/votos/cooperado/$cooperadoId');

  try {
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> body = jsonDecode(response.body);
      return ServiceResponse(success: true, data: body.cast<Map<String, dynamic>>());
    } else if (response.statusCode == 404) {
      return ServiceResponse(success: true, data: []); // nenhum voto, mas não erro
    } else {
      return ServiceResponse(success: false, message: 'Erro ao buscar votos: ${response.statusCode}');
    }
  } catch (e) {
    return ServiceResponse(success: false, message: 'Erro de conexão: $e');
  }
}

Future<ServiceResponse<void>> registrarVotoAssinado(Map<String, dynamic> voto) async {
    try {
      final assinatura = await _cryptoService.signVoto(voto);
      final chavePublica = await _cryptoService.getPublicKeyBase64();

      final payload = {
        "voto": voto,
        "assinatura": assinatura,
        "chave_publica": chavePublica,
      };

      final response = await http.post(
        Uri.parse('$baseUrl/votos'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      if (response.statusCode == 201) {
        return ServiceResponse(success: true, message: 'Voto assinado com sucesso');
      } else {
        final body = jsonDecode(response.body);
        return ServiceResponse(success: false, message: body['error'] ?? 'Erro ao registrar voto');
      }
    } catch (e) {
      return ServiceResponse(success: false, message: 'Erro interno: $e');
    }
  }

  /// Registra que o cooperado abriu a tela de votação.
  Future<ServiceResponse<int>> openInteraction({
    required int cooperadoId,
    String? ip,
    double? latitude,
    double? longitude,
  }) async {
    final url = Uri.parse('$baseUrl/interacoes/open');
    try {
      final resp = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'cooperado_id': cooperadoId,
          'ip': ip,
          'latitude': latitude,
          'longitude': longitude,
        }),
      );

      if (resp.statusCode == 201) {
        final data = jsonDecode(resp.body) as Map<String, dynamic>;
        return ServiceResponse(success: true, data: data['id'] as int);
      } else {
        return ServiceResponse(
          success: false,
          message: 'Falha ao registrar abertura (status ${resp.statusCode})',
        );
      }
    } catch (e) {
      return ServiceResponse(success: false, message: 'Erro de conexão: $e');
    }
  }

  /// Marca como concluída a interação previamente aberta.
  Future<ServiceResponse<void>> completeInteraction(int interactionId) async {
    final url = Uri.parse('$baseUrl/interacoes/complete/$interactionId');
    try {
      final resp = await http.post(url);
      if (resp.statusCode == 200) {
        return ServiceResponse(success: true);
      } else {
        return ServiceResponse(
          success: false,
          message: 'Falha ao concluir interação (status ${resp.statusCode})',
        );
      }
    } catch (e) {
      return ServiceResponse(success: false, message: 'Erro de conexão: $e');
    }
  }
}
