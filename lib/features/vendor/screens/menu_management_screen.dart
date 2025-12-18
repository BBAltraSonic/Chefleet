import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../shared/utils/currency_formatter.dart';
import '../../feed/models/dish_model.dart';
import '../blocs/menu_management_bloc.dart';
import '../widgets/dish_form.dart';
import '../widgets/search_filter_bar.dart';
import '../widgets/dish_list_view.dart';

class MenuManagementScreen extends StatefulWidget {
  const MenuManagementScreen({super.key});

  @override
  State<MenuManagementScreen> createState() => _MenuManagementScreenState();
}

class _MenuManagementScreenState extends State<MenuManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Load dishes when screen initializes
    context.read<MenuManagementBloc>().add(const LoadDishes());
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _showDishForm({Dish? dish}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DishForm(dish: dish),
    );
  }

  void _showDeleteConfirmation(Dish dish) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Dish'),
        content: Text('Are you sure you want to delete "${dish.name}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<MenuManagementBloc>().add(DeleteDish(dishId: dish.id));
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu Management'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              icon: Icon(Icons.restaurant_menu),
              text: 'Menu Items',
            ),
            Tab(
              icon: Icon(Icons.analytics),
              text: 'Analytics',
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<MenuManagementBloc>().add(const RefreshDishes());
            },
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMenuItemsTab(),
          _buildAnalyticsTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showDishForm(),
        tooltip: 'Add New Dish',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildMenuItemsTab() {
    return Column(
      children: [
        // Search and Filter Bar
        SearchFilterBar(
          searchController: _searchController,
          onSearchChanged: (query) {
            context.read<MenuManagementBloc>().add(SearchDishes(query: query));
          },
          onFilterChanged: (filters) {
            context.read<MenuManagementBloc>().add(FilterDishes(filters: filters));
          },
          onSortChanged: (sortBy, sortOrder) {
            context.read<MenuManagementBloc>().add(SortDishes(
              sortBy: sortBy,
              sortOrder: sortOrder,
            ));
          },
        ),

        // Menu Items List
        Expanded(
          child: BlocBuilder<MenuManagementBloc, MenuManagementState>(
            builder: (context, state) {
              if (state.isLoading) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (state.isError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error loading menu',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        state.errorMessage ?? 'Unknown error occurred',
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          context.read<MenuManagementBloc>().add(const LoadDishes());
                        },
                        child: const Text('Try Again'),
                      ),
                    ],
                  ),
                );
              }

              if (state.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.restaurant_menu_outlined,
                        size: 64,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No dishes yet',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Add your first dish to get started',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () => _showDishForm(),
                        icon: const Icon(Icons.add),
                        label: const Text('Add First Dish'),
                      ),
                    ],
                  ),
                );
              }

              // Show search results count if searching
              if (state.hasSearchQuery || state.hasFilters) {
                return Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      child: Text(
                        '${state.filteredDishCount} of ${state.dishCount} dishes',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                    Expanded(
                      child: DishListView(
                        dishes: state.filteredDishes,
                        onEdit: (dish) => _showDishForm(dish: dish),
                        onDelete: _showDeleteConfirmation,
                        onToggleAvailability: (dish) {
                          context.read<MenuManagementBloc>().add(
                            ToggleDishAvailability(dish: dish),
                          );
                        },
                      ),
                    ),
                  ],
                );
              }

              // Normal list view
              return DishListView(
                dishes: state.filteredDishes,
                onEdit: (dish) => _showDishForm(dish: dish),
                onDelete: _showDeleteConfirmation,
                onToggleAvailability: (dish) {
                  context.read<MenuManagementBloc>().add(
                    ToggleDishAvailability(dish: dish),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAnalyticsTab() {
    return BlocBuilder<MenuManagementBloc, MenuManagementState>(
      builder: (context, state) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Overview Cards
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Total Dishes',
                      '${state.dishCount}',
                      Icons.restaurant_menu,
                      Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      'Available',
                      '${state.dishes.where((d) => d.available).length}',
                      Icons.check_circle,
                      Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Unavailable',
                      '${state.dishes.where((d) => !d.available).length}',
                      Icons.cancel,
                      Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      'Featured',
                      '${state.dishes.where((d) => d.isFeatured).length}',
                      Icons.star,
                      Colors.amber,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Categories Breakdown
              Text(
                'Categories',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              _buildCategoriesBreakdown(state.dishes),

              const SizedBox(height: 24),

              // Popular Dishes
              Text(
                'Popular Dishes',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              _buildPopularDishes(state.dishes),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriesBreakdown(List<Dish> dishes) {
    final Map<String, int> categoryCount = {};

    for (final dish in dishes) {
      final category = dish.categoryEnum ?? 'Other';
      categoryCount[category] = (categoryCount[category] ?? 0) + 1;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: categoryCount.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Expanded(child: Text(entry.key)),
                  Text('${entry.value} dishes'),
                  const SizedBox(width: 16),
                  SizedBox(
                    width: 100,
                    child: LinearProgressIndicator(
                      value: entry.value / dishes.length,
                      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildPopularDishes(List<Dish> dishes) {
    final popularDishes = List<Dish>.from(dishes)
      ..sort((a, b) => (b.popularityScore ?? 0).compareTo(a.popularityScore ?? 0));

    if (popularDishes.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('No popularity data available yet'),
        ),
      );
    }

    return Card(
      child: Column(
        children: popularDishes.take(5).map((dish) {
          return ListTile(
            leading: dish.imageUrl != null
                ? Image.network(
                    dish.imageUrl!,
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 48,
                        height: 48,
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        child: const Icon(Icons.restaurant),
                      );
                    },
                  )
                : Container(
                    width: 48,
                    height: 48,
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    child: const Icon(Icons.restaurant),
                  ),
            title: Text(dish.name),
            subtitle: Text(CurrencyFormatter.formatCents(dish.priceCents)),
            trailing: Text('${dish.popularityScore ?? 0}'),
          );
        }).toList(),
      ),
    );
  }
}