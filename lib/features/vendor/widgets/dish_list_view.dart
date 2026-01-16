import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_strings.dart';

import '../../feed/models/dish_model.dart';
import '../blocs/menu_management_bloc.dart';
import 'dish_card.dart';

class DishListView extends StatelessWidget {
  final List<Dish> dishes;
  final Function(Dish) onEdit;
  final Function(Dish) onDelete;
  final Function(Dish) onToggleAvailability;

  const DishListView({
    super.key,
    required this.dishes,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleAvailability,
  });

  @override
  Widget build(BuildContext context) {
    if (dishes.isEmpty) {
      return const Center(
        child: Text(AppStrings.noDishesFound),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<MenuManagementBloc>().add(RefreshDishes());
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: dishes.length,
        itemBuilder: (context, index) {
          final dish = dishes[index];
          return DishCard(
            dish: dish,
            onEdit: () => onEdit(dish),
            onDelete: () => onDelete(dish),
            onToggleAvailability: () => onToggleAvailability(dish),
          );
        },
      ),
    );
  }
}