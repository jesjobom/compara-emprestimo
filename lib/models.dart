class LoanType {
  final String id;
  final String name;
  final String segment;
  final String modality;

  LoanType({
    required this.id,
    required this.name,
    required this.segment,
    required this.modality,
  });

  factory LoanType.fromJson(Map<String, dynamic> json) {
    final segment = json['Segmento'] as String;
    final modality = json['Modalidade'] as String;
    return LoanType(
      id: modality, // Using modality as a unique ID for simplicity
      name: '$segment - $modality',
      segment: segment,
      modality: modality,
    );
  }
}

class Bank {
  final String id;
  final String name;
  final double interestRate;

  Bank({required this.id, required this.name, required this.interestRate});

  factory Bank.fromJson(Map<String, dynamic> json) {
    return Bank(
      id: json['id'],
      name: json['name'],
      interestRate: json['interestRate'],
    );
  }
}
