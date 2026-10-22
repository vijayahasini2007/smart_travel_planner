import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../models/destination.dart';
import '../services/itinerary_service.dart';
import 'itinerary_screen.dart';

class TripDetailsScreen extends StatefulWidget {
  const TripDetailsScreen({super.key});

  @override
  State<TripDetailsScreen> createState() => _TripDetailsScreenState();
}

class _TripDetailsScreenState extends State<TripDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final destinationController = TextEditingController();
  final travelersController = TextEditingController();
  final budgetController = TextEditingController();

  DateTime? startDate;
  DateTime? endDate;
  String? startDateError;
  String? endDateError;

  String selectedBudget = 'Medium';
  String selectedTravelMode = 'Flight';
  bool isGenerating = false;

  final List<String> preferences = [
    'Sightseeing',
    'Food',
    'Adventure',
    'Nature',
    'Shopping',
    'Culture',
  ];
  final Set<String> selectedPreferences = {};
  final List<String> travelModes = ['Flight', 'Train', 'Bus', 'Car'];

  @override
  void dispose() {
    destinationController.dispose();
    travelersController.dispose();
    budgetController.dispose();
    super.dispose();
  }

  Future<void> selectStartDate() async {
    final today = DateUtils.dateOnly(DateTime.now());
    final initialDate = startDate != null &&
            !DateUtils.dateOnly(startDate!).isBefore(today)
        ? startDate!
        : today;

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: today,
      lastDate: DateTime(2035, 12, 31),
      helpText: 'SELECT START DATE',
    );

    if (pickedDate == null || !mounted) return;

    setState(() {
      startDate = DateUtils.dateOnly(pickedDate);
      startDateError = null;
      if (endDate != null &&
          !DateUtils.dateOnly(endDate!).isAfter(startDate!)) {
        endDate = null;
        endDateError = 'Choose an end date after the start date.';
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

    final earliestEndDate =
        DateUtils.dateOnly(startDate!.add(const Duration(days: 1)));
    final lastDate = DateTime(2035, 12, 31);

    if (earliestEndDate.isAfter(lastDate)) {
      setState(() => endDateError = 'No later date is available.');
      return;
    }

    final initialDate = endDate != null &&
            DateUtils.dateOnly(endDate!).isAfter(startDate!)
        ? endDate!
        : earliestEndDate;

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: earliestEndDate,
      lastDate: lastDate,
      helpText: 'SELECT END DATE',
    );

    if (pickedDate == null || !mounted) return;
    setState(() {
      endDate = DateUtils.dateOnly(pickedDate);
      endDateError = null;
    });
  }

    
Future<bool> _isValidDestination(String name) async {
  final input =
      name.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');

  if (input.isEmpty) return false;

  // Search both settlements (such as Hyderabad) and states (such as Goa).
  for (final featureType in ['settlement', 'state']) {
    final uri = Uri.https(
      'nominatim.openstreetmap.org',
      '/search',
      {
        'q': name.trim(),
        'format': 'jsonv2',
        'addressdetails': '1',
        'limit': '5',
        'featureType': featureType,
        'countrycodes': 'in',
      },
    );

    final response = await http.get(
      uri,
      headers: {
        'User-Agent': 'SmartTravelPlanner/1.0',
        'Accept': 'application/json',
      },
    ).timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw Exception('Destination search is unavailable.');
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! List) continue;

    for (final item in decoded) {
      if (item is! Map<String, dynamic>) continue;

      final resultName = (item['name'] ?? '')
          .toString()
          .trim()
          .toLowerCase()
          .replaceAll(RegExp(r'\s+'), ' ');

      if (resultName == input) {
        return true;
      }
    }
  }

  return false;
}


  Future<void> generateItinerary() async {
    FocusScope.of(context).unfocus();
    final formIsValid = _formKey.currentState?.validate() ?? false;

    setState(() {
      startDateError =
          startDate == null ? 'Please select a start date.' : null;
      endDateError = endDate == null
          ? 'Please select an end date.'
          : startDate != null &&
                  !DateUtils.dateOnly(endDate!)
                      .isAfter(DateUtils.dateOnly(startDate!))
              ? 'End date must be after the start date.'
              : null;
    });

    if (!formIsValid ||
        startDateError != null ||
        endDateError != null) {
      return;
    }

    final destinationName = destinationController.text.trim();
    final budget = double.tryParse(budgetController.text.trim());
    if (budget == null || !budget.isFinite || budget <= 0) return;

    setState(() => isGenerating = true);

    try {
      final isValid = await _isValidDestination(destinationName);
      if (!mounted) return;

      if (!isValid) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Enter a recognized city, town, village, or settlement name.',
            ),
          ),
        );
        return;
      }

      final numberOfDays = DateUtils.dateOnly(endDate!)
              .difference(DateUtils.dateOnly(startDate!))
              .inDays +
          1;

      final destination = Destination(
        name: destinationName,
        description: 'A travel plan for $destinationName.',
        averageCost: budget,
        popularPlaces: const [
          'Main Tourist Attraction',
          'Local Market',
          'Famous Landmark',
        ],
      );

      final itinerary = ItineraryService.generateItinerary(
        destination,
        numberOfDays: numberOfDays,
      );

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ItineraryScreen(
            destination: destination.name,
            travelMode: selectedTravelMode,
            itinerary: itinerary,
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Could not verify the destination. Check your internet connection and try again.',
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => isGenerating = false);
    }
  }

  Widget _sectionTitle(String title, {String? subtitle}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 13,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: Theme.of(context).colorScheme.surface,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: Theme.of(context).colorScheme.primary,
          width: 1.7,
        ),
      ),
    );
  }

  Widget _sectionCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: child,
    );
  }

  Widget _dateSelector({
    required String title,
    required DateTime? date,
    required String placeholder,
    required VoidCallback onTap,
    required String? error,
  }) {
    final theme = Theme.of(context);
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          InkWell(
            onTap: isGenerating ? null : onTap,
            borderRadius: BorderRadius.circular(14),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                border: Border.all(
                  color: error == null
                      ? theme.colorScheme.outlineVariant
                      : theme.colorScheme.error,
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_month, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      date == null
                          ? placeholder
                          : DateFormat('dd MMM yyyy').format(date),
                      style: TextStyle(
                        fontSize: 13,
                        color: date == null
                            ? theme.colorScheme.onSurfaceVariant
                            : theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (error != null) ...[
            const SizedBox(height: 5),
            Text(error, style: TextStyle(color: theme.colorScheme.error, fontSize: 11)),
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
    final theme = Theme.of(context);
    final width = MediaQuery.sizeOf(context).width;
    final compact = width < 520;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Plan your trip'),
        centerTitle: false,
      ),
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.primary.withValues(alpha: 0.06),
              theme.scaffoldBackgroundColor,
            ],
          ),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 850),
            child: SingleChildScrollView(
              padding: EdgeInsets.all(compact ? 16 : 28),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(compact ? 22 : 30),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        gradient: LinearGradient(
                          colors: [
                            theme.colorScheme.primary,
                            theme.colorScheme.tertiary,
                          ],
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.travel_explore,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                          const SizedBox(height: 18),
                          Text(
                            'Your next adventure starts here',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: compact ? 25 : 30,
                              fontWeight: FontWeight.w800,
                              height: 1.15,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Tell us a little about your trip and build a plan for your getaway.',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 14,
                              height: 1.45,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),

                    _sectionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _sectionTitle(
                            'Where are you going?',
                            subtitle: 'Start with the destination and your travel dates.',
                          ),
                          const SizedBox(height: 18),
                          TextFormField(
                            controller: destinationController,
                            enabled: !isGenerating,
                            textCapitalization: TextCapitalization.words,
                            decoration: _inputDecoration(
                              hint: 'e.g. Hyderabad, Goa, Jaipur',
                              icon: Icons.location_on_outlined,
                            ),
                            validator: (value) {
                              final name = value?.trim() ?? '';
                              if (name.isEmpty) return 'Please enter a destination.';
                              if (name.length < 2) return 'Enter a valid place name.';
                              if (!RegExp(
                                r"^[\p{L}\p{M}0-9 .,'-]+$",
                                unicode: true,
                              ).hasMatch(name)) {
                                return 'Use a valid place name.';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 18),
                          TextFormField(
                            controller: travelersController,
                            enabled: !isGenerating,
                            keyboardType: TextInputType.number,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            decoration: _inputDecoration(
                              hint: 'Number of travelers (1–100)',
                              icon: Icons.people_outline,
                            ),
                            validator: (value) {
                              final count = int.tryParse(value ?? '');
                              if (count == null || count < 1) {
                                return 'Enter at least 1 traveler.';
                              }
                              if (count > 100) return 'Maximum 100 travelers allowed.';
                              return null;
                            },
                          ),
                          const SizedBox(height: 18),
                          if (compact) ...[
                            _dateSelector(
                              title: 'Start date',
                              date: startDate,
                              placeholder: 'Choose start',
                              onTap: selectStartDate,
                              error: startDateError,
                            ),
                            const SizedBox(height: 14),
                            _dateSelector(
                              title: 'End date',
                              date: endDate,
                              placeholder: 'Choose end',
                              onTap: selectEndDate,
                              error: endDateError,
                            ),
                          ] else
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: _dateSelector(
                                  title: 'Start date',
                                  date: startDate,
                                  placeholder: 'Choose start date',
                                  onTap: selectStartDate,
                                  error: startDateError,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: _dateSelector(
                                  title: 'End date',
                                  date: endDate,
                                  placeholder: 'Choose end date',
                                  onTap: selectEndDate,
                                  error: endDateError,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    _sectionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _sectionTitle(
                            'Set your budget',
                            subtitle: 'Enter the total amount you plan to spend.',
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: budgetController,
                            enabled: !isGenerating,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                            ],
                            decoration: _inputDecoration(
                              hint: 'Total budget in rupees',
                              icon: Icons.currency_rupee,
                            ),
                            validator: (value) {
                              final amount = double.tryParse(value?.trim() ?? '');
                              if (amount == null || amount <= 0) {
                                return 'Enter a budget greater than ₹0.';
                              }
                              if (!amount.isFinite || amount > 1000000000) {
                                return 'Enter a valid budget amount.';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 18),
                          _sectionTitle('Budget category'),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: ['Low', 'Medium', 'High'].map((budget) {
                              return ChoiceChip(
                                avatar: Icon(
                                  budget == 'Low'
                                      ? Icons.savings_outlined
                                      : budget == 'Medium'
                                          ? Icons.account_balance_wallet_outlined
                                          : Icons.diamond_outlined,
                                  size: 18,
                                ),
                                label: Text(budget),
                                selected: selectedBudget == budget,
                                onSelected: isGenerating
                                    ? null
                                    : (_) => setState(() => selectedBudget = budget),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    _sectionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _sectionTitle(
                            'What do you enjoy?',
                            subtitle: 'Choose any interests that fit your trip.',
                          ),
                          const SizedBox(height: 14),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: preferences.map((preference) {
                              final selected = selectedPreferences.contains(preference);
                              return FilterChip(
                                avatar: Icon(_getPreferenceIcon(preference), size: 18),
                                label: Text(preference),
                                selected: selected,
                                onSelected: isGenerating
                                    ? null
                                    : (value) {
                                        setState(() {
                                          if (value) {
                                            selectedPreferences.add(preference);
                                          } else {
                                            selectedPreferences.remove(preference);
                                          }
                                        });
                                      },
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 22),
                          _sectionTitle(
                            'How will you travel?',
                            subtitle: 'Choose your preferred mode of transport.',
                          ),
                          const SizedBox(height: 8),
                          Material(
  color: Colors.transparent,
  child: RadioGroup<String>(
    groupValue: selectedTravelMode,
    onChanged: (value) {
      if (value == null || isGenerating) return;
      setState(() => selectedTravelMode = value);
    },
    child: Column(
      children: travelModes.map((mode) {
        return RadioListTile<String>(
          value: mode,
          title: Text(mode),
          secondary: Icon(_getTravelModeIcon(mode)),
          contentPadding: EdgeInsets.zero,
          dense: true,
        );
      }).toList(),
    ),
  ),
),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),

                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: isGenerating ? null : generateItinerary,
                        icon: isGenerating
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.auto_awesome),
                        label: Text(
                          isGenerating ? 'Checking destination…' : 'Generate my itinerary',
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                        ),
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Center(
                      child: Text(
                        'Place search powered by OpenStreetMap contributors.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
