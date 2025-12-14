import 'dart:async';
import 'package:chefleet/core/services/preparation_step_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}
class MockSupabaseQueryBuilder extends Mock implements SupabaseQueryBuilder {}
class MockPostgrestFilterBuilder extends Mock implements PostgrestFilterBuilder {}

// Fake that implements PostgrestTransformBuilder and behaves like a Future
class FakePostgrestTransformBuilder extends Fake implements PostgrestTransformBuilder<List<Map<String, dynamic>>> {
  final List<Map<String, dynamic>> _result;
  FakePostgrestTransformBuilder(this._result);

  @override
  Future<R> then<R>(FutureOr<R> Function(List<Map<String, dynamic>> value) onValue, {Function? onError}) {
    return Future.value(_result).then(onValue, onError: onError);
  }
}

void main() {
  late PreparationStepService service;
  late MockSupabaseClient mockSupabaseClient;
  late MockSupabaseQueryBuilder mockQueryBuilder;
  late MockPostgrestFilterBuilder mockFilterBuilder;

  setUp(() {
    resetMocktailState();
    mockSupabaseClient = MockSupabaseClient();
    mockQueryBuilder = MockSupabaseQueryBuilder();
    mockFilterBuilder = MockPostgrestFilterBuilder();

    // Register fallback values if needed, though 'any()' usually handles nulls for nullable types.
    // registerFallbackValue(''); 

    // Setup mocking chain: client.from() -> queryBuilder
    when(() => mockSupabaseClient.from(any())).thenAnswer((_) => mockQueryBuilder);
    
    // Setup mocking chain: queryBuilder.insert() -> filterBuilder
    when(() => mockQueryBuilder.insert(any())).thenAnswer((_) => mockFilterBuilder);

    // Setup mocking chain: filterBuilder.select() -> FakePostgrestTransformBuilder
    // We return an empty list because the service returns the result of select(), which are the inserted rows.
    // In reality, we should return the rows we expect to be inserted if we want to mimic the DB precisely,
    // but verifying the input to insert() is enough for this test.
    when(() => mockFilterBuilder.select(any())).thenAnswer((_) => FakePostgrestTransformBuilder([]));

    service = PreparationStepService(supabaseClient: mockSupabaseClient);
  });

  group('PreparationStepService', () {
    test('generateDefaultStepsForOrderItem generates fixed 3 steps', () async {
      const orderItemId = 'item-123';
      const dishName = 'Test Dish';
      const prepTimeMinutes = 20;
      const totalSeconds = prepTimeMinutes * 60;

      await service.generateDefaultStepsForOrderItem(
        orderItemId: orderItemId,
        dishName: dishName,
        dishCategory: 'main', // Category should be ignored
        dishPrepTimeMinutes: prepTimeMinutes,
      );

      // Verify correct insertions
      final capturedCall = verify(() => mockQueryBuilder.insert(captureAny())).captured.first;
      final insertedList = capturedCall as List<dynamic>; // List<Map<String, dynamic>>
      
      expect(insertedList.length, 3);
      
      // Step 1: Order confirmed
      expect(insertedList[0]['step_name'], 'Order confirmed');
      expect(insertedList[0]['estimated_duration_seconds'], 0);
      expect(insertedList[0]['step_number'], 1);
      expect(insertedList[0]['order_item_id'], orderItemId);

      // Step 2: Food preparation
      expect(insertedList[1]['step_name'], 'Food preparation');
      expect(insertedList[1]['estimated_duration_seconds'], totalSeconds); // 1200 seconds
      expect(insertedList[1]['step_number'], 2);
      expect(insertedList[1]['order_item_id'], orderItemId);

      // Step 3: Done waiting for collection
      expect(insertedList[2]['step_name'], 'Done waiting for collection');
      expect(insertedList[2]['estimated_duration_seconds'], 0);
      expect(insertedList[2]['step_number'], 3);
      expect(insertedList[2]['order_item_id'], orderItemId);
    });

    test('generateDefaultStepsForOrderItem generates fixed 3 steps regardless of category', () async {
      const orderItemId = 'item-456';
      
      await service.generateDefaultStepsForOrderItem(
        orderItemId: orderItemId,
        dishName: 'Drink',
        dishCategory: 'beverage', // Different category
        dishPrepTimeMinutes: 5,
      );

       final capturedCall = verify(() => mockQueryBuilder.insert(captureAny())).captured.last;
      final insertedList = capturedCall as List<dynamic>;
      
      expect(insertedList.length, 3);
      expect(insertedList[0]['step_name'], 'Order confirmed');
      expect(insertedList[1]['step_name'], 'Food preparation');
      expect(insertedList[2]['step_name'], 'Done waiting for collection');
    });
  });
}
