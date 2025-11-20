import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../map/blocs/map_feed_bloc.dart';
import '../models/vendor_model.dart';

class VendorFeedWidget extends StatelessWidget {
  const VendorFeedWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MapFeedBloc, MapFeedState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (state.hasError) {
          return Center(
            child: Text(
              'Error loading vendors',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
            ),
          );
        }

        final vendors = state.vendors;

        if (vendors.isEmpty) {
          return Center(
            child: Text(
              'No vendors found in this area',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
            ),
          );
        }

        return ListView.builder(
          itemCount: vendors.length,
          itemBuilder: (context, index) {
            final vendor = vendors[index];
            return VendorCard(vendor: vendor);
          },
        );
      },
    );
  }
}

class VendorCard extends StatelessWidget {
  final Vendor vendor;

  const VendorCard({
    super.key,
    required this.vendor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () {
          context.read<MapFeedBloc>().add(
                MapVendorSelected(vendor),
              );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundImage: vendor.logoUrl != null
                        ? NetworkImage(vendor.logoUrl!)
                        : null,
                    child: vendor.logoUrl == null
                        ? const Icon(Icons.store)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          vendor.name,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          vendor.cuisineType ?? 'Various',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                              ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star, size: 16, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(
                            vendor.rating.toStringAsFixed(1),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${vendor.dishCount} dishes',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
              if (vendor.description.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  vendor.description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}