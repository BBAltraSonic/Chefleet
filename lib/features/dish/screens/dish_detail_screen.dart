import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../feed/models/dish_model.dart';
import '../../feed/models/vendor_model.dart';
import '../../order/blocs/order_bloc.dart';
import '../../order/blocs/order_state.dart';
import '../../../shared/widgets/glass_container.dart';
import '../../../shared/widgets/loading_states.dart';
import '../../../core/theme/app_theme.dart' as theme;
import '../../../core/repositories/order_repository.dart';
import '../../../core/services/deep_link_service.dart';
import '../../../core/services/navigation_state_service.dart';
import '../../../core/blocs/navigation_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DishDetailScreen extends StatefulWidget {
  final String dishId;

  const DishDetailScreen({
    super.key,
    required this.dishId,
  });

  @override
  State<DishDetailScreen> createState() => _DishDetailScreenState();
}

class _DishDetailScreenState extends State<DishDetailScreen> {
  Dish? _dish;
  Vendor? _vendor;
  bool _isLoading = true;
  String? _error;
  late OrderBloc _orderBloc;

  @override
  void initState() {
    super.initState();
    _orderBloc = OrderBloc(
      orderRepository: OrderRepository(Supabase.instance.client),
    );
    _saveNavigationState();
    _loadDishDetails();
  }

  @override
  void dispose() {
    _orderBloc.close();
    _clearNavigationState();
    super.dispose();
  }

  Future<void> _loadDishDetails() async {
    try {
      // TODO: Implement actual data loading from Supabase
      // For now, create mock data
      _dish = Dish(
        id: widget.dishId,
        vendorId: 'vendor_1',
        name: 'Spicy Thai Basil Fried Rice',
        description: 'Authentic Thai-style fried rice with fresh basil, chilies, and your choice of protein. Stir-fried to perfection with aromatic spices and served with a side of cucumber salad.',
        priceCents: 1299,
        prepTimeMinutes: 15,
        available: true,
        imageUrl: 'https://example.com/dish.jpg',
        category: 'Thai Cuisine',
        tags: ['Spicy', 'Rice', 'Quick'],
        spiceLevel: 3,
        isVegetarian: false,
        allergens: ['Soy', 'Fish Sauce', 'Peanuts'],
        popularityScore: 4.7,
        orderCount: 234,
      );

      _vendor = Vendor(
        id: 'vendor_1',
        name: 'Bangkok Street Eats',
        description: 'Authentic Thai street food made fresh daily',
        latitude: 37.7749,
        longitude: -122.4194,
        dishCount: 25,
        isActive: true,
        rating: 4.8,
        cuisineType: 'Thai Street Food',
        address: '123 Market St, San Francisco, CA 94103',
        logoUrl: 'https://example.com/vendor.jpg',
        phoneNumber: '+1-415-555-0123',
        openHoursJson: {
          'monday': {'open': '11:00', 'close': '22:00'},
          'tuesday': {'open': '11:00', 'close': '22:00'},
          'wednesday': {'open': '11:00', 'close': '22:00'},
          'thursday': {'open': '11:00', 'close': '22:00'},
          'friday': {'open': '11:00', 'close': '23:00'},
          'saturday': {'open': '11:00', 'close': '23:00'},
          'sunday': {'open': '12:00', 'close': '21:00'},
        },
      );

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Failed to load dish details: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(
          value: context.read<NavigationBloc>(),
        ),
        BlocProvider(
          create: (context) => _orderBloc,
        ),
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<OrderBloc, OrderState>(
            listener: (context, orderState) {
              // Update navigation order count
              final navigationBloc = context.read<NavigationBloc>();
              navigationBloc.updateActiveOrderCount(orderState.itemCount);

              if (orderState.status == OrderStatus.success) {
                _showOrderSuccess(context);
              } else if (orderState.status == OrderStatus.error && orderState.errorMessage != null) {
                _showOrderError(context, orderState.errorMessage!);
              }
            },
          ),
        ],
        child: BlocBuilder<OrderBloc, OrderState>(
          builder: (context, orderState) {
            return Stack(
              children: [
                WillPopScope(
                  onWillPop: _onWillPop,
                  child: Scaffold(
                    backgroundColor: Colors.transparent,
                    body: _isLoading
                        ? const LoadingStateWidget(message: 'Loading dish details...')
                        : _error != null
                            ? _buildErrorState()
                            : _dish != null && _vendor != null
                                ? _buildDishDetail(orderState)
                                : const EmptyStateWidget(
                                    message: 'Dish not found',
                                    icon: Icons.restaurant,
                                  ),
                  ),
                ),
                // Show order loading overlay
                if (orderState.isPlacingOrder)
                  const OrderLoadingWidget(),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return ErrorStateWidget(
      error: _error!,
      onRetry: _loadDishDetails,
    );
  }

  Widget _buildDishDetail(OrderState orderState) {
    return CustomScrollView(
      slivers: [
        _buildHeroImage(),
        _buildContent(orderState),
      ],
    );
  }

  Widget _buildHeroImage() {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: Colors.transparent,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => context.pop(),
      ),
      actions: [
        if (_dish != null && _vendor != null)
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: () => _shareDish(),
          ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            if (_dish!.imageUrl != null)
              Image.network(
                _dish!.imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[300],
                    child: const Icon(
                      Icons.restaurant,
                      size: 100,
                      color: Colors.grey,
                    ),
                  );
                },
              )
            else
              Container(
                color: Colors.grey[300],
                child: const Icon(
                  Icons.restaurant,
                  size: 100,
                  color: Colors.grey,
                ),
              ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(OrderState orderState) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDishHeader(),
            const SizedBox(height: 24),
            _buildVendorInfo(),
            const SizedBox(height: 24),
            _buildDietaryInfo(),
            const SizedBox(height: 24),
            _buildDescription(),
            const SizedBox(height: 24),
            _buildQuantitySelector(orderState),
            const SizedBox(height: 24),
            _buildPickupTimeSelector(orderState),
            const SizedBox(height: 32),
            _buildOrderButton(orderState),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildDishHeader() {
    return GlassContainer(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Semantics(
                        header: true,
                        label: 'Dish Name',
                        child: Text(
                          _dish!.name,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Semantics(
                        label: 'Price: ${_dish!.formattedPrice}',
                        child: Text(
                          _dish!.formattedPrice,
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: theme.AppTheme.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Semantics(
                  label: _dish!.available ? 'Dish is currently available' : 'Dish is currently unavailable',
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _dish!.available ? Colors.green : Colors.red,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _dish!.available ? 'Available' : 'Unavailable',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.schedule, size: 16, color: Colors.grey[300]),
                const SizedBox(width: 4),
                Text(
                  _dish!.formattedPrepTime,
                  style: TextStyle(color: Colors.grey[300]),
                ),
                const SizedBox(width: 16),
                Icon(Icons.local_fire_department, size: 16, color: Colors.grey[300]),
                const SizedBox(width: 4),
                Text(
                  _dish!.spiceLevelDisplay,
                  style: TextStyle(color: Colors.grey[300]),
                ),
                const SizedBox(width: 16),
                Icon(Icons.star, size: 16, color: Colors.grey[300]),
                const SizedBox(width: 4),
                Text(
                  '${_dish!.popularityScore.toStringAsFixed(1)} (${_dish!.orderCount} orders)',
                  style: TextStyle(color: Colors.grey[300]),
                ),
              ],
            ),
            if (_dish!.tags.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: _dish!.tags.map((tag) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.AppTheme.primaryColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    tag,
                    style: TextStyle(
                      color: theme.AppTheme.primaryColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildVendorInfo() {
    return GlassContainer(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(12),
              ),
              child: _vendor!.logoUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        _vendor!.logoUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.store, color: Colors.grey);
                        },
                      ),
                    )
                  : const Icon(Icons.store, color: Colors.grey),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _vendor!.name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.star, size: 16, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        '${_vendor!.rating?.toStringAsFixed(1) ?? 'N/A'}',
                        style: TextStyle(color: Colors.grey[300]),
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.location_on, size: 16, color: Colors.grey[300]),
                      const SizedBox(width: 4),
                      Text(
                        '2.3 mi away',
                        style: TextStyle(color: Colors.grey[300]),
                      ),
                    ],
                  ),
                  if (_vendor!.cuisineType != null && _vendor!.cuisineType!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      _vendor!.cuisineType!,
                      style: TextStyle(
                        color: Colors.grey[300],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDietaryInfo() {
    if (_dish!.dietaryBadges.isEmpty && _dish!.allergens.isEmpty) {
      return const SizedBox.shrink();
    }

    return GlassContainer(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dietary Information',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            if (_dish!.dietaryBadges.isNotEmpty) ...[
              Text(
                'Suitable for:',
                style: TextStyle(
                  color: Colors.grey[300],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: _dish!.dietaryBadges.map((badge) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.green.withOpacity(0.5)),
                  ),
                  child: Text(
                    badge,
                    style: TextStyle(
                      color: Colors.green[300],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )).toList(),
              ),
              const SizedBox(height: 16),
            ],
            if (_dish!.allergens.isNotEmpty) ...[
              Text(
                'Contains allergens:',
                style: TextStyle(
                  color: Colors.grey[300],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: _dish!.allergens.map((allergen) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.orange.withOpacity(0.5)),
                  ),
                  child: Text(
                    allergen,
                    style: TextStyle(
                      color: Colors.orange[300],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDescription() {
    return GlassContainer(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Description',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _dish!.displayDescription,
              style: TextStyle(
                color: Colors.grey[300],
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantitySelector(OrderState orderState) {
    // Find existing item in cart or use default quantity of 1
    final existingItem = orderState.items.firstWhere(
      (item) => item.dishId == widget.dishId,
      orElse: () => OrderItem(
        dishId: widget.dishId,
        dishName: _dish!.name,
        dishPrice: _dish!.price,
        quantity: 1,
        vendorId: _dish!.vendorId,
        vendorName: _vendor!.name,
      ),
    );

    return GlassContainer(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Semantics(
              header: true,
              child: Text(
                'Quantity',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Semantics(
                  button: true,
                  enabled: existingItem.quantity > 1,
                  label: existingItem.quantity > 1
                      ? 'Decrease quantity to ${existingItem.quantity - 1}'
                      : 'Minimum quantity reached',
                  child: IconButton(
                    onPressed: existingItem.quantity > 1
                        ? () => _orderBloc.updateItem(
                              dishId: widget.dishId,
                              quantity: existingItem.quantity - 1,
                            )
                        : null,
                    icon: const Icon(Icons.remove_circle_outline),
                    iconSize: 32,
                    color: existingItem.quantity > 1 ? theme.AppTheme.primaryColor : Colors.grey,
                  ),
                ),
                Semantics(
                  label: 'Current quantity: ${existingItem.quantity}',
                  child: Container(
                    width: 60,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                    ),
                    child: Center(
                      child: Text(
                        '${existingItem.quantity}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                Semantics(
                  button: true,
                  label: 'Increase quantity to ${existingItem.quantity + 1}',
                  child: IconButton(
                    onPressed: () => _orderBloc.updateItem(
                      dishId: widget.dishId,
                      quantity: existingItem.quantity + 1,
                    ),
                    icon: const Icon(Icons.add_circle_outline),
                    iconSize: 32,
                    color: theme.AppTheme.primaryColor,
                  ),
                ),
                const Spacer(),
                Semantics(
                  label: 'Total price: ${(_dish!.price * existingItem.quantity).toStringAsFixed(2)}',
                  child: Text(
                    'Total: ${(_dish!.price * existingItem.quantity).toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: theme.AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPickupTimeSelector(OrderState orderState) {
    return GlassContainer(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pickup Time',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => _selectPickupTime(orderState),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: orderState.pickupTime != null
                        ? theme.AppTheme.primaryColor.withOpacity(0.5)
                        : Colors.white.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.schedule,
                      color: orderState.pickupTime != null
                          ? theme.AppTheme.primaryColor
                          : Colors.grey[400],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            orderState.pickupTime != null
                                ? _formatPickupTime(orderState.pickupTime!)
                                : 'ASAP (15-20 min)',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            orderState.pickupTime != null
                                ? 'Selected pickup time'
                                : 'Ready around ${_calculateAsapTime()}',
                            style: TextStyle(
                              color: Colors.grey[300],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderButton(OrderState orderState) {
    // Check if item is already in cart
    final existingItem = orderState.items.firstWhere(
      (item) => item.dishId == widget.dishId,
      orElse: () => OrderItem(
        dishId: widget.dishId,
        dishName: _dish!.name,
        dishPrice: _dish!.price,
        quantity: 1,
        vendorId: _dish!.vendorId,
        vendorName: _vendor!.name,
      ),
    );

    final totalAmount = _dish!.price * existingItem.quantity;
    final isPlacingOrder = orderState.status == OrderStatus.placing;
    final canPlaceOrder = _dish!.available && orderState.pickupTime != null;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: canPlaceOrder && !isPlacingOrder ? () => _placeOrder(existingItem.quantity) : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: canPlaceOrder ? theme.AppTheme.primaryColor : Colors.grey,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: isPlacingOrder
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text('Placing Order...'),
                ],
              )
            : Text(
                'Place Order • ${totalAmount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  void _placeOrder(int quantity) {
    // Add or update item in cart
    _orderBloc.addItem(
      dishId: widget.dishId,
      quantity: quantity,
      specialInstructions: null,
    );

    // Place the order
    _orderBloc.placeOrder();
  }

  void _selectPickupTime(OrderState orderState) async {
    final now = DateTime.now();
    final selectedTime = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 7)),
    );

    if (selectedTime != null) {
      final selectedTimeOfDay = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(now.add(const Duration(minutes: 15))),
      );

      if (selectedTimeOfDay != null) {
        final pickupDateTime = DateTime(
          selectedTime.year,
          selectedTime.month,
          selectedTime.day,
          selectedTimeOfDay.hour,
          selectedTimeOfDay.minute,
        );

        _orderBloc.setPickupTime(pickupDateTime);
      }
    }
  }

  String _formatPickupTime(DateTime dateTime) {
    final time = TimeOfDay.fromDateTime(dateTime);
    return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
  }

  String _calculateAsapTime() {
    final now = DateTime.now();
    final asapTime = now.add(const Duration(minutes: 15));
    final time = TimeOfDay.fromDateTime(asapTime);
    return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
  }

  void _showOrderSuccess(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            const SizedBox(width: 8),
            const Text('Order Placed!'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Your order has been successfully placed.'),
            SizedBox(height: 8),
            Text('You will receive a notification when your order is ready for pickup.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.pop(); // Go back to map
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  void _showOrderError(BuildContext context, String error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.error, color: Colors.red),
            const SizedBox(width: 8),
            const Text('Order Failed'),
          ],
        ),
        content: Text('Failed to place order: $error'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _orderBloc.retryOrder();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  void _shareDish() async {
    if (_dish != null && _vendor != null) {
      await DeepLinkService.shareDishLink(
        dishId: _dish!.id,
        dishName: _dish!.name,
        vendorName: _vendor!.name,
      );
    }
  }

  @override
  bool get wantKeepAlive => true;

  Future<void> _saveNavigationState() async {
    await NavigationStateService.saveLastViewedDish(widget.dishId);
  }

  Future<void> _clearNavigationState() async {
    await NavigationStateService.clearLastViewedDish();
  }

  Future<bool> _onWillPop() async {
    // Check if there are unsaved changes in the order
    if (_orderBloc.state.items.isNotEmpty) {
      return await NavigationStateService.showBackConfirmationDialog(context);
    }
    return true;
  }
}