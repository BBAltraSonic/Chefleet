import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../shared/utils/currency_formatter.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/glass_container.dart';
import '../../../core/routes/app_routes.dart';

class FavouritesScreen extends StatefulWidget {
  const FavouritesScreen({super.key});

  @override
  State<FavouritesScreen> createState() => _FavouritesScreenState();
}

class _FavouritesScreenState extends State<FavouritesScreen> {
  List<Map<String, dynamic>> _favourites = [];
  final Set<String> _optimisticRemovals = {};
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadFavourites();
  }

  Future<void> _loadFavourites() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final response = await Supabase.instance.client
          .from('favourites')
          .select('''
            dish_id,
            dishes!inner(
              id,
              name,
              description,
              price,
              prep_time_minutes,
              image_url,
              available,
              vendors!inner(
                business_name,
                location
              )
            )
          ''')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      setState(() {
        _favourites = List<Map<String, dynamic>>.from(response);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _removeFavourite(String dishId) async {
    // Optimistic update
    setState(() {
      _optimisticRemovals.add(dishId);
    });

    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      await Supabase.instance.client
          .from('favourites')
          .delete()
          .eq('user_id', userId)
          .eq('dish_id', dishId);

      // Actually remove from list after successful deletion
      setState(() {
        _favourites.removeWhere((fav) => fav['dish_id'] == dishId);
        _optimisticRemovals.remove(dishId);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Removed from favourites'),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      // Revert optimistic update on error
      setState(() {
        _optimisticRemovals.remove(dishId);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to remove: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Favourites'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppTheme.primaryGreen,
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: AppTheme.spacing16),
            Text(
              'Failed to load favourites',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: AppTheme.spacing8),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacing24,
              ),
              child: Text(
                _error!,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: AppTheme.spacing24),
            ElevatedButton.icon(
              onPressed: _loadFavourites,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final visibleFavourites = _favourites
        .where((fav) => !_optimisticRemovals.contains(fav['dish_id']))
        .toList();

    if (visibleFavourites.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _loadFavourites,
      child: ListView.builder(
        padding: const EdgeInsets.all(AppTheme.spacing16),
        itemCount: visibleFavourites.length,
        itemBuilder: (context, index) {
          final favourite = visibleFavourites[index];
          final dish = favourite['dishes'] as Map<String, dynamic>;
          return _buildFavouriteCard(dish);
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacing24),
        child: GlassContainer(
          borderRadius: AppTheme.radiusXLarge,
          blur: 18,
          opacity: 0.8,
          padding: const EdgeInsets.all(AppTheme.spacing32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.surfaceGreen,
                  border: Border.all(
                    color: AppTheme.primaryGreen,
                    width: 3,
                  ),
                ),
                child: const Icon(
                  Icons.favorite_border,
                  size: 60,
                  color: AppTheme.primaryGreen,
                ),
              ),
              const SizedBox(height: AppTheme.spacing24),
              Text(
                'No Favourites Yet',
                style: Theme.of(context).textTheme.headlineLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppTheme.spacing12),
              Text(
                'Discover amazing dishes and save your favourites for quick access',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppTheme.spacing32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => context.go(CustomerRoutes.map),
                  icon: const Icon(Icons.explore),
                  label: const Text('Explore Dishes'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFavouriteCard(Map<String, dynamic> dish) {
    final dishId = dish['id'] as String;
    final name = dish['name'] as String? ?? 'Unknown Dish';
    final description = dish['description'] as String? ?? '';
    final price = dish['price'] as num? ?? 0;
    final prepTime = dish['prep_time_minutes'] as int? ?? 0;
    final imageUrl = dish['image_url'] as String?;
    final isAvailable = dish['available'] as bool? ?? false;
    final vendor = dish['vendors'] as Map<String, dynamic>?;
    final businessName = vendor?['business_name'] as String? ?? 'Unknown Vendor';

    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacing12),
      child: GlassContainer(
        borderRadius: AppTheme.radiusLarge,
        blur: 12,
        opacity: 0.6,
        child: InkWell(
          onTap: () => context.push(CustomerRoutes.dishDetail(dishId)),
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spacing12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  child: imageUrl != null
                      ? Image.network(
                          imageUrl,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildPlaceholderImage();
                          },
                        )
                      : _buildPlaceholderImage(),
                ),
                const SizedBox(width: AppTheme.spacing12),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              name,
                              style: Theme.of(context).textTheme.headlineMedium,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.favorite,
                              color: Colors.red,
                            ),
                            onPressed: () => _removeFavourite(dishId),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppTheme.spacing4),
                      Text(
                        businessName,
                        style: Theme.of(context).textTheme.bodyMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppTheme.spacing8),
                      if (description.isNotEmpty)
                        Text(
                          description,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.secondaryGreen,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      const SizedBox(height: AppTheme.spacing12),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppTheme.spacing8,
                              vertical: AppTheme.spacing4,
                            ),
                            decoration: BoxDecoration(
                              color: isAvailable
                                  ? AppTheme.primaryGreen
                                  : AppTheme.surfaceOverlayDark,
                              borderRadius: BorderRadius.circular(
                                AppTheme.radiusSmall,
                              ),
                            ),
                            child: Text(
                              isAvailable ? 'Available' : 'Unavailable',
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: AppTheme.darkText,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            Icons.access_time,
                            size: 16,
                            color: AppTheme.secondaryGreen,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$prepTime min',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(width: AppTheme.spacing12),
                          Text(
                            CurrencyFormatter.format(price),
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: AppTheme.primaryGreen,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: 100,
      height: 100,
      color: AppTheme.surfaceGreen,
      child: const Icon(
        Icons.restaurant,
        size: 40,
        color: AppTheme.secondaryGreen,
      ),
    );
  }
}
