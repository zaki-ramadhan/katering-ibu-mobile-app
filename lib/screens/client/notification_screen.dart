import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:katering_ibu_m_flutter/constants/index.dart';
import 'package:katering_ibu_m_flutter/services/notification_service.dart';
import 'package:katering_ibu_m_flutter/widgets/custom_app_bar.dart';
import 'package:katering_ibu_m_flutter/widgets/custom_bottom_bar.dart';
import 'package:logger/logger.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<dynamic> _notifications = [];
  bool _isLoading = true;
  Logger logger = Logger();

  @override
  void initState() {
    super.initState();
    timeago.setLocaleMessages('id', timeago.IdMessages());
    _fetchNotifications();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        titleAppBar: 'Notifikasi',
        isIconShow: true,
        isLogoutIconShow: false,
        isNavigableByBottomBar: true,
      ),
      backgroundColor: white,
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _notifications.isEmpty
              ? Center(
                child: Text(
                  'Tidak ada notifikasi',
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.grey.shade700,
                    fontSize: 16,
                    fontWeight: medium,
                  ),
                ),
              )
              : ListView.builder(
                itemCount: _notifications.length,
                itemBuilder: (context, index) {
                  return _buildNotificationItem(_notifications[index]);
                },
              ),
      bottomNavigationBar: CustomBottomBar(currentPage: 'notification'),
    );
  }

  Widget _buildNotificationItem(dynamic notification) {
    Color bgColor;
    Color titleColor;
    final title = notification['title']?.toString().toLowerCase() ?? '';

    if (title.contains('berhasil') ||
        title.contains('diterima') ||
        title.contains('diverifikasi')) {
      bgColor = Colors.green.shade50.withAlpha(120);
      titleColor = Colors.green.shade700;
    } else if (title.contains('ditolak') ||
        title.contains('dibatalkan') ||
        title.contains('gagal')) {
      bgColor = Colors.red.shade50.withAlpha(120);
      titleColor = Colors.red.shade700;
    } else if (title.contains('dikerjakan') || title.contains('sedang')) {
      bgColor = Colors.orange.shade50.withAlpha(120);
      titleColor = Colors.orange.shade700;
    } else {
      bgColor = Colors.grey.shade100;
      titleColor = primaryColor;
    }

    final createdAt = notification['created_at'];
    String timeAgo = '';
    if (createdAt != null) {
      final dateTime = DateTime.tryParse(createdAt);
      if (dateTime != null) {
        timeAgo = timeago.format(dateTime, locale: 'id');
      }
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(
          bottom: BorderSide(width: 0.4, color: Colors.grey.shade300),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            notification['title'],
            style: GoogleFonts.plusJakartaSans(
              color: titleColor,
              fontWeight: semibold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            notification['message'],
            style: GoogleFonts.plusJakartaSans(
              color: primaryColor,
              fontSize: 14,
              height: 1.8,
            ),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              timeAgo.isNotEmpty ? timeAgo : createdAt ?? '',
              style: GoogleFonts.plusJakartaSans(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
