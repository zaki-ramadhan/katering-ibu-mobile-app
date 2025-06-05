import 'dart:async';
import 'package:katering_ibu_m_flutter/services/notification_service.dart';
import 'package:katering_ibu_m_flutter/services/local_notification_service.dart';
import 'package:logger/logger.dart';

class NotificationPollingService {
  static final NotificationPollingService _instance =
      NotificationPollingService._internal();
  factory NotificationPollingService() => _instance;
  NotificationPollingService._internal();

  Timer? _timer;
  final Logger _logger = Logger();
  List<dynamic> _lastNotifications = [];

  StreamController<List<dynamic>>? _notificationController;

  Stream<List<dynamic>> get notificationStream {
    _notificationController ??= StreamController<List<dynamic>>.broadcast();
    return _notificationController!.stream;
  }

  void startPolling({Duration interval = const Duration(seconds: 15)}) {
    _timer?.cancel();

    // Pastikan stream controller tersedia
    if (_notificationController == null || _notificationController!.isClosed) {
      _notificationController = StreamController<List<dynamic>>.broadcast();
    }

    _timer = Timer.periodic(interval, (timer) async {
      try {
        final notifications = await NotificationService().fetchNotifications();

        if (_hasNewNotifications(notifications)) {
          _logger.i('🔔 New notifications detected!');

          // HANYA BROADCAST JIKA STREAM MASIH TERBUKA
          if (_notificationController != null &&
              !_notificationController!.isClosed) {
            _notificationController!.add(notifications);
          }

          // Show notification untuk yang terbaru saja
          if (notifications.isNotEmpty) {
            final latest = notifications.first;
            await LocalNotificationService.showNotification(
              id: latest['id'] ?? DateTime.now().millisecondsSinceEpoch,
              title: latest['title'] ?? 'Notifikasi Baru',
              body: latest['message'] ?? 'Anda memiliki notifikasi baru',
              type: _getNotificationType(latest),
            );
          }

          _lastNotifications = notifications;
        }
      } catch (e) {
        _logger.e('❌ Error polling notifications: $e');
      }
    });

    _logger.i(
      '✅ Notification polling started with ${interval.inSeconds}s interval',
    );
  }

  bool _hasNewNotifications(List<dynamic> newNotifications) {
    if (_lastNotifications.isEmpty) {
      return newNotifications.isNotEmpty;
    }

    if (newNotifications.length != _lastNotifications.length) {
      return true;
    }

    if (newNotifications.isNotEmpty && _lastNotifications.isNotEmpty) {
      final newLatestId = newNotifications.first['id'];
      final oldLatestId = _lastNotifications.first['id'];
      return newLatestId != oldLatestId;
    }

    return false;
  }

  NotificationType _getNotificationType(dynamic notification) {
    final type = notification['type']?.toString() ?? '';
    if (type.contains('payment') || type.contains('bukti')) {
      return NotificationType.payment;
    } else if (type.contains('pesanan')) {
      return NotificationType.order;
    }
    return NotificationType.general;
  }

  void stopPolling() {
    _timer?.cancel();
    _timer = null;
    _logger.i('⏹️ Notification polling stopped');
  }

  void dispose() {
    stopPolling();
    if (_notificationController != null && !_notificationController!.isClosed) {
      _notificationController!.close();
    }
    _notificationController = null;
    _logger.i('🗑️ NotificationPollingService disposed');
  }
}
