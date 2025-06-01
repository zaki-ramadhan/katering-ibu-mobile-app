import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:katering_ibu_m_flutter/models/menu_model.dart';
import 'package:katering_ibu_m_flutter/services/keranjang_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';

class CartItem {
  final Menu menu;
  int quantity;

  CartItem({required this.menu, required this.quantity});

  Map<String, dynamic> toJson() {
    return {'menu': menu.toJson(), 'quantity': quantity};
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      menu: Menu.fromJson(json['menu']),
      quantity: json['quantity'],
    );
  }

  double get totalPrice => menu.harga * quantity;
}

class CartProvider extends ChangeNotifier {
  final KeranjangService _keranjangService = KeranjangService();
  List<CartItem> _cartItems = [];
  bool _isLoading = false;
  bool _isSyncing = false;
  Logger logger = Logger();

  bool get isLoading => _isLoading;
  bool get isSyncing => _isSyncing;
  List<CartItem> get cartItems => _cartItems;

  int get itemCount =>
      _cartItems.fold(0, (total, item) => total + item.quantity);

  double get totalPrice =>
      _cartItems.fold(0, (total, item) => total + item.totalPrice);

  Future<void> loadCartFromLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartData = prefs.getString('local_cart');

      if (cartData != null) {
        final List<dynamic> cartList = jsonDecode(cartData);
        _cartItems = cartList.map((item) => CartItem.fromJson(item)).toList();
        notifyListeners();
      }
    } catch (e) {
      logger.e('Error loading cart from local: $e');
    }
  }

  Future<void> _saveCartToLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartData = jsonEncode(
        _cartItems.map((item) => item.toJson()).toList(),
      );
      await prefs.setString('local_cart', cartData);
    } catch (e) {
      logger.e('Error saving cart to local: $e');
    }
  }

  Future<Map<String, dynamic>> addItem({
    required Menu menu,
    required int quantity,
  }) async {
    try {
      final existingIndex = _cartItems.indexWhere(
        (item) => item.menu.id == menu.id,
      );

      if (existingIndex != -1) {
        _cartItems[existingIndex].quantity += quantity;
      } else {
        _cartItems.add(CartItem(menu: menu, quantity: quantity));
      }

      await _saveCartToLocal();
      notifyListeners();

      return {
        'success': true,
        'message': 'Item berhasil ditambahkan ke keranjang',
      };
    } catch (e) {
      return {'success': false, 'message': 'Gagal menambahkan item: $e'};
    }
  }

  Future<Map<String, dynamic>> updateQuantity(
    Menu menu,
    int newQuantity,
  ) async {
    try {
      final index = _cartItems.indexWhere((item) => item.menu.id == menu.id);

      if (index != -1) {
        if (newQuantity > 0) {
          _cartItems[index].quantity = newQuantity;
        } else {
          _cartItems.removeAt(index);
        }

        await _saveCartToLocal();
        notifyListeners();

        return {'success': true, 'message': 'Quantity berhasil diupdate'};
      }

      return {'success': false, 'message': 'Item tidak ditemukan'};
    } catch (e) {
      return {'success': false, 'message': 'Gagal mengupdate quantity: $e'};
    }
  }

  Future<Map<String, dynamic>> removeItem(Menu menu) async {
    try {
      _cartItems.removeWhere((item) => item.menu.id == menu.id);
      await _saveCartToLocal();
      notifyListeners();

      return {'success': true, 'message': 'Item berhasil dihapus'};
    } catch (e) {
      return {'success': false, 'message': 'Gagal menghapus item: $e'};
    }
  }

  Future<Map<String, dynamic>> removeMultipleItems(List<Menu> menus) async {
    try {
      for (Menu menu in menus) {
        _cartItems.removeWhere((item) => item.menu.id == menu.id);
      }
      await _saveCartToLocal();
      notifyListeners();

      return {
        'success': true,
        'message': '${menus.length} item berhasil dihapus',
      };
    } catch (e) {
      return {'success': false, 'message': 'Gagal menghapus item: $e'};
    }
  }

  Future<void> clearCart() async {
    _cartItems.clear();
    await _saveCartToLocal();
    notifyListeners();
  }

  bool isMenuInCart(int menuId) {
    return _cartItems.any((item) => item.menu.id == menuId);
  }

  int getMenuQuantity(int menuId) {
    final item = _cartItems.where((item) => item.menu.id == menuId).firstOrNull;
    return item?.quantity ?? 0;
  }

  Future<Map<String, dynamic>> syncCartToBackend() async {
    if (_cartItems.isEmpty) {
      return {'success': false, 'message': 'Keranjang kosong'};
    }

    _isSyncing = true;
    notifyListeners();

    try {
      await _keranjangService.clearKeranjang();

      for (CartItem item in _cartItems) {
        final result = await _keranjangService.addItemToKeranjang(
          menuId: item.menu.id,
          jumlah: item.quantity,
        );

        if (!result['success']) {
          _isSyncing = false;
          notifyListeners();
          return {
            'success': false,
            'message': 'Gagal menyinkronisasi item: ${item.menu.namaMenu}',
          };
        }
      }

      _isSyncing = false;
      notifyListeners();

      return {'success': true, 'message': 'Keranjang berhasil disinkronisasi'};
    } catch (e) {
      _isSyncing = false;
      notifyListeners();

      return {
        'success': false,
        'message': 'Gagal menyinkronisasi keranjang: $e',
      };
    }
  }

  Future<void> loadCartFromBackend() async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _keranjangService.getKeranjang();

      if (result['success'] && result['data']['keranjang'] != null) {
        final keranjangData = result['data']['keranjang'];
        final items = keranjangData['items'] as List;

        _cartItems =
            items.map((item) {
              return CartItem(
                menu: Menu.fromJson(item['menu']),
                quantity: item['jumlah'],
              );
            }).toList();

        await _saveCartToLocal();
      }
    } catch (e) {
      logger.e('Error loading cart from backend: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<Map<String, dynamic>> syncSelectedItemsToBackend(
    List<CartItem> selectedItems,
  ) async {
    _isSyncing = true;
    notifyListeners();

    try {
      await _keranjangService.clearKeranjang();

      for (var item in selectedItems) {
        final result = await _keranjangService.addItemToKeranjang(
          menuId: item.menu.id,
          jumlah: item.quantity,
        );

        if (!result['success']) {
          _isSyncing = false;
          notifyListeners();
          return {
            'success': false,
            'message': 'Gagal sync item: ${item.menu.namaMenu}',
          };
        }
      }

      _isSyncing = false;
      notifyListeners();

      return {'success': true, 'message': 'Items berhasil di-sync'};
    } catch (e) {
      _isSyncing = false;
      notifyListeners();

      return {'success': false, 'message': 'Error: $e'};
    }
  }
}
