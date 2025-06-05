// ignore_for_file: use_build_context_synchronously, unnecessary_to_list_in_spreads

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:katering_ibu_m_flutter/constants/index.dart';
import 'package:katering_ibu_m_flutter/screens/client/review_order_screen.dart';
import 'package:katering_ibu_m_flutter/widgets/custom_app_bar.dart';
import 'package:katering_ibu_m_flutter/widgets/custom_notification.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:katering_ibu_m_flutter/services/order_service.dart';

class ViewOrderDetailScreen extends StatefulWidget {
  final dynamic order;

  const ViewOrderDetailScreen({super.key, required this.order});

  @override
  State<ViewOrderDetailScreen> createState() => _ViewOrderDetailScreenState();
}

class _ViewOrderDetailScreenState extends State<ViewOrderDetailScreen> {
  Logger logger = Logger();
  File? _selectedPaymentProof;
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;
  bool _hasReviewed = false; // Tambahkan state ini

  @override
  void initState() {
    super.initState();
    _checkReviewStatus(); // Tambahkan ini
  }

  // Method untuk cek status review
  Future<void> _checkReviewStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final reviewKey = 'review_order_${widget.order['id']}';
    final savedReview = prefs.getString(reviewKey);

    if (mounted) {
      setState(() {
        _hasReviewed = savedReview != null;
      });
    }
  }

  String formatRupiah(dynamic amount) {
    try {
      if (amount == null) return 'Rp 0';

      num number;
      if (amount is String) {
        number = num.tryParse(amount) ?? 0;
      } else if (amount is num) {
        number = amount;
      } else {
        number = 0;
      }

      return NumberFormat.currency(
        locale: 'id_ID',
        symbol: 'Rp ',
        decimalDigits: 0,
      ).format(number);
    } catch (e) {
      return 'Rp 0';
    }
  }

  String formatDate(String? dateStr) {
    if (dateStr == null) return '-';
    try {
      final date = DateTime.parse(dateStr);

      final dayNames = [
        'Minggu',
        'Senin',
        'Selasa',
        'Rabu',
        'Kamis',
        'Jumat',
        'Sabtu',
      ];

      final monthNames = [
        'Januari',
        'Februari',
        'Maret',
        'April',
        'Mei',
        'Juni',
        'Juli',
        'Agustus',
        'September',
        'Oktober',
        'November',
        'Desember',
      ];

      final dayName = dayNames[date.weekday % 7];
      final day = date.day.toString().padLeft(2, '0');
      final monthName = monthNames[date.month - 1];
      final year = date.year;

      return '$dayName, $day $monthName $year';
    } catch (_) {
      return dateStr;
    }
  }

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'processed':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return errorColor;
      default:
        return Colors.grey;
    }
  }

  IconData getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'Pending':
        return Icons.access_time;
      case 'processed':
        return Icons.autorenew;
      case 'completed':
        return Icons.check_circle;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.help_outline;
    }
  }

  Future<void> _pickPaymentProof() async {
    try {
      _showImageSourceDialog();
    } catch (e) {
      CustomNotification.showError(
        context: context,
        title: 'Error',
        message: 'Gagal mengakses galeri: $e',
      );
    }
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withAlpha(128),
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding: EdgeInsets.symmetric(horizontal: 32),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.receipt_long_rounded,
                    color: white,
                    size: 50,
                  ),
                ),
                SizedBox(height: 28),
                Text(
                  'Upload Bukti Pembayaran',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 12),
                Text(
                  'Pilih foto bukti pembayaran dari galeri\nuntuk memverifikasi pesanan Anda',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    color: Colors.grey.shade600,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 32),
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200, width: 1),
                  ),
                  child: Column(
                    children: [
                      // Info Section
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.blue.shade600,
                              size: 20,
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Tips Upload Bukti Pembayaran:',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue.shade700,
                                    ),
                                  ),
                                  SizedBox(height: 6),
                                  Text(
                                    '• Pastikan foto jelas dan tidak blur\n• Informasi transfer terlihat lengkap\n• Format JPG/PNG dengan ukuran maksimal 5MB',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12,
                                      color: Colors.blue.shade600,
                                      height: 1.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),

                      // Gallery Option
                      _buildImageSourceOption(
                        icon: Icons.photo_library_rounded,
                        title: 'Pilih dari Galeri',
                        subtitle:
                            'Pilih foto bukti pembayaran dari galeri Anda',
                        onTap: () {
                          Navigator.pop(context);
                          _pickImageFromGallery();
                        },
                        color: Colors.green,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey.shade700,
                      side: BorderSide(color: Colors.grey.shade300, width: 1.5),
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.close_rounded, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'Batal',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildImageSourceOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required Color color,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200, width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withAlpha(26),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.grey.shade400,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _selectedPaymentProof = File(image.path);
        });
      }
    } catch (e) {
      if (e.toString().contains('Permission denied')) {
        CustomNotification.showError(
          context: context,
          title: 'Izin Ditolak',
          message:
              'Aplikasi memerlukan izin untuk mengakses galeri. Silakan aktifkan di pengaturan.',
        );
      } else {
        CustomNotification.showError(
          context: context,
          title: 'Error',
          message: 'Gagal mengakses galeri: $e',
        );
      }
    }
  }

  Future<void> _uploadPaymentProof() async {
    if (_selectedPaymentProof == null) {
      CustomNotification.showError(
        context: context,
        title: 'Error',
        message: 'Pilih bukti pembayaran terlebih dahulu',
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      final orderService = OrderService();
      final result = await orderService.uploadPaymentProof(
        orderId: widget.order['id'],
        paymentProofFile: _selectedPaymentProof!,
      );

      logger.d('Upload result: $result');

      if (result['success']) {
        // Update order data dengan response dari server
        if (result['data'] != null) {
          setState(() {
            widget.order['payment_proof'] = result['data']['payment_proof_url'];
            widget.order['status_payment_proof'] =
                result['data']['status_payment_proof'];
          });
        }

        CustomNotification.showSuccess(
          context: context,
          title: 'Berhasil!',
          message: result['message'] ?? 'Bukti pembayaran berhasil dikirim',
        );

        // Refresh order data untuk memastikan data terbaru
        await _refreshOrderData();
      } else {
        CustomNotification.showError(
          context: context,
          title: 'Gagal!',
          message: result['message'] ?? 'Gagal mengirim bukti pembayaran',
        );
      }
    } catch (e) {
      logger.e('Upload payment proof error: $e');
      CustomNotification.showError(
        context: context,
        title: 'Error!',
        message: 'Terjadi kesalahan: $e',
      );
    } finally {
      setState(() {
        _isUploading = false;
        _selectedPaymentProof = null;
      });
    }
  }

  // Method untuk refresh data order
  Future<void> _refreshOrderData() async {
    try {
      final orderService = OrderService();
      final result = await orderService.refreshOrderDetail(widget.order['id']);

      if (result['success'] && result['data'] != null) {
        setState(() {
          final newData = result['data'];
          widget.order['payment_proof'] = newData['payment_proof'];
          widget.order['status_payment_proof'] =
              newData['status_payment_proof'];
        });
        logger.d('Order data refreshed successfully');
        logger.d('New payment_proof: ${widget.order['payment_proof']}');
      } else {
        logger.e('Failed to refresh order data: ${result['message']}');
      }
    } catch (e) {
      logger.e('Refresh order data error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final bool isPaid = order['status_payment_proof'] == 'Accepted';
    final bool isTransfer = order['payment_method'] == 'cashless';

    // Debug log
    logger.d('Order payment_proof: ${order['payment_proof']}');
    logger.d('Order status_payment_proof: ${order['status_payment_proof']}');

    return Scaffold(
      appBar: CustomAppBar(
        titleAppBar: 'Detail Pesanan ',
        isIconShow: true,
        isLogoutIconShow: false,
      ),
      backgroundColor: Colors.grey.shade50,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildStatusCard(order),
            _buildOrderInfoCard(order),
            _buildItemsCard(order),
            _buildDeliveryInfoCard(order),
            _buildPaymentInfoCard(order),

            if (isTransfer && order['status_payment_proof'] != 'Accepted')
              _buildPaymentProofSection(order),

            if (isPaid && isTransfer && order['payment_proof'] != null)
              _buildAcceptedPaymentInfo(order),

            if (isPaid && order['payment_method'] == 'cash')
              _buildCashPaymentInfo(order),

            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(dynamic order) {
    final status = order['status'];
    final statusColor = getStatusColor(status);
    final statusIcon = getStatusIcon(status);
    final isCompleted = status.toLowerCase() == 'completed';

    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: statusColor.withAlpha(26),
                  shape: BoxShape.circle,
                ),
                child: Icon(statusIcon, color: statusColor, size: 24),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Status Pesanan',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      status,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: semibold,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (isCompleted) ...[
            SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ReviewOrderScreen(order: order),
                    ),
                  );

                  // Refresh status review setelah kembali dari halaman Ulasan
                  if (result == true) {
                    _checkReviewStatus();
                  }
                },
                icon: Icon(
                  _hasReviewed ? Icons.rate_review : Icons.star_rate,
                  color: white,
                  size: 18,
                ),
                label: Text(
                  _hasReviewed ? 'Lihat Ulasan' : 'Beri Penilaian',
                  style: GoogleFonts.plusJakartaSans(
                    color: white,
                    fontWeight: semibold,
                    fontSize: 15,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      _hasReviewed
                          ? Colors
                              .green
                              .shade600 // Hijau jika sudah review
                          : Colors.amber.shade500, // Kuning jika belum review
                  foregroundColor: white,
                  elevation: 0,
                  shadowColor: transparent,
                  padding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            // Tambahkan info text jika sudah review
            if (_hasReviewed) ...[
              SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      color: Colors.green.shade600,
                      size: 16,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Anda sudah memberikan ulasan untuk pesanan ini',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: Colors.green.shade700,
                        fontWeight: medium,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildOrderInfoCard(dynamic order) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Informasi Pesanan',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: bold,
              color: primaryColor,
            ),
          ),
          SizedBox(height: 16),
          _buildInfoRow('ID Pesanan', '#${order['id']}'),
          _buildInfoRow('Tanggal Pesanan', formatDate(order['created_at'])),
          _buildInfoRow(
            'Tanggal Pengiriman',
            formatDate(order['delivery_date']),
          ),
          _buildInfoRow(
            'Total Pembayaran',
            formatRupiah(order['total_amount']),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsCard(dynamic order) {
    final items = order['items'] as List;

    num calculateSubtotal() {
      num subtotal = 0;
      for (var item in items) {
        final quantity =
            item['quantity'] is String
                ? num.tryParse(item['quantity'].toString()) ?? 0
                : (item['quantity'] as num? ?? 0);
        final price =
            item['price'] is String
                ? num.tryParse(item['price'].toString()) ?? 0
                : (item['price'] as num? ?? 0);
        subtotal += quantity * price;
      }
      return subtotal;
    }

    final totalAmount =
        order['total_amount'] is String
            ? num.tryParse(order['total_amount'].toString()) ?? 0
            : (order['total_amount'] as num? ?? 0);

    final shippingCost =
        order['shipping_cost'] is String
            ? num.tryParse(order['shipping_cost'].toString()) ?? 0
            : (order['shipping_cost'] as num? ?? 0);

    final subtotal = calculateSubtotal();

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Item Pesanan',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: bold,
              color: primaryColor,
            ),
          ),
          SizedBox(height: 16),
          ...items.map((item) => _buildItemRow(item)).toList(),
          Divider(height: 36),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Subtotal',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              Text(
                formatRupiah(subtotal),
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: semibold,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Ongkos Kirim',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              Text(
                formatRupiah(shippingCost),
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: semibold,
                ),
              ),
            ],
          ),
          Divider(height: 28),
          SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: bold,
                  color: primaryColor,
                ),
              ),
              Text(
                formatRupiah(totalAmount),
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: bold,
                  color: primaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildItemRow(dynamic item) {
    final quantity =
        item['quantity'] is String
            ? num.tryParse(item['quantity'].toString()) ?? 0
            : (item['quantity'] as num? ?? 0);

    final price =
        item['price'] is String
            ? num.tryParse(item['price'].toString()) ?? 0
            : (item['price'] as num? ?? 0);

    final itemTotal = quantity * price;
    final menuFoto = item['menu']['foto'];

    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 55,
            height: 55,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child:
                  menuFoto != null && menuFoto.isNotEmpty
                      ? Image.network(
                        menuFoto,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey.shade200,
                            child: Icon(
                              Icons.restaurant,
                              color: Colors.grey.shade400,
                              size: 24,
                            ),
                          );
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            color: Colors.grey.shade200,
                            child: Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.grey.shade400,
                                ),
                              ),
                            ),
                          );
                        },
                      )
                      : Icon(
                        Icons.restaurant,
                        color: Colors.grey.shade400,
                        size: 24,
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
                    fontSize: 15,
                    fontWeight: semibold,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  '${quantity.toInt()}x ${formatRupiah(price)}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Text(
            formatRupiah(itemTotal),
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: bold,
              color: primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryInfoCard(dynamic order) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Informasi Pengiriman',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: bold,
              color: primaryColor,
            ),
          ),
          SizedBox(height: 16),
          _buildInfoRow(
            'Metode',
            order['pickup_method'] == 'delivery' ? 'Delivery' : 'Pickup',
          ),
          if (order['pickup_method'] == 'delivery' &&
              order['delivery_address'] != null)
            _buildInfoRow('Alamat', order['delivery_address']),
        ],
      ),
    );
  }

  Widget _buildPaymentInfoCard(dynamic order) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Informasi Pembayaran',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: bold,
              color: primaryColor,
            ),
          ),
          SizedBox(height: 16),
          _buildInfoRow(
            'Metode',
            order['payment_method'] == 'cash' ? 'Cash' : 'Transfer',
          ),
          _buildInfoRow(
            'Status Pembayaran',
            order['status_payment_proof'] ?? 'Pending',
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentProofSection(dynamic order) {
    // Cek apakah sudah ada payment_proof yang diupload
    final hasUploadedProof =
        order['payment_proof'] != null &&
        order['payment_proof'].toString().isNotEmpty;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              hasUploadedProof ? Colors.blue.shade200 : Colors.orange.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                hasUploadedProof ? Icons.pending_outlined : Icons.warning_amber,
                color: hasUploadedProof ? Colors.blue : Colors.orange,
                size: 24,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  hasUploadedProof
                      ? 'Bukti Pembayaran Menunggu Verifikasi'
                      : 'Upload Bukti Pembayaran',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: bold,
                    color:
                        hasUploadedProof
                            ? Colors.blue.shade700
                            : Colors.orange.shade700,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            hasUploadedProof
                ? 'Bukti pembayaran Anda sedang dalam proses verifikasi oleh admin.'
                : 'Pesanan Anda tidak akan diproses sebelum bukti pembayaran dikirim dan diverifikasi.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(height: 16),

          // Tampilkan gambar yang sudah diupload jika ada
          if (hasUploadedProof) ...[
            Text(
              'Bukti Pembayaran yang Diupload:',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: semibold,
                color: Colors.grey.shade700,
              ),
            ),
            SizedBox(height: 12),
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade300),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  order['payment_proof'],
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                              strokeWidth: 2,
                              color: primaryColor,
                            ),
                            SizedBox(height: 12),
                            Text(
                              'Memuat gambar...',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: Colors.red.shade400,
                              size: 40,
                            ),
                            SizedBox(height: 12),
                            Text(
                              'Gagal memuat gambar',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                color: Colors.red.shade600,
                                fontWeight: medium,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Gambar mungkin rusak atau tidak tersedia',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                color: Colors.red.shade500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
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
                      'Anda dapat mengupload ulang bukti pembayaran jika diperlukan',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
          ],

          // Section untuk upload (baik upload baru atau upload ulang)
          if (_selectedPaymentProof != null) ...[
            Text(
              hasUploadedProof
                  ? 'Bukti Pembayaran Baru:'
                  : 'Preview Bukti Pembayaran:',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: semibold,
                color: Colors.grey.shade700,
              ),
            ),
            SizedBox(height: 12),
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade300),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(_selectedPaymentProof!, fit: BoxFit.cover),
              ),
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed:
                        () => setState(() => _selectedPaymentProof = null),
                    icon: Icon(Icons.close, size: 18),
                    label: Text(
                      'Batal',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: medium,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red.shade600,
                      side: BorderSide(color: Colors.red.shade300),
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isUploading ? null : _uploadPaymentProof,
                    icon:
                        _isUploading
                            ? SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: white,
                              ),
                            )
                            : Icon(Icons.upload, size: 18),
                    label: Text(
                      _isUploading
                          ? 'Uploading...'
                          : (hasUploadedProof ? 'Upload Ulang' : 'Upload'),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: medium,
                        color: white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: white,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          ] else ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _pickPaymentProof,
                icon: Icon(Icons.camera_alt, color: white),
                label: Text(
                  hasUploadedProof
                      ? 'Upload Bukti Baru'
                      : 'Pilih Bukti Pembayaran',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: semibold,
                    color: white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      hasUploadedProof ? Colors.blue.shade600 : primaryColor,
                  foregroundColor: white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAcceptedPaymentInfo(dynamic order) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 24),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Pembayaran Diterima',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: bold,
                    color: Colors.green.shade700,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            'Bukti pembayaran telah diterima dan diverifikasi. Pesanan Anda sedang diproses.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Bukti Pembayaran yang Diverifikasi:',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: semibold,
              color: Colors.grey.shade700,
            ),
          ),
          SizedBox(height: 12),
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade300),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  order['payment_proof'],
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: primaryColor,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: Colors.red.shade400,
                              size: 40,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Gagal memuat gambar',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                color: Colors.red.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCashPaymentInfo(dynamic order) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 24),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Pembayaran Diterima (Cash)',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: bold,
                    color: Colors.green.shade700,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            'Terima kasih, pembayaran Anda telah diterima. Pesanan Anda sedang diproses.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Text(
            ': ',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 15,
              color: Colors.grey.shade600,
              fontWeight: bold,
            ),
          ),
          Expanded(
            child: Text(
              ' $value',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                fontWeight: semibold,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
