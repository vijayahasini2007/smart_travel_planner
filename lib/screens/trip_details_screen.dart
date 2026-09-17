import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TripDetailsScreen extends StatefulWidget {
  const TripDetailsScreen({super.key});

  @override
  State<TripDetailsScreen> createState() => _TripDetailsScreenState();
}

class _TripDetailsScreenState extends State<TripDetailsScreen> {
  final TextEditingController destinationController =
      TextEditingController();

  final TextEditingController travelersController =
      TextEditingController();

  final TextEditingController budgetController =
      TextEditingController();

  DateTime? startDate;
  DateTime? endDate;

  String selectedBudget = 'Medium';

  final List<String> preferences = [
    'Sightseeing',
    'Food',
    'Adventure',
    'Nature',
    'Shopping',
    'Culture',
  ];

  final Set<String> selectedPreferences = {};

  Future<void> selectStartDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );

    if (pickedDate != null) {
      setState(() {
        startDate = pickedDate;

        if (endDate != null && endDate!.isBefore(pickedDate)) {
          endDate = null;
        }
      });
    }
  }

  Future<void> selectEndDate() async {
    if (startDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select the start date first.'),
        ),
      );
      return;
    }

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: startDate!,
      firstDate: startDate!,
      lastDate: DateTime(2030),
    );

    if (pickedDate != null) {
      setState(() {
        endDate = pickedDate;
      });
    }
  }

  @override
  void dispose() {
    destinationController.dispose();
    travelersController.dispose();
    budgetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trip Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Plan Your Trip',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Enter some basic details about your trip.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade700,
              ),
            ),

            const SizedBox(height: 30),

            // Destination
            const Text(
              'Destination',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: destinationController,
              decoration: InputDecoration(
                hintText: 'Enter destination',
                prefixIcon: const Icon(Icons.location_on),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 22),

            // Travelers
            const Text(
              'Number of Travelers',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: travelersController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Enter number of travelers',
                prefixIcon: const Icon(Icons.people),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 22),

            // Start Date
            const Text(
              'Start Date',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            GestureDetector(
              onTap: selectStartDate,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 17,
                ),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey.shade500,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today),
                    const SizedBox(width: 12),
                    Text(
                      startDate == null
                          ? 'Select start date'
                          : DateFormat('dd MMM yyyy')
                              .format(startDate!),
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 22),

            // End Date
            const Text(
              'End Date',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            GestureDetector(
              onTap: selectEndDate,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 17,
                ),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey.shade500,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today),
                    const SizedBox(width: 12),
                    Text(
                      endDate == null
                          ? 'Select end date'
                          : DateFormat('dd MMM yyyy')
                              .format(endDate!),
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 22),

            // Budget
            const Text(
              'Budget Amount',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: budgetController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Enter your budget',
                prefixIcon: const Icon(Icons.currency_rupee),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 22),

            const Text(
              'Budget Category',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Wrap(
              spacing: 10,
              children: [
                ChoiceChip(
                  label: const Text('Low'),
                  selected: selectedBudget == 'Low',
                  onSelected: (selected) {
                    setState(() {
                      selectedBudget = 'Low';
                    });
                  },
                ),
                ChoiceChip(
                  label: const Text('Medium'),
                  selected: selectedBudget == 'Medium',
                  onSelected: (selected) {
                    setState(() {
                      selectedBudget = 'Medium';
                    });
                  },
                ),
                ChoiceChip(
                  label: const Text('High'),
                  selected: selectedBudget == 'High',
                  onSelected: (selected) {
                    setState(() {
                      selectedBudget = 'High';
                    });
                  },
                ),
              ],
            ),

            const SizedBox(height: 25),

            // Travel Preferences
            const Text(
              'Travel Preferences',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Select what you are interested in.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
            ),

            const SizedBox(height: 12),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: preferences.map((preference) {
                final bool isSelected =
                    selectedPreferences.contains(preference);

                return FilterChip(
                  label: Text(preference),
                  selected: isSelected,
                  avatar: Icon(
                    _getPreferenceIcon(preference),
                    size: 18,
                  ),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        selectedPreferences.add(preference);
                      } else {
                        selectedPreferences.remove(preference);
                      }
                    });
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 30),

            // Continue button
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  FocusScope.of(context).unfocus();

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Travel preferences selected!',
                      ),
                    ),
                  );
                },
                child: const Text(
                  'Continue',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getPreferenceIcon(String preference) {
    switch (preference) {
      case 'Sightseeing':
        return Icons.location_city;
      case 'Food':
        return Icons.restaurant;
      case 'Adventure':
        return Icons.hiking;
      case 'Nature':
        return Icons.forest;
      case 'Shopping':
        return Icons.shopping_bag;
      case 'Culture':
        return Icons.museum;
      default:
        return Icons.star;
    }
  }
}