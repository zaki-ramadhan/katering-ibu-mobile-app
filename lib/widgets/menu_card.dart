// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:katering_ibu_m_flutter/constants/index.dart';
import 'package:katering_ibu_m_flutter/models/menu_model.dart';
import 'package:katering_ibu_m_flutter/provider/cart_provider.dart';
import 'package:katering_ibu_m_flutter/screens/client/view_menu_screen.dart';
import 'package:katering_ibu_m_flutter/widgets/custom_notification.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class MenuCard extends StatelessWidget {
  final Menu menu;
  final bool showCartButton;

  const MenuCard({super.key, required this.menu, this.showCartButton = true});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Image.network(
                  menu.foto,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[300],
                      child: const Center(
                        child: Icon(Icons.image, size: 40, color: Colors.grey),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              menu.namaMenu,
              style: GoogleFonts.plusJakartaSans(
                fontWeight: semibold,
                fontSize: 16,
                color: primaryColor,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              menu.formattedHarga,
              style: GoogleFonts.plusJakartaSans(
                fontWeight: semibold,
                fontSize: 18,
                color: primaryColor,
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Container(
                    margin: EdgeInsets.only(right: 6),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
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
                              return ViewMenu(menu: menu);
                            },
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        shadowColor: transparent,
                        backgroundColor: primaryColor,
                        padding: EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: primaryColor.withAlpha(140),
                            width: 1.2,
                          ),
                        ),
                      ),
                      child: Text(
                        'Lihat menu',
                        style: GoogleFonts.plusJakartaSans(
                          color: white,
                          fontWeight: semibold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
                if (showCartButton)
                  Expanded(
                    flex: 1,
                    child: Consumer<CartProvider>(
                      builder: (context, cartProvider, child) {
                        return ElevatedButton(
                          onPressed:
                              cartProvider.isLoading
                                  ? null
                                  : () => _showAddToCartModal(context, menu),
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            shadowColor: transparent,
                            foregroundColor: primaryColor,
                            backgroundColor: white,
                            padding: EdgeInsets.fromLTRB(13, 13, 10, 13),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: primaryColor.withAlpha(120),
                                width: 1.2,
                              ),
                            ),
                          ),
                          child:
                              cartProvider.isLoading
                                  ? SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        primaryColor,
                                      ),
                                    ),
                                  )
                                  : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.shopping_cart_rounded,
                                        size: 20,
                                      ),
                                      Text(
                                        '+',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontWeight: extrabold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  void _showAddToCartModal(BuildContext context, Menu menu) {
    int quantity = 1;
    final NumberFormat rupiahFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              decoration: BoxDecoration(
                color: white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Padding(
                padding: EdgeInsets.fromLTRB(24, 20, 24, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),

                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            menu.foto,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 80,
                                height: 80,
                                color: Colors.grey[300],
                                child: Icon(Icons.image_not_supported),
                              );
                            },
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                menu.namaMenu,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 18,
                                  fontWeight: semibold,
                                  color: primaryColor,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 8),
                              Text(
                                rupiahFormat.format(menu.harga),
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 16,
                                  fontWeight: bold,
                                  color: primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 24),

                    Text(
                      'Jumlah Pesanan',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: semibold,
                        color: primaryColor,
                      ),
                    ),
                    SizedBox(height: 12),

                    Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              IconButton(
                                onPressed:
                                    quantity > 1
                                        ? () {
                                          setState(() {
                                            quantity--;
                                          });
                                        }
                                        : null,
                                icon: Icon(Icons.remove),
                                color:
                                    quantity > 1 ? primaryColor : Colors.grey,
                              ),
                              Container(
                                width: 50,
                                alignment: Alignment.center,
                                child: Text(
                                  '$quantity',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 18,
                                    fontWeight: bold,
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    quantity++;
                                  });
                                },
                                icon: Icon(Icons.add),
                                color: primaryColor,
                              ),
                            ],
                          ),
                        ),
                        Spacer(),
                        Text(
                          'Subtotal: ${rupiahFormat.format(menu.harga * quantity)}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: bold,
                            color: primaryColor,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 24),

                    Consumer<CartProvider>(
                      builder: (context, cartProvider, child) {
                        return SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () async {
                              final result = await cartProvider.addItem(
                                menu: menu,
                                quantity: quantity,
                              );

                              Navigator.pop(context);

                              if (result['success']) {
                                CustomNotification.showSuccess(
                                  context: context,
                                  title: 'Berhasil ditambahkan!',
                                  message:
                                      '$quantity item ${menu.namaMenu} telah ditambahkan ke keranjang',
                                );
                              } else {
                                CustomNotification.showError(
                                  context: context,
                                  title: 'Gagal menambahkan',
                                  message: result['message'],
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child:
                                cartProvider.isLoading
                                    ? SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              white,
                                            ),
                                      ),
                                    )
                                    : Text(
                                      'Tambah ke Keranjang',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 16,
                                        color: white,
                                        fontWeight: semibold,
                                      ),
                                    ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
