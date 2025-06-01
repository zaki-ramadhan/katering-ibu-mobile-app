import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:katering_ibu_m_flutter/constants/index.dart';
import 'package:katering_ibu_m_flutter/models/ulasan_model.dart';
import 'package:katering_ibu_m_flutter/services/ulasan_service.dart';
import 'package:katering_ibu_m_flutter/services/user_service.dart';
import 'package:katering_ibu_m_flutter/widgets/custom_app_bar.dart';
import 'package:katering_ibu_m_flutter/widgets/review_card.dart';
import 'package:logger/logger.dart';

class ViewReviewsScreen extends StatefulWidget {
  const ViewReviewsScreen({super.key});

  @override
  State<ViewReviewsScreen> createState() => _ViewReviewsScreenState();
}

class _ViewReviewsScreenState extends State<ViewReviewsScreen> {
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
                                  !showMyReviewsOnly ? primaryColor : white,
                              foregroundColor:
                                  !showMyReviewsOnly ? white : primaryColor,
                              elevation: 0,
                              shadowColor: transparent,
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
                                  showMyReviewsOnly ? primaryColor : white,
                              foregroundColor:
                                  showMyReviewsOnly ? white : primaryColor,
                              elevation: 0,
                              shadowColor: transparent,
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
                              color: errorColor,
                              size: 32,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Gagal memuat testimoni',
                              style: GoogleFonts.plusJakartaSans(
                                color: errorColor,
                                fontWeight: medium,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    final allUlasans = snapshot.data ?? [];
                    final myUlasansCount =
                        allUlasans
                            .where(
                              (ulasan) => ulasan.user.nama == currentUserName,
                            )
                            .length;

                    final displayedUlasans =
                        showMyReviewsOnly
                            ? allUlasans
                                .where(
                                  (ulasan) =>
                                      ulasan.user.nama == currentUserName,
                                )
                                .toList()
                            : allUlasans;

                    return Column(
                      children: [
                        // Update info text and button labels
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: primaryColor.withAlpha(15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text(
                                'Semua (${allUlasans.length})',
                                style: GoogleFonts.plusJakartaSans(
                                  color:
                                      !showMyReviewsOnly
                                          ? primaryColor
                                          : Colors.grey.shade600,
                                  fontSize: 12,
                                  fontWeight:
                                      !showMyReviewsOnly ? bold : medium,
                                ),
                              ),
                              Container(
                                width: 1,
                                height: 16,
                                color: Colors.grey.shade300,
                              ),
                              Text(
                                'Saya ($myUlasansCount)',
                                style: GoogleFonts.plusJakartaSans(
                                  color:
                                      showMyReviewsOnly
                                          ? primaryColor
                                          : Colors.grey.shade600,
                                  fontSize: 12,
                                  fontWeight: showMyReviewsOnly ? bold : medium,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 16),

                        if (displayedUlasans.isEmpty)
                          Expanded(
                            child: Center(
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
                            ),
                          )
                        else
                          Expanded(
                            child: ListView.separated(
                              padding: EdgeInsets.all(0),
                              itemCount: displayedUlasans.length,
                              separatorBuilder:
                                  (context, index) => SizedBox(height: 16),
                              itemBuilder: (context, index) {
                                final ulasan = displayedUlasans[index];
                                final isMyReview =
                                    ulasan.user.nama == currentUserName;

                                return ReviewCard(
                                  ulasan: ulasan,
                                  isMyReview: isMyReview,
                                  isCompact: false,
                                );
                              },
                            ),
                          ),
                      ],
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
