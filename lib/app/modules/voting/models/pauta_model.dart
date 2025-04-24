class PautaModel {
  final int id;
  final String titulo;
  final String descricao;
  final String tipo;
  final DateTime dataInicio;
  final DateTime dataFim;
  final bool respostaMultipla;

  PautaModel({
    required this.id,
    required this.titulo,
    required this.descricao,
    required this.tipo,
    required this.dataInicio,
    required this.dataFim,
    required this.respostaMultipla,
  });

  factory PautaModel.fromJson(Map<String, dynamic> json) {
    return PautaModel(
      id: json['id'],
      titulo: json['titulo'],
      descricao: json['descricao'],
      tipo: json['tipo'],
      dataInicio: DateTime.parse(json['data_inicio']),
      dataFim: DateTime.parse(json['data_fim']),
      respostaMultipla: json['resposta_multipla'],
    );
  }

  @override
  String toString() {
    return 'PautaModel(id: $id, titulo: $titulo)';
  }
}