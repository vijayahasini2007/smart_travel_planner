import '../models/destination.dart';

class ItineraryService {
  static List<String> generateItinerary(Destination destination) {
    return [
      'Visit ${destination.popularPlaces[0]}',
      'Explore ${destination.popularPlaces[1]}',
      'Enjoy local food and culture',
      'Visit ${destination.popularPlaces[2]}',
    ];
  }
}