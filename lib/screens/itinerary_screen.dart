
import 'package:flutter/material.dart';

class ItineraryScreen extends StatelessWidget {
  final String destination;
  final String travelMode;
  final List<String> itinerary;

  const ItineraryScreen({
    super.key,
    required this.destination,
    required this.travelMode,
    required this.itinerary,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Itinerary'),
        centerTitle: true,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWideScreen = constraints.maxWidth >= 700;

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: Padding(
                padding: EdgeInsets.all(isWideScreen ? 32 : 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(isWideScreen ? 28 : 20),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: isWideScreen ? 32 : 26,
                              backgroundColor: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer,
                              child: Icon(
                                Icons.location_on,
                                size: isWideScreen ? 34 : 28,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    destination,
                                    style: TextStyle(
                                      fontSize: isWideScreen ? 30 : 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.flight_takeoff,
                                        color: Colors.blue,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Flexible(
                                        child: Text(
                                          'Travel mode: $travelMode',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyLarge,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    Text(
                      'Day-wise Travel Plan',
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: itinerary.isEmpty
                          ? const Center(
                              child: Text('No itinerary available yet.'),
                            )
                          : ListView.builder(
                              itemCount: itinerary.length,
                              itemBuilder: (context, index) {
                                return DayItineraryCard(
                                  dayNumber: index + 1,
                                  activity: itinerary[index],
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// Reusable custom widget for displaying one day's activities.
class DayItineraryCard extends StatelessWidget {
  final int dayNumber;
  final String activity;

  const DayItineraryCard({
    super.key,
    required this.dayNumber,
    required this.activity,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: ListTile(
          contentPadding: EdgeInsets.zero,
          leading: CircleAvatar(
            radius: 23,
            backgroundColor: colorScheme.primary,
            child: Text(
              '$dayNumber',
              style: TextStyle(
                color: colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          title: Text(
            'Day $dayNumber',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              activity,
              style: const TextStyle(height: 1.4),
            ),
          ),
        ),
      ),
    );
  }
}
