import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../blocs/vendor_dishes_bloc.dart';
import '../widgets/dish_card.dart';

/// Screen for vendors to view and manage their dishes.
///
/// Features:
/// - List of vendor's dishes
/// - Add/edit dish forms
/// - Toggle availability
/// - Pricing and inventory
class VendorDishesScreen extends StatelessWidget {
  const VendorDishesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => VendorDishesBloc()..add(const LoadVendorDishes()),
      child: const _VendorDishesView(),
    );
  }
}

class _VendorDishesView extends StatelessWidget {
  const _VendorDishesView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<VendorDishesBloc, VendorDishesState>(
        builder: (context, state) {
          if (state is VendorDishesLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is VendorDishesError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context
                          .read<VendorDishesBloc>()
                          .add(const LoadVendorDishes());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is VendorDishesLoaded) {
            if (state.dishes.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.restaurant_outlined,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No dishes yet',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Add your first dish to get started',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        // TODO: Navigate to add dish screen
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Add Dish'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context
                    .read<VendorDishesBloc>()
                    .add(const LoadVendorDishes());
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.dishes.length,
                itemBuilder: (context, index) {
                  final dish = state.dishes[index];
                  return DishCard(
                    dish: dish,
                    onEdit: () {
                      // TODO: Navigate to edit dish screen
                    },
                    onDelete: () {
                      // TODO: Show delete confirmation dialog
                    },
                    onToggleAvailability: () {
                      // TODO: Toggle dish availability
                    },
                  );
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navigate to add dish screen
        },
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add),
      ),
    );
  }
}
