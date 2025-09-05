class LoanType {
  final String id;
  final String name;
  final String segment;
  final String modality;
  final String segmentCode;
  final String modalityCode;

  LoanType({
    required this.id,
    required this.name,
    required this.segment,
    required this.modality,
    required this.segmentCode,
    required this.modalityCode,
  });

  factory LoanType.fromJson(Map<String, dynamic> json) {
    final segment = json['Segmento'] as String;
    final modality = json['Modalidade'] as String;
    final segmentCode = json['codigoSegmento'] as String;
    final modalityCode = json['codigoModalidade'] as String;

    return LoanType(
      id: modalityCode, // Use the modality code as the unique ID
      name: '$segment - $modality',
      segment: segment,
      modality: modality,
      segmentCode: segmentCode,
      modalityCode: modalityCode,
    );
  }
}

class Bank {
  final String id;
  final String name;
  final double monthlyInterestRate;
  final double yearlyInterestRate;

  Bank({
    required this.id,
    required this.name,
    required this.monthlyInterestRate,
    required this.yearlyInterestRate,
  });

  factory Bank.fromJson(Map<String, dynamic> json) {
    // Handles the comma as a decimal separator from the API
    final monthlyRateString = (json['TaxaJurosAoMes'] as String? ?? '0').replaceAll('.', '').replaceAll(',', '.');
    final yearlyRateString = (json['TaxaJurosAoAno'] as String? ?? '0').replaceAll('.', '').replaceAll(',', '.');

    final monthlyRate = double.tryParse(monthlyRateString) ?? 0.0;
    final yearlyRate = double.tryParse(yearlyRateString) ?? 0.0;

    return Bank(
      id: (json['Posicao'] as int).toString(),
      name: json['InstituicaoFinanceira'] as String,
      monthlyInterestRate: monthlyRate / 100.0, // Convert percentage to decimal
      yearlyInterestRate: yearlyRate / 100.0, // Convert percentage to decimal
    );
  }
}
