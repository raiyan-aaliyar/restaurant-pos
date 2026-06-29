import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:restobill/app.dart';

void main() {
  testWidgets('App loads POS screen with navigation', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: RestoBillApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('POS'), findsWidgets);
    expect(find.text('Point of Sale'), findsOneWidget);
    expect(find.text('Orders'), findsWidgets);
    expect(find.text('Analytics'), findsWidgets);
    expect(find.text('Settings'), findsWidgets);
  });

  testWidgets('Theme toggle switches between light and dark mode',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: RestoBillApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.light_mode_rounded), findsOneWidget);

    await tester.tap(find.byIcon(Icons.light_mode_rounded));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.dark_mode_rounded), findsOneWidget);
  });
}
