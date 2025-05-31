import 'package:flutter/material.dart';
import 'package:flutter_profile_picture/flutter_profile_picture.dart';
import 'package:katering_ibu_m_flutter/constants/index.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:katering_ibu_m_flutter/models/menu_model.dart';
import 'package:katering_ibu_m_flutter/models/ulasan_model.dart';
import 'package:katering_ibu_m_flutter/screens/client/view_reviews_screen.dart';
import 'package:katering_ibu_m_flutter/screens/client/notification_screen.dart';
import 'package:katering_ibu_m_flutter/screens/client/search_menu_screen.dart';
import 'package:katering_ibu_m_flutter/services/ulasan_service.dart';
import 'package:katering_ibu_m_flutter/services/user_service.dart';
import 'package:katering_ibu_m_flutter/widgets/custom_bottom_bar.dart';
import 'package:katering_ibu_m_flutter/widgets/menu_card.dart';
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
            return Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(12),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: primaryColor.withAlpha(51),
                            width: 2,
                          ),
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
                      SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  ulasan.user.nama,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontWeight: bold,
                                    color: primaryColor,
                                    fontSize: 16,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.blue.shade200,
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    'Customer',
                                    style: GoogleFonts.plusJakartaSans(
                                      color: Colors.blue.shade600,
                                      fontSize: 10,
                                      fontWeight: semibold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 4),
                            Text(
                              ulasan.waktu,
                              style: GoogleFonts.plusJakartaSans(
                                color: Colors.grey.shade500,
                                fontSize: 12,
                                fontWeight: medium,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: primaryColor.withAlpha(25),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.format_quote,
                          size: 16,
                          color: primaryColor,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          ulasan.pesan,
                          style: GoogleFonts.plusJakartaSans(
                            color: primaryColor,
                            fontSize: 14,
                            fontWeight: medium,
                            height: 1.5,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
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
                  return AllReviewsScreen();
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
