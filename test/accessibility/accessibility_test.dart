import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chefleet/core/theme/app_theme.dart';
import 'package:chefleet/core/utils/accessibility_utils.dart';

void main() {
  group('Accessibility Tests', () {
    group('Color Contrast', () {
      test('Primary green on background meets WCAG AA', () {
        final hasGoodContrast = AccessibilityUtils.hasGoodContrast(
          AppTheme.primaryGreen,
          AppTheme.backgroundColor,
        );
        expect(hasGoodContrast, isTrue,
            reason: 'Primary green should have good contrast on background');
      });

      test('Dark text on background meets WCAG AA', () {
        final hasGoodContrast = AccessibilityUtils.hasGoodContrast(
          AppTheme.darkText,
          AppTheme.backgroundColor,
        );
        expect(hasGoodContrast, isTrue,
            reason: 'Dark text should have good contrast on background');
      });

      test('Secondary green on surface green meets WCAG AA', () {
        final hasGoodContrast = AccessibilityUtils.hasGoodContrast(
          AppTheme.secondaryGreen,
          AppTheme.surfaceGreen,
        );
        expect(hasGoodContrast, isTrue,
            reason: 'Secondary green should have good contrast on surface green');
      });

      test('Dark text on surface green meets WCAG AA', () {
        final hasGoodContrast = AccessibilityUtils.hasGoodContrast(
          AppTheme.darkText,
          AppTheme.surfaceGreen,
        );
        expect(hasGoodContrast, isTrue,
            reason: 'Dark text should have good contrast on surface green');
      });

      test('Primary green on dark text has poor contrast (expected)', () {
        final hasGoodContrast = AccessibilityUtils.hasGoodContrast(
          AppTheme.primaryGreen,
          AppTheme.darkText,
        );
        // This should fail as they're both dark colors
        expect(hasGoodContrast, isFalse,
            reason: 'Primary green on dark text should have poor contrast');
      });
    });

    group('Tap Target Size', () {
      testWidgets('IconButton has minimum tap target size', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AccessibilityUtils.ensureTapTarget(
                child: IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {},
                ),
              ),
            ),
          ),
        );

        final iconButton = tester.widget<IconButton>(find.byType(IconButton));
        final renderBox = tester.renderObject(find.byType(IconButton)) as RenderBox;
        
        expect(renderBox.size.width, greaterThanOrEqualTo(AccessibilityUtils.minTapTargetSize));
        expect(renderBox.size.height, greaterThanOrEqualTo(AccessibilityUtils.minTapTargetSize));
      });

      testWidgets('Small button wrapped with ensureTapTarget meets minimum size', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AccessibilityUtils.ensureTapTarget(
                child: Container(
                  width: 20,
                  height: 20,
                  color: Colors.blue,
                ),
              ),
            ),
          ),
        );

        final constrainedBox = find.byType(ConstrainedBox);
        expect(constrainedBox, findsOneWidget);
        
        final renderBox = tester.renderObject(constrainedBox) as RenderBox;
        expect(renderBox.size.width, greaterThanOrEqualTo(AccessibilityUtils.minTapTargetSize));
        expect(renderBox.size.height, greaterThanOrEqualTo(AccessibilityUtils.minTapTargetSize));
      });
    });

    group('Semantic Labels', () {
      testWidgets('Image has semantic label', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AccessibilityUtils.labeledImage(
                imageWidget: const Icon(Icons.image),
                label: 'Test image description',
              ),
            ),
          ),
        );

        final semantics = tester.widget<Semantics>(find.byType(Semantics).first);
        expect(semantics.properties.label, equals('Test image description'));
        expect(semantics.properties.image, isTrue);
      });

      testWidgets('Icon has semantic label', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AccessibilityUtils.labeledIcon(
                icon: const Icon(Icons.star),
                label: 'Rating star',
              ),
            ),
          ),
        );

        final semantics = tester.widget<Semantics>(find.byType(Semantics).first);
        expect(semantics.properties.label, equals('Rating star'));
      });

      testWidgets('Button has proper semantics', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AccessibilityUtils.accessibleButton(
                child: const Text('Click me'),
                onPressed: () {},
                label: 'Action button',
                hint: 'Tap to perform action',
              ),
            ),
          ),
        );

        final semantics = tester.widget<Semantics>(find.byType(Semantics).first);
        expect(semantics.properties.button, isTrue);
        expect(semantics.properties.enabled, isTrue);
        expect(semantics.properties.label, equals('Action button'));
        expect(semantics.properties.hint, equals('Tap to perform action'));
      });

      testWidgets('Disabled button has proper semantics', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AccessibilityUtils.accessibleButton(
                child: const Text('Disabled'),
                onPressed: null,
                label: 'Disabled button',
              ),
            ),
          ),
        );

        final semantics = tester.widget<Semantics>(find.byType(Semantics).first);
        expect(semantics.properties.button, isTrue);
        expect(semantics.properties.enabled, isFalse);
      });

      testWidgets('Header has proper semantics', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AccessibilityUtils.semanticHeader(
                text: 'Page Title',
                style: const TextStyle(fontSize: 24),
                level: 1,
              ),
            ),
          ),
        );

        final semantics = tester.widget<Semantics>(find.byType(Semantics).first);
        expect(semantics.properties.header, isTrue);
        expect(semantics.properties.label, equals('Page Title'));
      });

      testWidgets('Loading indicator has semantic label', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AccessibilityUtils.semanticLoadingIndicator(
                label: 'Loading data',
              ),
            ),
          ),
        );

        final semantics = tester.widget<Semantics>(find.byType(Semantics).first);
        expect(semantics.properties.label, equals('Loading data'));
        expect(semantics.properties.liveRegion, isTrue);
      });

      testWidgets('Error message has proper semantics', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AccessibilityUtils.semanticError(
                message: 'Something went wrong',
                icon: const Icon(Icons.error),
              ),
            ),
          ),
        );

        final semantics = tester.widget<Semantics>(find.byType(Semantics).first);
        expect(semantics.properties.label, equals('Error: Something went wrong'));
        expect(semantics.properties.liveRegion, isTrue);
      });
    });

    group('Text Scaling', () {
      testWidgets('Text scale is reasonable at 1.0', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                final isReasonable = AccessibilityUtils.isTextScaleReasonable(context);
                return Text('Scale: $isReasonable');
              },
            ),
          ),
        );

        expect(find.text('Scale: true'), findsOneWidget);
      });

      testWidgets('Clamped text scale limits maximum', (tester) async {
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(textScaleFactor: 5.0),
            child: MaterialApp(
              home: Builder(
                builder: (context) {
                  final clampedScale = AccessibilityUtils.getClampedTextScale(context);
                  return Text('Scale: $clampedScale');
                },
              ),
            ),
          ),
        );

        expect(find.textContaining('Scale: 2.5'), findsOneWidget);
      });

      testWidgets('Clamped text scale allows normal scaling', (tester) async {
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(textScaleFactor: 1.5),
            child: MaterialApp(
              home: Builder(
                builder: (context) {
                  final clampedScale = AccessibilityUtils.getClampedTextScale(context);
                  return Text('Scale: $clampedScale');
                },
              ),
            ),
          ),
        );

        expect(find.textContaining('Scale: 1.5'), findsOneWidget);
      });
    });

    group('Semantic List', () {
      testWidgets('List has proper semantics', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AccessibilityUtils.semanticList(
                child: ListView(
                  children: const [
                    Text('Item 1'),
                    Text('Item 2'),
                    Text('Item 3'),
                  ],
                ),
                itemCount: 3,
                label: 'Items list',
              ),
            ),
          ),
        );

        final semantics = tester.widget<Semantics>(find.byType(Semantics).first);
        expect(semantics.properties.label, equals('Items list'));
      });
    });
  });

  group('Theme Accessibility', () {
    test('All text styles use readable font sizes', () {
      final textTheme = AppTheme.lightTheme.textTheme;
      
      // Minimum readable font size is 12sp
      expect(textTheme.bodySmall!.fontSize, greaterThanOrEqualTo(12));
      expect(textTheme.bodyMedium!.fontSize, greaterThanOrEqualTo(12));
      expect(textTheme.bodyLarge!.fontSize, greaterThanOrEqualTo(12));
      expect(textTheme.labelSmall!.fontSize, greaterThanOrEqualTo(12));
      expect(textTheme.labelMedium!.fontSize, greaterThanOrEqualTo(12));
      expect(textTheme.labelLarge!.fontSize, greaterThanOrEqualTo(12));
    });

    test('Font family is consistent', () {
      final textTheme = AppTheme.lightTheme.textTheme;
      
      expect(textTheme.displayLarge!.fontFamily, equals('PlusJakartaSans'));
      expect(textTheme.headlineLarge!.fontFamily, equals('PlusJakartaSans'));
      expect(textTheme.bodyLarge!.fontFamily, equals('PlusJakartaSans'));
      expect(textTheme.labelLarge!.fontFamily, equals('PlusJakartaSans'));
    });
  });
}
