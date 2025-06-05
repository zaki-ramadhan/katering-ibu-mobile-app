import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class LocalNotificationService {
  static final Logger _logger = Logger();

  static Future<void> initialize() async {
    await AwesomeNotifications().initialize(
      'resource://drawable/ic_notification_logo',
      [
        NotificationChannel(
          channelKey: 'katering_channel',
          channelName: '🍽️ Katering Ibu - Umum',
          channelDescription: 'Notifikasi umum dari Katering Ibu',
          defaultColor: Color(0xFFD4AF37),
          ledColor: Colors.amber,
          importance: NotificationImportance.High,
          channelShowBadge: true,
          playSound: true,
          enableVibration: true,
        ),
        NotificationChannel(
          channelKey: 'order_channel',
          channelName: '📦 Katering Ibu - Pesanan',
          channelDescription: 'Update status pesanan dari Katering Ibu',
          defaultColor: Color(0xFFD4AF37),
          ledColor: Colors.amber,
          importance: NotificationImportance.Max,
          channelShowBadge: true,
          playSound: true,
          enableVibration: true,
        ),
        NotificationChannel(
          channelKey: 'payment_channel',
          channelName: '💳 Katering Ibu - Pembayaran',
          channelDescription: 'Update status pembayaran dari Katering Ibu',
          defaultColor: Color(0xFFD4AF37),
          ledColor: Colors.amber,
          importance: NotificationImportance.High,
          channelShowBadge: true,
          playSound: true,
          enableVibration: true,
        ),
      ],
    );

    // Set notification listeners
    AwesomeNotifications().setListeners(
      onActionReceivedMethod: _onActionReceivedMethod,
      onNotificationCreatedMethod: _onNotificationCreatedMethod,
      onNotificationDisplayedMethod: _onNotificationDisplayedMethod,
      onDismissActionReceivedMethod: _onDismissActionReceivedMethod,
    );
  }

  static Future<void> _onActionReceivedMethod(
    ReceivedAction receivedAction,
  ) async {
    _logger.i('Notification action received: ${receivedAction.payload}');
    // Handle notification tap actions here
  }

  static Future<void> _onNotificationCreatedMethod(
    ReceivedNotification receivedNotification,
  ) async {
    _logger.i('Notification created: ${receivedNotification.title}');
  }

  static Future<void> _onNotificationDisplayedMethod(
    ReceivedNotification receivedNotification,
  ) async {
    _logger.i('Notification displayed: ${receivedNotification.title}');
  }

  static Future<void> _onDismissActionReceivedMethod(
    ReceivedAction receivedAction,
  ) async {
    _logger.i('Notification dismissed: ${receivedAction.id}');
  }

  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    NotificationType type = NotificationType.general,
  }) async {
    String channelKey = 'katering_channel';
    Color notificationColor = Color(0xFFD4AF37);

    switch (type) {
      case NotificationType.order:
        channelKey = 'order_channel';
        notificationColor = Color(0xFFD4AF37);
        break;
      case NotificationType.payment:
        channelKey = 'payment_channel';
        notificationColor = Color(0xFF4CAF50);
        break;
      default:
        break;
    }

    try {
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: id,
          channelKey: channelKey,
          title: title,
          body: body,
          payload: payload != null ? {'data': payload} : null,

          // icon: 'asset://assets/images/logo.png',

          notificationLayout: NotificationLayout.BigText,
          color: notificationColor,
          backgroundColor: notificationColor,
          category: NotificationCategory.Message,

          wakeUpScreen: true,
          autoDismissible: true,
          showWhen: true,
          roundedLargeIcon: true,

          ticker: 'Katering Ibu - $title',
          summary: 'Katering Ibu',
        ),
        actionButtons: [
          NotificationActionButton(
            key: 'OPEN_APP',
            label: '🍽️ BUKA APLIKASI',
            actionType: ActionType.Default,
            autoDismissible: true,
          ),
          NotificationActionButton(
            key: 'DISMISS',
            label: '❌ TUTUP',
            actionType: ActionType.DismissAction,
            autoDismissible: true,
          ),
        ],
      );

      _logger.i('✅ Notification with logo shown: $title');
    } catch (e) {
      _logger.e('❌ Error showing notification: $e');
    }
  }

  static Future<bool> requestPermissions() async {
    try {
      bool isAllowed = await AwesomeNotifications().isNotificationAllowed();

      if (!isAllowed) {
        isAllowed =
            await AwesomeNotifications().requestPermissionToSendNotifications();
      }

      if (isAllowed) {
        _logger.i('Notification permission granted');
        return true;
      } else {
        _logger.w('Notification permission denied');
        return false;
      }
    } catch (e) {
      _logger.e('Error requesting permissions: $e');
      return false;
    }
  }

  static Future<bool> areNotificationsEnabled() async {
    return await AwesomeNotifications().isNotificationAllowed();
  }

  static Future<void> cancelNotification(int id) async {
    await AwesomeNotifications().cancel(id);
  }

  static Future<void> cancelAllNotifications() async {
    await AwesomeNotifications().cancelAll();
  }
}

enum NotificationType { general, order, payment }
