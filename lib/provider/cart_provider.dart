import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:katering_ibu_m_flutter/models/menu_model.dart';
import 'package:katering_ibu_m_flutter/services/keranjang_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  // Getters
  bool get isLoading => _isLoading;
  bool get isSyncing => _isSyncing;
  List<CartItem> get cartItems => _cartItems;

  int get itemCount =>
      _cartItems.fold(0, (total, item) => total + item.quantity);

  double get totalPrice =>
      _cartItems.fold(0, (total, item) => total + item.totalPrice);

  // Initialize cart dari SharedPreferences
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
      print('Error loading cart from local: $e');
    }
  }

  // Save cart ke SharedPreferences
  Future<void> _saveCartToLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartData = jsonEncode(
        _cartItems.map((item) => item.toJson()).toList(),
      );
      await prefs.setString('local_cart', cartData);
    } catch (e) {
      print('Error saving cart to local: $e');
    }
  }

  // Add item ke cart lokal
  Future<Map<String, dynamic>> addItem({
    required Menu menu,
    required int quantity,
  }) async {
    try {
      // Cek apakah item sudah ada di cart
      final existingIndex = _cartItems.indexWhere(
        (item) => item.menu.id == menu.id,
      );

      if (existingIndex != -1) {
        // Update quantity jika item sudah ada
        _cartItems[existingIndex].quantity += quantity;
      } else {
        // Tambah item baru
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

  // Update quantity item di cart lokal
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

  // Remove item dari cart lokal
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

  // Remove multiple items
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

  // Clear cart lokal
  Future<void> clearCart() async {
    _cartItems.clear();
    await _saveCartToLocal();
    notifyListeners();
  }

  // Check if menu exists in cart
  bool isMenuInCart(int menuId) {
    return _cartItems.any((item) => item.menu.id == menuId);
  }

  // Get quantity of specific menu
  int getMenuQuantity(int menuId) {
    final item = _cartItems.where((item) => item.menu.id == menuId).firstOrNull;
    return item?.quantity ?? 0;
  }

  // Sync cart ke backend saat checkout
  Future<Map<String, dynamic>> syncCartToBackend() async {
    if (_cartItems.isEmpty) {
      return {'success': false, 'message': 'Keranjang kosong'};
    }

    _isSyncing = true;
    notifyListeners();

    try {
      // Hapus keranjang lama jika ada
      await _keranjangService.clearKeranjang();

      // Tambahkan semua item ke backend
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

  // Load cart dari backend (untuk sinkronisasi)
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
      print('Error loading cart from backend: $e');
    }

    _isLoading = false;
    notifyListeners();
  }
}
