
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myapp/api_service.dart';
import 'package:myapp/models.dart';
import 'dart:math';

enum LoanTermType { months, years }

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
  LoanTermType _loanTermType = LoanTermType.months;

  double? _monthlyPayment;
  double? _totalPayment;

  bool _isLoading = true;
  bool _isCalculating = false;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final loanTypes = await _apiService.getLoanTypes();
      setState(() {
        _loanTypes = loanTypes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar os tipos de empréstimo: $e')),
      );
    }
  }

  Future<void> _fetchBanks(String loanTypeId) async {
    setState(() {
      _banks = [];
      _selectedBank = null;
      _isLoading = true;
    });
    try {
      final banks = await _apiService.getBanksForLoanType(loanTypeId);
      setState(() {
        _banks = banks;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar os bancos: $e')),
      );
    }
  }

  void _calculatePayment() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isCalculating = true; // Not used yet, but good for future spinners
      });

      if (_selectedBank != null && _loanAmount != null && _loanTerm != null) {
        final principal = _loanAmount!;
        final termInMonths = _loanTermType == LoanTermType.years ? _loanTerm! * 12 : _loanTerm!;
        
        final monthlyInterestRate = _selectedBank!.monthlyInterestRate;

        if (monthlyInterestRate <= 0) {
          setState(() {
            _monthlyPayment = principal / termInMonths;
            _totalPayment = principal;
          });
          return;
        }
        
        final monthlyPayment = principal * (monthlyInterestRate * pow(1 + monthlyInterestRate, termInMonths)) / (pow(1 + monthlyInterestRate, termInMonths) - 1);
        final totalPayment = monthlyPayment * termInMonths;

        setState(() {
          _monthlyPayment = monthlyPayment;
          _totalPayment = totalPayment;
        });
      }
      setState(() {
        _isCalculating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Simulador de Empréstimos'),
      ),
      body: _isLoading && _loanTypes.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DropdownButtonFormField<LoanType>(
                      value: _selectedLoanType,
                      decoration: const InputDecoration(labelText: 'Tipo de Empréstimo'),
                      items: _loanTypes.map((type) {
                        return DropdownMenuItem<LoanType>(
                          value: type,
                          child: Text(type.name, overflow: TextOverflow.ellipsis),
                        );
                      }).toList(),
                      onChanged: (LoanType? newValue) {
                        setState(() {
                          _selectedLoanType = newValue;
                          _selectedBank = null; // Reset bank selection
                          _banks = [];
                          if (newValue != null) {
                            _fetchBanks(newValue.id);
                          }
                        });
                      },
                      validator: (value) => value == null ? 'Selecione um tipo de empréstimo' : null,
                    ),
                    const SizedBox(height: 16),
                    if (_selectedLoanType != null)
                      DropdownButtonFormField<Bank>(
                        value: _selectedBank,
                        decoration: const InputDecoration(labelText: 'Banco'),
                        items: _banks.map((bank) {
                          return DropdownMenuItem<Bank>(
                            value: bank,
                            child: Text(bank.name),
                          );
                        }).toList(),
                        onChanged: (Bank? newValue) {
                          setState(() {
                            _selectedBank = newValue;
                          });
                        },
                        validator: (value) => value == null ? 'Selecione um banco' : null,
                      ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Valor do Empréstimo'),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty || double.tryParse(value) == null || double.parse(value) <= 0) {
                          return 'Insira um valor válido';
                        }
                        return null;
                      },
                      onSaved: (value) => _loanAmount = double.tryParse(value!),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Prazo do Empréstimo',
                        suffix: Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Text(_loanTermType == LoanTermType.months ? 'Meses' : 'Anos'),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty || int.tryParse(value) == null || int.parse(value) <= 0) {
                          return 'Insira um prazo válido';
                        }
                        return null;
                      },
                      onSaved: (value) => _loanTerm = int.tryParse(value!),
                    ),
                    const SizedBox(height: 8),
                    SegmentedButton<LoanTermType>(
                      segments: const [
                        ButtonSegment<LoanTermType>(
                          value: LoanTermType.months,
                          label: Text('Meses'),
                        ),
                        ButtonSegment<LoanTermType>(
                          value: LoanTermType.years,
                          label: Text('Anos'),
                        ),
                      ],
                      selected: {_loanTermType},
                      onSelectionChanged: (newSelection) {
                        setState(() {
                          _loanTermType = newSelection.first;
                        });
                      },
                    ),

                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _calculatePayment,
                      child: const Text('Calcular'),
                      style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                    ),
                    const SizedBox(height: 24),

                    if (_monthlyPayment != null && _totalPayment != null)
                      Card(
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Resultado da Simulação', style: theme.textTheme.titleLarge),
                              const Divider(height: 20),
                              ListTile(
                                title: const Text('Pagamento Mensal'),
                                trailing: Text(
                                  currencyFormatter.format(_monthlyPayment),
                                  style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                                ),
                              ),
                              ListTile(
                                title: const Text('Pagamento Total'),
                                trailing: Text(
                                  currencyFormatter.format(_totalPayment),
                                   style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                                ),
                              ),
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
