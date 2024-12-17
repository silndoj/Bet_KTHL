import 'package:flutter/foundation.dart';

class ArbitrageProvider extends ChangeNotifier {
  final List<Map<String, dynamic>> _opportunities = [];
  double _totalStake = 1000.0;
  Map<String, double>? _currentCalculation;

  List<Map<String, dynamic>> get opportunities => _opportunities;
  double get totalStake => _totalStake;
  Map<String, double>? get currentCalculation => _currentCalculation;

  void updateOpportunities(List<Map<String, dynamic>> newOpportunities) {
    _opportunities.clear();
    _opportunities.addAll(newOpportunities);
    notifyListeners();
  }

  void setTotalStake(double stake) {
    _totalStake = stake;
    notifyListeners();
  }

  void calculateStakes(List<double> odds) {
    double totalPercentage = 0;
    List<double> individualPercentages = [];
    Map<String, double> result = {};

    // Calculate total percentage and individual percentages
    for (double odd in odds) {
      double percentage = 1 / odd;
      totalPercentage += percentage;
      individualPercentages.add(percentage);
    }

    // If there's an arbitrage opportunity
    if (totalPercentage < 1) {
      for (int i = 0; i < odds.length; i++) {
        double stake = (_totalStake * individualPercentages[i]) / totalPercentage;
        result['stake${i + 1}'] = stake;
        result['return${i + 1}'] = stake * odds[i];
      }
      result['profit'] = (result['return1'] ?? 0) - _totalStake;
      result['profitPercentage'] = (result['profit'] ?? 0) / _totalStake * 100;
    }

    _currentCalculation = result;
    notifyListeners();
  }

  void clearCalculation() {
    _currentCalculation = null;
    notifyListeners();
  }

  double calculateArbitragePercentage(List<double> odds) {
    double sum = 0;
    for (double odd in odds) {
      sum += 1 / odd;
    }
    return (1 - sum) * 100;
  }
}
