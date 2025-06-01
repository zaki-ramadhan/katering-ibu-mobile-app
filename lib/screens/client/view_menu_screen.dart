// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:katering_ibu_m_flutter/constants/index.dart';
import 'package:katering_ibu_m_flutter/models/menu_model.dart';
import 'package:katering_ibu_m_flutter/provider/cart_provider.dart';
import 'package:katering_ibu_m_flutter/screens/client/checkout_order_screen.dart';
import 'package:katering_ibu_m_flutter/services/menu_service.dart';
import 'package:katering_ibu_m_flutter/widgets/custom_app_bar.dart';
import 'package:katering_ibu_m_flutter/widgets/custom_notification.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class ViewMenu extends StatelessWidget {
  final Menu menu;
  const ViewMenu({super.key, required this.menu});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      appBar: CustomAppBar(
        titleAppBar: 'Detail Menu',
        isIconShow: false,
        isLogoutIconShow: false,
        isNavigableByBottomBar: false,
      ),
      body: Container(
        color: white,
        height: double.infinity,
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.only(bottom: 92),
              child: Column(
                children: [
                  SafeArea(child: Container()),
                  Stack(
                    children: [
                      Image.network(
                        menu.foto,
                        width: double.infinity,
                        height: 380,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[300],
                            child: Icon(Icons.image_not_supported),
                          );
                        },
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
                        child: Column(
                          spacing: 24,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    spacing: 3,
                                    children: [
                                      Text(
                                        menu.namaMenu,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 20,
                                          color: primaryColor,
                                          fontWeight: medium,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        menu.formattedHarga,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 28,
                                          color: primaryColor,
                                          fontWeight: semibold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  spacing: 2,
                                  children: [
                                    Icon(
                                      Icons.star,
                                      color: const Color.fromARGB(
                                        255,
                                        255,
                                        206,
                                        59,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            FutureBuilder<List<Menu>>(
                              future: MenuService().getMenus(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return _buildDefaultLabels(context);
                                }

                                if (snapshot.hasError) {
                                  return _buildDefaultLabels(context);
                                }

                                final allMenus = snapshot.data ?? [];
                                return _buildDynamicLabels(context, allMenus);
                              },
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              spacing: 6,
                              children: [
                                Text(
                                  'Deskripsi',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontWeight: semibold,
                                    fontSize: 18,
                                  ),
                                ),
                                Text(
                                  menu.deskripsi,
                                  style: GoogleFonts.plusJakartaSans(
                                    height: 1.7,
                                    fontSize: 16,
                                    fontWeight: regular,
                                    color: Colors.grey.shade500,
                                  ),
                                  maxLines: 4,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                      FutureBuilder<List<Menu>>(
                        future: MenuService().getMenus(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          }

                          if (snapshot.hasError) {
                            return Center(
                              child: Text(
                                'Error: ${snapshot.error}',
                                style: GoogleFonts.plusJakartaSans(
                                  color: errorColor,
                                ),
                              ),
                            );
                          }

                          final allMenus = snapshot.data ?? [];
                          return _buildSimilarMenuRecommendations(
                            context,
                            allMenus,
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            _buildCTACustomBottomBar(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSimilarMenuRecommendations(
    BuildContext context,
    List<Menu> allMenus,
  ) {
    final similarMenus =
        allMenus.where((otherMenu) {
          if (menu.namaMenu.contains('Nasi Liwet') &&
              otherMenu.namaMenu.contains('Nasi Liwet')) {
            return menu.namaMenu != otherMenu.namaMenu;
          } else if (menu.namaMenu.contains('Nasi Kuning') &&
              otherMenu.namaMenu.contains('Nasi Kuning')) {
            return menu.namaMenu != otherMenu.namaMenu;
          }
          return false;
        }).toList();

    if (similarMenus.isEmpty) {
      return SizedBox();
    }

    return Container(
      color: Colors.blueGrey.shade100.withAlpha(25),
      padding: EdgeInsets.fromLTRB(20, 16, 20, 36),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Rekomendasi menu serupa',
            style: GoogleFonts.plusJakartaSans(
              fontWeight: semibold,
              fontSize: 20,
            ),
          ),
          SizedBox(height: 12),
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: similarMenus.length,
            itemBuilder: (context, index) {
              final similarMenu = similarMenus[index];
              return Container(
                margin: EdgeInsets.only(bottom: 16),
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: white,
                  border: Border.all(
                    color: Colors.blueGrey.shade100.withAlpha(150),
                    width: 0.8,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        similarMenu.foto,
                        width: 100,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
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
                            similarMenu.namaMenu,
                            style: GoogleFonts.plusJakartaSans(
                              color: primaryColor,
                              fontSize: 16,
                              fontWeight: semibold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 8),
                          Text(
                            similarMenu.formattedHarga,
                            style: GoogleFonts.plusJakartaSans(
                              color: primaryColor,
                              fontWeight: semibold,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ViewMenu(menu: similarMenu),
                          ),
                        );
                      },
                      icon: Icon(Icons.navigate_next, size: 36),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(
    BuildContext context,
    String label,
    Color colour, [
    IconData? icon,
  ]) {
    return Container(
      decoration: BoxDecoration(
        color: colour.withAlpha(20),
        border: Border.all(color: colour.withAlpha(180), width: 1.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 6,
          children: [
            if (icon != null) Icon(icon, size: 16, color: colour),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                color: colour,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCTACustomBottomBar(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        decoration: BoxDecoration(
          color: white,
          border: Border(
            top: BorderSide(color: Colors.grey.shade300, width: 1),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: TextButton(
                onPressed: () => _buildAddToCartModal(context),
                style: TextButton.styleFrom(
                  foregroundColor: primaryColor,
                  padding: EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add_shopping_cart_rounded, size: 28),
                    SizedBox(height: 4),
                    Text(
                      'Tambah Keranjang',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: medium,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              flex: 1,
              child: ElevatedButton(
                onPressed:
                    () => Navigator.push(
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
                        pageBuilder: (context, animation, secondaryAnimation) {
                          return CheckoutOrderScreen();
                        },
                      ),
                    ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  padding: EdgeInsets.symmetric(vertical: 20),
                  elevation: 0,
                  shadowColor: transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Pesan Sekarang',
                  style: GoogleFonts.plusJakartaSans(
                    color: white,
                    fontSize: 14,
                    fontWeight: semibold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _buildAddToCartModal(BuildContext context) {
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

  Widget _buildDynamicLabels(BuildContext context, List<Menu> allMenus) {
    List<Widget> labels = [];

    final sortedByTerjual = [...allMenus];
    sortedByTerjual.sort((a, b) => b.terjual.compareTo(a.terjual));
    final top4Terlaris = sortedByTerjual.take(4).toList();

    final sortedByHarga = [...allMenus];
    sortedByHarga.sort((a, b) => a.harga.compareTo(b.harga));
    final top4Termurah = sortedByHarga.take(4).toList();

    bool isTerlaris = top4Terlaris.any((m) => m.id == menu.id);
    bool isTermurah = top4Termurah.any((m) => m.id == menu.id);

    if (isTerlaris) {
      labels.add(
        _buildLabel(
          context,
          'Terlaris',
          Colors.red.shade500,
          Icons.local_fire_department_rounded,
        ),
      );
    }

    if (isTermurah) {
      labels.add(
        _buildLabel(
          context,
          'Termurah',
          Colors.green.shade600,
          Icons.monetization_on_rounded,
        ),
      );
    }

    if (isTerlaris) {
      labels.add(
        _buildLabel(
          context,
          'Pilihan Populer',
          Colors.orange.shade500,
          Icons.thumb_up_rounded,
        ),
      );
    }

    if (labels.isEmpty) {
      return _buildDefaultLabels(context);
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: Wrap(spacing: 8, runSpacing: 8, children: labels),
    );
  }

  Widget _buildDefaultLabels(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Wrap(
        spacing: 10,
        children: [
          _buildLabel(
            context,
            'Rekomendasi',
            Colors.blue.shade600,
            Icons.recommend_rounded,
          ),
          _buildLabel(
            context,
            'Berkualitas',
            Colors.amber.shade600,
            Icons.verified_rounded,
          ),
        ],
      ),
    );
  }
}
