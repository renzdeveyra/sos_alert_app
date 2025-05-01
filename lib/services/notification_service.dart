import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    // Android initialization settings
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization settings (if needed)
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings();

    // Initialize settings for all platforms
    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    // Initialize the plugin
    await _notifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  // Handle notification taps
  static void _onNotificationTapped(NotificationResponse notificationResponse) {
    // Handle notification tap based on payload if needed
    if (notificationResponse.payload != null) {
      // Process the payload
    }
  }

  static Future<void> showAlertNotification() async {
    // Android notification details
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'sos_alert_channel',
          'SOS Alerts',
          channelDescription: 'Notifications for SOS alerts',
          importance: Importance.high,
          priority: Priority.high,
          ticker: 'SOS Alert',
          icon: '@mipmap/ic_launcher',
        );

    // iOS notification details
    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    // Platform-specific notification details
    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Show the notification
    await _notifications.show(
      0, // Notification ID
      'SOS Alert Active',
      'Your emergency contacts have been notified',
      platformDetails,
      payload: 'sos_alert', // Optional payload for handling taps
    );
  }

  // Cancel a specific notification
  static Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  // Cancel all notifications
  static Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  // Request notification permissions (especially important for iOS)
  static Future<void> requestPermissions() async {
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    // For iOS
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);

    // For Android 13 and above
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
  }
}
