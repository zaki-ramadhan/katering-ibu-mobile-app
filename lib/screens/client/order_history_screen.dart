// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:katering_ibu_m_flutter/constants/index.dart';
import 'package:katering_ibu_m_flutter/screens/client/view_order_detail_screen.dart';
import 'package:katering_ibu_m_flutter/services/order_service.dart';
import 'package:katering_ibu_m_flutter/widgets/custom_app_bar.dart';
import 'package:katering_ibu_m_flutter/widgets/custom_bottom_bar.dart';
import 'package:katering_ibu_m_flutter/widgets/custom_notification.dart';
import 'package:logger/logger.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  int _selectedIndex = 0;

  final _labels = [
    'Semua',
    'Belum Bayar',
    'Menunggu Verifikasi',
    'Diproses',
    'Selesai',
    'Dibatalkan',
  ];

  final Map<String, String?> _labelToStatus = {
    'Semua': null,
    'Belum Bayar': 'Pending',
    'Menunggu Verifikasi': 'Pending',
    'Diproses': 'Processed',
    'Selesai': 'Completed',
    'Dibatalkan': 'Cancelled',
  };

  List<dynamic> _orders = [];
  bool _isLoading = true;
  Logger logger = Logger();
  Map<int, bool> _reviewStatus = {};

  @override
  void initState() {
    super.initState();
    timeago.setLocaleMessages('id', timeago.IdMessages());
    _fetchOrderHistory();
  }

  Future<void> _fetchOrderHistory() async {
    try {
      final orders = await OrderService().fetchOrderHistory();
      setState(() {
        _orders = orders;
        _isLoading = false;
      });

      _checkAllReviewStatus();
    } catch (e) {
      logger.e('Error fetching order history: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _checkAllReviewStatus() async {
    final prefs = await SharedPreferences.getInstance();
    Map<int, bool> reviewStatus = {};

    for (var order in _orders) {
      if (order['status'] == 'Completed') {
        final reviewKey = 'review_order_${order['id']}';
        final savedReview = prefs.getString(reviewKey);
        reviewStatus[order['id']] = savedReview != null;
      }
    }

    if (mounted) {
      setState(() {
        _reviewStatus = reviewStatus;
      });
    }
  }

  Future<void> _deleteOrder(int orderId) async {
    try {
      await OrderService().deleteOrder(orderId);
      CustomNotification.showSuccess(
        context: context,
        title: 'Berhasil!',
        message: 'Pesanan berhasil dihapus',
      );
      _fetchOrderHistory();
    } catch (e) {
      CustomNotification.showError(
        context: context,
        title: 'Gagal!',
        message: 'Gagal menghapus pesanan: $e',
      );
    }
  }

  void _showDeleteConfirmation(dynamic order) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(26),
                  blurRadius: 20,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.delete_forever_rounded,
                    color: Colors.red.shade400,
                    size: 40,
                  ),
                ),
                SizedBox(height: 24),
                Text(
                  'Hapus Pesanan?',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 12),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: primaryColor.withAlpha(26),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Pesanan #${order['id']}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: primaryColor,
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Apakah Anda yakin ingin menghapus pesanan ini dari riwayat?',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.red.shade200, width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.warning_rounded,
                        size: 16,
                        color: Colors.red.shade600,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Tindakan ini tidak dapat dibatalkan',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: Colors.red.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.grey.shade600,
                          side: BorderSide(
                            color: Colors.grey.shade300,
                            width: 1.5,
                          ),
                          padding: EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Batal',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _deleteOrder(order['id']);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade500,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.delete_outline_rounded, size: 18),
                            SizedBox(width: 6),
                            Text(
                              'Hapus',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  bool _canDeleteOrder(String status) {
    return ['Completed', 'Cancelled', 'Pending'].contains(status);
  }

  String _formatTimeAgo(String? dateStr) {
    if (dateStr == null) return '-';
    try {
      final date = DateTime.parse(dateStr);
      return timeago.format(date, locale: 'id');
    } catch (_) {
      return dateStr;
    }
  }

  String formatRupiah(dynamic amount) {
    try {
      final number = amount is num ? amount : num.parse(amount.toString());
      return NumberFormat('#,##0', 'id_ID').format(number);
    } catch (_) {
      return amount.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        titleAppBar: 'Riwayat Pesanan',
        isIconShow: true,
        isLogoutIconShow: false,
      ),
      backgroundColor: white,
      body: Column(
        children: [
          _buildLabelsScrollable(context),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: _buildOrders(context),
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomBar(currentPage: 'order_history'),
    );
  }

  Widget _buildLabel(BuildContext context, String status, int index) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: Chip(
        label: Text(status),
        labelStyle: GoogleFonts.plusJakartaSans(
          color: isSelected ? white : primaryColor,
          fontWeight: medium,
        ),
        backgroundColor: isSelected ? primaryColor : white,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        shape: RoundedRectangleBorder(
          side: BorderSide(
            color: isSelected ? primaryColor : primaryColor.withAlpha(60),
            width: 1.1,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget _buildLabelsScrollable(BuildContext context) {
    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _labels.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.only(
              left: index == 0 ? 20 : 8,
              right: index == _labels.length - 1 ? 20 : 0,
            ),
            child: _buildLabel(context, _labels[index], index),
          );
        },
      ),
    );
  }

  Widget _buildOrders(BuildContext context) {
    if (_isLoading) {
      return Padding(
        padding: EdgeInsets.only(top: 60),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    String? selectedStatus = _labelToStatus[_labels[_selectedIndex]];
    List<dynamic> filteredOrders;

    if (selectedStatus == null) {
      filteredOrders = _orders;
    } else if (_labels[_selectedIndex] == 'Belum Bayar') {
      filteredOrders =
          _orders
              .where(
                (order) =>
                    order['status'] == 'Pending' &&
                    (order['payment_proof'] == null ||
                        order['payment_proof'].isEmpty),
              )
              .toList();
    } else if (_labels[_selectedIndex] == 'Menunggu Verifikasi') {
      filteredOrders =
          _orders
              .where(
                (order) =>
                    order['status'] == 'Pending' &&
                    order['payment_proof'] != null &&
                    order['payment_proof'].isNotEmpty,
              )
              .toList();
    } else {
      filteredOrders =
          _orders.where((order) => order['status'] == selectedStatus).toList();
    }

    if (filteredOrders.isEmpty) {
      return Padding(
        padding: EdgeInsets.only(top: 60),
        child: Center(
          child: Text(
            'Tidak ada riwayat pesanan',
            style: GoogleFonts.plusJakartaSans(
              color: Colors.grey,
              fontSize: 16,
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: filteredOrders.length,
      itemBuilder: (context, index) {
        final order = filteredOrders[index];
        return _buildOrderItem(order);
      },
    );
  }

  Widget _buildOrderItem(dynamic order) {
    Color statusColor;
    IconData statusIcon;
    switch (order['status']) {
      case 'Pending':
        statusColor = Colors.amber;
        statusIcon = Icons.schedule;
        break;
      case 'Processed':
        statusColor = Colors.blue;
        statusIcon = Icons.autorenew;
        break;
      case 'Completed':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'Cancelled':
        statusColor = errorColor;
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = Colors.grey.shade500;
        statusIcon = Icons.help_outline;
        break;
    }

    final canDelete = _canDeleteOrder(order['status']);
    final isCompleted = order['status'] == 'Completed';
    final hasReviewed = _reviewStatus[order['id']] ?? false;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ViewOrderDetailScreen(order: order),
          ),
        ).then((result) {
          if (result == true) {
            _fetchOrderHistory();
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        decoration: BoxDecoration(
          color: white,
          border: Border(
            bottom: BorderSide(color: Colors.grey.shade200, width: 1),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '#${order['id']}',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: bold,
                    fontSize: 14,
                    color: primaryColor.withAlpha(120),
                  ),
                ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(statusIcon, color: white, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            order['status'],
                            style: GoogleFonts.plusJakartaSans(
                              color: white,
                              fontWeight: medium,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),

                    if (isCompleted) ...[
                      SizedBox(width: 8),
                      Container(
                        padding: EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color:
                              hasReviewed
                                  ? Colors.green.shade50
                                  : Colors.orange.shade50,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color:
                                hasReviewed
                                    ? Colors.green.shade200
                                    : Colors.orange.shade200,
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          hasReviewed ? Icons.rate_review : Icons.star_border,
                          color:
                              hasReviewed
                                  ? Colors.green.shade600
                                  : Colors.orange.shade600,
                          size: 16,
                        ),
                      ),
                    ],

                    if (canDelete) ...[
                      SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => _showDeleteConfirmation(order),
                        child: Container(
                          padding: EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.red.shade200,
                              width: 1,
                            ),
                          ),
                          child: Icon(
                            Icons.delete_outline,
                            color: Colors.red.shade600,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Rp ${formatRupiah(order['total_amount'])}',
                  style: GoogleFonts.plusJakartaSans(
                    color: primaryColor,
                    fontWeight: semibold,
                    fontSize: 18,
                  ),
                ),
                Text(
                  _formatTimeAgo(order['created_at']),
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.grey[500],
                    fontSize: 12,
                    fontWeight: medium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Item Pesanan:',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: medium,
                    fontSize: 14,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 32,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: (order['items'] as List).length,
                    itemBuilder: (context, index) {
                      final item = (order['items'] as List)[index];
                      return Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(55),
                        ),
                        child: Text(
                          item['menu']['nama_menu'],
                          style: GoogleFonts.plusJakartaSans(fontSize: 12),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
