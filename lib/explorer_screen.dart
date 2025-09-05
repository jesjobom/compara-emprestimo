import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/api_service.dart';
import 'package:myapp/models.dart';

class ExplorerScreen extends StatefulWidget {
  const ExplorerScreen({Key? key}) : super(key: key);

  @override
  State<ExplorerScreen> createState() => _ExplorerScreenState();
}

class _ExplorerScreenState extends State<ExplorerScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<LoanType>> _loanTypesFuture;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loanTypesFuture = _apiService.getLoanTypes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Explorar Empréstimos'),
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
                labelText: 'Pesquisar',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<LoanType>>(
              future: _loanTypesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Erro: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Nenhum tipo de empréstimo encontrado'));
                } else {
                  final loanTypes = snapshot.data!.where((loanType) {
                    return loanType.name.toLowerCase().contains(_searchQuery.toLowerCase());
                  }).toList();
                  return ListView.builder(
                    itemCount: loanTypes.length,
                    itemBuilder: (context, index) {
                      final loanType = loanTypes[index];
                      return ListTile(
                        title: Text(loanType.name),
                        trailing: IconButton(
                          icon: const Icon(Icons.star_border),
                          onPressed: () {
                            // Handle starring the loan type
                          },
                        ),
                        onTap: () {
                          context.go('/banks/${loanType.id}', extra: loanType.name);
                        },
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
