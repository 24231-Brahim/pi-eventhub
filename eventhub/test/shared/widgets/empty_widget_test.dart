import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:eventhub/shared/widgets/empty_widget.dart';

void main() {
  testWidgets('EmptyWidget shows message', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: EmptyWidget(message: 'No items found')),
      ),
    );

    expect(find.text('No items found'), findsOneWidget);
  });

  testWidgets('EmptyWidget shows default icon', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: EmptyWidget(message: 'Empty')),
      ),
    );

    expect(find.byIcon(Icons.inbox_outlined), findsOneWidget);
  });

  testWidgets('EmptyWidget shows custom icon', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body:
              EmptyWidget(message: 'Nothing', icon: Icons.event_busy),
        ),
      ),
    );

    expect(find.byIcon(Icons.event_busy), findsOneWidget);
  });
}
