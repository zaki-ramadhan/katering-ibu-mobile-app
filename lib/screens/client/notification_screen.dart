// ignore_for_file: unnecessary_string_interpolations

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:katering_ibu_m_flutter/constants/index.dart';
import 'package:katering_ibu_m_flutter/services/notification_service.dart';
import 'package:katering_ibu_m_flutter/widgets/custom_app_bar.dart';
import 'package:katering_ibu_m_flutter/widgets/custom_bottom_bar.dart';
import 'package:logger/logger.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:katering_ibu_m_flutter/widgets/custom_notification.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen>
    with SingleTickerProviderStateMixin {
  List<dynamic> _notifications = [];
  bool _isLoading = true;
  Logger logger = Logger();

  late TabController _tabController;
  int _selectedFilterIndex = 0;

  // Filter labels untuk notifikasi pesanan
  final List<String> _orderFilters = [
    'Semua',
    'Diproses',
    'Selesai',
    'Dibatalkan',
  ];

  // Filter labels untuk notifikasi pembayaran
  final List<String> _paymentFilters = [
    'Semua',
    'Diterima',
    'Ditolak',
    'Pending',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedFilterIndex = 0; // Reset filter saat ganti tab
      });
    });
    timeago.setLocaleMessages('id', timeago.IdMessages());
    _fetchNotifications();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchNotifications() async {
    try {
      final notifications = await NotificationService().fetchNotifications();
      setState(() {
        _notifications = notifications;
        _isLoading = false;
      });
    } catch (e) {
      logger.e('Error fetching notifications: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshNotifications() async {
    setState(() {
      _isLoading = true;
    });
    await _fetchNotifications();
  }

  List<dynamic> _getOrderNotifications() {
    return _notifications.where((notification) {
      final type = notification['type']?.toString() ?? '';
      return type.contains('status_pesanan') ||
          notification['title']?.toString().toLowerCase().contains('pesanan') ==
              true;
    }).toList();
  }

  List<dynamic> _getPaymentNotifications() {
    return _notifications.where((notification) {
      final type = notification['type']?.toString() ?? '';
      return type.contains('status_bukti_pembayaran') ||
          notification['title']?.toString().toLowerCase().contains(
                'pembayaran',
              ) ==
              true;
    }).toList();
  }

  List<dynamic> _getFilteredNotifications(
    List<dynamic> notifications,
    bool isOrderTab,
  ) {
    if (_selectedFilterIndex == 0) return notifications; // Semua

    if (isOrderTab) {
      String filter = _orderFilters[_selectedFilterIndex];
      return notifications.where((notification) {
        final title = notification['title']?.toString().toLowerCase() ?? '';

        switch (filter) {
          case 'Diproses':
            return title.contains('dikerjakan') || title.contains('diproses');
          case 'Selesai':
            return title.contains('berhasil') || title.contains('selesai');
          case 'Dibatalkan':
            return title.contains('dibatalkan') || title.contains('batal');
          default:
            return true;
        }
      }).toList();
    } else {
      String filter = _paymentFilters[_selectedFilterIndex];
      return notifications.where((notification) {
        final message = notification['message']?.toString().toLowerCase() ?? '';

        switch (filter) {
          case 'Diterima':
            return message.contains('diterima');
          case 'Ditolak':
            return message.contains('ditolak');
          case 'Pending':
            return message.contains('pending') ||
                (!message.contains('diterima') && !message.contains('ditolak'));
          default:
            return true;
        }
      }).toList();
    }
  }

  // Tambahkan method untuk menghitung jumlah notifikasi berdasarkan filter
  int _getFilteredCount(
    List<dynamic> notifications,
    bool isOrderTab,
    int filterIndex,
  ) {
    if (filterIndex == 0) return notifications.length; // Semua

    if (isOrderTab) {
      String filter = _orderFilters[filterIndex];
      return notifications.where((notification) {
        final title = notification['title']?.toString().toLowerCase() ?? '';

        switch (filter) {
          case 'Diproses':
            return title.contains('dikerjakan') || title.contains('diproses');
          case 'Selesai':
            return title.contains('berhasil') || title.contains('selesai');
          case 'Dibatalkan':
            return title.contains('dibatalkan') || title.contains('batal');
          default:
            return true;
        }
      }).length;
    } else {
      String filter = _paymentFilters[filterIndex];
      return notifications.where((notification) {
        final message = notification['message']?.toString().toLowerCase() ?? '';

        switch (filter) {
          case 'Diterima':
            return message.contains('diterima');
          case 'Ditolak':
            return message.contains('ditolak');
          case 'Pending':
            return message.contains('pending') ||
                (!message.contains('diterima') && !message.contains('ditolak'));
          default:
            return true;
        }
      }).length;
    }
  }

  @override
  Widget build(BuildContext context) {
    final orderNotifications = _getOrderNotifications();
    final paymentNotifications = _getPaymentNotifications();

    return Scaffold(
      appBar: CustomAppBar(
        titleAppBar: 'Notifikasi',
        isIconShow: false,
        isLogoutIconShow: false,
        isNavigableByBottomBar: true,
      ),
      backgroundColor: white,
      body: Column(
        children: [
          // Tab Bar dengan badge count
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(12),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelColor: white,
              unselectedLabelColor: primaryColor,
              labelStyle: GoogleFonts.plusJakartaSans(
                fontWeight: semibold,
                fontSize: 14,
              ),
              unselectedLabelStyle: GoogleFonts.plusJakartaSans(
                fontWeight: medium,
                fontSize: 14,
              ),
              tabs: [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Pesanan'),
                      if (orderNotifications.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color:
                                _tabController.index == 0
                                    ? white
                                    : primaryColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${orderNotifications.length}',
                            style: GoogleFonts.plusJakartaSans(
                              color:
                                  _tabController.index == 0
                                      ? primaryColor
                                      : white,
                              fontSize: 12,
                              fontWeight: semibold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Pembayaran'),
                      if (paymentNotifications.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color:
                                _tabController.index == 1
                                    ? white
                                    : primaryColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${paymentNotifications.length}',
                            style: GoogleFonts.plusJakartaSans(
                              color:
                                  _tabController.index == 1
                                      ? primaryColor
                                      : white,
                              fontSize: 12,
                              fontWeight: semibold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Filter Labels dengan count
          _buildFilterLabels(),

          // Tab Bar View
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshNotifications,
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildNotificationList(
                    _getFilteredNotifications(orderNotifications, true),
                    true,
                  ),
                  _buildNotificationList(
                    _getFilteredNotifications(paymentNotifications, false),
                    false,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomBar(currentPage: 'notification'),
    );
  }

  Widget _buildFilterLabels() {
    List<String> currentFilters =
        _tabController.index == 0 ? _orderFilters : _paymentFilters;
    List<dynamic> currentNotifications =
        _tabController.index == 0
            ? _getOrderNotifications()
            : _getPaymentNotifications();

    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: currentFilters.length,
        itemBuilder: (context, index) {
          final isSelected = _selectedFilterIndex == index;
          final count = _getFilteredCount(
            currentNotifications,
            _tabController.index == 0,
            index,
          );

          return Padding(
            padding: EdgeInsets.only(
              left: index == 0 ? 20 : 8,
              right: index == currentFilters.length - 1 ? 20 : 0,
            ),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedFilterIndex = index;
                });
              },
              child: Chip(
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(currentFilters[index]),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? white : primaryColor.withAlpha(30),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '$count',
                        style: GoogleFonts.plusJakartaSans(
                          color: isSelected ? primaryColor : primaryColor,
                          fontSize: 11,
                          fontWeight: semibold,
                        ),
                      ),
                    ),
                  ],
                ),
                labelStyle: GoogleFonts.plusJakartaSans(
                  color: isSelected ? white : primaryColor,
                  fontWeight: medium,
                ),
                backgroundColor: isSelected ? primaryColor : white,
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    color:
                        isSelected ? primaryColor : primaryColor.withAlpha(60),
                    width: 1.1,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNotificationList(List<dynamic> notifications, bool isOrderTab) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Header dengan informasi jumlah data
    Widget header = Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${isOrderTab ? 'Notifikasi Pesanan' : 'Notifikasi Pembayaran'}',
            style: GoogleFonts.plusJakartaSans(
              color: primaryColor,
              fontSize: 16,
              fontWeight: semibold,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: primaryColor.withAlpha(20),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${notifications.length} notifikasi',
              style: GoogleFonts.plusJakartaSans(
                color: primaryColor,
                fontSize: 12,
                fontWeight: medium,
              ),
            ),
          ),
        ],
      ),
    );

    if (notifications.isEmpty) {
      return Column(
        children: [
          header,
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_off,
                    size: 80,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Tidak ada notifikasi',
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.grey.shade700,
                      fontSize: 16,
                      fontWeight: medium,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _selectedFilterIndex == 0
                        ? 'Belum ada notifikasi ${isOrderTab ? 'pesanan' : 'pembayaran'}'
                        : 'Tidak ada notifikasi dengan filter "${(isOrderTab ? _orderFilters : _paymentFilters)[_selectedFilterIndex]}"',
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.grey.shade500,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        header,
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              return _buildNotificationItem(notifications[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationItem(dynamic notification) {
    Color bgColor;
    Color titleColor;
    IconData statusIcon;
    final title =
        notification['title']?.toString().toLowerCase() ?? 'Tidak ada judul';
    final message = notification['message'] ?? 'Tidak ada pesan';
    final createdAt = notification['created_at'] ?? '';
    final orderId = notification['order_id']?.toString() ?? 'Tidak tersedia';

    // Pengkondisian berdasarkan title dan message
    if (title.contains('pesanan sedang dikerjakan')) {
      bgColor = Colors.blue.shade50.withAlpha(120);
      titleColor = Colors.blue.shade700;
      statusIcon = Icons.work_outline;
    } else if (title.contains('pesanan berhasil diproses')) {
      bgColor = Colors.green.shade50.withAlpha(120);
      titleColor = Colors.green.shade700;
      statusIcon = Icons.check_circle_outline;
    } else if (title.contains('pesanan dibatalkan')) {
      bgColor = errorColor.shade50.withAlpha(120);
      titleColor = errorColor.shade700;
      statusIcon = Icons.cancel_outlined;
    } else if (title.contains('perubahan status bukti pembayaran')) {
      if (message.contains('diterima')) {
        bgColor = Colors.green.shade50.withAlpha(120);
        titleColor = Colors.green.shade700;
        statusIcon = Icons.payment;
      } else if (message.contains('ditolak')) {
        bgColor = errorColor.shade50.withAlpha(120);
        titleColor = errorColor.shade700;
        statusIcon = Icons.payment_outlined;
      } else {
        bgColor = Colors.orange.shade50.withAlpha(120);
        titleColor = Colors.orange.shade700;
        statusIcon = Icons.payment;
      }
    } else {
      bgColor = Colors.grey.shade100;
      titleColor = primaryColor;
      statusIcon = Icons.info_outline;
    }

    String timeAgo = '';
    if (createdAt.isNotEmpty) {
      final dateTime = DateTime.tryParse(createdAt);
      if (dateTime != null) {
        timeAgo = timeago
            .format(dateTime, locale: 'id', allowFromNow: true)
            .replaceAll('sekitar ', '');
      }
    }

    return GestureDetector(
      onTap: () {
        CustomNotification.showInfo(
          context: context,
          title: 'Notifikasi',
          message: message,
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: titleColor.withAlpha(30), width: 1),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: titleColor.withAlpha(30),
                shape: BoxShape.circle,
              ),
              child: Icon(statusIcon, color: titleColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification['title'] ?? 'Tidak ada judul',
                    style: GoogleFonts.plusJakartaSans(
                      color: titleColor,
                      fontWeight: semibold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message,
                    style: GoogleFonts.plusJakartaSans(
                      color: primaryColor,
                      fontSize: 14,
                      height: 1.8,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: titleColor.withAlpha(20),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'ID Pesanan: $orderId',
                          style: GoogleFonts.plusJakartaSans(
                            color: titleColor,
                            fontSize: 12,
                            fontWeight: medium,
                          ),
                        ),
                      ),
                      Text(
                        timeAgo.isNotEmpty ? timeAgo : createdAt,
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.grey.shade600,
                          fontSize: 12,
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
