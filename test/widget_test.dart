import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rozay_connect/home_screen.dart';

void main() {
  testWidgets('shows Rozay Connect marketplace and sample products', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    expect(find.text('Rozay Connect'), findsOneWidget);
    expect(find.text('Featured products'), findsOneWidget);
    expect(find.text('Classic Leather Sneakers'), findsOneWidget);
  });

  testWidgets('search filters products and shows empty state', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    await tester.enterText(find.byType(TextField), 'not-a-product');
    await tester.pumpAndSettle();
    expect(find.text('No products found'), findsOneWidget);
    expect(find.text('Classic Leather Sneakers'), findsNothing);
  });

  testWidgets('category chip filters catalogue', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    await tester.tap(find.widgetWithText(ChoiceChip, 'Electronics'));
    await tester.pumpAndSettle();
    expect(find.text('Smart Watch'), findsOneWidget);
    expect(find.text('Classic Leather Sneakers'), findsNothing);
  });

  testWidgets('seller centre opens from the Sell button', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    await tester.tap(find.text('Sell'));
    await tester.pumpAndSettle();
    expect(find.text('Seller centre'), findsOneWidget);
    expect(find.text('Start selling on Rozay Connect'), findsOneWidget);
    expect(find.text('Business or seller name'), findsOneWidget);
    expect(find.text('1. Seller details'), findsOneWidget);
  });

  testWidgets('clearing search restores catalogue', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    await tester.enterText(find.byType(TextField), 'not-a-product');
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Clear search'));
    await tester.pumpAndSettle();
    expect(find.text('Classic Leather Sneakers'), findsOneWidget);
  });
}
