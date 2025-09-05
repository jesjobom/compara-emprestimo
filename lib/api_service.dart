import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:myapp/models.dart';

class ApiService {
  static const String _bcbBaseUrl = 'https://www.bcb.gov.br/api/servico/sitebcb';
  static List<LoanType>? _cachedLoanTypes;

  Future<List<LoanType>> getLoanTypes() async {
    if (_cachedLoanTypes != null) {
      return _cachedLoanTypes!;
    }

    final url = Uri.parse('$_bcbBaseUrl/HistoricoTaxaJurosDiario/ParametrosConsulta');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> loanParams = data['conteudo'];

        final uniqueLoanTypes = <String, LoanType>{};
        for (var jsonItem in loanParams) {
          final loanType = LoanType.fromJson(jsonItem);
          uniqueLoanTypes[loanType.name] = loanType;
        }

        _cachedLoanTypes = uniqueLoanTypes.values.toList();
        return _cachedLoanTypes!;
      } else {
        throw Exception('Failed to load loan types from BCB API');
      }
    } catch (e) {
      throw Exception('Error fetching loan types: $e');
    }
  }

  Future<List<Bank>> getBanksForLoanType(String loanTypeId) async {
    if (_cachedLoanTypes == null) {
      await getLoanTypes();
    }

    final loanType = _cachedLoanTypes!.firstWhere(
      (lt) => lt.id == loanTypeId,
      orElse: () => throw Exception('Loan type with id $loanTypeId not found in cache.'),
    );

    var threeWeeksAgo = DateTime.now().subtract(const Duration(days: 21));
    // Adjust to the previous weekday if it's a weekend
    if (threeWeeksAgo.weekday == DateTime.saturday) {
      threeWeeksAgo = threeWeeksAgo.subtract(const Duration(days: 1));
    } else if (threeWeeksAgo.weekday == DateTime.sunday) {
      threeWeeksAgo = threeWeeksAgo.subtract(const Duration(days: 2));
    }
    final formattedDate = DateFormat('yyyy-MM-dd').format(threeWeeksAgo);

    final filter = "(codigoSegmento eq '${loanType.segmentCode}') and (codigoModalidade eq '${loanType.modalityCode}') and (InicioPeriodo eq '$formattedDate')";

    final url = Uri.https('www.bcb.gov.br', '/api/servico/sitebcb/historicotaxajurosdiario/atual', {
      'filtro': filter,
      '\$format': 'json',
    });

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> bankData = data['conteudo'];

        if (bankData.isEmpty) {
          return [];
        }

        final banks = bankData.map((json) => Bank.fromJson(json)).toList();
        return banks;
      } else {
        throw Exception('Failed to load banks for loan type $loanTypeId. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching banks: $e');
    }
  }
}
