import 'package:flutter/foundation.dart';
import 'package:votacao_uniodonto/app/modules/voting/models/pauta_model.dart';
import 'package:votacao_uniodonto/app/shared/service_response.dart';

class VotingService {
  // ─── DADOS MOCK DE PAUTAS ───────────────────────────────────────────
  static final List<Map<String, dynamic>> _pautasMock = [
    {
      'id': 1,
      'numero_pauta': 1,
      'titulo': 'Aprovação das Contas do Exercício 2024',
      'descricao':
          'Deliberação sobre a aprovação das demonstrações contábeis e financeiras referentes ao exercício social encerrado em 31/12/2024, incluindo balanço patrimonial, demonstração de resultados e parecer do conselho fiscal.',
      'assembleia_id': 1,
      'resposta_editavel': false,
      'respostas': ['Aprovo', 'Reprovo', 'Abstenho'],
      'multipla_escolha': false,
      'created_at': '2025-03-01T10:00:00.000Z',
    },
    {
      'id': 2,
      'numero_pauta': 2,
      'titulo': 'Destinação das Sobras Líquidas',
      'descricao':
          'Deliberação sobre a destinação das sobras líquidas apuradas no exercício de 2024, conforme proposta apresentada pelo Conselho de Administração, incluindo distribuição aos cooperados e reservas estatutárias.',
      'assembleia_id': 1,
      'resposta_editavel': false,
      'respostas': ['Aprovo', 'Reprovo', 'Abstenho'],
      'multipla_escolha': false,
      'created_at': '2025-03-01T10:00:00.000Z',
    },
    {
      'id': 3,
      'numero_pauta': 3,
      'titulo': 'Eleição do Conselho de Administração',
      'descricao':
          'Eleição dos membros do Conselho de Administração para o mandato 2025-2028. Selecione até 3 candidatos da lista abaixo.',
      'assembleia_id': 1,
      'resposta_editavel': false,
      'respostas': [
        'Dr. Marcos Antônio Souza',
        'Dra. Patrícia Lima Ferreira',
        'Dr. Ricardo Gomes Neto',
        'Dra. Juliana Martins Rocha',
        'Dr. Fernando Alves Costa',
      ],
      'multipla_escolha': true,
      'created_at': '2025-03-01T10:00:00.000Z',
    },
    {
      'id': 4,
      'numero_pauta': 4,
      'titulo': 'Reforma do Estatuto Social',
      'descricao':
          'Deliberação sobre as alterações propostas ao Estatuto Social da cooperativa, visando adequação à legislação vigente e modernização dos processos de governança corporativa.',
      'assembleia_id': 1,
      'resposta_editavel': false,
      'respostas': ['Aprovo', 'Reprovo', 'Abstenho'],
      'multipla_escolha': false,
      'created_at': '2025-03-01T10:00:00.000Z',
    },
    {
      'id': 5,
      'numero_pauta': 5,
      'titulo': 'Plano de Investimentos 2025',
      'descricao':
          'Aprovação do plano de investimentos para o exercício de 2025, contemplando expansão da rede credenciada, melhorias tecnológicas e programas de capacitação profissional.',
      'assembleia_id': 1,
      'resposta_editavel': false,
      'respostas': ['Aprovo', 'Reprovo', 'Abstenho'],
      'multipla_escolha': false,
      'created_at': '2025-03-01T10:00:00.000Z',
    },
  ];

  // ─── ARMAZENA VOTOS REGISTRADOS LOCALMENTE (MOCK) ──────────────────
  static final List<Map<String, dynamic>> _votosRegistrados = [];

  // ─── ARMAZENA INTERAÇÕES (MOCK) ────────────────────────────────────
  static int _nextInteractionId = 1;
  static final List<Map<String, dynamic>> _interacoes = [];

  /// Retorna lista de pautas (MOCK)
  Future<ServiceResponse<List<PautaModel>>> getPautas() async {
    await Future.delayed(const Duration(milliseconds: 600));

    try {
      final pautas = _pautasMock.map((e) => PautaModel.fromJson(e)).toList();
      debugPrint('✅ [MOCK] ${pautas.length} pautas carregadas');
      return ServiceResponse(success: true, data: pautas);
    } catch (e) {
      debugPrint('❌ [MOCK] Erro ao carregar pautas: $e');
      return ServiceResponse(
          success: false, message: 'Erro ao carregar pautas: $e');
    }
  }

  /// Retorna IP falso (MOCK)
  Future<String> getIp() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return '192.168.1.100';
  }

  /// Retorna geolocalização falsa (MOCK)
  Future<Map<String, dynamic>> getGeolocation() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return {
      'latitude': -16.6869,
      'longitude': -49.2648,
    };
  }

  /// Registra voto (MOCK - salva localmente)
  Future<ServiceResponse<void>> registrarVoto(Map<String, dynamic> voto) async {
    await Future.delayed(const Duration(milliseconds: 400));

    try {
      _votosRegistrados.add({
        ...voto,
        'created_at': DateTime.now().toIso8601String(),
      });
      debugPrint('✅ [MOCK] Voto registrado com sucesso');
      return ServiceResponse(
          success: true, message: 'Voto registrado com sucesso');
    } catch (e) {
      debugPrint('❌ [MOCK] Erro ao registrar voto: $e');
      return ServiceResponse(
          success: false, message: 'Erro ao registrar voto: $e');
    }
  }

  /// Busca votos por cooperado (MOCK)
  Future<ServiceResponse<List<Map<String, dynamic>>>> getVotosPorCooperado(
      int cooperadoId) async {
    await Future.delayed(const Duration(milliseconds: 400));

    try {
      final votos = _votosRegistrados
          .where((v) => v['cooperado_id'] == cooperadoId)
          .toList();
      debugPrint(
          '✅ [MOCK] ${votos.length} votos encontrados para cooperado $cooperadoId');
      return ServiceResponse(success: true, data: votos);
    } catch (e) {
      return ServiceResponse(
          success: false, message: 'Erro ao buscar votos: $e');
    }
  }

  /// Registra voto assinado (MOCK - salva localmente sem criptografia real)
  Future<ServiceResponse<void>> registrarVotoAssinado(
      Map<String, dynamic> voto) async {
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      final votoData = voto['voto'] as Map<String, dynamic>? ?? voto;
      _votosRegistrados.add({
        ...votoData,
        'assinatura': 'mock_signature_${DateTime.now().millisecondsSinceEpoch}',
        'created_at': DateTime.now().toIso8601String(),
      });
      debugPrint('✅ [MOCK] Voto assinado registrado com sucesso');
      return ServiceResponse(
          success: true, message: 'Voto assinado com sucesso');
    } catch (e) {
      debugPrint('❌ [MOCK] Erro ao registrar voto assinado: $e');
      return ServiceResponse(success: false, message: 'Erro interno: $e');
    }
  }

  /// Registra que o cooperado abriu a tela de votação (MOCK)
  Future<ServiceResponse<int>> openInteraction({
    required int cooperadoId,
    String? ip,
    double? latitude,
    double? longitude,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));

    try {
      final id = _nextInteractionId++;
      _interacoes.add({
        'id': id,
        'cooperado_id': cooperadoId,
        'ip': ip ?? '192.168.1.100',
        'latitude': latitude ?? -16.6869,
        'longitude': longitude ?? -49.2648,
        'opened_at': DateTime.now().toIso8601String(),
        'completed_at': null,
      });
      debugPrint('✅ [MOCK] Interação aberta com id: $id');
      return ServiceResponse(success: true, data: id);
    } catch (e) {
      return ServiceResponse(
          success: false, message: 'Erro ao abrir interação: $e');
    }
  }

  /// Marca como concluída a interação previamente aberta (MOCK)
  Future<ServiceResponse<void>> completeInteraction(int interactionId) async {
    await Future.delayed(const Duration(milliseconds: 200));

    try {
      final idx = _interacoes.indexWhere((i) => i['id'] == interactionId);
      if (idx != -1) {
        _interacoes[idx]['completed_at'] = DateTime.now().toIso8601String();
      }
      debugPrint('✅ [MOCK] Interação $interactionId concluída');
      return ServiceResponse(success: true);
    } catch (e) {
      return ServiceResponse(
          success: false, message: 'Erro ao concluir interação: $e');
    }
  }
}
