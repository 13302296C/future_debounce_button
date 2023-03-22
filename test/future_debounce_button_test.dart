import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'test_widget.dart';

void main() {
  testWidgets('Button test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const TestWidget());

    await test1(tester);
  });
}

// Test1: call succeeds, debounce duration is 1 second
// Button is blocked for 1 second, then spinner is shown for 1 seconds,
// then button is enabled again after 2 seconds.
// Button text is changed to 'Success' after 3 seconds for 1 second.
Future<void> test1(WidgetTester tester) async {
  String test1 = 'Test 1';
  await tester.runAsync(() async {
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(FilledButton), findsOneWidget);
    expect(find.text(test1), findsOneWidget);

    // Press button - button in debounce state
    await tester.tap(find.text(test1));

    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text(test1), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsNothing);

    // Wait for debounce duration
    await tester.pump(const Duration(milliseconds: 1000));

    // Button in progress state
    expect(find.text(test1), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Wait for progress duration
    await tester.pump(const Duration(milliseconds: 1000));

    // Button in success state
    expect(find.text(test1), findsNothing);
    expect(find.text('Success!'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);

    // Wait for success duration
    await tester.pump(const Duration(milliseconds: 2000));

    // Button in normal state
    expect(find.text(test1), findsOneWidget);
    expect(find.text('Success!'), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });
}
