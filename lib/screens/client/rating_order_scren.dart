import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:katering_ibu_m_flutter/constants/index.dart';
import 'package:katering_ibu_m_flutter/dummy_data.dart';
import 'package:katering_ibu_m_flutter/widgets/custom_app_bar.dart';

class RatingOrderScren extends StatefulWidget {
  const RatingOrderScren({super.key});

  @override
  State<RatingOrderScren> createState() => _RatingOrderScrenState();
}

class _RatingOrderScrenState extends State<RatingOrderScren> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      appBar: CustomAppBar(
        titleAppBar: 'Beri Penilaian Pesanan',
        isIconShow: false,
        isLogoutIconShow: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              color: Colors.blueGrey.shade50.withAlpha(120),
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 52),
              child: Column(
                spacing: 20,
                children: [
                  Text(
                    "#2309401",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: semibold,
                      color: primaryColor,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Transform.translate(
                        offset: Offset(30, 0),
                        child: CircleAvatar(
                          radius: 45,
                          backgroundImage: AssetImage(
                            DummyData.allMenus[2]['image'],
                          ),
                          backgroundColor: Colors.transparent,
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: white, width: 3),
                            ),
                          ),
                        ),
                      ),
                      Transform.translate(
                        offset: Offset(0, 0),
                        child: CircleAvatar(
                          radius: 45,
                          backgroundImage: AssetImage(
                            DummyData.allMenus[1]['image'],
                          ),
                          backgroundColor: Colors.transparent,
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: white, width: 3),
                            ),
                          ),
                        ),
                      ),
                      Transform.translate(
                        offset: Offset(-30, 0),
                        child: CircleAvatar(
                          radius: 45,
                          backgroundImage: AssetImage(
                            DummyData.allMenus[6]['image'],
                          ),
                          backgroundColor: Colors.transparent,
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: white, width: 3),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: 8,
                    children: [
                      Text(
                        'Selesai',
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.green.shade500,
                          fontWeight: semibold,
                          fontSize: 16,
                        ),
                      ),
                      Icon(Icons.check_circle, color: Colors.green.shade400),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 52),
              child: Column(
                spacing: 12,
                children: [
                  Text(
                    'Seberapa puas kamu dengan pelayanan kami?\nBerikan penilaianmu!',
                    style: GoogleFonts.plusJakartaSans(
                      color: primaryColor,
                      fontSize: 18,
                      fontWeight: medium,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.star_rounded,
                        color: Colors.blueGrey.shade100.withAlpha(180),
                        size: 36,
                      ),
                      Icon(
                        Icons.star_rounded,
                        color: Colors.blueGrey.shade100.withAlpha(180),
                        size: 36,
                      ),
                      Icon(
                        Icons.star_rounded,
                        color: Colors.blueGrey.shade100.withAlpha(180),
                        size: 36,
                      ),
                      Icon(
                        Icons.star_rounded,
                        color: Colors.blueGrey.shade100.withAlpha(180),
                        size: 36,
                      ),
                      Icon(
                        Icons.star_rounded,
                        color: Colors.blueGrey.shade100.withAlpha(180),
                        size: 36,
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 32),
                    child: TextField(
                      maxLines: 8,
                      decoration: InputDecoration(
                        hintText: 'Apa pendapat Anda tentang pesanan ini?',
                        hintStyle: GoogleFonts.plusJakartaSans(
                          color: Colors.blueGrey.shade400,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 20,
                          horizontal: 24,
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: Colors.blueGrey.shade200,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            width: 1.3,
                            color: Colors.blueGrey.shade500,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Colors.red,
                            width: 1.3,
                          ),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Colors.red,
                            width: 1.3,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: BottomAppBar(
        color: white,
        height: 110,
        padding: EdgeInsetsDirectional.zero,
        child: Expanded(
          child: Padding(
            padding: EdgeInsets.fromLTRB(24, 20, 24, 32),
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                elevation: 0,
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 6),
                shadowColor: transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                backgroundColor: primaryColor,
                foregroundColor: white,
              ),
              child: Text(
                'Kirim Penilaian',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: medium,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
