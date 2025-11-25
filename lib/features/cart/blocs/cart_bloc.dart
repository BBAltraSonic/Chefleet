import 'dart:async';
import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cart_item.dart';
import 'cart_event.dart';
import 'cart_state.dart';

/// BLoC for managing shopping cart state
class CartBloc extends Bloc<CartEvent, CartState> {
  CartBloc() : super(const CartState()) {
    on<AddToCart>(_onAddToCart);
    on<RemoveFromCart>(_onRemoveFromCart);
    on<UpdateQuantity>(_onUpdateQuantity);
    on<UpdateSpecialInstructions>(_onUpdateSpecialInstructions);
    on<SetPickupTime>(_onSetPickupTime);
    on<ClearCart>(_onClearCart);
    on<LoadCart>(_onLoadCart);
    on<SaveCart>(_onSaveCart);
  }

  static const String _cartStorageKey = 'shopping_cart';

  /// Add item to cart or update quantity if already exists
  Future<void> _onAddToCart(AddToCart event, Emitter<CartState> emit) async {
    try {
      if (state.items.isNotEmpty) {
        final currentVendorId = state.items.first.dish.vendorId;
        if (currentVendorId != event.dish.vendorId) {
          emit(state.copyWith(
            error: 'You can only order from one vendor at a time. Please clear your cart first.',
          ));
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
      add(const SaveCart());
    } catch (e) {
      emit(state.copyWith(error: 'Failed to add item to cart: ${e.toString()}'));
    }
  }

  /// Remove item from cart completely
  Future<void> _onRemoveFromCart(
    RemoveFromCart event,
    Emitter<CartState> emit,
  ) async {
    try {
      final updatedItems = state.items
          .where((item) => item.dish.id != event.dishId)
          .toList();

      emit(state.copyWith(items: updatedItems));
      add(const SaveCart());
    } catch (e) {
      emit(state.copyWith(error: 'Failed to remove item: ${e.toString()}'));
    }
  }

  /// Update quantity of an item in cart
  Future<void> _onUpdateQuantity(
    UpdateQuantity event,
    Emitter<CartState> emit,
  ) async {
    try {
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
      add(const SaveCart());
    } catch (e) {
      emit(state.copyWith(error: 'Failed to update quantity: ${e.toString()}'));
    }
  }

  /// Update special instructions for an item
  Future<void> _onUpdateSpecialInstructions(
    UpdateSpecialInstructions event,
    Emitter<CartState> emit,
  ) async {
    try {
      final updatedItems = state.items.map((item) {
        if (item.dish.id == event.dishId) {
          return item.copyWith(specialInstructions: event.instructions);
        }
        return item;
      }).toList();

      emit(state.copyWith(items: updatedItems));
      add(const SaveCart());
    } catch (e) {
      emit(state.copyWith(
        error: 'Failed to update instructions: ${e.toString()}',
      ));
    }
  }

  /// Set pickup time for the cart
  Future<void> _onSetPickupTime(
    SetPickupTime event,
    Emitter<CartState> emit,
  ) async {
    emit(state.copyWith(pickupTime: event.pickupTime));
  }

  /// Clear all items from cart
  Future<void> _onClearCart(ClearCart event, Emitter<CartState> emit) async {
    try {
      emit(const CartState(items: []));
      add(const SaveCart());
    } catch (e) {
      emit(state.copyWith(error: 'Failed to clear cart: ${e.toString()}'));
    }
  }

  /// Load cart from local storage
  Future<void> _onLoadCart(LoadCart event, Emitter<CartState> emit) async {
    try {
      emit(state.copyWith(isLoading: true));

      final prefs = await SharedPreferences.getInstance();
      final cartJson = prefs.getString(_cartStorageKey);

      if (cartJson != null) {
        final List<dynamic> itemsJson = json.decode(cartJson) as List<dynamic>;
        final items = itemsJson
            .map((itemJson) => CartItem.fromJson(itemJson as Map<String, dynamic>))
            .toList();

        emit(CartState(items: items, isLoading: false));
      } else {
        emit(state.copyWith(isLoading: false));
      }
    } catch (e) {
      emit(CartState(
        items: state.items,
        isLoading: false,
        error: 'Failed to load cart: ${e.toString()}',
      ));
    }
  }

  /// Save cart to local storage
  Future<void> _onSaveCart(SaveCart event, Emitter<CartState> emit) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final itemsJson = state.items.map((item) => item.toJson()).toList();
      final cartJson = json.encode(itemsJson);

      await prefs.setString(_cartStorageKey, cartJson);
    } catch (e) {
      // Silent fail - don't disrupt user experience for storage issues
      emit(state.copyWith(
        error: 'Failed to save cart: ${e.toString()}',
      ));
    }
  }
}
