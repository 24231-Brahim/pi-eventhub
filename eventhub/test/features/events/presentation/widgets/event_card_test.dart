import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:eventhub/features/events/domain/entities/event.dart';
import 'package:eventhub/features/events/presentation/widgets/event_card.dart';

void main() {
  final testEvent = Event(
    id: '1',
    title: 'Flutter Conference 2026',
    description: 'A great conference about Flutter',
    date: DateTime(2026, 7, 15, 9, 0),
    location: 'Tunis, Tunisia',
    maxParticipants: 200,
    category: EventCategory.conference,
    organizerId: 'org1',
    price: 0,
  );

  Widget createTestWidget() => MaterialApp(
        home: Scaffold(
          body: EventCard(
            event: testEvent,
            onTap: () {},
          ),
        ),
      );

  testWidgets('EventCard displays event title', (tester) async {
    await tester.pumpWidget(createTestWidget());
    expect(find.text('Flutter Conference 2026'), findsOneWidget);
  });

  testWidgets('EventCard displays FREE badge', (tester) async {
    await tester.pumpWidget(createTestWidget());
    expect(find.text('FREE'), findsOneWidget);
  });

  testWidgets('EventCard displays location', (tester) async {
    await tester.pumpWidget(createTestWidget());
    expect(find.text('Tunis, Tunisia'), findsOneWidget);
  });

  testWidgets('EventCard displays category chip', (tester) async {
    await tester.pumpWidget(createTestWidget());
    expect(find.text('CONFERENCE'), findsOneWidget);
  });

  testWidgets('EventCard shows participants count', (tester) async {
    await tester.pumpWidget(createTestWidget());
    expect(find.textContaining('0/200'), findsOneWidget);
  });

  testWidgets('EventCard shows price when not free', (tester) async {
    final paidEvent = Event(
      id: '2',
      title: 'Paid Workshop',
      description: 'A paid workshop',
      date: DateTime(2026, 8, 1),
      location: 'Online',
      maxParticipants: 50,
      category: EventCategory.workshop,
      organizerId: 'org1',
      price: 25.0,
    );

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: EventCard(event: paidEvent, onTap: () {}),
      ),
    ));

    expect(find.textContaining('25.00'), findsOneWidget);
    expect(find.text('FREE'), findsNothing);
  });

  testWidgets('EventCard triggers onTap', (tester) async {
    bool tapped = false;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: EventCard(
          event: testEvent,
          onTap: () => tapped = true,
        ),
      ),
    ));

    await tester.tap(find.text('Flutter Conference 2026'));
    expect(tapped, isTrue);
  });
}
