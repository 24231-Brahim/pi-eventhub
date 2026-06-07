import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:eventhub/shared/widgets/loading_widget.dart';

void main() {
  testWidgets('LoadingWidget shows circular progress', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: LoadingWidget())),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('LoadingWidget shows optional message', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: LoadingWidget(message: 'Loading...')),
      ),
    );

    expect(find.text('Loading...'), findsOneWidget);
  });

  testWidgets('LoadingWidget hides message when not provided', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: LoadingWidget())),
    );

    expect(find.text('Loading...'), findsNothing);
  });
}
