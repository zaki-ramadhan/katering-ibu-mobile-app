import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:katering_ibu_m_flutter/constants/index.dart';
import 'package:katering_ibu_m_flutter/models/cart_model.dart';
import 'package:katering_ibu_m_flutter/screens/client/rating_order_scren.dart';
import 'package:katering_ibu_m_flutter/widgets/custom_app_bar.dart';
import 'package:provider/provider.dart';

import '../../provider/cart_provider.dart';

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

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    List<CartItem> items = cartProvider.cartItems;
    return Scaffold(
      appBar: CustomAppBar(
        titleAppBar: 'Keranjang Saya',
        isIconShow: true,
        isLogoutIconShow: false,
        isNavigableByBottomBar: true,
      ),
      backgroundColor: Colors.white,
      body: SizedBox(
        child: Stack(
          children: [
            Container(
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 32),
              child:
                  items.isEmpty
                      ? Center(
                        child: Text(
                          'Keranjang kosong',
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.grey,
                            fontSize: 18,
                          ),
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
      ),
      bottomNavigationBar: _buildCTABottomBar(context, items),
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
                color: isSelected ? primaryColor : Colors.transparent,
              ),
              child:
                  isSelected
                      ? Icon(Icons.check, color: Colors.white, size: 16)
                      : null,
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
                      )
                      : Container(
                        width: 70,
                        height: 70,
                        color: Colors.grey.shade200,
                        child: Icon(Icons.fastfood, color: Colors.grey),
                      ),
            ),
            SizedBox(width: 18),
            Column(
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
                // SizedBox(height: 8),
                // Text(
                //   '${rupiahFormat.format(cartItem.menu.harga)} x ${cartItem.quantity}',
                //   style: GoogleFonts.plusJakartaSans(
                //     color: Colors.grey,
                //     fontSize: 13,
                //     fontWeight: medium
                //   ),
                // ),
                SizedBox(height: 8),
                Text(
                  rupiahFormat.format(cartItem.menu.harga * cartItem.quantity),
                  style: GoogleFonts.plusJakartaSans(
                    color: primaryColor,
                    fontSize: 18,
                    fontWeight: bold,
                  ),
                ),
              ],
            ),
            Spacer(),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
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
                  child: IconButton(
                    onPressed: () {
                      final cartProvider = Provider.of<CartProvider>(
                        context,
                        listen: false,
                      );
                      cartProvider.updateQuantity(
                        cartItem,
                        cartItem.quantity - 1,
                      );
                      setState(() {});
                    },
                    constraints: BoxConstraints(),
                    icon: Icon(Icons.remove),
                    padding: EdgeInsets.all(2),
                    style: IconButton.styleFrom(
                      splashFactory: InkRipple.splashFactory,
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  '${cartItem.quantity}',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: semibold,
                    fontSize: 18,
                  ),
                ),
                SizedBox(width: 8),
                IconButton(
                  onPressed: () {
                    final cartProvider = Provider.of<CartProvider>(
                      context,
                      listen: false,
                    );
                    cartProvider.updateQuantity(
                      cartItem,
                      cartItem.quantity + 1,
                    );
                    setState(() {});
                  },
                  icon: Icon(Icons.add),
                  color: Colors.white,
                  padding: EdgeInsets.all(6),
                  style: IconButton.styleFrom(
                    backgroundColor: primaryColor,
                    splashFactory: InkRipple.splashFactory,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCTABottomBar(BuildContext context, List<CartItem> items) {
    final allItemsSelected =
        selectedItems.length == items.length && items.isNotEmpty;
    final selectedCount = selectedItems.length;

    double totalHarga = 0;
    for (int i = 0; i < items.length; i++) {
      if (selectedItems.contains(i)) {
        totalHarga += items[i].menu.harga * items[i].quantity;
      }
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
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
                          ? 'Batalkan pilih semua menu'
                          : 'Pilih semua menu',
                      style: GoogleFonts.plusJakartaSans(fontWeight: semibold),
                    ),
                  ],
                ),
              ),
              Text.rich(
                TextSpan(
                  style: GoogleFonts.plusJakartaSans(fontWeight: semibold),
                  children: [
                    TextSpan(
                      text: 'Item dipilih : ',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.grey.shade600,
                      ),
                    ),
                    TextSpan(
                      text: '$selectedCount',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: extrabold,
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
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed:
                  selectedItems.isEmpty
                      ? null
                      : () => Navigator.push(
                        context,
                        PageRouteBuilder(
                          transitionDuration: Duration(milliseconds: 300),
                          transitionsBuilder: (
                            context,
                            animation,
                            secondaryAnimation,
                            child,
                          ) {
                            return FadeTransition(
                              opacity: animation,
                              child: child,
                            );
                          },
                          pageBuilder: (
                            context,
                            animation,
                            secondaryAnimation,
                          ) {
                            return RatingOrderScren();
                          },
                        ),
                      ),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 18),
                elevation: 0,
                backgroundColor: primaryColor,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                splashFactory: InkRipple.splashFactory,
              ),
              child: Text(
                'Lanjut ke Pembayaran',
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontWeight: semibold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
