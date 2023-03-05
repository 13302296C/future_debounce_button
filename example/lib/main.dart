import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:future_debounce_button/future_debounce_button.dart';

void main() {
  const String title = 'Future Debounce Button Demo';
  runApp(const MyHomePage(title: title));
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  bool useM3 = true;

  void _incrementCounter(int value) {
    setState(() {
      _counter += value;
    });
  }

  /// The future that completes successfully
  Future<int> _futureThatCompletes() async {
    await Future<void>.delayed(const Duration(seconds: 2));
    return 1;
  }

  /// The future that throws an exception
  Future<int> _futureThatThrows() async {
    await Future<void>.delayed(const Duration(seconds: 2));
    throw Exception('This future hase thrown an exception');
  }

  /// The future that never completes, so you will have to cancel it
  Future<int> _futureThatNeverCompletes() async {
    while (true) {
      await Future<void>.delayed(const Duration(seconds: 10));
    }
  }

  Future<int> _future(int i) async {
    switch (i) {
      case 0:
        return await _futureThatCompletes();
      case 1:
        return await _futureThatThrows();
      case 2:
      default:
        return await _futureThatNeverCompletes();
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> rows = [];
    for (int i = 0; i < FDBType.values.length; i++) {
      List<Widget> buttons = [];
      for (int y = 0; y < 3; y++) {
        buttons.add(Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: FutureDebounceButton(
                enabled: false,
                buttonType: FDBType.values[i],
                onPressed: () async => _future(y),
                onSuccess: _incrementCounter,
                onError: _onError,
                // errorStateDuration: null,
                // successStateDuration: null,
                onAbort: y == 1 ? null : _onAbort,
              ),
            )));
      }
      rows.add(Row(children: [
        Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(FDBType.values[i].toString().split('.').last),
            )),
        ...buttons
      ]));
      rows.add(const Divider());
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: widget.title,
      theme: useM3
          ? ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue)
          : ThemeData(
              primarySwatch: Colors.blue,
            ),
      home: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Center(
          child: SizedBox(
            width: 700,
            child: Column(
              children: [
                const SizedBox(height: 8),
                // material3 switch row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Use Material 3"),
                    Switch(
                        value: useM3,
                        onChanged: (value) => setState(() => useM3 = value)),
                  ],
                ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'You have pushed the button this many times:',
                    ),
                    Text(
                      '$_counter',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ],
                ),

                const Divider(),
                Row(children: const [
                  Expanded(flex: 1, child: Text("Button type")),
                  Expanded(
                      flex: 1,
                      child: Text("Success", textAlign: TextAlign.center)),
                  Expanded(
                      flex: 1,
                      child: Text("Error", textAlign: TextAlign.center)),
                  Expanded(
                      flex: 1,
                      child: Text("Abort", textAlign: TextAlign.center)),
                ]),
                const Divider(),
                ...rows,
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Display abort message
  void _onAbort() {
    log("Operation cancelled");
    // ScaffoldMessenger.of(context).showSnackBar(
    //   const SnackBar(
    //     content: Text("Operation cancelled"),
    //   ),
    // );
  }

  /// Display error message
  void _onError(dynamic error, dynamic stackTrace) {
    log(error.toString(), stackTrace: stackTrace);
    // showDialog(
    //     context: context,
    //     builder: (_) => AlertDialog(
    //           title: const Text("Error"),
    //           content: Text(error.toString()),
    //         ));
  }
}
