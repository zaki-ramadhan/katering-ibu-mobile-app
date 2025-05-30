import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:katering_ibu_m_flutter/models/cart_model.dart';
import 'package:katering_ibu_m_flutter/models/menu_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItem> _cartItems = [];

  List<CartItem> get cartItems => _cartItems;

  Future<void> loadCart(Menu Function(int id) menuById) async {
    final prefs = await SharedPreferences.getInstance();
    final cartString = prefs.getString('cart_items');
    if (cartString != null) {
      final List<dynamic> jsonList = json.decode(cartString);
      _cartItems.clear();
      for (var item in jsonList) {
        final menu = menuById(item['menu_id']);
        _cartItems.add(CartItem(menu: menu, quantity: item['quantity']));
      }
      notifyListeners();
    }
  }

  Future<void> saveCart() async {
    final prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> jsonList =
        _cartItems
            .map((item) => {'menu_id': item.menu.id, 'quantity': item.quantity})
            .toList();
    await prefs.setString('cart_items', json.encode(jsonList));
  }

  void addItem(Menu menu) {
    int index = _cartItems.indexWhere((item) => item.menu.id == menu.id);
    if (index != -1) {
      _cartItems[index].incrementQuantity();
    } else {
      _cartItems.add(CartItem(menu: menu));
    }
    saveCart();
    notifyListeners();
  }

  void removeItem(CartItem cartItem) {
    _cartItems.remove(cartItem);
    saveCart();
    notifyListeners();
  }

  void updateQuantity(CartItem cartItem, int newQuantity) {
    if (newQuantity > 0) {
      cartItem.quantity = newQuantity;
      saveCart();
      notifyListeners();
    } else {
      removeItem(cartItem);
    }
  }

  double get totalHarga {
    double total = 0;
    for (var item in _cartItems) {
      total += item.menu.harga * item.quantity;
    }
    return total;
  }

  int get itemCount {
    return _cartItems.fold(0, (total, item) => total + item.quantity);
  }

  void clearCart() {
    _cartItems.clear();
    saveCart();
    notifyListeners();
  }
}
