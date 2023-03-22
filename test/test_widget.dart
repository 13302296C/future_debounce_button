import 'package:flutter/material.dart';
import 'package:future_debounce_button/future_debounce_button.dart';

class TestWidget extends StatelessWidget {
  const TestWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Test1: call succeeds, debounce duration is 1 second
            // Button is blocked for 1 second, then spinner is shown for 1 seconds,
            // then button is enabled again after 2 seconds.
            // Button text is changed to 'Success' after 3 seconds for 1 second.
            FutureDebounceButton(
              onPressed: () async {
                await Future.delayed(const Duration(seconds: 2));
                return true;
              },
              actionCallText: 'Test 1',
              debounceDuration: const Duration(seconds: 1),
              successStateDuration: const Duration(seconds: 2),
            ),
          ],
        ),
      ),
    );
  }
}
