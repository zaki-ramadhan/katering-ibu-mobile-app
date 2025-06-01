// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:katering_ibu_m_flutter/constants/index.dart';
import 'package:katering_ibu_m_flutter/models/menu_model.dart';
import 'package:katering_ibu_m_flutter/provider/cart_provider.dart';
import 'package:katering_ibu_m_flutter/screens/client/view_menu_screen.dart';
import 'package:katering_ibu_m_flutter/widgets/custom_notification.dart';
import 'package:provider/provider.dart';

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
                                  : () async {
                                    final result = await cartProvider.addItem(
                                      menu: menu,
                                      quantity: 1,
                                    );

                                    if (result['success']) {
                                      CustomNotification.showCart(
                                        context: context,
                                        menuName: menu.namaMenu,
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
}
