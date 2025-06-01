import 'package:flutter/material.dart';
import 'package:flutter_profile_picture/flutter_profile_picture.dart';
import 'package:katering_ibu_m_flutter/constants/index.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:katering_ibu_m_flutter/models/menu_model.dart';
import 'package:katering_ibu_m_flutter/models/ulasan_model.dart';
import 'package:katering_ibu_m_flutter/screens/client/view_reviews_screen.dart';
import 'package:katering_ibu_m_flutter/screens/client/notification_screen.dart';
import 'package:katering_ibu_m_flutter/screens/client/search_menu_screen.dart';
import 'package:katering_ibu_m_flutter/screens/client/cust_account_screen.dart';
import 'package:katering_ibu_m_flutter/services/ulasan_service.dart';
import 'package:katering_ibu_m_flutter/services/user_service.dart';
import 'package:katering_ibu_m_flutter/widgets/custom_bottom_bar.dart';
import 'package:katering_ibu_m_flutter/widgets/menu_card.dart';
import 'package:katering_ibu_m_flutter/widgets/review_card.dart';
import 'package:katering_ibu_m_flutter/services/menu_service.dart';
import 'package:logger/logger.dart';

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

  void _navigateToAccount() {
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: Duration(milliseconds: 300),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        pageBuilder: (context, animation, secondaryAnimation) {
          return CustomerAccount();
        },
      ),
    );
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
          GestureDetector(
            onTap: _navigateToAccount,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    child:
                        profileImage != null && profileImage!.isNotEmpty
                            ? CircleAvatar(
                              radius: 24,
                              backgroundColor: Colors.grey.shade300,
                              backgroundImage: NetworkImage(profileImage!),
                            )
                            : ProfilePicture(
                              name: name ?? '',
                              radius: 24,
                              fontsize: 18,
                            ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            name ?? '',
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white,
                              fontWeight: semibold,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: Colors.white.withAlpha(180),
                            size: 14,
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
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
            ),
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
                return MenuCard(menu: topMenus[index]);
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
                return MenuCard(menu: menus[index]);
              },
            );
          },
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
          children: [
            FutureBuilder<List<Ulasan>>(
              future: ulasanService.getUlasan(),
              builder: (context, snapshot) {
                final ulasans = snapshot.data ?? [];

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Testimoni Pelanggan (${ulasans.length})',
                          style: GoogleFonts.plusJakartaSans(
                            color: primaryColor,
                            fontSize: 20,
                            fontWeight: bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),

                    if (snapshot.connectionState == ConnectionState.waiting)
                      SizedBox(
                        height: 200,
                        child: Center(
                          child: CircularProgressIndicator(color: primaryColor),
                        ),
                      )
                    else if (snapshot.hasError)
                      SizedBox(
                        height: 100,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline,
                                color: Colors.red,
                                size: 32,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Gagal memuat testimoni',
                                style: GoogleFonts.plusJakartaSans(
                                  color: Colors.red,
                                  fontWeight: medium,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else if (ulasans.isEmpty)
                      SizedBox(
                        height: 120,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.chat_bubble_outline,
                                color: Colors.grey.shade400,
                                size: 40,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Belum ada testimoni',
                                style: GoogleFonts.plusJakartaSans(
                                  color: Colors.grey.shade600,
                                  fontWeight: medium,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      _buildTestimoniList(ulasans),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestimoniList(List<Ulasan> ulasans) {
    List<Ulasan> uniqueUserUlasans = [];
    Set<String> seenUsers = <String>{};

    for (Ulasan ulasan in ulasans) {
      String userIdentifier = ulasan.user.nama.toLowerCase().trim();

      if (!seenUsers.contains(userIdentifier) && uniqueUserUlasans.length < 3) {
        uniqueUserUlasans.add(ulasan);
        seenUsers.add(userIdentifier);
      }
    }

    final displayedUlasans = uniqueUserUlasans;

    return Column(
      children: [
        ListView.separated(
          shrinkWrap: true,
          padding: EdgeInsets.all(0),
          physics: const NeverScrollableScrollPhysics(),
          itemCount: displayedUlasans.length,
          separatorBuilder: (context, index) => SizedBox(height: 16),
          itemBuilder: (context, index) {
            final ulasan = displayedUlasans[index];
            return ReviewCard(ulasan: ulasan, isCompact: true);
          },
        ),
        SizedBox(height: 24),
        ElevatedButton(
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
                  return FadeTransition(opacity: animation, child: child);
                },
                pageBuilder: (context, animation, secondaryAnimation) {
                  return ViewReviewsScreen();
                },
              ),
            );
          },
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
          child: SizedBox(
            width: double.infinity,
            child: Text(
              'Lihat Semua Testimoni',
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white,
                fontWeight: semibold,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }
}
