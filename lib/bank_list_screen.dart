import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myapp/api_service.dart';
import 'package:myapp/models.dart';

enum SortOption { name, monthly, yearly }

class BankListScreen extends StatefulWidget {
  final String loanTypeId;
  final String loanTypeName;

  const BankListScreen({Key? key, required this.loanTypeId, required this.loanTypeName}) : super(key: key);

  @override
  State<BankListScreen> createState() => _BankListScreenState();
}

class _BankListScreenState extends State<BankListScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<Bank>> _banksFuture;
  String _searchQuery = '';
  SortOption _sortOption = SortOption.monthly;

  @override
  void initState() {
    super.initState();
    _banksFuture = _apiService.getBanksForLoanType(widget.loanTypeId);
  }

  String _formatRate(double rate) {
    // Use a formatter that shows at least 2 decimal places for the percentage.
    final formatter = NumberFormat.percentPattern('pt_BR');
    formatter.minimumFractionDigits = 2;
    return formatter.format(rate);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.loanTypeName),
        actions: [
          PopupMenuButton<SortOption>(
            icon: const Icon(Icons.sort),
            tooltip: 'Ordenar por',
            onSelected: (sortOption) {
              setState(() {
                _sortOption = sortOption;
              });
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<SortOption>>[
              const PopupMenuItem<SortOption>(
                value: SortOption.monthly,
                child: Text('Juros (mensal)'),
              ),
              const PopupMenuItem<SortOption>(
                value: SortOption.yearly,
                child: Text('Juros (anual)'),
              ),
              const PopupMenuItem<SortOption>(
                value: SortOption.name,
                child: Text('Nome da Instituição'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                labelText: 'Pesquisar por banco',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Bank>>(
              future: _banksFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Erro ao carregar os bancos: ${snapshot.error}',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Nenhum banco encontrado para este tipo de empréstimo'));
                } else {
                  final banks = snapshot.data!.where((bank) {
                    return bank.name.toLowerCase().contains(_searchQuery.toLowerCase());
                  }).toList();

                  banks.sort((a, b) {
                    switch (_sortOption) {
                      case SortOption.monthly:
                        return a.monthlyInterestRate.compareTo(b.monthlyInterestRate);
                      case SortOption.yearly:
                        return a.yearlyInterestRate.compareTo(b.yearlyInterestRate);
                      case SortOption.name:
                        return a.name.compareTo(b.name);
                    }
                  });

                  return ListView.builder(
                    itemCount: banks.length,
                    itemBuilder: (context, index) {
                      final bank = banks[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                          title: Text(bank.name, style: Theme.of(context).textTheme.titleMedium),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                'Taxa Mensal: ${_formatRate(bank.monthlyInterestRate)}',
                                style: TextStyle(color: Theme.of(context).colorScheme.primary),
                              ),
                              Text(
                                'Taxa Anual: ${_formatRate(bank.yearlyInterestRate)}',
                                style: TextStyle(color: Theme.of(context).colorScheme.secondary),
                              ),
                            ],
                          ),
                          leading: CircleAvatar(
                            child: Text((index + 1).toString()),
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
