import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:episode3/main.dart';

void main() {
  testWidgets('MyHomePage AppLifecycleState Test', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('App lifecycle history:'), findsOneWidget);
    expect(find.text('Nothing yet'), findsOneWidget);

    final states = [
      AppLifecycleState.paused,
      AppLifecycleState.inactive,
      AppLifecycleState.hidden,
      AppLifecycleState.inactive,
      AppLifecycleState.resumed,
    ];

    for (final state in states) {
      tester.binding.handleAppLifecycleStateChanged(state);
    }

    await tester.pump();

    expect(find.text('Nothing yet'), findsNothing);
    expect(find.text(states.map((e) => e.name).join(' -> ')), findsOneWidget);
  });
}
