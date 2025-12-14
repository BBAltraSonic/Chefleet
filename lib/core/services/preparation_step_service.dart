import 'package:supabase_flutter/supabase_flutter.dart';

class PreparationStepService {
  final SupabaseClient _supabaseClient;

  PreparationStepService({required SupabaseClient supabaseClient})
      : _supabaseClient = supabaseClient;

  Future<List<Map<String, dynamic>>> generateDefaultStepsForOrderItem({
    required String orderItemId,
    required String dishName,
    required String? dishCategory,
    int? dishPrepTimeMinutes,
  }) async {
    final steps = _getDefaultStepsForCategory(
      dishCategory ?? 'main',
      dishPrepTimeMinutes ?? 15,
    );

    final stepsToInsert = steps.asMap().entries.map((entry) {
      return {
        'order_item_id': orderItemId,
        'step_number': entry.key + 1,
        'step_name': entry.value['name'],
        'estimated_duration_seconds': entry.value['duration'],
        'status': 'pending',
      };
    }).toList();

    try {
      final response = await _supabaseClient
          .from('order_item_preparation_steps')
          .insert(stepsToInsert)
          .select();

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to generate preparation steps: $e');
    }
  }

  Future<void> startStep({
    required String stepId,
  }) async {
    await _supabaseClient
        .from('order_item_preparation_steps')
        .update({
          'status': 'in_progress',
          'started_at': DateTime.now().toIso8601String(),
        })
        .eq('id', stepId);
  }

  Future<void> completeStep({
    required String stepId,
  }) async {
    await _supabaseClient
        .from('order_item_preparation_steps')
        .update({
          'status': 'completed',
          'completed_at': DateTime.now().toIso8601String(),
        })
        .eq('id', stepId);
  }

  Future<void> skipStep({
    required String stepId,
  }) async {
    await _supabaseClient
        .from('order_item_preparation_steps')
        .update({
          'status': 'skipped',
        })
        .eq('id', stepId);
  }

  Future<void> startNextStep(String orderItemId) async {
    final steps = await _supabaseClient
        .from('order_item_preparation_steps')
        .select()
        .eq('order_item_id', orderItemId)
        .order('step_number');

    final stepsList = List<Map<String, dynamic>>.from(steps);
    
    final currentStep = stepsList.firstWhere(
      (step) => step['status'] == 'in_progress',
      orElse: () => <String, dynamic>{},
    );

    if (currentStep.isNotEmpty) {
      await completeStep(stepId: currentStep['id'] as String);
    }

    final nextStep = stepsList.firstWhere(
      (step) => step['status'] == 'pending',
      orElse: () => <String, dynamic>{},
    );

    if (nextStep.isNotEmpty) {
      await startStep(stepId: nextStep['id'] as String);
    }
  }

  Future<void> updateOrderPreparationTimes(String orderId) async {
    final orderItems = await _supabaseClient
        .from('order_items')
        .select()
        .eq('order_id', orderId);

    final items = List<Map<String, dynamic>>.from(orderItems);
    
    int totalEstimatedSeconds = 0;
    
    for (final item in items) {
      final steps = await _supabaseClient
          .from('order_item_preparation_steps')
          .select()
          .eq('order_item_id', item['id']);

      final stepsList = List<Map<String, dynamic>>.from(steps);
      
      for (final step in stepsList) {
        totalEstimatedSeconds += step['estimated_duration_seconds'] as int;
      }
    }

    final now = DateTime.now();
    final estimatedReady = now.add(Duration(seconds: totalEstimatedSeconds));

    await _supabaseClient
        .from('orders')
        .update({
          'preparation_started_at': now.toIso8601String(),
          'estimated_ready_at': estimatedReady.toIso8601String(),
        })
        .eq('id', orderId);
  }

  List<Map<String, dynamic>> _getDefaultStepsForCategory(
    String category,
    int totalPrepTimeMinutes,
  ) {
    final totalSeconds = totalPrepTimeMinutes * 60;
    
    switch (category.toLowerCase()) {
      case 'appetizer':
        return [
          {'name': 'Gather ingredients', 'duration': (totalSeconds * 0.2).round()},
          {'name': 'Prepare & cook', 'duration': (totalSeconds * 0.6).round()},
          {'name': 'Plate & garnish', 'duration': (totalSeconds * 0.2).round()},
        ];
      
      case 'main':
        return [
          {'name': 'Prep ingredients', 'duration': (totalSeconds * 0.25).round()},
          {'name': 'Cook protein', 'duration': (totalSeconds * 0.35).round()},
          {'name': 'Prepare sides', 'duration': (totalSeconds * 0.25).round()},
          {'name': 'Final plating', 'duration': (totalSeconds * 0.15).round()},
        ];
      
      case 'dessert':
        return [
          {'name': 'Prepare base', 'duration': (totalSeconds * 0.3).round()},
          {'name': 'Bake/chill', 'duration': (totalSeconds * 0.5).round()},
          {'name': 'Decorate', 'duration': (totalSeconds * 0.2).round()},
        ];
      
      case 'beverage':
        return [
          {'name': 'Prepare ingredients', 'duration': (totalSeconds * 0.4).round()},
          {'name': 'Mix/brew', 'duration': (totalSeconds * 0.6).round()},
        ];
      
      case 'snack':
      case 'side':
        return [
          {'name': 'Prepare', 'duration': (totalSeconds * 0.5).round()},
          {'name': 'Cook/assemble', 'duration': (totalSeconds * 0.5).round()},
        ];
      
      default:
        return [
          {'name': 'Prepare ingredients', 'duration': (totalSeconds * 0.3).round()},
          {'name': 'Cook', 'duration': (totalSeconds * 0.5).round()},
          {'name': 'Finish & plate', 'duration': (totalSeconds * 0.2).round()},
        ];
    }
  }

  Future<List<Map<String, dynamic>>> getStepsForOrder(String orderId) async {
    final response = await _supabaseClient
        .from('order_item_preparation_steps')
        .select('*, order_items!inner(order_id)')
        .eq('order_items.order_id', orderId)
        .order('step_number');

    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> getStepsForOrderItem(String orderItemId) async {
    final response = await _supabaseClient
        .from('order_item_preparation_steps')
        .select()
        .eq('order_item_id', orderItemId)
        .order('step_number');

    return List<Map<String, dynamic>>.from(response);
  }
}
