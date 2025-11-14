part of 'menu_management_bloc.dart';

abstract class MenuManagementEvent extends Equatable {
  const MenuManagementEvent();

  @override
  List<Object> get props => [];
}

class LoadDishes extends MenuManagementEvent {
  const LoadDishes();
}

class CreateDish extends MenuManagementEvent {
  final Dish dish;

  const CreateDish({required this.dish});

  @override
  List<Object> get props => [dish];
}

class UpdateDish extends MenuManagementEvent {
  final Dish dish;

  const UpdateDish({required this.dish});

  @override
  List<Object> get props => [dish];
}

class DeleteDish extends MenuManagementEvent {
  final String dishId;

  const DeleteDish({required this.dishId});

  @override
  List<Object> get props => [dishId];
}

class ToggleDishAvailability extends MenuManagementEvent {
  final Dish dish;

  const ToggleDishAvailability({required this.dish});

  @override
  List<Object> get props => [dish];
}

class SearchDishes extends MenuManagementEvent {
  final String query;

  const SearchDishes({required this.query});

  @override
  List<Object> get props => [query];
}

class FilterDishes extends MenuManagementEvent {
  final DishFilters filters;

  const FilterDishes({required this.filters});

  @override
  List<Object> get props => [filters];
}

class SortDishes extends MenuManagementEvent {
  final DishSortOption sortBy;
  final SortOrder sortOrder;

  const SortDishes({
    required this.sortBy,
    required this.sortOrder,
  });

  @override
  List<Object> get props => [sortBy, sortOrder];
}

class RefreshDishes extends MenuManagementEvent {
  const RefreshDishes();
}

class DishFilters extends Equatable {
  final bool availableOnly;
  final String? category;
  final int? minPrice;
  final int? maxPrice;

  const DishFilters({
    this.availableOnly = false,
    this.category,
    this.minPrice,
    this.maxPrice,
  });

  @override
  List<Object?> get props => [
        availableOnly,
        category,
        minPrice,
        maxPrice,
      ];

  DishFilters copyWith({
    bool? availableOnly,
    String? category,
    int? minPrice,
    int? maxPrice,
  }) {
    return DishFilters(
      availableOnly: availableOnly ?? this.availableOnly,
      category: category ?? this.category,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
    );
  }
}

enum DishSortOption {
  name,
  price,
  popularity,
  preparationTime,
  createdDate,
}

enum SortOrder {
  ascending,
  descending,
}