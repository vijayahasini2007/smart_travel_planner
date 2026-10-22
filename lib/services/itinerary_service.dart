
import '../models/destination.dart';

class ItineraryService {
  static List<String> generateItinerary(
    Destination destination, {
    required int numberOfDays,
  }) {
    if (numberOfDays < 1) return [];

    final places = destination.popularPlaces;

    return List.generate(numberOfDays, (index) {
      final day = index + 1;

      if (places.isEmpty) {
        return 'Day $day: Explore ${destination.name} and discover local attractions.';
      }

      final place = places[index % places.length];

      switch (index % 4) {
        case 0:
          return 'Day $day: Visit $place and explore the surrounding area.';
        case 1:
          return 'Day $day: Discover local culture and attractions near $place.';
        case 2:
          return 'Day $day: Enjoy local food and sightseeing around $place.';
        default:
          return 'Day $day: Explore more of ${destination.name} and visit $place.';
      }
    });
  }
}
