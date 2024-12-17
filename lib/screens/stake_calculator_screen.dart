import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/arbitrage_provider.dart';

class StakeCalculatorScreen extends StatefulWidget {
  const StakeCalculatorScreen({super.key});

  @override
  State<StakeCalculatorScreen> createState() => _StakeCalculatorScreenState();
}

class _StakeCalculatorScreenState extends State<StakeCalculatorScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _totalStakeController = TextEditingController();
  final List<TextEditingController> _oddsControllers = [];
  final List<TextEditingController> _bookmakerControllers = [];
  bool _showResults = false;
  Map<String, double> _results = {};

  @override
  void initState() {
    super.initState();
    _addOutcome();
    _addOutcome();
    final arbitrageProvider = context.read<ArbitrageProvider>();
    _totalStakeController.text = arbitrageProvider.totalStake.toString();
  }

  @override
  void dispose() {
    _totalStakeController.dispose();
    for (var controller in _oddsControllers) {
      controller.dispose();
    }
    for (var controller in _bookmakerControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addOutcome() {
    setState(() {
      _oddsControllers.add(TextEditingController());
      _bookmakerControllers.add(TextEditingController());
    });
  }

  void _removeOutcome(int index) {
    setState(() {
      _oddsControllers[index].dispose();
      _bookmakerControllers[index].dispose();
      _oddsControllers.removeAt(index);
      _bookmakerControllers.removeAt(index);
    });
  }

  void _calculateStakes() {
    if (_formKey.currentState!.validate()) {
      final totalStake = double.parse(_totalStakeController.text);
      final List<double> odds = _oddsControllers
          .map((controller) => double.parse(controller.text))
          .toList();

      double totalProbability = 0;
      List<double> individualProbabilities = [];

      // Calculate individual probabilities
      for (double odd in odds) {
        double probability = 1 / odd;
        totalProbability += probability;
        individualProbabilities.add(probability);
      }

      // Check if there's an arbitrage opportunity
      if (totalProbability < 1) {
        Map<String, double> results = {};
        double totalReturn = 0;

        // Calculate stakes and returns for each outcome
        for (int i = 0; i < odds.length; i++) {
          double stake = (totalStake * individualProbabilities[i]) / totalProbability;
          double return_ = stake * odds[i];
          results['stake${i + 1}'] = stake;
          results['return${i + 1}'] = return_;
          totalReturn = return_; // All returns should be equal in a perfect arbitrage
        }

        // Calculate profit and ROI
        double profit = totalReturn - totalStake;
        double roi = (profit / totalStake) * 100;

        results['profit'] = profit;
        results['roi'] = roi;

        setState(() {
          _results = results;
          _showResults = true;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No arbitrage opportunity found with these odds'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stake Calculator'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Investment',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _totalStakeController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Total Stake',
                            prefixText: '\$',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter total stake';
                            }
                            final number = double.tryParse(value);
                            if (number == null || number <= 0) {
                              return 'Please enter a valid amount';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Outcomes',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            TextButton.icon(
                              onPressed: _addOutcome,
                              icon: const Icon(Icons.add),
                              label: const Text('Add Outcome'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ..._oddsControllers.asMap().entries.map((entry) {
                          final index = entry.key;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _bookmakerControllers[index],
                                    decoration: InputDecoration(
                                      labelText: 'Bookmaker ${index + 1}',
                                      border: const OutlineInputBorder(),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Required';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextFormField(
                                    controller: _oddsControllers[index],
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      labelText: 'Odds ${index + 1}',
                                      border: const OutlineInputBorder(),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Required';
                                      }
                                      final number = double.tryParse(value);
                                      if (number == null || number <= 1) {
                                        return 'Invalid odds';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                if (_oddsControllers.length > 2)
                                  IconButton(
                                    icon: const Icon(Icons.remove_circle_outline),
                                    onPressed: () => _removeOutcome(index),
                                    color: Colors.red,
                                  ),
                              ],
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _calculateStakes,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                  ),
                  child: const Text('Calculate Stakes'),
                ),
                if (_showResults && _results.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Card(
                    color: Colors.green[50],
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Results',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 16),
                          ..._bookmakerControllers.asMap().entries.map((entry) {
                            final index = entry.key;
                            final stake = _results['stake${index + 1}'];
                            final return_ = _results['return${index + 1}'];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(_bookmakerControllers[index].text),
                                  Text(
                                    '\$${stake?.toStringAsFixed(2)} → \$${return_?.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Total Investment:'),
                              Text(
                                '\$${_totalStakeController.text}',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Expected Profit:'),
                              Text(
                                '\$${_results['profit']?.toStringAsFixed(2)}',
                                style: TextStyle(
                                  color: Colors.green[700],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('ROI:'),
                              Text(
                                '${_results['roi']?.toStringAsFixed(2)}%',
                                style: TextStyle(
                                  color: Colors.green[700],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
