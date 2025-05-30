import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:katering_ibu_m_flutter/constants/index.dart';
import 'package:katering_ibu_m_flutter/models/menu_model.dart';
import 'package:katering_ibu_m_flutter/screens/client/cart_screen.dart';
import 'package:katering_ibu_m_flutter/screens/client/view_menu_screen.dart';
import 'package:katering_ibu_m_flutter/services/menu_service.dart';
import 'package:katering_ibu_m_flutter/widgets/custom_app_bar.dart';
import 'package:logger/logger.dart';

class SearchMenuScreen extends StatefulWidget {
  final String searchMenuName;

  const SearchMenuScreen({super.key, required this.searchMenuName});

  @override
  State<SearchMenuScreen> createState() => _SearchMenuScreenState();
}

class _SearchMenuScreenState extends State<SearchMenuScreen> {
  List<Menu> _searchResults = [];
  bool _isLoading = true;
  Logger logger = Logger();

  @override
  void initState() {
    super.initState();
    _searchMenus(widget.searchMenuName);
  }

  Future<void> _searchMenus(String searchMenuName) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final menus = await MenuService().getMenus();
      final results =
          menus
              .where(
                (menu) => menu.namaMenu.toLowerCase().contains(
                  searchMenuName.toLowerCase(),
                ),
              )
              .toList();

      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      logger.e('Error searching menus: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        titleAppBar: 'Hasil Pencarian (${_searchResults.length})',
        isIconShow: true,
        isLogoutIconShow: false,
        isNavigableByBottomBar: true,
      ),
      backgroundColor: white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.blueGrey.shade50,
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Text(
                'Anda mencari : ${widget.searchMenuName}',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: medium,
                ),
              ),
            ),
          ),
          Expanded(
            child:
                _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : _searchResults.isEmpty
                    ? Center(
                      child: Text(
                        'Tidak ada hasil untuk "${widget.searchMenuName}"',
                        style: GoogleFonts.plusJakartaSans(fontSize: 16),
                      ),
                    )
                    : GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.65,
                            crossAxisSpacing: 18,
                            mainAxisSpacing: 24,
                          ),
                      itemCount: _searchResults.length,
                      itemBuilder: (context, index) {
                        return _buildMenuItem(_searchResults[index], context);
                      },
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(Menu menu, BuildContext context) {
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
                    margin: EdgeInsets.only(right: 6), // jarak antar tombol
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
                              return ViewMenu(
                                menu: menu,
                              ); // Pass Menu object langsung
                            },
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        shadowColor: Colors.transparent,
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
                              // Animasi Fade
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
                              return CartScreen();
                            },
                          ),
                        ),
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      shadowColor: Colors.transparent,
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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.shopping_cart_rounded, size: 20),
                        Text(
                          '+',
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: extrabold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        // ! label terlaris
        // Positioned(
        //   top: 8,
        //   left: -35,
        //   child: Transform.rotate(
        //     angle: -0.6,
        //     child: Container(
        //       padding: EdgeInsets.symmetric(vertical: 5, horizontal: 40),
        //       color: primaryColor,
        //       child: Text(
        //         'Terlaris',
        //         style: GoogleFonts.plusJakartaSans(
        //           color: Colors.yellow.shade500,
        //           fontWeight: semibold,
        //         ),
        //       ),
        //     ),
        //   ),
        // ),
      ],
    );
  }
}
