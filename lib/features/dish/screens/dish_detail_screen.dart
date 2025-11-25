import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../auth/blocs/auth_bloc.dart';
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
    final supabaseClient = Supabase.instance.client;
    _orderBloc = OrderBloc(
      orderRepository: OrderRepository(supabaseClient),
      supabaseClient: supabaseClient,
      authBloc: context.read<AuthBloc>(),
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
      final supabase = Supabase.instance.client;

      // Load dish details
      final dishResponse = await supabase
          .from('dishes')
          .select('''
            *,
            vendors!inner(
              id,
              business_name,
              description,
              address,
              latitude,
              longitude,
              logo_url,
              phone,
              rating,
              cuisine_type,
              open_hours_json
            )
          ''')
          .eq('id', widget.dishId)
          .single();

      // Parse dish data
      _dish = Dish.fromJson(dishResponse);

      // Parse vendor data
      final vendorData = dishResponse['vendors'] as Map<String, dynamic>;
      _vendor = Vendor(
        id: vendorData['id'] as String,
        name: vendorData['business_name'] as String? ?? 'Unknown Vendor',
        description: vendorData['description'] as String? ?? '',
        latitude: (vendorData['latitude'] as num?)?.toDouble() ?? 0.0,
        longitude: (vendorData['longitude'] as num?)?.toDouble() ?? 0.0,
        dishCount: 0, // Would need to calculate this
        isActive: true,
        rating: (vendorData['rating'] as num?)?.toDouble() ?? 0.0,
        cuisineType: vendorData['cuisine_type'] as String?,
        address: vendorData['address'] as String? ?? 'Address not available',
        logoUrl: vendorData['logo_url'] as String?,
        phoneNumber: vendorData['phone'] as String? ??
            vendorData['phone_number'] as String? ??
            '',
        openHoursJson: vendorData['open_hours_json'] as Map<String, dynamic>?,
      );

      setState(() {
        _isLoading = false;
      });

      // Initialize order with 1 item
      _orderBloc.addItem(
        dishId: _dish!.id,
        quantity: 1,
        specialInstructions: null,
      );
      
      // Set default pickup time to first slot (30 minutes from now)
      _orderBloc.setPickupTime(DateTime.now().add(const Duration(minutes: 30)));
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
    return Scaffold(
      backgroundColor: theme.AppTheme.backgroundColor,
      body: CustomScrollView(
        slivers: [
          _buildHeader(),
          _buildHeroImage(),
          _buildContent(orderState),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return SliverToBoxAdapter(
      child: Container(
        color: theme.AppTheme.backgroundColor,
        padding: const EdgeInsets.fromLTRB(16, 48, 16, 8),
        child: Row(
          children: [
            Semantics(
              button: true,
              label: 'Go back',
              child: IconButton(
                icon: Icon(Icons.arrow_back, color: theme.AppTheme.darkText),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            Expanded(
              child: Semantics(
                header: true,
                child: Text(
                  'Dish Details',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: theme.AppTheme.darkText,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(width: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroImage() {
    return SliverToBoxAdapter(
      child: Container(
        height: 218,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(theme.AppTheme.radiusMedium),
          color: theme.AppTheme.surfaceGreen,
        ),
        child: Semantics(
          image: true,
          label: 'Image of ${_dish!.name}',
          child: ClipRRect(
            borderRadius: BorderRadius.circular(theme.AppTheme.radiusMedium),
            child: _dish!.imageUrl != null
                ? Image.network(
                    _dish!.imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: theme.AppTheme.borderGreen,
                        child: Icon(
                          Icons.restaurant,
                          size: 80,
                          color: theme.AppTheme.secondaryGreen,
                        ),
                      );
                    },
                  )
                : Container(
                    color: theme.AppTheme.borderGreen,
                    child: Icon(
                      Icons.restaurant,
                      size: 80,
                      color: theme.AppTheme.secondaryGreen,
                    ),
                  ),
          ),
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
            // Dish Header Info (Name, Price, Stats, Tags)
            _buildDishHeaderContent(),
            
            const SizedBox(height: 24),
            
            // Description
            if (_dish!.description.isNotEmpty) ...[
              Text(
                'Description',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.AppTheme.darkText,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _dish!.description,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: theme.AppTheme.darkText.withOpacity(0.8),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
            ],

            _buildVendorInfo(),
            const SizedBox(height: 24),

            _buildQuantitySelector(orderState),
            const SizedBox(height: 24),
            _buildPickupTimeSelector(orderState),
            const SizedBox(height: 24),
            _buildOrderButton(orderState),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildDishHeaderContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Semantics(
                header: true,
                label: 'Dish name: ${_dish!.name}',
                child: ExcludeSemantics(
                  child: Text(
                    _dish!.name,
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: theme.AppTheme.darkText,
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                ),
              ),
            ),
            Semantics(
              label: 'Price: ${_dish!.formattedPrice}',
              child: ExcludeSemantics(
                child: Text(
                  _dish!.formattedPrice,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: theme.AppTheme.primaryGreen,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        // Stats Row
        Row(
          children: [
            _buildStatItem(Icons.schedule, _dish!.formattedPrepTime),
            const SizedBox(width: 16),
            _buildStatItem(Icons.local_fire_department, _dish!.spiceLevelDisplay),
            const SizedBox(width: 16),
            _buildStatItem(Icons.star, '${_dish!.popularityScore.toStringAsFixed(1)} (${_dish!.orderCount})'),
          ],
        ),
        
        if (_dish!.tags.isNotEmpty) ...[
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _dish!.tags.map((tag) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: theme.AppTheme.surfaceGreen,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: theme.AppTheme.borderGreen),
              ),
              child: Text(
                tag,
                style: TextStyle(
                  color: theme.AppTheme.secondaryGreen,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildStatItem(IconData icon, String text) {
    return Semantics(
      label: text,
      child: ExcludeSemantics(
        child: Row(
          children: [
            Icon(icon, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 4),
            Text(
              text,
              style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w500),
            ),
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
                        '${_vendor!.rating.toStringAsFixed(1)}',
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

  Widget _buildQuantitySelector(OrderState orderState) {
    // Use orderState items to find quantity, default to 1
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quantity',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.AppTheme.darkText,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: theme.AppTheme.surfaceGreen,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.AppTheme.borderGreen),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Semantics(
                button: true,
                enabled: existingItem.quantity > 1,
                label: 'Decrease quantity',
                hint: 'Current quantity is ${existingItem.quantity}',
                child: IconButton(
                  onPressed: existingItem.quantity > 1
                      ? () => _orderBloc.updateItem(
                            dishId: widget.dishId,
                            quantity: existingItem.quantity - 1,
                          )
                      : null,
                  icon: const Icon(Icons.remove),
                  color: theme.AppTheme.darkText,
                ),
              ),
              Semantics(
                label: 'Quantity: ${existingItem.quantity}',
                child: Container(
                  width: 40,
                  alignment: Alignment.center,
                  child: ExcludeSemantics(
                    child: Text(
                      '${existingItem.quantity}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              Semantics(
                button: true,
                label: 'Increase quantity',
                hint: 'Current quantity is ${existingItem.quantity}',
                child: IconButton(
                  onPressed: () => _orderBloc.updateItem(
                    dishId: widget.dishId,
                    quantity: existingItem.quantity + 1,
                  ),
                  icon: const Icon(Icons.add),
                  color: theme.AppTheme.darkText,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPickupTimeSelector(OrderState orderState) {
    final pickupSlots = [
      'Today, 12:00 PM - 12:30 PM',
      'Today, 12:30 PM - 1:00 PM',
      'Today, 1:00 PM - 1:30 PM',
    ];
    
    // Determine which slot is selected based on pickup time
    int selectedIndex = 0; // Default to first slot
    if (orderState.pickupTime != null) {
      final now = DateTime.now();
      final minutesDiff = orderState.pickupTime!.difference(now).inMinutes;
      // Each slot is 30 minutes apart, starting at 30 minutes from now
      if (minutesDiff >= 25 && minutesDiff < 45) {
        selectedIndex = 0; // 30 min slot
      } else if (minutesDiff >= 45 && minutesDiff < 75) {
        selectedIndex = 1; // 60 min slot
      } else if (minutesDiff >= 75) {
        selectedIndex = 2; // 90 min slot
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pickup Time',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.AppTheme.darkText,
          ),
        ),
        const SizedBox(height: 12),
        ...pickupSlots.asMap().entries.map((entry) {
          final index = entry.key;
          final slot = entry.value;
          final isSelected = index == selectedIndex;

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Semantics(
              button: true,
              selected: isSelected,
              label: 'Pickup time: $slot',
              hint: isSelected ? 'Currently selected' : 'Tap to select this time slot',
              child: GestureDetector(
                onTap: () {
                  _orderBloc.setPickupTime(DateTime.now().add(Duration(minutes: 30 * (index + 1))));
                },
                child: Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    border: Border.all(color: theme.AppTheme.borderGreen),
                    borderRadius: BorderRadius.circular(theme.AppTheme.radiusMedium),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          slot,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: theme.AppTheme.darkText,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? theme.AppTheme.primaryGreen : theme.AppTheme.borderGreen,
                            width: 2,
                          ),
                        ),
                        child: isSelected
                            ? Center(
                                child: Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: theme.AppTheme.primaryGreen,
                                  ),
                                ),
                              )
                            : null,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildOrderButton(OrderState orderState) {
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

    final isPlacingOrder = orderState.status == OrderStatus.placing;
    final canPlaceOrder = _dish!.available;
    
    // Calculate total formatted
    final totalAmount = orderState.total;
    final totalFormatted = '\$${totalAmount.toStringAsFixed(2)}';

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: Semantics(
        button: true,
        enabled: canPlaceOrder && !isPlacingOrder,
        label: isPlacingOrder ? 'Placing order' : 'Order for pickup, total $totalFormatted',
        hint: canPlaceOrder ? 'Double tap to place order' : 'Dish is currently unavailable',
        child: ElevatedButton(
          onPressed: canPlaceOrder && !isPlacingOrder ? () => _placeOrder(0) : null, // Quantity is managed by bloc state now
          style: ElevatedButton.styleFrom(
            backgroundColor: canPlaceOrder ? theme.AppTheme.primaryGreen : Colors.grey,
            foregroundColor: theme.AppTheme.darkText,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(theme.AppTheme.radiusLarge),
            ),
          ),
          child: isPlacingOrder
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(theme.AppTheme.darkText),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text('Placing Order...', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Order for Pickup',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      totalFormatted,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  void _placeOrder(int quantity) {
    // We ignore quantity param as it is already in bloc
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
              Navigator.of(context).pop(); // Close dialog
              // Don't pop again - tab navigation handles returning to home
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