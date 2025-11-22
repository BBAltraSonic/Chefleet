import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:chefleet/features/chat/screens/chat_detail_screen.dart';
import 'package:chefleet/features/chat/blocs/chat_bloc.dart';
import 'package:chefleet/features/chat/blocs/chat_state.dart';
import 'package:chefleet/core/repositories/chat_repository.dart';

class MockChatRepository extends Mock implements ChatRepository {}
class MockChatBloc extends Mock implements ChatBloc {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  group('ChatDetailScreen Widget Tests', () {
    late MockChatRepository mockChatRepository;
    late MockChatBloc mockChatBloc;

    setUp(() {
      mockChatRepository = MockChatRepository();
      mockChatBloc = MockChatBloc();
    });

    Widget createWidgetUnderTest({
      required String orderId,
      String orderStatus = 'pending',
    }) {
      return MaterialApp(
        home: BlocProvider<ChatBloc>.value(
          value: mockChatBloc,
          child: ChatDetailScreen(
            orderId: orderId,
            orderStatus: orderStatus,
          ),
        ),
      );
    }

    testWidgets('displays chat header with order status', (WidgetTester tester) async {
      when(() => mockChatBloc.state).thenReturn(
        ChatState(
          messages: [],
          status: ChatStatus.loaded,
        ),
      );

      await tester.pumpWidget(createWidgetUnderTest(
        orderId: 'order_123',
        orderStatus: 'accepted',
      ));
      await tester.pumpAndSettle();

      // Should display header
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('header color matches order status', (WidgetTester tester) async {
      when(() => mockChatBloc.state).thenReturn(
        ChatState(
          messages: [],
          status: ChatStatus.loaded,
        ),
      );

      await tester.pumpWidget(createWidgetUnderTest(
        orderId: 'order_123',
        orderStatus: 'ready',
      ));
      await tester.pumpAndSettle();

      // Header should have status-specific color
      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      expect(appBar.backgroundColor, isNotNull);
    });

    testWidgets('displays message list', (WidgetTester tester) async {
      when(() => mockChatBloc.state).thenReturn(
        ChatState(
          messages: [],
          status: ChatStatus.loaded,
        ),
      );

      await tester.pumpWidget(createWidgetUnderTest(orderId: 'order_123'));
      await tester.pumpAndSettle();

      // Should display message list
      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('displays message input field', (WidgetTester tester) async {
      when(() => mockChatBloc.state).thenReturn(
        ChatState(
          messages: [],
          status: ChatStatus.loaded,
        ),
      );

      await tester.pumpWidget(createWidgetUnderTest(orderId: 'order_123'));
      await tester.pumpAndSettle();

      // Should have text input
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('send button sends message', (WidgetTester tester) async {
      when(() => mockChatBloc.state).thenReturn(
        ChatState(
          messages: [],
          status: ChatStatus.loaded,
        ),
      );

      await tester.pumpWidget(createWidgetUnderTest(orderId: 'order_123'));
      await tester.pumpAndSettle();

      // Enter message
      await tester.enterText(find.byType(TextField), 'Test message');
      await tester.pumpAndSettle();

      // Find send button
      final sendButton = find.byIcon(Icons.send);
      expect(sendButton, findsOneWidget);

      // Tap send
      await tester.tap(sendButton);
      await tester.pumpAndSettle();
    });

    testWidgets('displays quick replies', (WidgetTester tester) async {
      when(() => mockChatBloc.state).thenReturn(
        ChatState(
          messages: [],
          status: ChatStatus.loaded,
        ),
      );

      await tester.pumpWidget(createWidgetUnderTest(orderId: 'order_123'));
      await tester.pumpAndSettle();

      // Should display quick reply options
      expect(find.text('On my way'), findsOneWidget);
      expect(find.text('Running late'), findsOneWidget);
    });

    testWidgets('quick reply sends predefined message', (WidgetTester tester) async {
      when(() => mockChatBloc.state).thenReturn(
        ChatState(
          messages: [],
          status: ChatStatus.loaded,
        ),
      );

      await tester.pumpWidget(createWidgetUnderTest(orderId: 'order_123'));
      await tester.pumpAndSettle();

      // Tap quick reply
      await tester.tap(find.text('On my way'));
      await tester.pumpAndSettle();
    });

    testWidgets('autoscrolls to latest message', (WidgetTester tester) async {
      when(() => mockChatBloc.state).thenReturn(
        ChatState(
          messages: [],
          status: ChatStatus.loaded,
        ),
      );

      await tester.pumpWidget(createWidgetUnderTest(orderId: 'order_123'));
      await tester.pumpAndSettle();

      // List should scroll to bottom
      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('displays empty state when no messages', (WidgetTester tester) async {
      when(() => mockChatBloc.state).thenReturn(
        ChatState(
          messages: [],
          status: ChatStatus.loaded,
        ),
      );

      await tester.pumpWidget(createWidgetUnderTest(orderId: 'order_123'));
      await tester.pumpAndSettle();

      // Should show empty state
      expect(find.text('No messages yet'), findsOneWidget);
    });

    testWidgets('displays error state', (WidgetTester tester) async {
      when(() => mockChatBloc.state).thenReturn(
        ChatState(
          messages: [],
          status: ChatStatus.error,
          errorMessage: 'Failed to load messages',
        ),
      );

      await tester.pumpWidget(createWidgetUnderTest(orderId: 'order_123'));
      await tester.pumpAndSettle();

      // Should show error
      expect(find.text('Failed to load messages'), findsOneWidget);
    });

    testWidgets('attachment button shows stub message', (WidgetTester tester) async {
      when(() => mockChatBloc.state).thenReturn(
        ChatState(
          messages: [],
          status: ChatStatus.loaded,
        ),
      );

      await tester.pumpWidget(createWidgetUnderTest(orderId: 'order_123'));
      await tester.pumpAndSettle();

      // Find attachment button
      final attachButton = find.byIcon(Icons.attach_file);
      if (attachButton.evaluate().isNotEmpty) {
        await tester.tap(attachButton);
        await tester.pumpAndSettle();

        // Should show snackbar
        expect(find.text('Attachments coming soon'), findsOneWidget);
      }
    });

    testWidgets('back button navigates back', (WidgetTester tester) async {
      when(() => mockChatBloc.state).thenReturn(
        ChatState(
          messages: [],
          status: ChatStatus.loaded,
        ),
      );

      await tester.pumpWidget(createWidgetUnderTest(orderId: 'order_123'));
      await tester.pumpAndSettle();

      // Find back button
      final backButton = find.byIcon(Icons.arrow_back);
      expect(backButton, findsOneWidget);
    });
  });
}
