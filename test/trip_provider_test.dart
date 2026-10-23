
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_travel_planner/providers/trip_provider.dart';

void main() {
  group('TripProvider Tests', () {
    late TripProvider provider;

    setUp(() {
      provider = TripProvider();
    });

    test('Initial values are set correctly', () {
      expect(provider.destination, '');
      expect(provider.travelMode, 'Flight');
      expect(provider.numberOfTravelers, 1);
      expect(provider.budget, 0);
      expect(provider.budgetCategory, 'Medium');
      expect(provider.preferences, isEmpty);
      expect(provider.itinerary, isEmpty);
    });

    test('updateDestination updates the destination', () {
      provider.updateDestination('Hyderabad');

      expect(provider.destination, 'Hyderabad');
    });

    test('updateTravelMode updates the travel mode', () {
      provider.updateTravelMode('Train');

      expect(provider.travelMode, 'Train');
    });

    test('updateNumberOfTravelers updates traveler count', () {
      provider.updateNumberOfTravelers(4);

      expect(provider.numberOfTravelers, 4);
    });

    test('updateBudget updates the budget', () {
      provider.updateBudget(15000);

      expect(provider.budget, 15000);
    });

    test('updateItinerary saves the itinerary', () {
      final itinerary = ['Day 1: Sightseeing', 'Day 2: Shopping'];

      provider.updateItinerary(itinerary);

      expect(provider.itinerary, itinerary);
    });

    test('clearTrip resets trip information', () {
      provider.updateDestination('Hyderabad');
      provider.updateTravelMode('Train');
      provider.updateNumberOfTravelers(4);
      provider.updateBudget(15000);
      provider.updateItinerary(['Day 1: Sightseeing']);

      provider.clearTrip();

      expect(provider.destination, '');
      expect(provider.travelMode, 'Flight');
      expect(provider.numberOfTravelers, 1);
      expect(provider.budget, 0);
      expect(provider.budgetCategory, 'Medium');
      expect(provider.preferences, isEmpty);
      expect(provider.itinerary, isEmpty);
    });
  });
}
