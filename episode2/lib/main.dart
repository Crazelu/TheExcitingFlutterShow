import 'package:episode2/inline_demo_page.dart';
import 'package:episode2/keyboard_demo_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Autocomplete Demo',
      theme: ThemeData(
          primarySwatch: Colors.grey,
          textButtonTheme: TextButtonThemeData(
            style: ButtonStyle(
              backgroundColor:
                  MaterialStateProperty.resolveWith((states) => Colors.black),
              foregroundColor:
                  MaterialStateProperty.resolveWith((states) => Colors.white),
            ),
          )),
      home: const Home(),
    );
  }
}

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Autocomplete Demo'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  CupertinoPageRoute(
                    builder: (_) => const InlineDemoPage(),
                  ),
                );
              },
              child: const Text("👉Inline Demo"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  CupertinoPageRoute(
                    builder: (_) => const KeyboardDemoPage(),
                  ),
                );
              },
              child: const Text("👉Keyboard Demo"),
            ),
          ],
        ),
      ),
    );
  }
}
