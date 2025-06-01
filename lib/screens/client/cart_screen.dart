// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:katering_ibu_m_flutter/constants/index.dart';
import 'package:katering_ibu_m_flutter/provider/cart_provider.dart';
import 'package:katering_ibu_m_flutter/screens/client/checkout_order_screen.dart';
import 'package:katering_ibu_m_flutter/widgets/custom_app_bar.dart';
import 'package:katering_ibu_m_flutter/widgets/custom_notification.dart';
import 'package:provider/provider.dart';
import 'dart:async';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final Set<int> selectedItems = {};
  final NumberFormat rupiahFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp',
    decimalDigits: 0,
  );

  Timer? _timer;
  bool _isLongPressing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CartProvider>(context, listen: false).loadCartFromLocal();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startIncrement(CartItem item) {
    _isLongPressing = true;
    _incrementQuantity(item);
    _timer = Timer.periodic(Duration(milliseconds: 150), (timer) {
      if (_isLongPressing) {
        _incrementQuantity(item);
      } else {
        timer.cancel();
      }
    });
  }

  void _startDecrement(CartItem item) {
    if (item.quantity <= 1) return;

    _isLongPressing = true;
    _decrementQuantity(item);
    _timer = Timer.periodic(Duration(milliseconds: 150), (timer) {
      if (_isLongPressing && item.quantity > 1) {
        _decrementQuantity(item);
      } else {
        timer.cancel();
      }
    });
  }

  void _stopAction() {
    _isLongPressing = false;
    _timer?.cancel();
  }

  void _incrementQuantity(CartItem item) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    cartProvider.updateQuantity(item.menu, item.quantity + 1);
  }

  void _decrementQuantity(CartItem item) {
    if (item.quantity > 1) {
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      cartProvider.updateQuantity(item.menu, item.quantity - 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        titleAppBar: 'Keranjang Saya',
        isIconShow: true,
        isLogoutIconShow: false,
        isNavigableByBottomBar: true,
      ),
      backgroundColor: white,
      body: Consumer<CartProvider>(
        builder: (context, cartProvider, child) {
          if (cartProvider.isLoading) {
            return Center(
              child: CircularProgressIndicator(color: primaryColor),
            );
          }

          final items = cartProvider.cartItems;

          return SizedBox(
            child: Stack(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(vertical: 20, horizontal: 32),
                  child:
                      items.isEmpty
                          ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.shopping_cart_outlined,
                                  size: 80,
                                  color: Colors.grey.shade400,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'Keranjang Kosong',
                                  style: GoogleFonts.plusJakartaSans(
                                    color: primaryColor,
                                    fontSize: 20,
                                    fontWeight: bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Tidak ada menu di keranjang\nMulai belanja sekarang!',
                                  style: GoogleFonts.plusJakartaSans(
                                    color: Colors.grey.shade600,
                                    fontSize: 16,
                                    height: 1.5,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          )
                          : Column(
                            children: [
                              for (int i = 0; i < items.length; i++)
                                _buildItem(context, items[i], i),
                            ],
                          ),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: Consumer<CartProvider>(
        builder: (context, cartProvider, child) {
          final items = cartProvider.cartItems;
          return items.isEmpty
              ? SizedBox.shrink()
              : _buildCTABottomBar(context, items);
        },
      ),
    );
  }

  Widget _buildItem(BuildContext context, CartItem cartItem, int index) {
    final isSelected = selectedItems.contains(index);

    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            selectedItems.remove(index);
          } else {
            selectedItems.add(index);
          }
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              margin: EdgeInsets.only(right: 16),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: primaryColor, width: 2),
                color: isSelected ? primaryColor : transparent,
              ),
              child:
                  isSelected ? Icon(Icons.check, color: white, size: 16) : null,
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child:
                  cartItem.menu.foto.isNotEmpty
                      ? Image.network(
                        cartItem.menu.foto,
                        width: 70,
                        height: 70,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 70,
                            height: 70,
                            color: Colors.grey.shade200,
                            child: Icon(
                              Icons.image_not_supported,
                              color: Colors.grey,
                            ),
                          );
                        },
                      )
                      : Container(
                        width: 70,
                        height: 70,
                        color: Colors.grey.shade200,
                        child: Icon(Icons.fastfood, color: Colors.grey),
                      ),
            ),
            SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cartItem.menu.namaMenu,
                    style: GoogleFonts.plusJakartaSans(
                      color: primaryColor,
                      fontSize: 16,
                      fontWeight: medium,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    rupiahFormat.format(cartItem.totalPrice),
                    style: GoogleFonts.plusJakartaSans(
                      color: primaryColor,
                      fontSize: 18,
                      fontWeight: bold,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (cartItem.quantity > 1) ...[
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: primaryColor.withAlpha(60),
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: GestureDetector(
                      onTap: () => _decrementQuantity(cartItem),
                      onLongPressStart: (_) => _startDecrement(cartItem),
                      onLongPressEnd: (_) => _stopAction(),
                      onLongPressCancel: () => _stopAction(),
                      child: Icon(Icons.remove, color: primaryColor, size: 20),
                    ),
                  ),
                  SizedBox(width: 8),
                ] else ...[
                  SizedBox(width: 48),
                ],
                Container(
                  constraints: BoxConstraints(minWidth: 30),
                  child: Text(
                    '${cartItem.quantity}',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: semibold,
                      fontSize: 18,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(width: 8),
                GestureDetector(
                  onTap: () => _incrementQuantity(cartItem),
                  onLongPressStart: (_) => _startIncrement(cartItem),
                  onLongPressEnd: (_) => _stopAction(),
                  onLongPressCancel: () => _stopAction(),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Icon(Icons.add, color: white, size: 20),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _deleteSelectedItems(List<CartItem> items) async {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    List<CartItem> itemsToRemove = [];
    for (int i = 0; i < items.length; i++) {
      if (selectedItems.contains(i)) {
        itemsToRemove.add(items[i]);
      }
    }

    final menusToRemove = itemsToRemove.map((item) => item.menu).toList();
    final result = await cartProvider.removeMultipleItems(menusToRemove);

    setState(() {
      selectedItems.clear();
    });

    if (result['success']) {
      CustomNotification.showSuccess(
        context: context,
        title: 'Berhasil dihapus!',
        message: result['message'],
      );
    } else {
      CustomNotification.showError(
        context: context,
        title: 'Gagal menghapus',
        message: result['message'],
      );
    }
  }

  Widget _buildCTABottomBar(BuildContext context, List<CartItem> items) {
    if (items.isEmpty) {
      return SizedBox.shrink();
    }

    final allItemsSelected =
        selectedItems.length == items.length && items.isNotEmpty;
    final selectedCount = selectedItems.length;

    double totalHarga = 0;
    for (int i = 0; i < items.length; i++) {
      if (selectedItems.contains(i)) {
        totalHarga += items[i].totalPrice;
      }
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: white,
        border: Border(top: BorderSide(color: Colors.grey.shade300, width: 1)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    if (allItemsSelected) {
                      selectedItems.clear();
                    } else {
                      selectedItems.addAll(
                        List.generate(items.length, (index) => index),
                      );
                    }
                  });
                },
                child: Row(
                  children: [
                    Icon(
                      allItemsSelected
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      color: primaryColor,
                    ),
                    SizedBox(width: 8),
                    Text(
                      allItemsSelected
                          ? 'Batalkan pilih semua'
                          : 'Pilih semua menu',
                      style: GoogleFonts.plusJakartaSans(fontWeight: semibold),
                    ),
                  ],
                ),
              ),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'Item dipilih: ',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.grey.shade600,
                      ),
                    ),
                    TextSpan(
                      text: '$selectedCount',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: bold,
                        color: primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Harga:',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: semibold,
                  color: Colors.grey.shade600,
                ),
              ),
              Text(
                rupiahFormat.format(totalHarga),
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: bold,
                  color: primaryColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 24),
          selectedItems.isEmpty
              ? SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: null,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 18),
                    backgroundColor: Colors.grey.shade200,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    'Pilih item untuk melanjutkan',
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.grey.shade500,
                      fontWeight: semibold,
                    ),
                  ),
                ),
              )
              : Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: ElevatedButton(
                      onPressed: () => _deleteSelectedItems(items),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 18),
                        backgroundColor: white,
                        side: BorderSide(color: Colors.blueGrey.shade400),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        'Hapus',
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.blueGrey.shade700,
                          fontWeight: semibold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: Consumer<CartProvider>(
                      builder: (context, cartProvider, child) {
                        return ElevatedButton(
                          onPressed:
                              cartProvider.isSyncing
                                  ? null
                                  : () => _proceedToCheckout(context),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 18),
                            backgroundColor: primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child:
                              cartProvider.isSyncing
                                  ? SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                  : Text(
                                    'Lanjut ke Pembayaran',
                                    style: GoogleFonts.plusJakartaSans(
                                      color: white,
                                      fontWeight: semibold,
                                      fontSize: 16,
                                    ),
                                  ),
                        );
                      },
                    ),
                  ),
                ],
              ),
        ],
      ),
    );
  }

  void _proceedToCheckout(BuildContext context) async {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    List<CartItem> selectedCartItems = [];
    for (int i = 0; i < cartProvider.cartItems.length; i++) {
      if (selectedItems.contains(i)) {
        selectedCartItems.add(cartProvider.cartItems[i]);
      }
    }

    if (selectedCartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Pilih item yang ingin di-checkout'),
          backgroundColor: errorColor,
        ),
      );
      return;
    }

    final result = await cartProvider.syncCartToBackend();

    if (result['success']) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) =>
                  CheckoutOrderScreen(selectedItems: selectedCartItems),
        ),
      );
    } else {
      CustomNotification.showError(
        context: context,
        title: 'Gagal memproses',
        message: result['message'],
      );
    }
  }
}
