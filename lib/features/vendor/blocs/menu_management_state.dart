part of 'menu_management_bloc.dart';

enum MenuManagementStatus {
  initial,
  loading,
  loaded,
  error,
  success,
}

enum MenuManagementAction {
  create,
  update,
  delete,
  toggle,
}

class MenuManagementState extends Equatable {
  final List<Dish> dishes;
  final List<Dish> filteredDishes;
  final MenuManagementStatus status;
  final String? errorMessage;
  final MenuManagementAction? lastAction;
  final String searchQuery;
  final DishFilters filters;
  final DishSortOption sortBy;
  final SortOrder sortOrder;

  const MenuManagementState({
    this.dishes = const [],
    this.filteredDishes = const [],
    this.status = MenuManagementStatus.initial,
    this.errorMessage,
    this.lastAction,
    this.searchQuery = '',
    this.filters = const DishFilters(),
    this.sortBy = DishSortOption.createdDate,
    this.sortOrder = SortOrder.descending,
  });

  MenuManagementState copyWith({
    List<Dish>? dishes,
    List<Dish>? filteredDishes,
    MenuManagementStatus? status,
    String? errorMessage,
    MenuManagementAction? lastAction,
    String? searchQuery,
    DishFilters? filters,
    DishSortOption? sortBy,
    SortOrder? sortOrder,
  }) {
    return MenuManagementState(
      dishes: dishes ?? this.dishes,
      filteredDishes: filteredDishes ?? this.filteredDishes,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      lastAction: lastAction ?? this.lastAction,
      searchQuery: searchQuery ?? this.searchQuery,
      filters: filters ?? this.filters,
      sortBy: sortBy ?? this.sortBy,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  List<Object?> get props => [
        dishes,
        filteredDishes,
        status,
        errorMessage,
        lastAction,
        searchQuery,
        filters,
        sortBy,
        sortOrder,
      ];

  bool get isLoading => status == MenuManagementStatus.loading;
  bool get isLoaded => status == MenuManagementStatus.loaded;
  bool get isError => status == MenuManagementStatus.error;
  bool get hasError => errorMessage != null;
  bool get isEmpty => filteredDishes.isEmpty;
  bool get hasSearchQuery => searchQuery.isNotEmpty;
  bool get hasFilters => filters != const DishFilters();
  int get dishCount => dishes.length;
  int get filteredDishCount => filteredDishes.length;
}