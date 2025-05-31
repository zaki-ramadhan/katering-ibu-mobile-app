import 'package:flutter/material.dart';
import 'package:flutter_profile_picture/flutter_profile_picture.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:katering_ibu_m_flutter/constants/index.dart';
import 'package:katering_ibu_m_flutter/models/ulasan_model.dart';
import 'package:katering_ibu_m_flutter/services/ulasan_service.dart';
import 'package:katering_ibu_m_flutter/services/user_service.dart';
import 'package:katering_ibu_m_flutter/widgets/custom_app_bar.dart';
import 'package:logger/logger.dart';

class AllReviewsScreen extends StatefulWidget {
  const AllReviewsScreen({super.key});

  @override
  State<AllReviewsScreen> createState() => _AllReviewsScreenState();
}

class _AllReviewsScreenState extends State<AllReviewsScreen> {
  bool showMyReviewsOnly = false;
  String? currentUserName;
  Logger logger = Logger();

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  Future<void> _getCurrentUser() async {
    try {
      final userData = await UserService().fetchLoggedInUser();
      setState(() {
        currentUserName = userData['name'];
      });
    } catch (e) {
      logger.e('Error getting current user: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final ulasanService = UlasanService();

    return Scaffold(
      appBar: CustomAppBar(
        titleAppBar: showMyReviewsOnly ? 'Ulasan Saya' : 'Semua Testimoni',
        isIconShow: true,
        isLogoutIconShow: false,
        isNavigableByBottomBar: false,
      ),
      backgroundColor: Colors.grey.shade50,
      body: Container(
        color: Colors.blueGrey.shade100.withAlpha(45),
        child: Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blueGrey.shade100.withAlpha(60),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: primaryColor.withAlpha(80),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: primaryColor, size: 20),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            showMyReviewsOnly
                                ? 'Menampilkan ulasan Anda'
                                : 'Semua testimoni dari pelanggan kami',
                            style: GoogleFonts.plusJakartaSans(
                              color: primaryColor,
                              fontSize: 14,
                              fontWeight: semibold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                showMyReviewsOnly = false;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  !showMyReviewsOnly
                                      ? primaryColor
                                      : Colors.white,
                              foregroundColor:
                                  !showMyReviewsOnly
                                      ? Colors.white
                                      : primaryColor,
                              elevation: 0,
                              padding: EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: BorderSide(color: primaryColor, width: 1),
                              ),
                            ),
                            child: Text(
                              'Semua',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: semibold,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                showMyReviewsOnly = true;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  showMyReviewsOnly
                                      ? primaryColor
                                      : Colors.white,
                              foregroundColor:
                                  showMyReviewsOnly
                                      ? Colors.white
                                      : primaryColor,
                              elevation: 0,
                              padding: EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: BorderSide(color: primaryColor, width: 1),
                              ),
                            ),
                            child: Text(
                              'Saya',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: semibold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Expanded(
                child: FutureBuilder<List<Ulasan>>(
                  future: ulasanService.getUlasan(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(color: primaryColor),
                      );
                    }

                    if (snapshot.hasError) {
                      return Center(
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
                      );
                    }

                    final allUlasans = snapshot.data ?? [];

                    final displayedUlasans =
                        showMyReviewsOnly
                            ? allUlasans
                                .where(
                                  (ulasan) =>
                                      ulasan.user.nama == currentUserName,
                                )
                                .toList()
                            : allUlasans;

                    if (displayedUlasans.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.chat_bubble_outline,
                              color: Colors.grey.shade400,
                              size: 80,
                            ),
                            SizedBox(height: 16),
                            Text(
                              showMyReviewsOnly
                                  ? 'Belum Ada Ulasan Anda'
                                  : 'Belum Ada Testimoni',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 20,
                                fontWeight: bold,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              showMyReviewsOnly
                                  ? 'Anda belum memberikan ulasan'
                                  : 'Jadilah yang pertama memberikan testimoni!',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.separated(
                      padding: EdgeInsets.all(0),
                      itemCount: displayedUlasans.length,
                      separatorBuilder:
                          (context, index) => SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final ulasan = displayedUlasans[index];
                        final isMyReview = ulasan.user.nama == currentUserName;

                        return Container(
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color:
                                  isMyReview
                                      ? primaryColor.withAlpha(100)
                                      : Colors.grey.shade200,
                              width: isMyReview ? 2 : 1,
                            ),
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
                                        color:
                                            isMyReview
                                                ? primaryColor
                                                : primaryColor.withAlpha(51),
                                        width: 2,
                                      ),
                                    ),
                                    child:
                                        ulasan.user.fotoProfil != null &&
                                                ulasan
                                                    .user
                                                    .fotoProfil!
                                                    .isNotEmpty
                                            ? ClipOval(
                                              child: Image.network(
                                                ulasan.user.fotoProfil!,
                                                width: 48,
                                                height: 48,
                                                fit: BoxFit.cover,
                                                errorBuilder: (
                                                  context,
                                                  error,
                                                  stackTrace,
                                                ) {
                                                  return ProfilePicture(
                                                    name: ulasan.user.nama,
                                                    radius: 24,
                                                    fontsize: 14,
                                                  );
                                                },
                                              ),
                                            )
                                            : ProfilePicture(
                                              name: ulasan.user.nama,
                                              radius: 24,
                                              fontsize: 18,
                                            ),
                                  ),
                                  SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              ulasan.user.nama,
                                              style:
                                                  GoogleFonts.plusJakartaSans(
                                                    fontWeight: bold,
                                                    color: primaryColor,
                                                    fontSize: 16,
                                                  ),
                                            ),
                                            SizedBox(width: 8),
                                            if (isMyReview)
                                              Container(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 3,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: primaryColor.withAlpha(
                                                    25,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  border: Border.all(
                                                    color: primaryColor
                                                        .withAlpha(80),
                                                    width: 1,
                                                  ),
                                                ),
                                                child: Text(
                                                  'Anda',
                                                  style:
                                                      GoogleFonts.plusJakartaSans(
                                                        color: primaryColor,
                                                        fontSize: 10,
                                                        fontWeight: bold,
                                                      ),
                                                ),
                                              )
                                            else
                                              Container(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 3,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.blue.shade50,
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  border: Border.all(
                                                    color: Colors.blue.shade200,
                                                    width: 1,
                                                  ),
                                                ),
                                                child: Text(
                                                  'Customer',
                                                  style:
                                                      GoogleFonts.plusJakartaSans(
                                                        color:
                                                            Colors
                                                                .blue
                                                                .shade600,
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
                                      color:
                                          isMyReview
                                              ? primaryColor.withAlpha(40)
                                              : primaryColor.withAlpha(25),
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
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
