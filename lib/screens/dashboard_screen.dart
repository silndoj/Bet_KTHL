import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/event_card.dart';
import '../widgets/custom_filter_chip.dart';
import '../providers/odds_provider.dart';
import 'stake_calculator_screen.dart';
import 'settings_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final List<String> _sports = ['Football', 'Basketball', 'Tennis', 'Baseball'];
  final List<String> _bookmakers = ['Bet365', 'DraftKings', 'FanDuel', 'BetMGM'];
  String? _selectedSport;
  String? _selectedBookmaker;
  bool _isRefreshing = false;

  Future<void> _refreshOpportunities() async {
    setState(() {
      _isRefreshing = true;
    });

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      if (!mounted) return;

      // Mock data for demonstration
      final opportunities = [
        {
          'sport': 'Football',
          'league': 'Premier League',
          'homeTeam': 'Arsenal',
          'awayTeam': 'Chelsea',
          'date': '2024-12-16 20:00',
          'profit': '2.5',
          'odds': {
            'Bet365': 2.10,
            'DraftKings': 1.95,
            'FanDuel': 2.05,
          },
        },
        {
          'sport': 'Basketball',
          'league': 'NBA',
          'homeTeam': 'Lakers',
          'awayTeam': 'Warriors',
          'date': '2024-12-16 22:30',
          'profit': '1.8',
          'odds': {
            'BetMGM': 1.90,
            'DraftKings': 2.00,
            'FanDuel': 1.85,
          },
        },
      ];

      context.read<OddsProvider>().updateOdds(opportunities);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to refresh opportunities'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _refreshOpportunities();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Arbitrage Opportunities'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calculate),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const StakeCalculatorScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<OddsProvider>(
        builder: (context, oddsProvider, child) {
          final opportunities = oddsProvider.odds;

          return RefreshIndicator(
            onRefresh: _refreshOpportunities,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Filters',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            const SizedBox(width: 4),
                            CustomFilterChip(
                              label: const Text('All Sports'),
                              selected: _selectedSport == null,
                              onSelected: (selected) {
                                setState(() {
                                  _selectedSport = selected ? null : _selectedSport;
                                });
                              },
                            ),
                            ..._sports.map((sport) {
                              return Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: CustomFilterChip(
                                  label: Text(sport),
                                  selected: _selectedSport == sport,
                                  onSelected: (selected) {
                                    setState(() {
                                      _selectedSport = selected ? sport : null;
                                    });
                                  },
                                ),
                              );
                            }).toList(),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            const SizedBox(width: 4),
                            CustomFilterChip(
                              label: const Text('All Bookmakers'),
                              selected: _selectedBookmaker == null,
                              onSelected: (selected) {
                                setState(() {
                                  _selectedBookmaker =
                                      selected ? null : _selectedBookmaker;
                                });
                              },
                            ),
                            ..._bookmakers.map((bookmaker) {
                              return Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: CustomFilterChip(
                                  label: Text(bookmaker),
                                  selected: _selectedBookmaker == bookmaker,
                                  onSelected: (selected) {
                                    setState(() {
                                      _selectedBookmaker =
                                          selected ? bookmaker : null;
                                    });
                                  },
                                ),
                              );
                            }).toList(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _isRefreshing && opportunities.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : opportunities.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.search_off,
                                    size: 64,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No arbitrage opportunities found',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 16,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: _refreshOpportunities,
                                    child: const Text('Refresh'),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(8),
                              itemCount: opportunities.length,
                              itemBuilder: (context, index) {
                                final opportunity = opportunities[index];
                                if (_selectedSport != null &&
                                    opportunity['sport'] != _selectedSport) {
                                  return const SizedBox.shrink();
                                }
                                if (_selectedBookmaker != null &&
                                    !opportunity['odds']
                                        .containsKey(_selectedBookmaker)) {
                                  return const SizedBox.shrink();
                                }
                                return EventCard(
                                  homeTeam: opportunity['homeTeam'] as String,
                                  awayTeam: opportunity['awayTeam'] as String,
                                  date: opportunity['date'] as String,
                                  profit: opportunity['profit'] as String,
                                  sport: opportunity['sport'] as String,
                                  league: opportunity['league'] as String,
                                  odds: Map<String, double>.from(
                                      opportunity['odds'] as Map),
                                );
                              },
                            ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _refreshOpportunities,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
