import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:katering_ibu_m_flutter/constants/index.dart';
import 'package:katering_ibu_m_flutter/widgets/custom_app_bar.dart';
import 'package:katering_ibu_m_flutter/widgets/custom_notification.dart';
import 'package:logger/logger.dart';

class RatingOrderScreen extends StatefulWidget {
  final dynamic order;

  const RatingOrderScreen({super.key, required this.order});

  @override
  State<RatingOrderScreen> createState() => _RatingOrderScreenState();
}

class _RatingOrderScreenState extends State<RatingOrderScreen> {
  Logger logger = Logger();
  int _rating = 0;
  final TextEditingController _reviewController = TextEditingController();
  bool _isSubmitting = false;

  List<String> getRatingTexts() {
    switch (_rating) {
      case 1:
        return ['Sangat Buruk', '😞'];
      case 2:
        return ['Buruk', '😕'];
      case 3:
        return ['Cukup', '😐'];
      case 4:
        return ['Bagus', '😊'];
      case 5:
        return ['Sangat Bagus', '😍'];
      default:
        return ['Belum dinilai', ''];
    }
  }

  Future<void> _submitRating() async {
    if (_rating == 0) {
      CustomNotification.showError(
        context: context,
        title: 'Rating Diperlukan',
        message: 'Silakan berikan rating terlebih dahulu',
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // TODO: Implement API call to submit rating
      final ratingData = {
        'order_id': widget.order['id'],
        'rating': _rating,
        'review': _reviewController.text.trim(),
      };

      logger.i('Submitting rating: $ratingData');

      // Simulate API call
      await Future.delayed(Duration(seconds: 2));

      CustomNotification.showSuccess(
        context: context,
        title: 'Terima Kasih!',
        message: 'Penilaian Anda berhasil dikirim',
      );

      Navigator.pop(context, true);
    } catch (e) {
      CustomNotification.showError(
        context: context,
        title: 'Gagal!',
        message: 'Gagal mengirim penilaian: $e',
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
    final ratingInfo = getRatingTexts();

    return Scaffold(
      backgroundColor: white,
      appBar: CustomAppBar(
        titleAppBar: 'Beri Penilaian Pesanan',
        isIconShow: true,
        isLogoutIconShow: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              color: Colors.blueGrey.shade50.withAlpha(120),
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Column(
                children: [
                  Text(
                    "#${order['id']}",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: semibold,
                      color: primaryColor,
                    ),
                  ),
                  SizedBox(height: 20),
                  _buildOrderItems(items),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Selesai',
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.green.shade500,
                          fontWeight: semibold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.check_circle, color: Colors.green.shade400),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(32),
              child: Column(
                children: [
                  Text(
                    'Seberapa puas kamu dengan pesanan ini?',
                    style: GoogleFonts.plusJakartaSans(
                      color: primaryColor,
                      fontSize: 18,
                      fontWeight: medium,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 24),
                  _buildStarRating(),
                  SizedBox(height: 16),
                  if (_rating > 0) ...[
                    Text(
                      '${ratingInfo[1]} ${ratingInfo[0]}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: semibold,
                        color: _getRatingColor(),
                      ),
                    ),
                    SizedBox(height: 24),
                  ],
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      controller: _reviewController,
                      maxLines: 6,
                      maxLength: 500,
                      decoration: InputDecoration(
                        hintText:
                            'Ceritakan pengalaman Anda dengan pesanan ini... (opsional)',
                        hintStyle: GoogleFonts.plusJakartaSans(
                          color: Colors.blueGrey.shade400,
                          fontSize: 14,
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 20,
                          horizontal: 20,
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.blueGrey.shade200,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(width: 2, color: primaryColor),
                        ),
                        counterStyle: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        color: Colors.black87,
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
        child: Padding(
          padding: EdgeInsets.fromLTRB(24, 20, 24, 32),
          child: ElevatedButton(
            onPressed: _isSubmitting ? null : _submitRating,
            style: ElevatedButton.styleFrom(
              elevation: 0,
              padding: EdgeInsets.symmetric(vertical: 16),
              shadowColor: transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              backgroundColor:
                  _rating > 0 ? primaryColor : Colors.grey.shade300,
              foregroundColor: white,
            ),
            child:
                _isSubmitting
                    ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: white,
                      ),
                    )
                    : Text(
                      'Kirim Penilaian',
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

  Widget _buildOrderItems(List items) {
    if (items.length == 1) {
      return CircleAvatar(
        radius: 50,
        backgroundColor: Colors.grey.shade200,
        backgroundImage:
            items[0]['menu']['foto'] != null
                ? NetworkImage(items[0]['menu']['foto'])
                : null,
        child:
            items[0]['menu']['foto'] == null
                ? Icon(Icons.restaurant, size: 40, color: Colors.grey.shade400)
                : null,
      );
    } else if (items.length == 2) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.grey.shade200,
            backgroundImage:
                items[0]['menu']['foto'] != null
                    ? NetworkImage(items[0]['menu']['foto'])
                    : null,
            child:
                items[0]['menu']['foto'] == null
                    ? Icon(
                      Icons.restaurant,
                      size: 30,
                      color: Colors.grey.shade400,
                    )
                    : Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: white, width: 3),
                      ),
                    ),
          ),
          SizedBox(width: 20),
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.grey.shade200,
            backgroundImage:
                items[1]['menu']['foto'] != null
                    ? NetworkImage(items[1]['menu']['foto'])
                    : null,
            child:
                items[1]['menu']['foto'] == null
                    ? Icon(
                      Icons.restaurant,
                      size: 30,
                      color: Colors.grey.shade400,
                    )
                    : Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: white, width: 3),
                      ),
                    ),
          ),
        ],
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Transform.translate(
            offset: Offset(30, 0),
            child: CircleAvatar(
              radius: 35,
              backgroundColor: Colors.grey.shade200,
              backgroundImage:
                  items[0]['menu']['foto'] != null
                      ? NetworkImage(items[0]['menu']['foto'])
                      : null,
              child:
                  items[0]['menu']['foto'] == null
                      ? Icon(
                        Icons.restaurant,
                        size: 25,
                        color: Colors.grey.shade400,
                      )
                      : Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: white, width: 3),
                        ),
                      ),
            ),
          ),
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.grey.shade200,
            backgroundImage:
                items[1]['menu']['foto'] != null
                    ? NetworkImage(items[1]['menu']['foto'])
                    : null,
            child:
                items[1]['menu']['foto'] == null
                    ? Icon(
                      Icons.restaurant,
                      size: 30,
                      color: Colors.grey.shade400,
                    )
                    : Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: white, width: 3),
                      ),
                    ),
          ),
          Transform.translate(
            offset: Offset(-30, 0),
            child: CircleAvatar(
              radius: 35,
              backgroundColor: Colors.grey.shade200,
              backgroundImage:
                  items.length > 2 && items[2]['menu']['foto'] != null
                      ? NetworkImage(items[2]['menu']['foto'])
                      : null,
              child:
                  items.length > 2 && items[2]['menu']['foto'] == null
                      ? Icon(
                        Icons.restaurant,
                        size: 25,
                        color: Colors.grey.shade400,
                      )
                      : items.length > 3
                      ? Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black.withAlpha(128),
                          border: Border.all(color: white, width: 3),
                        ),
                        child: Center(
                          child: Text(
                            '+${items.length - 2}',
                            style: GoogleFonts.plusJakartaSans(
                              color: white,
                              fontWeight: bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      )
                      : Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: white, width: 3),
                        ),
                      ),
            ),
          ),
        ],
      );
    }
  }

  Widget _buildStarRating() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return GestureDetector(
          onTap: () {
            setState(() {
              _rating = index + 1;
            });
          },
          child: Container(
            padding: EdgeInsets.all(4),
            child: Icon(
              Icons.star_rounded,
              color:
                  index < _rating
                      ? Colors.amber.shade400
                      : Colors.blueGrey.shade200,
              size: 40,
            ),
          ),
        );
      }),
    );
  }

  Color _getRatingColor() {
    switch (_rating) {
      case 1:
      case 2:
        return errorColor.shade500;
      case 3:
        return Colors.orange.shade500;
      case 4:
      case 5:
        return Colors.green.shade500;
      default:
        return Colors.grey.shade500;
    }
  }
}
