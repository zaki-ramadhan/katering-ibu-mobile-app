// ignore_for_file: use_build_context_synchronously, unnecessary_to_list_in_spreads

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:katering_ibu_m_flutter/constants/index.dart';
import 'package:katering_ibu_m_flutter/screens/client/rating_order_screen.dart';
import 'package:katering_ibu_m_flutter/widgets/custom_app_bar.dart';
import 'package:katering_ibu_m_flutter/widgets/custom_notification.dart';
import 'package:logger/logger.dart';

class OrderDetailScreen extends StatefulWidget {
  final dynamic order;

  const OrderDetailScreen({super.key, required this.order});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  Logger logger = Logger();
  File? _selectedPaymentProof;
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;

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
      case 'rejected':
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
      case 'rejected':
        return Icons.cancel;
      default:
        return Icons.help_outline;
    }
  }

  Future<void> _pickPaymentProof() async {
    try {
      showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return SafeArea(
            child: SizedBox(
              child: Wrap(
                children: <Widget>[
                  ListTile(
                    leading: Icon(Icons.photo_camera),
                    title: Text('Ambil dari Kamera'),
                    onTap: () {
                      Navigator.of(context).pop();
                      _getImage(ImageSource.camera);
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.photo_library),
                    title: Text('Pilih dari Galeri'),
                    onTap: () {
                      Navigator.of(context).pop();
                      _getImage(ImageSource.gallery);
                    },
                  ),
                ],
              ),
            ),
          );
        },
      );
    } catch (e) {
      CustomNotification.showError(
        context: context,
        title: 'Error',
        message: 'Gagal mengakses kamera/galeri: $e',
      );
    }
  }

  Future<void> _getImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
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
      CustomNotification.showError(
        context: context,
        title: 'Error',
        message: 'Gagal mengambil gambar: $e',
      );
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
      await Future.delayed(Duration(seconds: 2));

      CustomNotification.showSuccess(
        context: context,
        title: 'Berhasil!',
        message: 'Bukti pembayaran berhasil dikirim',
      );

      Navigator.pop(context, true);
    } catch (e) {
      CustomNotification.showError(
        context: context,
        title: 'Gagal!',
        message: 'Gagal mengirim bukti pembayaran: $e',
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final bool isPaid = order['status_payment_proof'] == 'Accepted';
    final bool hasPendingPayment =
        order['payment_method'] == 'cashless' &&
        order['status_payment_proof'] == 'Pending';

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
            if (hasPendingPayment) _buildPaymentProofSection(order),
            if (isPaid && order['payment_proof'] != null)
              _buildPaymentProofDisplay(order),
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
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RatingOrderScreen(order: order),
                    ),
                  );
                },
                icon: Icon(Icons.star_rate, color: white, size: 18),
                label: Text(
                  'Beri Penilaian',
                  style: GoogleFonts.plusJakartaSans(
                    color: white,
                    fontWeight: semibold,
                    fontSize: 15,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber.shade500,
                  foregroundColor: white,
                  elevation: 20,
                  shadowColor: transparent,
                  padding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
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
              image:
                  item['menu']['foto'] != null &&
                          item['menu']['foto'].isNotEmpty
                      ? DecorationImage(
                        image: NetworkImage(item['menu']['foto']),
                        fit: BoxFit.cover,
                      )
                      : null,
            ),
            child:
                item['menu']['foto'] == null || item['menu']['foto'].isEmpty
                    ? Icon(Icons.restaurant, color: Colors.grey.shade400)
                    : null,
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
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade200),
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
              Icon(Icons.warning_amber, color: Colors.orange, size: 24),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Bukti Pembayaran Diperlukan',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: bold,
                    color: Colors.orange.shade700,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            'Pesanan Anda tidak akan diproses sebelum bukti pembayaran dikirim dan diverifikasi.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(height: 16),
          if (_selectedPaymentProof != null) ...[
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
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
                  child: OutlinedButton(
                    onPressed: _pickPaymentProof,
                    child: Text(
                      'Ganti Foto',
                      style: GoogleFonts.plusJakartaSans(),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isUploading ? null : _uploadPaymentProof,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                    ),
                    child:
                        _isUploading
                            ? SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: white,
                              ),
                            )
                            : Text(
                              'Kirim',
                              style: GoogleFonts.plusJakartaSans(color: white),
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
                  'Upload Bukti Pembayaran',
                  style: GoogleFonts.plusJakartaSans(
                    color: white,
                    fontWeight: semibold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPaymentProofDisplay(dynamic order) {
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
                  'Bukti Pembayaran',
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
            'Bukti pembayaran telah diterima dan diverifikasi.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(height: 16),
          Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                order['payment_proof'],
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey.shade200,
                    child: Center(
                      child: Icon(
                        Icons.image_not_supported,
                        color: Colors.grey.shade400,
                        size: 40,
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
