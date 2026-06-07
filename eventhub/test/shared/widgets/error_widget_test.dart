import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:eventhub/shared/widgets/error_widget.dart';

void main() {
  testWidgets('AppErrorWidget shows error message', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: AppErrorWidget(message: 'Something went wrong')),
      ),
    );

    expect(find.text('Something went wrong'), findsOneWidget);
    expect(find.text('Retry'), findsNothing); // No retry button
  });

  testWidgets('AppErrorWidget shows retry button when onRetry provided',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppErrorWidget(
            message: 'Error!',
            onRetry: () {},
          ),
        ),
      ),
    );

    expect(find.text('Retry'), findsOneWidget);
  });

  testWidgets('AppErrorWidget triggers retry callback', (tester) async {
    bool retried = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppErrorWidget(
            message: 'Error!',
            onRetry: () => retried = true,
          ),
        ),
      ),
    );

    await tester.tap(find.text('Retry'));
    expect(retried, isTrue);
  });
}
