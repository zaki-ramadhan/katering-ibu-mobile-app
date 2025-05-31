import 'package:flutter/material.dart';
import 'package:flutter_profile_picture/flutter_profile_picture.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:katering_ibu_m_flutter/constants/index.dart';
import 'package:katering_ibu_m_flutter/models/ulasan_model.dart';

class ReviewCard extends StatelessWidget {
  final Ulasan ulasan;
  final bool isMyReview;
  final bool isCompact;

  const ReviewCard({
    super.key,
    required this.ulasan,
    this.isMyReview = false,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              isMyReview ? primaryColor.withAlpha(100) : Colors.grey.shade200,
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
                        isMyReview ? primaryColor : primaryColor.withAlpha(51),
                    width: 2,
                  ),
                ),
                child:
                    ulasan.user.fotoProfil != null &&
                            ulasan.user.fotoProfil!.isNotEmpty
                        ? ClipOval(
                          child: Image.network(
                            ulasan.user.fotoProfil!,
                            width: 48,
                            height: 48,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
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
                        if (isMyReview)
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: primaryColor.withAlpha(25),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: primaryColor.withAlpha(80),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              'Anda',
                              style: GoogleFonts.plusJakartaSans(
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
                  color:
                      isMyReview
                          ? primaryColor.withAlpha(40)
                          : primaryColor.withAlpha(25),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.format_quote, size: 16, color: primaryColor),
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
                  maxLines: isCompact ? 2 : null,
                  overflow: isCompact ? TextOverflow.ellipsis : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
