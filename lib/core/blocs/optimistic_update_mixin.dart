import 'package:flutter_bloc/flutter_bloc.dart';

/// Mixin that adds optimistic update capabilities to BLoCs
/// 
/// Allows immediate UI updates with automatic rollback on error.
/// Usage:
/// ```dart
/// class MyBloc extends Bloc<MyEvent, MyState> with OptimisticUpdateMixin<MyState> {
///   void updateSomething() async {
///     final rollback = applyOptimisticUpdate(
///       state.copyWith(value: newValue),
///     );
///     
///     try {
///       await apiCall();
///       // Success - optimistic update stays
///     } catch (e) {
///       rollback(); // Revert to previous state
///     }
///   }
/// }
/// ```
mixin OptimisticUpdateMixin<S> on BlocBase<S> {
  /// Apply an optimistic update and return a rollback function
  /// 
  /// The optimistic state is emitted immediately. If the operation fails,
  /// call the returned rollback function to revert to the previous state.
  /// 
  /// Returns a function that reverts to the state before the optimistic update.
  VoidCallback applyOptimisticUpdate(S optimisticState) {
    final previousState = state;
    emit(optimisticState);
    
    return () {
      emit(previousState);
    };
  }

  /// Apply an optimistic update with automatic error handling
  /// 
  /// Executes the operation and automatically rolls back if it fails.
  /// Returns true if successful, false if rolled back.
  Future<bool> withOptimisticUpdate(
    S optimisticState,
    Future<void> Function() operation,
  ) async {
    final rollback = applyOptimisticUpdate(optimisticState);
    
    try {
      await operation();
      return true;
    } catch (e) {
      rollback();
      rethrow;
    }
  }
}

/// Callback type for rollback functions
typedef VoidCallback = void Function();
