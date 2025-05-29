import 'package:katering_ibu_m_flutter/models/menu_model.dart';

class CartItem {
  Menu menu;
  int quantity;

  CartItem({required this.menu, this.quantity = 1});

  void incrementQuantity() {
    quantity++;
  }

  void decrementQuantity() {
    if (quantity > 1) {
      quantity--;
    }
  }
}