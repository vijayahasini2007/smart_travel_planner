import 'package:flutter/material.dart';

void main() {
  runApp(const SmartTravelPlanner());
}

class SmartTravelPlanner extends StatelessWidget {
  const SmartTravelPlanner({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Travel Planner',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Travel Planner'),
      ),
      body: const Center(
        child: Text(
          'Smart Travel Planner\n\nPlan your trip smarter ✈️',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}