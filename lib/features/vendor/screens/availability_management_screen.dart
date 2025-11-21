import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../blocs/menu_management_bloc.dart';
import '../../feed/models/dish_model.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/glass_container.dart';

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
          actions: [
            IconButton(
              icon: const Icon(Icons.info_outline),
              tooltip: 'Help',
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Availability Management'),
                    content: const Text(
                      'Toggle dish availability on/off to control what customers can order. '
                      'Unavailable dishes won\'t appear in the feed.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Got it'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
        body: BlocBuilder<MenuManagementBloc, MenuManagementState>(
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.dishes.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.spacing24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.restaurant_menu_outlined,
                        size: 64,
                        color: AppTheme.secondaryGreen,
                      ),
                      const SizedBox(height: AppTheme.spacing16),
                      Text(
                        'No Menu Items',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: AppTheme.spacing8),
                      Text(
                        'Add dishes to your menu to manage their availability',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppTheme.secondaryGreen,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }

            final availableCount = state.dishes.where((d) => d.available).length;
            
            return Column(
              children: [
                // Summary card
                Container(
                  margin: const EdgeInsets.all(AppTheme.spacing16),
                  padding: const EdgeInsets.all(AppTheme.spacing16),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceGreen,
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    border: Border.all(color: AppTheme.borderGreen),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStat(
                        context,
                        'Total Items',
                        state.dishes.length.toString(),
                        Icons.restaurant,
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: AppTheme.borderGreen,
                      ),
                      _buildStat(
                        context,
                        'Available',
                        availableCount.toString(),
                        Icons.check_circle_outline,
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: AppTheme.borderGreen,
                      ),
                      _buildStat(
                        context,
                        'Unavailable',
                        (state.dishes.length - availableCount).toString(),
                        Icons.cancel_outlined,
                      ),
                    ],
                  ),
                ),
                
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing16),
                    itemCount: state.dishes.length,
                    itemBuilder: (context, index) {
                      final dish = state.dishes[index];
                      return _buildAvailabilityItem(context, dish);
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildStat(BuildContext context, String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.primaryGreen, size: 24),
        const SizedBox(height: AppTheme.spacing4),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: AppTheme.darkText,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppTheme.secondaryGreen,
          ),
        ),
      ],
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
