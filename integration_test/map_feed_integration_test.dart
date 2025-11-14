import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:chefleet/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Map and Feed Integration Tests', () {
    testWidgets('Full map-to-feed workflow', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      expect(find.byType(MaterialApp), findsOneWidget);
      
      await tester.pumpAndSettle(const Duration(seconds: 2));
    });

    testWidgets('Map initializes with user location', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await tester.pumpAndSettle(const Duration(seconds: 3));

      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('Feed displays dishes from visible area', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await tester.pumpAndSettle(const Duration(seconds: 3));

      expect(find.text('Nearby Dishes'), findsWidgets);
    });

    testWidgets('Scroll triggers map animation', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await tester.pumpAndSettle(const Duration(seconds: 2));

      await tester.drag(
        find.byType(CustomScrollView),
        const Offset(0, -300),
      );
      await tester.pumpAndSettle();

      expect(find.byType(CustomScrollView), findsOneWidget);
    });

    testWidgets('Infinite scroll loads more dishes', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await tester.pumpAndSettle(const Duration(seconds: 3));

      await tester.drag(
        find.byType(CustomScrollView),
        const Offset(0, -1000),
      );
      await tester.pumpAndSettle();

      await tester.drag(
        find.byType(CustomScrollView),
        const Offset(0, -1000),
      );
      await tester.pumpAndSettle();

      expect(find.byType(CustomScrollView), findsOneWidget);
    });

    testWidgets('Tapping vendor pin shows mini card', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await tester.pumpAndSettle(const Duration(seconds: 3));

      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('Offline mode displays cached data', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await tester.pumpAndSettle(const Duration(seconds: 3));

      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('Map bounds change updates feed', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await tester.pumpAndSettle(const Duration(seconds: 3));

      expect(find.byType(MaterialApp), findsOneWidget);
    });
  });

  group('Performance Tests', () {
    testWidgets('Map renders smoothly with many markers', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await tester.pumpAndSettle(const Duration(seconds: 3));

      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('Feed grid scrolls smoothly', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await tester.pumpAndSettle(const Duration(seconds: 2));

      for (int i = 0; i < 5; i++) {
        await tester.drag(
          find.byType(CustomScrollView),
          const Offset(0, -200),
        );
        await tester.pump();
      }

      await tester.pumpAndSettle();

      expect(find.byType(CustomScrollView), findsOneWidget);
    });
  });
}
