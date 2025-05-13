class CooperadoModel {
  final int id;          // Novo campo ID
  final String nomeCompleto;
  final String cpf;
  final String celular;
  final String email;
  final DateTime dtNascimento;

  CooperadoModel({
    required this.id,        // Agora exigimos o ID no construtor
    required this.nomeCompleto,
    required this.cpf,
    required this.celular,
    required this.email,
    required this.dtNascimento,
  });

  factory CooperadoModel.fromJson(Map<String, dynamic> json) {
    return CooperadoModel(
      id: json['id'] ?? '',  // Garantindo que o ID seja atribuído
      nomeCompleto: json['nome_completo'] ?? '',
      cpf: json['cpf'] ?? '',
      celular: json['celular'] ?? '',
      email: json['email'] ?? '',
      dtNascimento: DateTime.parse(json['dt_nascimento']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,               // Incluindo o ID no JSON
      'nome_completo': nomeCompleto,
      'cpf': cpf,
      'celular': celular,
      'email': email,
      'dt_nascimento': dtNascimento.toIso8601String(),
    };
  }
}