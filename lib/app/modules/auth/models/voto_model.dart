class VotoModel {
  final int pautaId;
  final List<String> votos;
  final String ip;
  final DateTime dataHora;
  final Map<String, dynamic> geolocalizacao;
  final int cooperadoId;
  final String cooperadoName;
  final String status;

  VotoModel({
    required this.pautaId,
    required this.votos,
    required this.ip,
    required this.dataHora,
    required this.geolocalizacao,
    required this.cooperadoId,
    required this.cooperadoName,
    this.status = 'votado',
  });

  Map<String, dynamic> toJson() {
    return {
      'pauta_id': pautaId,
      'cooperado_id': cooperadoId,
      'votos': votos.length == 1
          ? {'resposta': votos.first}
          : {'resposta': votos}, // compatível com backend
      'ip': ip,
      'latitude': geolocalizacao['latitude'],
      'longitude': geolocalizacao['longitude'],
      'data_hora': dataHora.toIso8601String(),
      'status': status,
      'cooperado_name': cooperadoName,
    };
  }
}