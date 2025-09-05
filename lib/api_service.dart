import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:myapp/models.dart';

class ApiService {
  static const String _bcbBaseUrl = 'https://www.bcb.gov.br/api/servico/sitebcb';
  static List<LoanType>? _cachedLoanTypes;
  static List<Bank>? _cachedBanks;
  static DateTime? _lastFetchTime;

  Future<List<LoanType>> getLoanTypes() async {
    if (_cachedLoanTypes != null &&
        _lastFetchTime != null &&
        DateTime.now().difference(_lastFetchTime!) < const Duration(days: 1)) {
      return _cachedLoanTypes!;
    }

    final url = Uri.parse('$_bcbBaseUrl/HistoricoTaxaJurosDiario/ParametrosConsulta');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        // The response body is a string, needs to be decoded
        final data = json.decode(response.body);
        // The actual list is under the 'conteudo' key
        final List<dynamic> loanParams = data['conteudo'];

        // Use a Set to store unique modalities to avoid duplicates
        final uniqueLoanTypes = <String, LoanType>{};
        for (var jsonItem in loanParams) {
          final loanType = LoanType.fromJson(jsonItem);
          // Use the combined name as the key to ensure uniqueness
          uniqueLoanTypes[loanType.name] = loanType;
        }

        _cachedLoanTypes = uniqueLoanTypes.values.toList();
        _lastFetchTime = DateTime.now();
        return _cachedLoanTypes!;
      } else {
        throw Exception('Failed to load loan types from BCB API');
      }
    } catch (e) {
      // Rethrow the exception to be handled by the UI
      throw Exception('Error fetching loan types: $e');
    }
  }

  Future<List<Bank>> getBanksForLoanType(String loanTypeId) async {
    // Using mock data for now as the BCB API for banks per modality is more complex
    await Future.delayed(const Duration(seconds: 1)); // Simulate network latency
    _cachedBanks = mockBanks;
    return _cachedBanks!;
  }
}

// Mock bank data remains for now
final List<Bank> mockBanks = [
  Bank(id: 'a', name: 'Banco do Brasil', interestRate: 0.05),
  Bank(id: 'b', name: 'Caixa Econômica Federal', interestRate: 0.045),
  Bank(id: 'c', name: 'Itaú Unibanco', interestRate: 0.06),
  Bank(id: 'd', name: 'Bradesco', interestRate: 0.055),
  Bank(id: 'e', name: 'Santander', interestRate: 0.058),
];
