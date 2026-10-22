import 'package:flutter_test/flutter_test.dart';
import 'package:smart_travel_planner/main.dart';

void main() {
  testWidgets('Home screen displays app title and planning button',
      (WidgetTester tester) async {
    await tester.pumpWidget(const SmartTravelPlanner());

    expect(find.text('Smart Travel Planner'), findsOneWidget);
    expect(find.text('Start Planning'), findsOneWidget);
  });

  testWidgets('Start Planning opens the trip details screen',
      (WidgetTester tester) async {
    await tester.pumpWidget(const SmartTravelPlanner());

    await tester.tap(find.text('Start Planning'));
    await tester.pumpAndSettle();

    // Expectations matching the redesigned screen
    expect(find.text('Plan your trip'), findsOneWidget);
    expect(find.text('Where are you going?'), findsOneWidget);
    expect(find.text('Generate my itinerary'), findsOneWidget);
  });
} 