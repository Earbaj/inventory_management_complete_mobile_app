// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_management_complete/core/presentation/widgets/no_internet_dialog.dart';

void main() {
  testWidgets('NoInternetDialog renders correctly with title and retry button', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: NoInternetDialog(),
        ),
      ),
    );

    // Verify dialog elements render
    expect(find.byType(NoInternetDialog), findsOneWidget);
    expect(find.byIcon(Icons.wifi_off_rounded), findsOneWidget);
    expect(find.byType(ElevatedButton), findsOneWidget);
  });
}
