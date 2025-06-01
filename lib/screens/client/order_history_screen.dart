import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:katering_ibu_m_flutter/constants/index.dart';
import 'package:katering_ibu_m_flutter/screens/client/order_detail_screen.dart';
import 'package:katering_ibu_m_flutter/services/order_service.dart';
import 'package:katering_ibu_m_flutter/widgets/custom_app_bar.dart';
import 'package:katering_ibu_m_flutter/widgets/custom_bottom_bar.dart';
import 'package:logger/logger.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:intl/intl.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  int _selectedIndex = 0;
  final _labels = [
    'Semua',
    'Belum dibayar',
    'Diproses',
    'Dikirim',
    'Selesai',
    'Dibatalkan',
  ];

  final Map<String, String?> _labelToStatus = {
    'Semua': null,
    'Belum dibayar': 'Pending',
    'Diproses': 'Processed',
    'Dikirim': 'Shipped',
    'Selesai': 'Completed',
    'Dibatalkan': 'Rejected',
  };

  List<dynamic> _orders = [];
  bool _isLoading = true;
  Logger logger = Logger();

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
    } catch (e) {
      logger.e('Error fetching order history: $e');
      setState(() {
        _isLoading = false;
      });
    }
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
    List<dynamic> filteredOrders =
        selectedStatus == null
            ? _orders
            : _orders
                .where((order) => order['status'] == selectedStatus)
                .toList();

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
      case 'Processed':
        statusColor = Colors.blue;
        statusIcon = Icons.autorenew;
        break;
      case 'Completed':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'Rejected':
        statusColor = errorColor;
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = Colors.grey.shade500;
        statusIcon = Icons.help_outline;
        break;
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OrderDetailScreen(order: order),
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
                    fontSize: 16,
                    color: primaryColor.withAlpha(120),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(8, 6, 14, 6),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, color: white, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        order['status'],
                        style: GoogleFonts.plusJakartaSans(
                          color: white,
                          fontWeight: medium,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
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
                  _formatTimeAgo(order['delivery_date']),
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
