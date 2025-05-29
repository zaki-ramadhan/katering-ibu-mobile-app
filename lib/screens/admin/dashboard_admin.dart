import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:katering_ibu_m_flutter/constants/index.dart';

class DashboardAdmin extends StatelessWidget {
  const DashboardAdmin({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        child: Column(
          children: [
            Container(
              color: primaryColor,
              padding: EdgeInsets.fromLTRB(20, 60, 24, 92),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 6,
                    children: [
                      Text(
                        'Halo, Admin',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: bold,
                          fontSize: 24,
                          color: white
                        ),
                      ),
                      Text(
                        'Senin, 12 Mei 2025',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: medium,
                          fontSize: 15,
                          color: Colors.blueGrey.shade400,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
