
import 'package:flutter/foundation.dart';

class TripProvider extends ChangeNotifier {
  String _destination = '';
  String _travelMode = 'Flight';
  int _numberOfTravelers = 1;
  double _budget = 0;
  String _budgetCategory = 'Medium';
  List<String> _preferences = [];
  DateTime? _startDate;
  DateTime? _endDate;
  List<String> _itinerary = [];

  String get destination => _destination;
  String get travelMode => _travelMode;
  int get numberOfTravelers => _numberOfTravelers;
  double get budget => _budget;
  String get budgetCategory => _budgetCategory;
  List<String> get preferences => List.unmodifiable(_preferences);
  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;
  List<String> get itinerary => List.unmodifiable(_itinerary);

  void updateTrip({
    required String destination,
    required String travelMode,
    required int numberOfTravelers,
    required double budget,
    required String budgetCategory,
    required List<String> preferences,
    required DateTime startDate,
    required DateTime endDate,
    required List<String> itinerary,
  }) {
    _destination = destination;
    _travelMode = travelMode;
    _numberOfTravelers = numberOfTravelers;
    _budget = budget;
    _budgetCategory = budgetCategory;
    _preferences = List<String>.of(preferences);
    _startDate = startDate;
    _endDate = endDate;
    _itinerary = List<String>.of(itinerary);

    notifyListeners();
  }

  void updateDestination(String value) {
    _destination = value;
    notifyListeners();
  }

  void updateTravelMode(String value) {
    _travelMode = value;
    notifyListeners();
  }

  void updateNumberOfTravelers(int value) {
    if (value < 1) return;
    _numberOfTravelers = value;
    notifyListeners();
  }

  void updateBudget(double value) {
    if (value < 0) return;
    _budget = value;
    notifyListeners();
  }

  void updateItinerary(List<String> value) {
    _itinerary = List<String>.of(value);
    notifyListeners();
  }

  void clearTrip() {
    _destination = '';
    _travelMode = 'Flight';
    _numberOfTravelers = 1;
    _budget = 0;
    _budgetCategory = 'Medium';
    _preferences = [];
    _startDate = null;
    _endDate = null;
    _itinerary = [];

    notifyListeners();
  }
}
