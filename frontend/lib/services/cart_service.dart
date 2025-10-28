import 'package:flutter/material.dart';
import '../models/product.dart';

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  double get totalPrice => product.price * quantity;
}

class CartService with ChangeNotifier {
  static final CartService _instance = CartService._internal();
  factory CartService() => _instance;
  CartService._internal();

  List<CartItem> _cartItems = [];

  List<CartItem> get cartItems => List.unmodifiable(_cartItems);

  int get totalItems => _cartItems.fold(0, (sum, item) => sum + item.quantity);

  double get totalPrice {
    return _cartItems.fold(0, (sum, item) => sum + item.totalPrice);
  }

  void addToCart(Product product) {
    final existingItemIndex = _cartItems.indexWhere(
      (item) => item.product.id == product.id,
    );

    if (existingItemIndex != -1) {
      _cartItems[existingItemIndex].quantity++;
    } else {
      _cartItems.add(CartItem(product: product));
    }

    notifyListeners();
    _saveToLocalStorage();
  }

  void removeFromCart(Product product) {
    _cartItems.removeWhere((item) => item.product.id == product.id);
    notifyListeners();
    _saveToLocalStorage();
  }

  void updateQuantity(Product product, int newQuantity) {
    final existingItemIndex = _cartItems.indexWhere(
      (item) => item.product.id == product.id,
    );

    if (existingItemIndex != -1) {
      if (newQuantity <= 0) {
        _cartItems.removeAt(existingItemIndex);
      } else {
        _cartItems[existingItemIndex].quantity = newQuantity;
      }
    }

    notifyListeners();
    _saveToLocalStorage();
  }

  void clearCart() {
    _cartItems.clear();
    notifyListeners();
    _saveToLocalStorage();
  }

  bool isInCart(Product product) {
    return _cartItems.any((item) => item.product.id == product.id);
  }

  void _saveToLocalStorage() {}

  void loadFromLocalStorage() {}
}
