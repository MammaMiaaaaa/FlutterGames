// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:animal_edu_games/app.dart';
import 'package:animal_edu_games/screens/math_racer_screen.dart' show _AnimatedAnswerButton, MathRacerScreen;

void main() {
  testWidgets('App launches without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const App());
    expect(find.byType(App), findsOneWidget);
  });

  testWidgets('MathRacerScreen answer button tap does not crash', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: MathRacerScreen()));
    await tester.pumpAndSettle();
    // Find the first answer button by key
    final answerButton = find.byKey(const Key('answer_button_0'));
    expect(answerButton, findsOneWidget);
    await tester.tap(answerButton);
    await tester.pumpAndSettle();
    // If we reach here without an exception, the test passes
    expect(true, isTrue);
  });
}
