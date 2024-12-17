import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/arbitrage_provider.dart';

class EventDetailScreen extends StatelessWidget {
  final String homeTeam;
  final String awayTeam;
  final String date;
  final Map<String, double>? odds;

  const EventDetailScreen({
    super.key,
    required this.homeTeam,
    required this.awayTeam,
    required this.date,
    this.odds,
  });

  @override
  Widget build(BuildContext context) {
    final arbitrageProvider = Provider.of<ArbitrageProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Details'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$homeTeam vs $awayTeam',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Date: $date',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 24),
              if (odds != null) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Odds Analysis',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        Table(
                          border: TableBorder.all(
                            color: Colors.grey.shade300,
                            width: 1,
                          ),
                          children: [
                            TableRow(
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor.withOpacity(0.1),
                              ),
                              children: const [
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text('Bookmaker'),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text('Odds'),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text('Implied Prob.'),
                                ),
                              ],
                            ),
                            ...odds!.entries.map((entry) {
                              final impliedProb = (1 / entry.value) * 100;
                              return TableRow(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(entry.key),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(entry.value.toStringAsFixed(2)),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text('${impliedProb.toStringAsFixed(1)}%'),
                                  ),
                                ],
                              );
                            }).toList(),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Arbitrage Calculator',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                initialValue: arbitrageProvider.totalStake.toString(),
                                decoration: const InputDecoration(
                                  labelText: 'Total Stake',
                                  border: OutlineInputBorder(),
                                  prefixText: '\$',
                                ),
                                keyboardType: TextInputType.number,
                                onChanged: (value) {
                                  if (value.isNotEmpty) {
                                    arbitrageProvider.setTotalStake(double.parse(value));
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            ElevatedButton(
                              onPressed: () {
                                arbitrageProvider.calculateStakes(
                                  odds!.values.toList(),
                                );
                              },
                              child: const Text('Calculate'),
                            ),
                          ],
                        ),
                        if (arbitrageProvider.currentCalculation != null) ...[
                          const SizedBox(height: 16),
                          Card(
                            color: Colors.green[50],
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Recommended Stakes',
                                    style: Theme.of(context).textTheme.titleMedium,
                                  ),
                                  const SizedBox(height: 8),
                                  ...odds!.keys.toList().asMap().entries.map((entry) {
                                    final stake = arbitrageProvider
                                        .currentCalculation!['stake${entry.key + 1}'];
                                    final return_ = arbitrageProvider
                                        .currentCalculation!['return${entry.key + 1}'];
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 4),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(entry.value),
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
                                      const Text('Expected Profit:'),
                                      Text(
                                        '\$${arbitrageProvider.currentCalculation!['profit']?.toStringAsFixed(2)} (${arbitrageProvider.currentCalculation!['profitPercentage']?.toStringAsFixed(2)}%)',
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
              ] else
                const Center(
                  child: Text('No odds data available for this event.'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
