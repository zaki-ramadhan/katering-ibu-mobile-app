import 'package:flutter/material.dart';
import 'package:flutter_profile_picture/flutter_profile_picture.dart';
import 'package:katering_ibu_m_flutter/constants/index.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:katering_ibu_m_flutter/models/menu_model.dart';
import 'package:katering_ibu_m_flutter/models/ulasan_model.dart';
import 'package:katering_ibu_m_flutter/provider/cart_provider.dart';
import 'package:katering_ibu_m_flutter/screens/client/cart_screen.dart';
import 'package:katering_ibu_m_flutter/screens/client/notification_screen.dart';
import 'package:katering_ibu_m_flutter/screens/client/search_menu_screen.dart';
import 'package:katering_ibu_m_flutter/screens/client/view_menu_screen.dart';
import 'package:katering_ibu_m_flutter/services/ulasan_service.dart';
import 'package:katering_ibu_m_flutter/services/user_service.dart';
import 'package:katering_ibu_m_flutter/widgets/custom_bottom_bar.dart';
import 'package:katering_ibu_m_flutter/services/menu_service.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? name;
  String? role;
  String? profileImage;
  String? phone;

  Logger logger = Logger();

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      final userData = await UserService().fetchLoggedInUser();

      setState(() {
        name = userData['name'];
        role = userData['role'];
        profileImage = userData['foto_profile'];
        phone = userData['notelp'];
      });
    } catch (e) {
      logger.i('Error fetching user data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(top: 44),
          child: Column(
            children: [
              Container(
                color: Colors.white,
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          center: Alignment.bottomCenter,
                          radius: 2.0,
                          colors: [
                            primaryColor,
                            const Color.fromARGB(255, 59, 77, 97),
                            const Color.fromARGB(255, 38, 54, 68),
                          ],
                          stops: [0.0, 0.5, 0.9],
                        ),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(20),
                          bottomRight: Radius.circular(20),
                        ),
                      ),
                      child: Column(
                        children: [_buildHeader(context), _buildSearchBar()],
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildRecommendationsList(),
                    const SizedBox(height: 66),
                    _buildAllMenuList(),
                    const SizedBox(height: 52),
                    _buildReviewCustomers(context),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomBar(currentPage: 'home'),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            spacing: 4,
            children: [
              profileImage != null && profileImage!.isNotEmpty
                  ? CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.grey.shade300,
                    backgroundImage: NetworkImage(profileImage!),
                  )
                  : ProfilePicture(name: name ?? '', radius: 24, fontsize: 18),
              const SizedBox(width: 10),
              Column(
                spacing: 1,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name ?? '',
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white,
                      fontWeight: semibold,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    phone ?? '',
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.grey[400],
                      fontSize: 14,
                      fontWeight: medium,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Container(
            decoration: BoxDecoration(
              color: white.withAlpha(20),
              borderRadius: BorderRadius.circular(14),
            ),
            padding: const EdgeInsets.all(2),
            child: IconButton(
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
                        return FadeTransition(opacity: animation, child: child);
                      },
                      pageBuilder: (context, animation, secondaryAnimation) {
                        return NotificationScreen();
                      },
                    ),
                  ),
              icon: Icon(Icons.notifications),
              iconSize: 28,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    final TextEditingController searchController = TextEditingController();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(
          children: [
            const Icon(Icons.search, color: Colors.grey, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: 'Cari menu disini ...',
                  hintStyle: GoogleFonts.plusJakartaSans(
                    color: Colors.grey[500],
                    fontSize: 16,
                    fontWeight: medium,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                ),
                style: GoogleFonts.plusJakartaSans(
                  color: primaryColor,
                  fontWeight: medium,
                  fontSize: 16,
                ),
                onSubmitted: (text) {
                  if (text.isNotEmpty) {
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
                        pageBuilder: (context, animation, secondaryAnimation) {
                          return SearchMenuScreen(searchMenuName: text);
                        },
                      ),
                    );
                    searchController.clear();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationsList() {
    final menuService = MenuService();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Rekomendasi menu untukmu',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 20,
                  fontWeight: bold,
                  color: primaryColor,
                ),
              ),
            ],
          ),
        ),
        FutureBuilder<List<Menu>>(
          future: menuService.getMenus(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error: ${snapshot.error}',
                  style: GoogleFonts.plusJakartaSans(color: Colors.red),
                ),
              );
            }

            final menus = snapshot.data ?? [];
            menus.sort((a, b) => b.terjual.compareTo(a.terjual));
            final topMenus = menus.take(4).toList();

            return GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: topMenus.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.65,
                crossAxisSpacing: 18,
                mainAxisSpacing: 24,
              ),
              itemBuilder: (context, index) {
                return _buildMenuItem(topMenus[index], context);
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildAllMenuList() {
    final menuService = MenuService();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Semua Menu',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 20,
                  fontWeight: bold,
                  color: primaryColor,
                ),
              ),
            ],
          ),
        ),
        FutureBuilder<List<Menu>>(
          future: menuService.getMenus(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error: ${snapshot.error}',
                  style: GoogleFonts.plusJakartaSans(color: Colors.red),
                ),
              );
            }

            final menus = snapshot.data ?? [];

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.65,
                crossAxisSpacing: 18,
                mainAxisSpacing: 24,
              ),
              itemCount: menus.length,
              itemBuilder: (context, index) {
                return _buildMenuItem(menus[index], context);
              },
            );
          },
        ),
      ],
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
                    onPressed: () {
                      Provider.of<CartProvider>(
                        context,
                        listen: false,
                      ).addItem(menu);
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Menu ${menu.namaMenu} ditambahkan ke keranjang!',
                          ),
                          backgroundColor: Colors.green,
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
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
      ],
    );
  }

  Widget _buildReviewCustomers(BuildContext context) {
    final ulasanService = UlasanService();

    return Container(
      color: Colors.blueGrey.shade100.withAlpha(45),
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 56, 20, 66),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 6,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  'Testimoni Pelanggan',
                  style: GoogleFonts.plusJakartaSans(
                    color: primaryColor,
                    fontSize: 20,
                    fontWeight: bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 4),
            FutureBuilder<List<Ulasan>>(
              future: ulasanService.getUlasan(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error: ${snapshot.error}',
                      style: GoogleFonts.plusJakartaSans(color: Colors.red),
                    ),
                  );
                }

                final ulasans = snapshot.data ?? [];
                final displayedUlasans = ulasans.take(3).toList();

                return ListView.builder(
                  shrinkWrap: true,
                  padding: EdgeInsets.all(0),
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: displayedUlasans.length,
                  itemBuilder: (context, index) {
                    final ulasan = displayedUlasans[index];
                    return Container(
                      margin: EdgeInsets.only(bottom: 8),
                      padding: EdgeInsets.fromLTRB(18, 18, 24, 32),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey.shade200,
                          width: 1,
                        ),
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: const Color.fromARGB(7, 0, 0, 0),
                            blurRadius: 6,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                image:
                                    ulasan.user.fotoProfil != null
                                        ? NetworkImage(ulasan.user.fotoProfil!)
                                        : const AssetImage(
                                              'assets/images/default_profile.jpg',
                                            )
                                            as ImageProvider,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  ulasan.user.nama,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontWeight: semibold,
                                    color: primaryColor,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  ulasan.pesan,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.plusJakartaSans(
                                    color: primaryColor,
                                    fontSize: 14,
                                    fontWeight: medium,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  ulasan.waktu,
                                  style: GoogleFonts.plusJakartaSans(
                                    color: Colors.grey[500],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.all(18),
                  elevation: 0,
                ),
                onPressed: () {},
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Lihat Testimoni Lainnya',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: semibold,
                      ),
                    ),
                    Icon(Icons.navigate_next),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
