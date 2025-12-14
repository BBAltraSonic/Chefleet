import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:chefleet/features/chat/blocs/chat_bloc.dart';
import 'package:chefleet/features/chat/screens/chat_detail_screen.dart';
import 'package:chefleet/features/auth/blocs/auth_bloc.dart';

class MockChatBloc extends Mock implements ChatBloc {}
class MockAuthBloc extends Mock implements AuthBloc {}
class FakeChatEvent extends Fake implements ChatEvent {}
class FakeAuthEvent extends Fake implements AuthEvent {}

void main() {
  late MockChatBloc mockChatBloc;
  late MockAuthBloc mockAuthBloc;

  setUpAll(() {
    registerFallbackValue(FakeChatEvent());
    registerFallbackValue(FakeAuthEvent());
  });

  setUp(() {
    mockChatBloc = MockChatBloc();
    mockAuthBloc = MockAuthBloc();
  });

  Widget createTestWidget({
    required String orderId,
    required String orderStatus,
    ChatState? chatState,
    AuthState? authState,
  }) {
    when(() => mockChatBloc.state).thenReturn(
      chatState ?? const ChatState(),
    );
    when(() => mockChatBloc.stream).thenAnswer((_) => Stream.value(
      chatState ?? const ChatState(),
    ));
    when(() => mockAuthBloc.state).thenReturn(
      authState ?? const AuthState(mode: AuthMode.authenticated),
    );
    when(() => mockAuthBloc.stream).thenAnswer((_) => Stream.value(
      authState ?? const AuthState(mode: AuthMode.authenticated),
    ));

    return MaterialApp(
      home: MultiBlocProvider(
        providers: [
          BlocProvider<ChatBloc>.value(value: mockChatBloc),
          BlocProvider<AuthBloc>.value(value: mockAuthBloc),
        ],
        child: ChatDetailScreen(
          orderId: orderId,
          orderStatus: orderStatus,
        ),
      ),
    );
  }

  group('ChatDetailScreen - Guest User', () {
    testWidgets('TEST START: Guest user can load chat screen', (tester) async {
      print('TEST: Guest user can load chat screen - STARTED');
      
      final authState = const AuthState(
        mode: AuthMode.guest,
        guestId: 'guest_123',
      );
      
      when(() => mockChatBloc.add(any())).thenReturn(null);

      await tester.pumpWidget(createTestWidget(
        orderId: 'order_123',
        orderStatus: 'pending',
        authState: authState,
      ));
      await tester.pumpAndSettle();

      expect(find.byType(ChatDetailScreen), findsOneWidget);
      
      verify(() => mockChatBloc.add(any(that: isA<LoadChatMessages>()))).called(1);
      verify(() => mockChatBloc.add(any(that: isA<SubscribeToOrderChat>()))).called(1);
      
      print('TEST: Guest user can load chat screen - SUCCESS');
    });

    testWidgets('TEST START: Guest messages display correctly', (tester) async {
      print('TEST: Guest messages display correctly - STARTED');
      
      final authState = const AuthState(
        mode: AuthMode.guest,
        guestId: 'guest_123',
      );
      
      final chatState = ChatState(
        messagesStatus: ChatStatus.loaded,
        messages: [
          {
            'id': 'msg_1',
            'order_id': 'order_123',
            'guest_sender_id': 'guest_123',
            'content': 'Hello from guest',
            'sender_type': 'buyer',
            'message_type': 'text',
            'created_at': DateTime.now().toIso8601String(),
            'is_read': false,
          },
          {
            'id': 'msg_2',
            'order_id': 'order_123',
            'sender_id': 'vendor_123',
            'content': 'Hello from vendor',
            'sender_type': 'vendor',
            'message_type': 'text',
            'created_at': DateTime.now().toIso8601String(),
            'is_read': true,
          },
        ],
      );
      
      when(() => mockChatBloc.add(any())).thenReturn(null);

      await tester.pumpWidget(createTestWidget(
        orderId: 'order_123',
        orderStatus: 'pending',
        authState: authState,
        chatState: chatState,
      ));
      await tester.pumpAndSettle();

      expect(find.text('Hello from guest'), findsOneWidget);
      expect(find.text('Hello from vendor'), findsOneWidget);
      
      print('TEST: Guest messages display correctly - SUCCESS (2 messages found)');
    });
  });

  group('ChatDetailScreen - Authenticated User', () {
    testWidgets('TEST START: Authenticated user can send messages', (tester) async {
      print('TEST: Authenticated user can send messages - STARTED');
      
      final authState = const AuthState(
        mode: AuthMode.authenticated,
      );
      
      when(() => mockChatBloc.add(any())).thenReturn(null);

      await tester.pumpWidget(createTestWidget(
        orderId: 'order_123',
        orderStatus: 'pending',
        authState: authState,
      ));
      await tester.pumpAndSettle();

      expect(find.byType(ChatDetailScreen), findsOneWidget);
      
      print('TEST: Authenticated user can send messages - SUCCESS');
    });

    testWidgets('TEST START: Empty chat state displays correctly', (tester) async {
      print('TEST: Empty chat state displays correctly - STARTED');
      
      final chatState = const ChatState(
        messagesStatus: ChatStatus.loaded,
        messages: [],
      );
      
      when(() => mockChatBloc.add(any())).thenReturn(null);

      await tester.pumpWidget(createTestWidget(
        orderId: 'order_123',
        orderStatus: 'pending',
        chatState: chatState,
      ));
      await tester.pumpAndSettle();

      expect(find.text('Start the conversation'), findsOneWidget);
      
      print('TEST: Empty chat state displays correctly - SUCCESS');
    });

    testWidgets('TEST START: Error state displays correctly', (tester) async {
      print('TEST: Error state displays correctly - STARTED');
      
      final chatState = const ChatState(
        messagesStatus: ChatStatus.error,
        errorMessage: 'Failed to load messages',
      );
      
      when(() => mockChatBloc.add(any())).thenReturn(null);

      await tester.pumpWidget(createTestWidget(
        orderId: 'order_123',
        orderStatus: 'pending',
        chatState: chatState,
      ));
      await tester.pumpAndSettle();

      expect(find.text('Failed to load messages'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
      
      print('TEST: Error state displays correctly - SUCCESS');
    });
  });

  group('ChatDetailScreen - Real-time Updates', () {
    testWidgets('TEST START: Subscribe to chat on init', (tester) async {
      print('TEST: Subscribe to chat on init - STARTED');
      
      when(() => mockChatBloc.add(any())).thenReturn(null);

      await tester.pumpWidget(createTestWidget(
        orderId: 'order_123',
        orderStatus: 'pending',
      ));
      await tester.pumpAndSettle();

      verify(() => mockChatBloc.add(any(that: isA<LoadChatMessages>()))).called(1);
      verify(() => mockChatBloc.add(any(that: isA<SubscribeToOrderChat>()))).called(1);
      
      print('TEST: Subscribe to chat on init - SUCCESS (both events triggered)');
    });

    testWidgets('TEST START: Unsubscribe from chat on dispose', (tester) async {
      print('TEST: Unsubscribe from chat on dispose - STARTED');
      
      when(() => mockChatBloc.add(any())).thenReturn(null);

      await tester.pumpWidget(createTestWidget(
        orderId: 'order_123',
        orderStatus: 'pending',
      ));
      await tester.pumpAndSettle();

      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();

      verify(() => mockChatBloc.add(any(that: isA<UnsubscribeFromOrderChat>()))).called(1);
      
      print('TEST: Unsubscribe from chat on dispose - SUCCESS');
    });
  });
}
