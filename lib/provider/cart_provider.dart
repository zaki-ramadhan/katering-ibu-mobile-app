import 'package:flutter/foundation.dart';
import 'package:katering_ibu_m_flutter/models/cart_model.dart';
import 'package:katering_ibu_m_flutter/models/menu_model.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItem> _cartItems = [];

  List<CartItem> get cartItems => _cartItems;

  void addItem(Menu menu) {
    int index = _cartItems.indexWhere((item) => item.menu.id == menu.id);
    if (index != -1) {
      _cartItems[index].incrementQuantity();
    } else {
      _cartItems.add(CartItem(menu: menu));
    }
    notifyListeners();
  }

  void removeItem(CartItem cartItem) {
    _cartItems.remove(cartItem);
    notifyListeners();
  }

  void updateQuantity(CartItem cartItem, int newQuantity) {
    if (newQuantity > 0) {
      cartItem.quantity = newQuantity;
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
    notifyListeners();
  }
}