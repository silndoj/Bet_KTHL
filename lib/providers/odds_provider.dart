import 'package:flutter/foundation.dart';

class OddsProvider extends ChangeNotifier {
  final List<Map<String, dynamic>> _odds = [];
  String _selectedSport = 'All';
  String _selectedBookmaker = 'All';
  DateTime _lastUpdate = DateTime(2024, 12, 16, 1, 39, 43);

  List<Map<String, dynamic>> get odds => _odds;
  String get selectedSport => _selectedSport;
  String get selectedBookmaker => _selectedBookmaker;
  DateTime get lastUpdate => _lastUpdate;

  void updateOdds(List<Map<String, dynamic>> newOdds) {
    _odds.clear();
    _odds.addAll(newOdds);
    _lastUpdate = DateTime(2024, 12, 16, 1, 39, 43);
    notifyListeners();
  }

  void setSelectedSport(String sport) {
    _selectedSport = sport;
    notifyListeners();
  }

  void setSelectedBookmaker(String bookmaker) {
    _selectedBookmaker = bookmaker;
    notifyListeners();
  }

  List<Map<String, dynamic>> getFilteredOdds() {
    return _odds.where((odd) {
      bool matchesSport = _selectedSport == 'All' || odd['sport'] == _selectedSport;
      bool matchesBookmaker = _selectedBookmaker == 'All' || 
          odd['bookmaker'] == _selectedBookmaker;
      return matchesSport && matchesBookmaker;
    }).toList();
  }

  double calculateImpliedProbability(double decimalOdds) {
    return (1 / decimalOdds) * 100;
  }

  bool hasArbitrageOpportunity(List<double> odds) {
    double sum = 0;
    for (double odd in odds) {
      sum += 1 / odd;
    }
    return sum < 1;
  }
}
