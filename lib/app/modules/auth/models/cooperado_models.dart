class CooperadoModel {
  final String nomeCompleto;
  final String cpf;
  final String celular;
  final String email;
  final DateTime dtNascimento;

  CooperadoModel({
    required this.nomeCompleto,
    required this.cpf,
    required this.celular,
    required this.email,
    required this.dtNascimento,
  });

  factory CooperadoModel.fromJson(Map<String, dynamic> json) {
    return CooperadoModel(
      nomeCompleto: json['nome_completo'] ?? '',
      cpf: json['cpf'] ?? '',
      celular: json['celular'] ?? '',
      email: json['email'] ?? '',
      dtNascimento: DateTime.parse(json['dt_nascimento']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nome_completo': nomeCompleto,
      'cpf': cpf,
      'celular': celular,
      'email': email,
      'dt_nascimento': dtNascimento.toIso8601String(),
    };
  }
}