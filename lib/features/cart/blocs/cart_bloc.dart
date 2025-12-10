import 'dart:async';
import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:chefleet/core/diagnostics/diagnostic_domains.dart';
import 'package:chefleet/core/diagnostics/diagnostic_harness.dart';
import 'package:chefleet/core/diagnostics/diagnostic_severity.dart';
import '../models/cart_item.dart';
import 'cart_event.dart';
import 'cart_state.dart';

/// BLoC for managing shopping cart state
class CartBloc extends Bloc<CartEvent, CartState> with HydratedMixin {
  CartBloc() : super(const CartState()) {
    on<AddToCart>(_onAddToCart);
    on<RemoveFromCart>(_onRemoveFromCart);
    on<UpdateQuantity>(_onUpdateQuantity);
    on<UpdateSpecialInstructions>(_onUpdateSpecialInstructions);
    on<SetPickupTime>(_onSetPickupTime);
    on<ClearCart>(_onClearCart);
  }

  final DiagnosticHarness _diagnostics = DiagnosticHarness.instance;

  void _logCart(
    String event, {
    Map<String, Object?> payload = const <String, Object?>{},
    DiagnosticSeverity severity = DiagnosticSeverity.info,
    String? correlationId,
  }) {
    _diagnostics.log(
      domain: DiagnosticDomains.ordering,
      event: 'cart.$event',
      payload: payload,
      severity: severity,
      correlationId: correlationId,
    );
  }

  String? _currentVendorScope() {
    if (state.items.isEmpty) {
      return null;
    }
    return 'vendor-${state.items.first.dish.vendorId}';
  }

  /// Add item to cart or update quantity if already exists
  Future<void> _onAddToCart(AddToCart event, Emitter<CartState> emit) async {
    try {
      _logCart(
        'add_to_cart.request',
        payload: {
          'dishId': event.dish.id,
          'vendorId': event.dish.vendorId,
          'quantity': event.quantity,
        },
        correlationId: 'dish-${event.dish.id}',
        severity: DiagnosticSeverity.debug,
      );
      if (state.items.isNotEmpty) {
        final currentVendorId = state.items.first.dish.vendorId;
        if (currentVendorId != event.dish.vendorId) {
          emit(state.copyWith(
            error: 'You can only order from one vendor at a time. Please clear your cart first.',
          ));
          _logCart(
            'add_to_cart.vendor_conflict',
            payload: {
              'existingVendorId': currentVendorId,
              'incomingVendorId': event.dish.vendorId,
            },
            severity: DiagnosticSeverity.warn,
            correlationId: 'vendor-$currentVendorId',
          );
          return;
        }
      }

      final existingIndex = state.items.indexWhere(
        (item) => item.dish.id == event.dish.id,
      );

      List<CartItem> updatedItems;
      if (existingIndex >= 0) {
        // Update existing item
        updatedItems = List.from(state.items);
        final existingItem = updatedItems[existingIndex];
        updatedItems[existingIndex] = existingItem.copyWith(
          quantity: existingItem.quantity + event.quantity,
          specialInstructions: event.specialInstructions ?? existingItem.specialInstructions,
        );
      } else {
        // Add new item
        updatedItems = [
          ...state.items,
          CartItem(
            dish: event.dish,
            quantity: event.quantity,
            specialInstructions: event.specialInstructions,
          ),
        ];
      }

      emit(state.copyWith(items: updatedItems));
      emit(state.copyWith(items: updatedItems));
      // add(const SaveCart()); Removed
      _logCart(
        'add_to_cart.success',
        payload: {
          'dishId': event.dish.id,
          'totalItems': state.totalItems + event.quantity,
        },
        correlationId: _currentVendorScope(),
      );
    } catch (e) {
      emit(state.copyWith(error: 'Failed to add item to cart: ${e.toString()}'));
      _logCart(
        'add_to_cart.error',
        payload: {'message': e.toString()},
        severity: DiagnosticSeverity.error,
        correlationId: _currentVendorScope(),
      );
    }
  }

  /// Remove item from cart completely
  Future<void> _onRemoveFromCart(
    RemoveFromCart event,
    Emitter<CartState> emit,
  ) async {
    try {
      _logCart(
        'remove_from_cart.request',
        payload: {'dishId': event.dishId},
        severity: DiagnosticSeverity.debug,
        correlationId: _currentVendorScope(),
      );
      final updatedItems = state.items
          .where((item) => item.dish.id != event.dishId)
          .toList();

      emit(state.copyWith(items: updatedItems));
      emit(state.copyWith(items: updatedItems));
      // add(const SaveCart()); Removed
      _logCart(
        'remove_from_cart.success',
        payload: {'dishId': event.dishId, 'remainingItems': updatedItems.length},
        correlationId: _currentVendorScope(),
      );
    } catch (e) {
      emit(state.copyWith(error: 'Failed to remove item: ${e.toString()}'));
      _logCart(
        'remove_from_cart.error',
        payload: {'message': e.toString(), 'dishId': event.dishId},
        severity: DiagnosticSeverity.error,
        correlationId: _currentVendorScope(),
      );
    }
  }

  /// Update quantity of an item in cart
  Future<void> _onUpdateQuantity(
    UpdateQuantity event,
    Emitter<CartState> emit,
  ) async {
    try {
      _logCart(
        'update_quantity.request',
        payload: {'dishId': event.dishId, 'quantity': event.quantity},
        severity: DiagnosticSeverity.debug,
        correlationId: _currentVendorScope(),
      );
      if (event.quantity <= 0) {
        // If quantity is 0 or less, remove the item
        add(RemoveFromCart(event.dishId));
        return;
      }

      final updatedItems = state.items.map((item) {
        if (item.dish.id == event.dishId) {
          return item.copyWith(quantity: event.quantity);
        }
        return item;
      }).toList();

      emit(state.copyWith(items: updatedItems));
      emit(state.copyWith(items: updatedItems));
      // add(const SaveCart()); Removed
      _logCart(
        'update_quantity.success',
        payload: {'dishId': event.dishId, 'quantity': event.quantity},
        correlationId: _currentVendorScope(),
      );
    } catch (e) {
      emit(state.copyWith(error: 'Failed to update quantity: ${e.toString()}'));
      _logCart(
        'update_quantity.error',
        payload: {'message': e.toString(), 'dishId': event.dishId},
        severity: DiagnosticSeverity.error,
        correlationId: _currentVendorScope(),
      );
    }
  }

  /// Update special instructions for an item
  Future<void> _onUpdateSpecialInstructions(
    UpdateSpecialInstructions event,
    Emitter<CartState> emit,
  ) async {
    try {
      _logCart(
        'update_instructions.request',
        payload: {'dishId': event.dishId},
        severity: DiagnosticSeverity.debug,
        correlationId: _currentVendorScope(),
      );
      final updatedItems = state.items.map((item) {
        if (item.dish.id == event.dishId) {
          return item.copyWith(specialInstructions: event.instructions);
        }
        return item;
      }).toList();

      emit(state.copyWith(items: updatedItems));
      emit(state.copyWith(items: updatedItems));
      // add(const SaveCart()); Removed
      _logCart(
        'update_instructions.success',
        payload: {'dishId': event.dishId},
        correlationId: _currentVendorScope(),
      );
    } catch (e) {
      emit(state.copyWith(
        error: 'Failed to update instructions: ${e.toString()}',
      ));
      _logCart(
        'update_instructions.error',
        payload: {'message': e.toString(), 'dishId': event.dishId},
        severity: DiagnosticSeverity.error,
        correlationId: _currentVendorScope(),
      );
    }
  }

  /// Set pickup time for the cart
  Future<void> _onSetPickupTime(
    SetPickupTime event,
    Emitter<CartState> emit,
  ) async {
    emit(state.copyWith(pickupTime: event.pickupTime));
    _logCart(
      'pickup_time.updated',
      payload: {'pickupTime': event.pickupTime.toIso8601String()},
      correlationId: _currentVendorScope(),
    );
  }

  /// Clear all items from cart
  Future<void> _onClearCart(ClearCart event, Emitter<CartState> emit) async {
    try {
      emit(const CartState(items: []));
      emit(const CartState(items: []));
      // add(const SaveCart()); Removed
      _logCart(
        'clear_cart.success',
        severity: DiagnosticSeverity.debug,
      );
    } catch (e) {
      emit(state.copyWith(error: 'Failed to clear cart: ${e.toString()}'));
      _logCart(
        'clear_cart.error',
        payload: {'message': e.toString()},
        severity: DiagnosticSeverity.error,
      );
    }
  }

  @override
  CartState? fromJson(Map<String, dynamic> json) {
    try {
      return CartState.fromJson(json);
    } catch (_) {
      return null;
    }
  }

  @override
  Map<String, dynamic>? toJson(CartState state) {
    return state.toJson();
  }
}
