import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../feed/models/dish_model.dart';

// Events
abstract class VendorDishesEvent extends Equatable {
  const VendorDishesEvent();

  @override
  List<Object?> get props => [];
}

class LoadVendorDishes extends VendorDishesEvent {
  const LoadVendorDishes();
}

class AddDish extends VendorDishesEvent {
  const AddDish(this.dish);

  final Dish dish;

  @override
  List<Object?> get props => [dish];
}

class UpdateDish extends VendorDishesEvent {
  const UpdateDish(this.dish);

  final Dish dish;

  @override
  List<Object?> get props => [dish];
}

class DeleteDish extends VendorDishesEvent {
  const DeleteDish(this.dishId);

  final String dishId;

  @override
  List<Object?> get props => [dishId];
}

class ToggleDishAvailability extends VendorDishesEvent {
  const ToggleDishAvailability(this.dishId);

  final String dishId;

  @override
  List<Object?> get props => [dishId];
}

// States
abstract class VendorDishesState extends Equatable {
  const VendorDishesState();

  @override
  List<Object?> get props => [];
}

class VendorDishesInitial extends VendorDishesState {
  const VendorDishesInitial();
}

class VendorDishesLoading extends VendorDishesState {
  const VendorDishesLoading();
}

class VendorDishesLoaded extends VendorDishesState {
  const VendorDishesLoaded({required this.dishes});

  final List<Dish> dishes;

  @override
  List<Object?> get props => [dishes];
}

class VendorDishesError extends VendorDishesState {
  const VendorDishesError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

// Bloc
/// **DEPRECATED**: This BLoC is deprecated. Use [MenuManagementBloc] instead.
/// The "Dishes" bottom navigation tab now redirects to the Dashboard Menu tab,
/// which uses [MenuManagementBloc] with full Supabase integration.
@Deprecated('Use MenuManagementBloc instead')
class VendorDishesBloc extends Bloc<VendorDishesEvent, VendorDishesState> {
  VendorDishesBloc() : super(const VendorDishesInitial()) {
    on<LoadVendorDishes>(_onLoadVendorDishes);
    on<AddDish>(_onAddDish);
    on<UpdateDish>(_onUpdateDish);
    on<DeleteDish>(_onDeleteDish);
    on<ToggleDishAvailability>(_onToggleDishAvailability);
  }

  Future<void> _onLoadVendorDishes(
    LoadVendorDishes event,
    Emitter<VendorDishesState> emit,
  ) async {
    emit(const VendorDishesLoading());
    try {
      // TODO: Implement actual dish loading from Supabase
      // For now, return empty list
      await Future.delayed(const Duration(milliseconds: 500));
      emit(const VendorDishesLoaded(dishes: []));
    } catch (e) {
      emit(VendorDishesError('Failed to load dishes: $e'));
    }
  }

  Future<void> _onAddDish(
    AddDish event,
    Emitter<VendorDishesState> emit,
  ) async {
    if (state is VendorDishesLoaded) {
      try {
        // TODO: Implement add dish logic
        final currentState = state as VendorDishesLoaded;
        emit(VendorDishesLoaded(
          dishes: [...currentState.dishes, event.dish],
        ));
      } catch (e) {
        emit(VendorDishesError('Failed to add dish: $e'));
      }
    }
  }

  Future<void> _onUpdateDish(
    UpdateDish event,
    Emitter<VendorDishesState> emit,
  ) async {
    if (state is VendorDishesLoaded) {
      try {
        // TODO: Implement update dish logic
        final currentState = state as VendorDishesLoaded;
        final updatedDishes = currentState.dishes.map((dish) {
          return dish.id == event.dish.id ? event.dish : dish;
        }).toList();
        emit(VendorDishesLoaded(dishes: updatedDishes));
      } catch (e) {
        emit(VendorDishesError('Failed to update dish: $e'));
      }
    }
  }

  Future<void> _onDeleteDish(
    DeleteDish event,
    Emitter<VendorDishesState> emit,
  ) async {
    if (state is VendorDishesLoaded) {
      try {
        // TODO: Implement delete dish logic
        final currentState = state as VendorDishesLoaded;
        final updatedDishes = currentState.dishes
            .where((dish) => dish.id != event.dishId)
            .toList();
        emit(VendorDishesLoaded(dishes: updatedDishes));
      } catch (e) {
        emit(VendorDishesError('Failed to delete dish: $e'));
      }
    }
  }

  Future<void> _onToggleDishAvailability(
    ToggleDishAvailability event,
    Emitter<VendorDishesState> emit,
  ) async {
    if (state is VendorDishesLoaded) {
      try {
        // TODO: Implement toggle availability logic
        final currentState = state as VendorDishesLoaded;
        emit(VendorDishesLoaded(dishes: currentState.dishes));
      } catch (e) {
        emit(VendorDishesError('Failed to toggle availability: $e'));
      }
    }
  }
}
