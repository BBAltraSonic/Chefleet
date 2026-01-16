import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/utils/currency_formatter.dart';
import 'package:intl/intl.dart';

import '../../cart/blocs/cart_bloc.dart';
import '../../cart/blocs/cart_event.dart';
import '../../cart/blocs/cart_state.dart';
import '../../feed/models/dish_model.dart';
import '../../feed/models/vendor_model.dart';
import '../../../core/constants/timing_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/routes/app_routes.dart';

class DishModal extends StatefulWidget {
  const DishModal({
    super.key,
    required this.dish,
    required this.vendor,
  });

  final Dish dish;
  final Vendor vendor;

  @override
  State<DishModal> createState() => _DishModalState();
}

class _DishModalState extends State<DishModal> {
  int _quantity = 1;
  final TextEditingController _instructionsController = TextEditingController();
  DateTime? _selectedPickupTime;

  @override
  void initState() {
    super.initState();
    // Default pickup time: Now + 15 mins (rounded to next slot?)
    // Let's just use current time + 15m as a baseline
    _selectedPickupTime = DateTime.now().add(const Duration(minutes: 15));
  }

  @override
  void dispose() {
    _instructionsController.dispose();
    super.dispose();
  }

  void _incrementQuantity() {
    setState(() {
      _quantity++;
    });
  }

  void _decrementQuantity() {
    if (_quantity > 1) {
      setState(() {
        _quantity--;
      });
    }
  }

  /// Phase 4 Fix: Uses postFrameCallback with context.mounted check
  /// to prevent navigation after modal disposal (Issue #8).
  void _onCheckout() {
    final cartBloc = context.read<CartBloc>();
    final cartState = cartBloc.state;

    // Check for vendor conflict
    if (cartState.items.isNotEmpty && 
        cartState.items.first.dish.vendorId != widget.dish.vendorId) {
      _showClearCartDialog(cartBloc);
      return;
    }

    // Set pickup time if selected
    if (_selectedPickupTime != null) {
      cartBloc.add(SetPickupTime(_selectedPickupTime!));
    }

    // Add item
    cartBloc.add(AddToCart(
      widget.dish,
      quantity: _quantity,
      specialInstructions: _instructionsController.text.trim().isEmpty 
          ? null 
          : _instructionsController.text.trim(),
    ));

    // Close modal first
    Navigator.of(context).pop();

    // Navigate after the frame completes and verify context is still mounted
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) {
        context.push(CustomerRoutes.checkout);
      }
    });
  }

  void _onaddToCart() {
    final cartBloc = context.read<CartBloc>();
    final cartState = cartBloc.state;

    // Check for vendor conflict
    if (cartState.items.isNotEmpty && 
        cartState.items.first.dish.vendorId != widget.dish.vendorId) {
      _showClearCartDialog(cartBloc);
      return;
    }

    // Update pickup time if changed (optional, but consistent)
    if (_selectedPickupTime != null) {
      cartBloc.add(SetPickupTime(_selectedPickupTime!));
    }

    // Add item
    cartBloc.add(AddToCart(
      widget.dish,
      quantity: _quantity,
      specialInstructions: _instructionsController.text.trim().isEmpty 
          ? null 
          : _instructionsController.text.trim(),
    ));

    // Close modal
    Navigator.pop(context);

    // Show snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${widget.dish.name} added to cart'),
        backgroundColor: AppTheme.primaryGreen,
        duration: TimingConstants.snackbarSuccess,
      ),
    );
  }

  Future<void> _showClearCartDialog(CartBloc cartBloc) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Start new order?'),
        content: const Text(
          'You have items from another vendor in your cart. '
          'Clearing your cart will remove them.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              cartBloc.add(const ClearCart());
              // Retry checkout logic
              
              if (_selectedPickupTime != null) {
                cartBloc.add(SetPickupTime(_selectedPickupTime!));
              }
              cartBloc.add(AddToCart(
                widget.dish,
                quantity: _quantity,
                specialInstructions: _instructionsController.text.trim(),
              ));
              
              // Close modal first
              Navigator.of(context).pop();
              
              // Navigate after the frame completes and verify context is still mounted
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (context.mounted) {
                  context.push(CustomerRoutes.checkout);
                }
              });
            },
            child: const Text('Clear & Start'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalPrice = widget.dish.price * _quantity;
    final hasCartItemsFromSameVendor = context.select<CartBloc, bool>((bloc) {
      final state = bloc.state;
      return state.items.isNotEmpty && state.items.first.dish.vendorId == widget.dish.vendorId;
    });

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.dish.name,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.dish.formattedPrice,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.primaryGreen,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Image thumbnail if available
                      if (widget.dish.imageUrl != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            widget.dish.imageUrl!,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          ),
                        ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Description
                  if (widget.dish.description.isNotEmpty)
                    Text(
                      widget.dish.description,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),

                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 24),

                  // Quantity
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Quantity',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceGreen,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: _quantity > 1 ? _decrementQuantity : null,
                              icon: const Icon(Icons.remove),
                              color: AppTheme.primaryGreen,
                            ),
                            Text(
                              '$_quantity',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              onPressed: _incrementQuantity,
                              icon: const Icon(Icons.add),
                              color: AppTheme.primaryGreen,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Pickup Time
                  const Text(
                    'Pickup Time',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: () async {
                      final now = DateTime.now();
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(
                          _selectedPickupTime ?? now.add(const Duration(minutes: 15))
                        ),
                      );
                      if (time != null) {
                        setState(() {
                          _selectedPickupTime = DateTime(
                            now.year,
                            now.month,
                            now.day,
                            time.hour,
                            time.minute,
                          );
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.access_time, color: AppTheme.primaryGreen),
                          const SizedBox(width: 12),
                          Text(
                            _selectedPickupTime != null
                                ? DateFormat('h:mm a').format(_selectedPickupTime!)
                                : 'Select time',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Spacer(),
                          const Icon(Icons.keyboard_arrow_down),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Special Instructions
                  const Text(
                    'Special Instructions',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _instructionsController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Add notes for the kitchen...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppTheme.primaryGreen),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Footer Actions
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _onCheckout,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryGreen,
                        foregroundColor: AppTheme.darkText,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Check Out - ${CurrencyFormatter.format(totalPrice)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  if (hasCartItemsFromSameVendor) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: _onaddToCart,
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: const BorderSide(color: AppTheme.primaryGreen),
                          ),
                        ),
                        child: const Text(
                          'Add to Cart & Keep Browsing',
                          style: TextStyle(
                            color: AppTheme.darkText,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
