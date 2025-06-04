// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:katering_ibu_m_flutter/constants/index.dart';
import 'package:katering_ibu_m_flutter/widgets/custom_app_bar.dart';
import 'package:katering_ibu_m_flutter/widgets/custom_notification.dart';
import 'package:logger/logger.dart';
import 'package:katering_ibu_m_flutter/services/ulasan_service.dart';

class FeedbackOrderScreen extends StatefulWidget {
  final dynamic order;

  const FeedbackOrderScreen({super.key, required this.order});

  @override
  State<FeedbackOrderScreen> createState() => _FeedbackOrderScreenState();
}

class _FeedbackOrderScreenState extends State<FeedbackOrderScreen> {
  Logger logger = Logger();
  final TextEditingController _reviewController = TextEditingController();
  bool _isSubmitting = false;

  Future<void> _submitFeedback() async {
    final feedbackText = _reviewController.text.trim();

    if (feedbackText.isEmpty) {
      CustomNotification.showError(
        context: context,
        title: 'Feedback Diperlukan',
        message: 'Silakan berikan feedback terlebih dahulu',
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final ulasanService = UlasanService();

      final result = await ulasanService.submitUlasan(
        orderId: widget.order['id'],
        feedback: feedbackText,
      );

      if (result['success']) {
        CustomNotification.showSuccess(
          context: context,
          title: 'Terima Kasih! 🙏',
          message: 'Ulasan Anda sangat berharga untuk kami',
        );
        Navigator.pop(context, true);
      } else {
        CustomNotification.showError(
          context: context,
          title: 'Gagal!',
          message: result['message'],
        );
      }
    } catch (e) {
      CustomNotification.showError(
        context: context,
        title: 'Terjadi Kesalahan',
        message: 'Gagal mengirim ulasan: $e',
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final items = order['items'] as List;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: CustomAppBar(
        titleAppBar: 'Beri Feedback',
        isIconShow: true,
        isLogoutIconShow: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order Info Card
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(13),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: primaryColor.withAlpha(26),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.receipt_long_rounded,
                            color: primaryColor,
                            size: 20,
                          ),
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Pesanan #${order['id']}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 18,
                            fontWeight: semibold,
                            color: primaryColor,
                          ),
                        ),
                        Spacer(),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.shade100,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Selesai',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: semibold,
                              color: Colors.green.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Divider(color: Colors.grey.shade200),
                    SizedBox(height: 16),
                    Text(
                      'Menu yang dipesan:',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: medium,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    SizedBox(height: 12),
                    ...items.map(
                      (item) => Padding(
                        padding: EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.grey.shade200,
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child:
                                    item['menu']['foto'] != null
                                        ? Image.network(
                                          item['menu']['foto'],
                                          fit: BoxFit.cover,
                                          errorBuilder: (
                                            context,
                                            error,
                                            stackTrace,
                                          ) {
                                            return Icon(
                                              Icons.restaurant,
                                              color: Colors.grey.shade400,
                                              size: 20,
                                            );
                                          },
                                        )
                                        : Icon(
                                          Icons.restaurant,
                                          color: Colors.grey.shade400,
                                          size: 20,
                                        ),
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['menu']['nama_menu'] ?? 'Menu',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 14,
                                      fontWeight: medium,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  Text(
                                    '${item['quantity']}x',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24),

              // Feedback Section
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(13),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.feedback_rounded,
                            color: Colors.orange.shade600,
                            size: 20,
                          ),
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Bagaimana pengalaman Anda?',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: semibold,
                            color: primaryColor,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: _reviewController,
                      maxLines: 6,
                      maxLength: 500,
                      decoration: InputDecoration(
                        hintText:
                            'Ceritakan pengalaman Anda...\n\n• Bagaimana rasa makanannya?\n• Apakah pelayanannya memuaskan?\n• Ada saran untuk perbaikan?',
                        hintStyle: GoogleFonts.plusJakartaSans(
                          color: Colors.grey.shade500,
                          fontSize: 14,
                          height: 1.4,
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: primaryColor, width: 2),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        contentPadding: EdgeInsets.all(16),
                        counterStyle: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        color: Colors.black87,
                        height: 1.4,
                      ),
                      onChanged: (value) {
                        setState(() {});
                      },
                    ),
                    SizedBox(height: 16),
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.blue.shade600,
                            size: 16,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Feedback Anda sangat membantu kami untuk memberikan pelayanan yang lebih baik',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                color: Colors.blue.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(13),
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed:
                _isSubmitting || _reviewController.text.trim().isEmpty
                    ? null
                    : _submitFeedback,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: white,
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child:
                _isSubmitting
                    ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: white,
                          ),
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Mengirim Feedback...',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: semibold,
                          ),
                        ),
                      ],
                    )
                    : Text(
                      'Kirim Feedback',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: semibold,
                      ),
                    ),
          ),
        ),
      ),
    );
  }
}
