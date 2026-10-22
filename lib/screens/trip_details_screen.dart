
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../models/destination.dart';
import '../services/itinerary_service.dart';
import 'itinerary_screen.dart';

class TripDetailsScreen extends StatefulWidget {
  const TripDetailsScreen({super.key});

  @override
  State<TripDetailsScreen> createState() =>
      _TripDetailsScreenState();
}

class _TripDetailsScreenState extends State<TripDetailsScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController destinationController =
      TextEditingController();

  final TextEditingController travelersController =
      TextEditingController();

  final TextEditingController budgetController =
      TextEditingController();

  DateTime? startDate;
  DateTime? endDate;

  String? startDateError;
  String? endDateError;

  String selectedBudget = 'Medium';
  String selectedTravelMode = 'Flight';

  final List<String> preferences = [
    'Sightseeing',
    'Food',
    'Adventure',
    'Nature',
    'Shopping',
    'Culture',
  ];

  final Set<String> selectedPreferences = {};

  final List<String> travelModes = [
    'Flight',
    'Train',
    'Bus',
    'Car',
  ];

  @override
  void dispose() {
    destinationController.dispose();
    travelersController.dispose();
    budgetController.dispose();
    super.dispose();
  }

  Future<void> selectStartDate() async {
    final now = DateTime.now();
    final initialDate = startDate != null &&
            !startDate!.isBefore(
              DateTime(now.year, now.month, now.day),
            )
        ? startDate!
        : now;

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(2035),
    );

    if (pickedDate == null || !mounted) return;

    setState(() {
      startDate = pickedDate;
      startDateError = null;

      if (endDate != null && endDate!.isBefore(pickedDate)) {
        endDate = null;
        endDateError = 'Please select a valid end date.';
      } else {
        endDateError = null;
      }
    });
  }

  Future<void> selectEndDate() async {
    if (startDate == null) {
      setState(() {
        startDateError = 'Please select a start date first.';
      });
      return;
    }

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: endDate ?? startDate!,
      firstDate: startDate!,
      lastDate: DateTime(2035),
    );

    if (pickedDate == null || !mounted) return;

    setState(() {
      endDate = pickedDate;
      endDateError = null;
    });
  }

  void generateItinerary() {
    FocusScope.of(context).unfocus();

    final formIsValid = _formKey.currentState!.validate();

    setState(() {
      startDateError = startDate == null
          ? 'Please select a start date.'
          : null;

      endDateError = endDate == null
          ? 'Please select an end date.'
          : startDate != null && endDate!.isBefore(startDate!)
              ? 'End date cannot be before start date.'
              : null;
    });

    if (!formIsValid ||
        startDateError != null ||
        endDateError != null) {
      return;
    }

    final destinationName = destinationController.text.trim();
    final budget = double.parse(budgetController.text.trim());

    final destination = Destination(
      name: destinationName,
      description: 'A travel plan for $destinationName.',
      averageCost: budget,
      popularPlaces: [
        'Main Tourist Attraction',
        'Local Market',
        'Famous Landmark',
      ],
    );

    final itinerary = ItineraryService.generateItinerary(
      destination,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ItineraryScreen(
          destination: destination.name,
          travelMode: selectedTravelMode,
          itinerary: itinerary,
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  Widget _dateSelector({
    required String title,
    required DateTime? date,
    required String placeholder,
    required VoidCallback onTap,
    required String? error,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(title),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 17,
            ),
            decoration: BoxDecoration(
              border: Border.all(
                color: error == null
                    ? Colors.grey.shade500
                    : Theme.of(context).colorScheme.error,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    date == null
                        ? placeholder
                        : DateFormat('dd MMM yyyy').format(date),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (error != null) ...[
          const SizedBox(height: 6),
          Text(
            error,
            style: TextStyle(
              color: Theme.of(context).colorScheme.error,
              fontSize: 12,
            ),
          ),
        ],
      ],
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

  IconData _getTravelModeIcon(String mode) {
    switch (mode) {
      case 'Flight':
        return Icons.flight;
      case 'Train':
        return Icons.train;
      case 'Bus':
        return Icons.directions_bus;
      case 'Car':
        return Icons.directions_car;
      default:
        return Icons.travel_explore;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trip Details'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
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

                  _sectionTitle('Destination'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: destinationController,
                    textCapitalization: TextCapitalization.words,
                    decoration: _inputDecoration(
                      hint: 'Enter destination',
                      icon: Icons.location_on,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a destination.';
                      }
                      if (value.trim().length < 2) {
                        return 'Destination must be at least 2 characters.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 22),

                  _sectionTitle('Number of Travelers'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: travelersController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    decoration: _inputDecoration(
                      hint: 'Enter number of travelers',
                      icon: Icons.people,
                    ),
                    validator: (value) {
                      final count = int.tryParse(value ?? '');
                      if (count == null || count < 1) {
                        return 'Enter at least 1 traveler.';
                      }
                      if (count > 100) {
                        return 'Maximum 100 travelers allowed.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 22),

                  _dateSelector(
                    title: 'Start Date',
                    date: startDate,
                    placeholder: 'Select start date',
                    onTap: selectStartDate,
                    error: startDateError,
                  ),
                  const SizedBox(height: 22),

                  _dateSelector(
                    title: 'End Date',
                    date: endDate,
                    placeholder: 'Select end date',
                    onTap: selectEndDate,
                    error: endDateError,
                  ),
                  const SizedBox(height: 22),

                  _sectionTitle('Budget Amount (₹)'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: budgetController,
                    keyboardType:
                        const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^\d*\.?\d{0,2}'),
                      ),
                    ],
                    decoration: _inputDecoration(
                      hint: 'Enter your total budget',
                      icon: Icons.currency_rupee,
                    ),
                    validator: (value) {
                      final amount = double.tryParse(
                        value?.trim() ?? '',
                      );
                      if (amount == null || amount <= 0) {
                        return 'Enter a budget greater than ₹0.';
                      }
                      if (!amount.isFinite || amount > 1000000000) {
                        return 'Enter a valid budget amount.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 22),

                  _sectionTitle('Budget Category'),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    children: ['Low', 'Medium', 'High'].map((budget) {
                      return ChoiceChip(
                        label: Text(budget),
                        selected: selectedBudget == budget,
                        onSelected: (_) {
                          setState(() {
                            selectedBudget = budget;
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 25),

                  _sectionTitle('Travel Preferences'),
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
                      final isSelected =
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
                  const SizedBox(height: 25),

                  _sectionTitle('Travel Mode'),
                  const SizedBox(height: 8),
                  Text(
                    'Choose how you want to travel.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  RadioGroup<String>(
  groupValue: selectedTravelMode,
  onChanged: (value) {
    if (value == null) return;
    setState(() {
      selectedTravelMode = value;
    });
  },
  child: Column(
    children: travelModes.map((mode) {
      return RadioListTile<String>(
        value: mode,
        title: Text(mode),
        secondary: Icon(_getTravelModeIcon(mode)),
        contentPadding: EdgeInsets.zero,
      );
    }).toList(),
  ),
),
                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton.icon(
                      onPressed: generateItinerary,
                      icon: const Icon(Icons.auto_awesome),
                      label: const Text(
                        'Generate Itinerary',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
