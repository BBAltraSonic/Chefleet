import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../blocs/menu_management_bloc.dart';
import '../../feed/models/dish_model.dart';
import '../../../core/theme/app_theme.dart';

class AvailabilityManagementScreen extends StatelessWidget {
  final String vendorId;

  const AvailabilityManagementScreen({super.key, required this.vendorId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MenuManagementBloc(
        supabaseClient: Supabase.instance.client,
      )..add(const LoadDishes()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Availability Management'),
        ),
        body: BlocBuilder<MenuManagementBloc, MenuManagementState>(
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.dishes.isEmpty) {
              return const Center(child: Text('No items in menu'));
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.dishes.length,
              itemBuilder: (context, index) {
                final dish = state.dishes[index];
                return _buildAvailabilityItem(context, dish);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildAvailabilityItem(BuildContext context, Dish dish) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: SwitchListTile(
        title: Text(
          dish.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          dish.available ? 'Available' : 'Unavailable',
          style: TextStyle(
            color: dish.available ? Colors.green : Colors.red,
          ),
        ),
        value: dish.available,
        activeColor: AppTheme.primaryGreen,
        onChanged: (bool value) {
          context.read<MenuManagementBloc>().add(
                ToggleDishAvailability(
                  dish: dish,
                ),
              );
        },
        secondary: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
            image: dish.imageUrl != null
                ? DecorationImage(
                    image: NetworkImage(dish.imageUrl!),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: dish.imageUrl == null
              ? const Icon(Icons.restaurant, size: 20)
              : null,
        ),
      ),
    );
  }
}
