import 'package:flutter/material.dart';
import 'package:myapp/api_service.dart';
import 'package:myapp/models.dart';

enum SortOption { name, interest }

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
  SortOption _sortOption = SortOption.interest;

  @override
  void initState() {
    super.initState();
    _banksFuture = _apiService.getBanksForLoanType(widget.loanTypeId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.loanTypeName),
        actions: [
          PopupMenuButton<SortOption>(
            onSelected: (sortOption) {
              setState(() {
                _sortOption = sortOption;
              });
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<SortOption>>[
              const PopupMenuItem<SortOption>(
                value: SortOption.interest,
                child: Text('Ordenar por juros'),
              ),
              const PopupMenuItem<SortOption>(
                value: SortOption.name,
                child: Text('Ordenar por nome'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
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
                  borderRadius: BorderRadius.circular(8.0),
                ),
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
                  return Center(child: Text('Erro: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Nenhum banco encontrado para este tipo de empréstimo'));
                } else {
                  final banks = snapshot.data!.where((bank) {
                    return bank.name.toLowerCase().contains(_searchQuery.toLowerCase());
                  }).toList();

                  banks.sort((a, b) {
                    if (_sortOption == SortOption.interest) {
                      return a.interestRate.compareTo(b.interestRate);
                    } else {
                      return a.name.compareTo(b.name);
                    }
                  });

                  return ListView.builder(
                    itemCount: banks.length,
                    itemBuilder: (context, index) {
                      final bank = banks[index];
                      return ListTile(
                        title: Text(bank.name),
                        subtitle: Text('Taxa de juros: ${(bank.interestRate * 100).toStringAsFixed(2)}%'),
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
