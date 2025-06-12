class PautaModel {
  final int id;
  final int numeroPauta;
  final String titulo;
  final String descricao;
  final int assembleiaId;
  final bool respostaEditavel;
  final List<String> respostas;
  final bool multiplaEscolha;
  final DateTime createdAt;

  PautaModel({
    required this.id,
    required this.numeroPauta,
    required this.titulo,
    required this.descricao,
    required this.assembleiaId,
    required this.respostaEditavel,
    required this.respostas,
    required this.multiplaEscolha,
    required this.createdAt,
  });

  factory PautaModel.fromJson(Map<String, dynamic> json) {
    return PautaModel(
      id: json['id'],
      numeroPauta: json['numero_pauta'],
      titulo: json['titulo'],
      descricao: json['descricao'],
      assembleiaId: json['assembleia_id'],
      respostaEditavel: json['resposta_editavel'],
      respostas: List<String>.from(json['respostas'] ?? []),
      multiplaEscolha: json['multipla_escolha'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'numero_pauta': numeroPauta,
      'titulo': titulo,
      'descricao': descricao,
      'assembleia_id': assembleiaId,
      'resposta_editavel': respostaEditavel,
      'respostas': respostas,
      'multipla_escolha': multiplaEscolha,
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'PautaModel(id: $numeroPauta, titulo: $titulo)';
  }
}