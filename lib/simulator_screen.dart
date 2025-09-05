import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myapp/api_service.dart';
import 'package:myapp/models.dart';
import 'dart:math';

class SimulatorScreen extends StatefulWidget {
  const SimulatorScreen({Key? key}) : super(key: key);

  @override
  State<SimulatorScreen> createState() => _SimulatorScreenState();
}

class _SimulatorScreenState extends State<SimulatorScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();

  List<LoanType> _loanTypes = [];
  List<Bank> _banks = [];

  LoanType? _selectedLoanType;
  Bank? _selectedBank;
  double? _loanAmount;
  int? _loanTerm;

  double? _monthlyPayment;
  double? _totalPayment;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final loanTypes = await _apiService.getLoanTypes();
      final banks = await _apiService.getBanksForLoanType(''); // Fetch all banks initially
      if (!mounted) return; // Check if the widget is still in the tree
      setState(() {
        _loanTypes = loanTypes;
        _banks = banks;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return; // Check if the widget is still in the tree
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Falha ao carregar dados: $e')),
      );
    }
  }

  void _calculateLoan() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      if (_selectedBank != null && _loanAmount != null && _loanTerm != null) {
        final double rate = _selectedBank!.interestRate;
        final double principal = _loanAmount!;
        final int term = _loanTerm!;

        if (rate <= 0) {
          setState(() {
            _monthlyPayment = principal / term;
            _totalPayment = principal;
          });
          return;
        }

        // The formula uses the monthly interest rate.
        // We are assuming the 'interestRate' from the API is already a monthly rate.
        final monthlyRate = rate;
        final monthlyPayment = principal * (monthlyRate * pow(1 + monthlyRate, term)) / (pow(1 + monthlyRate, term) - 1);
        final totalPayment = monthlyPayment * term;

        setState(() {
          _monthlyPayment = monthlyPayment;
          _totalPayment = totalPayment;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Simulador de Empréstimos'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    DropdownButtonFormField<LoanType>(
                      value: _selectedLoanType,
                      items: _loanTypes.map((loanType) {
                        return DropdownMenuItem<LoanType>(
                          value: loanType,
                          child: Text(loanType.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedLoanType = value;
                          _selectedBank = null; // Reset bank selection
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: 'Tipo de Empréstimo',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => value == null ? 'Selecione um tipo de empréstimo' : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<Bank>(
                      value: _selectedBank,
                      items: _banks.map((bank) {
                        return DropdownMenuItem<Bank>(
                          value: bank,
                          child: Text(bank.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedBank = value;
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: 'Banco',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => value == null ? 'Selecione um banco' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Valor do Empréstimo (R\$)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      onSaved: (value) => _loanAmount = double.tryParse(value ?? ''),
                      validator: (value) {
                        if (value == null || value.isEmpty || double.tryParse(value) == null || double.parse(value) <= 0) {
                          return 'Por favor, insira um valor válido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Prazo (meses)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      onSaved: (value) => _loanTerm = int.tryParse(value ?? ''),
                      validator: (value) {
                        if (value == null || value.isEmpty || int.tryParse(value) == null || int.parse(value) <= 0) {
                          return 'Por favor, insira um prazo válido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _calculateLoan,
                      child: const Text('Simular'),
                    ),
                    const SizedBox(height: 32),
                    if (_monthlyPayment != null && _totalPayment != null)
                      Card(
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Resultado da Simulação', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 12),
                              Text('Pagamento Mensal: ${currencyFormatter.format(_monthlyPayment)}'),
                              const SizedBox(height: 8),
                              Text('Total a Pagar: ${currencyFormatter.format(_totalPayment)}'),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
    );
  }
}
