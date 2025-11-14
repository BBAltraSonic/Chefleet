import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../feed/models/dish_model.dart';

part 'menu_management_event.dart';
part 'menu_management_state.dart';

class MenuManagementBloc
    extends Bloc<MenuManagementEvent, MenuManagementState> {
  final SupabaseClient _supabaseClient;

  MenuManagementBloc({required SupabaseClient supabaseClient})
      : _supabaseClient = supabaseClient,
        super(const MenuManagementState()) {
    on<LoadDishes>(_onLoadDishes);
    on<CreateDish>(_onCreateDish);
    on<UpdateDish>(_onUpdateDish);
    on<DeleteDish>(_onDeleteDish);
    on<ToggleDishAvailability>(_onToggleDishAvailability);
    on<SearchDishes>(_onSearchDishes);
    on<FilterDishes>(_onFilterDishes);
    on<SortDishes>(_onSortDishes);
    on<RefreshDishes>(_onRefreshDishes);
  }

  void _onLoadDishes(
    LoadDishes event,
    Emitter<MenuManagementState> emit,
  ) async {
    emit(state.copyWith(
      status: MenuManagementStatus.loading,
    ));

    try {
      final currentUser = _supabaseClient.auth.currentUser;
      if (currentUser == null) {
        emit(state.copyWith(
          status: MenuManagementStatus.error,
          errorMessage: 'User not authenticated',
        ));
        return;
      }

      // Get vendor ID for current user
      final vendorResponse = await _supabaseClient
          .from('vendors')
          .select('id')
          .eq('owner_id', currentUser.id)
          .single();

      final vendorId = vendorResponse['id'] as String;

      final response = await _supabaseClient
          .from('dishes')
          .select()
          .eq('vendor_id', vendorId)
          .order('created_at', ascending: false);

      final dishes = (response as List)
          .map((json) => Dish.fromJson(json))
          .toList();

      emit(state.copyWith(
        status: MenuManagementStatus.loaded,
        dishes: dishes,
        filteredDishes: dishes,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: MenuManagementStatus.error,
        errorMessage: 'Failed to load dishes: ${e.toString()}',
      ));
    }
  }

  void _onCreateDish(
    CreateDish event,
    Emitter<MenuManagementState> emit,
  ) async {
    emit(state.copyWith(
      status: MenuManagementStatus.loading,
    ));

    try {
      final currentUser = _supabaseClient.auth.currentUser;
      if (currentUser == null) {
        emit(state.copyWith(
          status: MenuManagementStatus.error,
          errorMessage: 'User not authenticated',
        ));
        return;
      }

      // Get vendor ID for current user
      final vendorResponse = await _supabaseClient
          .from('vendors')
          .select('id')
          .eq('owner_id', currentUser.id)
          .single();

      final vendorId = vendorResponse['id'] as String;

      final dishData = {
        'vendor_id': vendorId,
        'name': event.dish.name,
        'description': event.dish.description,
        'price': event.dish.price,
        'category': event.dish.category,
        'image_url': event.dish.imageUrl,
        'available': event.dish.available,
        'description_long': event.dish.descriptionLong,
        'ingredients': event.dish.ingredients,
        'allergens': event.dish.allergens,
        'dietary_restrictions': event.dish.dietaryRestrictions,
        'preparation_time_minutes': event.dish.preparationTimeMinutes,
        'spice_level': event.dish.spiceLevel,
        'is_featured': event.dish.isFeatured,
        'category_enum': event.dish.categoryEnum,
      };

      final response = await _supabaseClient
          .from('dishes')
          .insert(dishData)
          .select()
          .single();

      final createdDish = Dish.fromJson(response);

      final updatedDishes = [createdDish, ...state.dishes];
      emit(state.copyWith(
        status: MenuManagementStatus.loaded,
        dishes: updatedDishes,
        filteredDishes: updatedDishes,
        lastAction: MenuManagementAction.create,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: MenuManagementStatus.error,
        errorMessage: 'Failed to create dish: ${e.toString()}',
      ));
    }
  }

  void _onUpdateDish(
    UpdateDish event,
    Emitter<MenuManagementState> emit,
  ) async {
    emit(state.copyWith(
      status: MenuManagementStatus.loading,
    ));

    try {
      final dishData = {
        'name': event.dish.name,
        'description': event.dish.description,
        'price': event.dish.price,
        'category': event.dish.category,
        'image_url': event.dish.imageUrl,
        'available': event.dish.available,
        'description_long': event.dish.descriptionLong,
        'ingredients': event.dish.ingredients,
        'allergens': event.dish.allergens,
        'dietary_restrictions': event.dish.dietaryRestrictions,
        'preparation_time_minutes': event.dish.preparationTimeMinutes,
        'spice_level': event.dish.spiceLevel,
        'is_featured': event.dish.isFeatured,
        'category_enum': event.dish.categoryEnum,
        'updated_at': DateTime.now().toIso8601String(),
      };

      final response = await _supabaseClient
          .from('dishes')
          .update(dishData)
          .eq('id', event.dish.id)
          .select()
          .single();

      final updatedDish = Dish.fromJson(response);

      final updatedDishes = state.dishes.map((dish) {
        return dish.id == updatedDish.id ? updatedDish : dish;
      }).toList();

      emit(state.copyWith(
        status: MenuManagementStatus.loaded,
        dishes: updatedDishes,
        filteredDishes: _applyFiltersAndSorting(updatedDishes),
        lastAction: MenuManagementAction.update,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: MenuManagementStatus.error,
        errorMessage: 'Failed to update dish: ${e.toString()}',
      ));
    }
  }

  void _onDeleteDish(
    DeleteDish event,
    Emitter<MenuManagementState> emit,
  ) async {
    emit(state.copyWith(
      status: MenuManagementStatus.loading,
    ));

    try {
      await _supabaseClient
          .from('dishes')
          .delete()
          .eq('id', event.dishId);

      final updatedDishes = state.dishes
          .where((dish) => dish.id != event.dishId)
          .toList();

      emit(state.copyWith(
        status: MenuManagementStatus.loaded,
        dishes: updatedDishes,
        filteredDishes: _applyFiltersAndSorting(updatedDishes),
        lastAction: MenuManagementAction.delete,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: MenuManagementStatus.error,
        errorMessage: 'Failed to delete dish: ${e.toString()}',
      ));
    }
  }

  void _onToggleDishAvailability(
    ToggleDishAvailability event,
    Emitter<MenuManagementState> emit,
  ) async {
    try {
      final updatedDish = event.dish.copyWith(available: !event.dish.available);

      final dishData = {
        'available': updatedDish.available,
        'updated_at': DateTime.now().toIso8601String(),
      };

      await _supabaseClient
          .from('dishes')
          .update(dishData)
          .eq('id', event.dish.id);

      final updatedDishes = state.dishes.map((dish) {
        return dish.id == updatedDish.id ? updatedDish : dish;
      }).toList();

      emit(state.copyWith(
        dishes: updatedDishes,
        filteredDishes: _applyFiltersAndSorting(updatedDishes),
      ));
    } catch (e) {
      emit(state.copyWith(
        status: MenuManagementStatus.error,
        errorMessage: 'Failed to toggle dish availability: ${e.toString()}',
      ));
    }
  }

  void _onSearchDishes(
    SearchDishes event,
    Emitter<MenuManagementState> emit,
  ) {
    final filteredDishes = state.dishes.where((dish) {
      return dish.name.toLowerCase().contains(event.query.toLowerCase()) ||
          (dish.description?.toLowerCase().contains(event.query.toLowerCase()) ?? false);
    }).toList();

    emit(state.copyWith(
      filteredDishes: filteredDishes,
      searchQuery: event.query,
    ));
  }

  void _onFilterDishes(
    FilterDishes event,
    Emitter<MenuManagementState> emit,
  ) {
    emit(state.copyWith(
      filters: event.filters,
      filteredDishes: _applyFiltersAndSorting(state.dishes),
    ));
  }

  void _onSortDishes(
    SortDishes event,
    Emitter<MenuManagementState> emit,
  ) {
    emit(state.copyWith(
      sortBy: event.sortBy,
      sortOrder: event.sortOrder,
      filteredDishes: _applyFiltersAndSorting(state.dishes),
    ));
  }

  void _onRefreshDishes(
    RefreshDishes event,
    Emitter<MenuManagementState> emit,
  ) {
    add(LoadDishes());
  }

  List<Dish> _applyFiltersAndSorting(List<Dish> dishes) {
    List<Dish> filteredDishes = List.from(dishes);

    // Apply filters
    if (state.filters.availableOnly) {
      filteredDishes = filteredDishes.where((dish) => dish.available).toList();
    }

    if (state.filters.category != null) {
      filteredDishes = filteredDishes
          .where((dish) => dish.categoryEnum == state.filters.category)
          .toList();
    }

    if (state.filters.minPrice != null) {
      filteredDishes = filteredDishes
          .where((dish) => dish.priceCents >= state.filters.minPrice!)
          .toList();
    }

    if (state.filters.maxPrice != null) {
      filteredDishes = filteredDishes
          .where((dish) => dish.priceCents <= state.filters.maxPrice!)
          .toList();
    }

    // Apply search
    if (state.searchQuery.isNotEmpty) {
      filteredDishes = filteredDishes.where((dish) {
        return dish.name.toLowerCase().contains(state.searchQuery.toLowerCase()) ||
            (dish.description?.toLowerCase().contains(state.searchQuery.toLowerCase()) ?? false);
      }).toList();
    }

    // Apply sorting
    filteredDishes.sort((a, b) {
      int comparison = 0;

      switch (state.sortBy) {
        case DishSortOption.name:
          comparison = a.name.compareTo(b.name);
          break;
        case DishSortOption.price:
          comparison = a.priceCents.compareTo(b.priceCents);
          break;
        case DishSortOption.popularity:
          comparison = (b.popularityScore ?? 0).compareTo(a.popularityScore ?? 0);
          break;
        case DishSortOption.preparationTime:
          comparison = a.preparationTimeMinutes.compareTo(b.preparationTimeMinutes);
          break;
        case DishSortOption.createdDate:
          comparison = b.createdAt?.compareTo(a.createdAt ?? DateTime.now()) ?? 0;
          break;
      }

      return state.sortOrder == SortOrder.ascending ? comparison : -comparison;
    });

    return filteredDishes;
  }
}