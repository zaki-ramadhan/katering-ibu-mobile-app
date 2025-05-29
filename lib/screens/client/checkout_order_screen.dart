import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:katering_ibu_m_flutter/constants/index.dart';
import 'package:katering_ibu_m_flutter/widgets/custom_app_bar.dart';

class CheckoutOrderScreen extends StatefulWidget {
  const CheckoutOrderScreen({super.key});

  @override
  State<CheckoutOrderScreen> createState() => _CheckoutOrderScreenState();
}

class _CheckoutOrderScreenState extends State<CheckoutOrderScreen> {
  bool _isShowed = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(titleAppBar: 'Checkout Pesanan', isIconShow: false, isLogoutIconShow: false),
      backgroundColor: white,
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 40, horizontal: 24),
          child: Column(
            spacing: 40,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 16,
                children: [
                  Text(
                    'Informasi Pemesan:',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: medium,
                      fontSize: 18,
                    ),
                  ),
                  _buildInput(
                    context,
                    top: 18,
                    defaultVal: 'Nama Anda',
                    icon: Icons.person,
                    size: 28,
                  ),
                  _buildInput(
                    context,
                    top: 21,
                    defaultVal: 'Email Anda ',
                    icon: Icons.email_rounded,
                    size: 24,
                  ),
                  _buildInput(
                    context,
                    top: 22,
                    defaultVal: 'Nomor HP Anda icon:',
                    icon: Icons.phone,
                    size: 26,
                  ),
                  RichText(
                    text: TextSpan(
                      style: TextStyle(fontSize: 16, color: Colors.black),
                      children: [
                        TextSpan(
                          text: '** ',
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: medium,
                            fontSize: 14,
                            color: Colors.red.shade300,
                          ),
                        ),
                        TextSpan(
                          text:
                              'Anda dapat mengubah informasi diatas dengan memperbarui data informasi akun Katering milik Anda',
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: medium,
                            fontSize: 14,
                            color: Colors.blueGrey.shade200,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 16,
                children: [
                  Text(
                    'Metode Pengambilan:',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: medium,
                      fontSize: 18,
                    ),
                  ),
                  _buildInput(
                    context,
                    top: 18,
                    defaultVal: 'Nama Anda',
                    icon: Icons.person,
                    size: 28,
                  ),
                  _buildInput(
                    context,
                    top: 21,
                    defaultVal: 'Email Anda ',
                    icon: Icons.email_rounded,
                    size: 24,
                  ),
                  _buildInput(
                    context,
                    top: 22,
                    defaultVal: 'Nomor HP Anda icon:',
                    icon: Icons.phone,
                    size: 26,
                  ),
                  RichText(
                    text: TextSpan(
                      style: TextStyle(fontSize: 16, color: Colors.black),
                      children: [
                        TextSpan(
                          text: '** ',
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: medium,
                            fontSize: 14,
                            color: Colors.red.shade300,
                          ),
                        ),
                        TextSpan(
                          text:
                              'Anda dapat mengubah informasi diatas dengan memperbarui data informasi akun Katering milik Anda',
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: medium,
                            fontSize: 14,
                            color: Colors.blueGrey.shade200,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 16,
                children: [
                  Text(
                    'Metode Pembayaran:',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: medium,
                      fontSize: 18,
                    ),
                  ),
                  _buildInput(
                    context,
                    top: 18,
                    defaultVal: 'Nama Anda',
                    icon: Icons.person,
                    size: 24,
                  ),
                  _buildInput(
                    context,
                    top: 21,
                    defaultVal: 'Email Anda ',
                    icon: Icons.email_rounded,
                    size: 20,
                  ),
                  _buildInput(
                    context,
                    top: 22,
                    defaultVal: 'Nomor HP Anda icon:',
                    icon: Icons.phone,
                    size: 22,
                  ),
                  RichText(
                    text: TextSpan(
                      style: TextStyle(fontSize: 16, color: Colors.black),
                      children: [
                        TextSpan(
                          text: '** ',
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: medium,
                            fontSize: 14,
                            color: Colors.red.shade300,
                          ),
                        ),
                        TextSpan(
                          text:
                              'Anda dapat mengubah informasi diatas dengan memperbarui data informasi akun Katering milik Anda',
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: medium,
                            fontSize: 14,
                            color: Colors.blueGrey.shade200,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomBar(context),
    );
  }

  Widget _buildInput(
    BuildContext context, {
    required double top,
    required String defaultVal,
    required IconData icon,
    required double size,
  }) {
    return Stack(
      children: [
        Positioned(
          top: top,
          left: 20,
          child: Icon(icon, size: size, color: primaryColor.withAlpha(130)),
        ),
        TextFormField(
          enabled: false,
          initialValue: defaultVal,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.fromLTRB(
              66,
              20,
              24,
              20,
            ),
            hintText: defaultVal,
            hintStyle: GoogleFonts.plusJakartaSans(
              color: primaryColor.withAlpha(130),
              fontWeight: medium,
            ),
            filled: true,
            fillColor: Colors.blueGrey.shade100.withAlpha(60),
            disabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: transparent),
              borderRadius: BorderRadius.circular(14),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: primaryColor.withAlpha(200),
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            errorBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.red),
              borderRadius: BorderRadius.circular(16),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.red, width: 1.5),
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          style: GoogleFonts.plusJakartaSans(
            color: primaryColor.withAlpha(130),
            fontWeight: medium,
            fontSize: 15,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 12, 0, 20),
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(_isShowed ? 44 : 32),
          topRight: Radius.circular(_isShowed ? 44 : 32),
        ),
      ),
      child: Column(
        spacing: _isShowed ? 14 : 2,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 6),
            child: Column(
              spacing: 8,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total :',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        color: white,
                        fontWeight: medium,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          'Rp 165.000',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 18,
                            fontWeight: semibold,
                            color: white,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              _isShowed = !_isShowed;
                            });
                          },
                          icon: Icon(
                            _isShowed
                                ? Icons.arrow_drop_up
                                : Icons.arrow_drop_down,
                            color: !_isShowed ? white : white.withAlpha(100),
                            size: 28,
                          ),
                          padding: EdgeInsets.zero,
                        ),
                      ],
                    ),
                  ],
                ),
                if (_isShowed)
                  Container(
                    padding: EdgeInsets.only(right: 20),
                    child: Column(
                      spacing: 12,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Subtotal :',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 16,
                                color: white.withAlpha(140),
                                fontWeight: medium,
                              ),
                            ),
                            Text(
                              '150.000',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 16,
                                fontWeight: medium,
                                color: white.withAlpha(140),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Biaya Ongkos Kirim :',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 16,
                                color: white.withAlpha(140),
                                fontWeight: medium,
                              ),
                            ),
                            Text(
                              '15.000',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 16,
                                fontWeight: medium,
                                color: white.withAlpha(140),
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
          Container(
            padding: EdgeInsets.only(right: 20),
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                foregroundColor: primaryColor,
                backgroundColor: white,
                elevation: 0,
                shadowColor: transparent,
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                'Checkout',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: semibold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
