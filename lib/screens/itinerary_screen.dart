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
        title: const Text("Your Itinerary"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              destination,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Row(
              children: [
                const Icon(Icons.flight_takeoff, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  travelMode,
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),

            const SizedBox(height: 25),

            const Text(
              "Day-wise Travel Plan",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            Expanded(
              child: ListView.builder(
                itemCount: itinerary.length,
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 3,
                    margin: const EdgeInsets.only(bottom: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue,
                        child: Text(
                          "${index + 1}",
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text("Day ${index + 1}"),
                      subtitle: Text(itinerary[index]),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}