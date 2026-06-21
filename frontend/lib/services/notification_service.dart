import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    if (kIsWeb) return;
    if (!Platform.isAndroid) return;

    try {
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('launcher_icon');

      const InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
      );

      await _notificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          // Handle notification click if needed
        },
      );
    } catch (e) {
      debugPrint("NotificationService: Failed to initialize with 'launcher_icon': $e");
      try {
        const AndroidInitializationSettings initializationSettingsAndroid =
            AndroidInitializationSettings('ic_launcher');

        const InitializationSettings initializationSettings = InitializationSettings(
          android: initializationSettingsAndroid,
        );

        await _notificationsPlugin.initialize(
          initializationSettings,
          onDidReceiveNotificationResponse: (NotificationResponse response) {
            // Handle notification click if needed
          },
        );
      } catch (ex) {
        debugPrint("NotificationService: Fallback 'ic_launcher' also failed: $ex");
      }
    }
  }

  static Future<void> requestPermissions() async {
    if (kIsWeb) return;
    if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _notificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (androidImplementation != null) {
        await androidImplementation.requestNotificationsPermission();
      }
    }
  }

  // Returns a unique integer ID from a jobId string hash
  static int _getNotificationId(String jobId) {
    return jobId.hashCode & 0x7FFFFFFF; // Ensure positive 32-bit int
  }

  static Future<void> showDownloadProgress(
    String jobId,
    String title,
    int progress, {
    String status = "Downloading...",
  }) async {
    if (kIsWeb) return;
    if (!Platform.isAndroid) return;

    final int id = _getNotificationId(jobId);

    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'download_channel',
      'Downloads',
      channelDescription: 'Real-time progress of media downloads',
      importance: Importance.low,
      priority: Priority.low,
      onlyAlertOnce: true,
      showProgress: true,
      maxProgress: 100,
      progress: progress,
      ongoing: true,
      silent: true,
    );

    final NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await _notificationsPlugin.show(
      id,
      title,
      '$status ($progress%)',
      platformChannelSpecifics,
    );
  }

  static Future<void> showDownloadComplete(String jobId, String title) async {
    if (kIsWeb) return;
    if (!Platform.isAndroid) return;

    final int id = _getNotificationId(jobId);

    // Cancel ongoing progress notification first
    await cancelNotification(jobId);

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'download_complete_channel',
      'Completed Downloads',
      channelDescription: 'Notifications for completed downloads',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    // Show a new complete notification (non-ongoing)
    await _notificationsPlugin.show(
      id + 1, // different ID so it doesn't get dismissed
      title,
      'Download Complete!',
      platformChannelSpecifics,
    );
  }

  static Future<void> showDownloadFailed(String jobId, String title, String reason) async {
    if (kIsWeb) return;
    if (!Platform.isAndroid) return;

    final int id = _getNotificationId(jobId);

    await cancelNotification(jobId);

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'download_failed_channel',
      'Failed Downloads',
      channelDescription: 'Notifications for failed downloads',
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await _notificationsPlugin.show(
      id + 2,
      title,
      'Download Failed: $reason',
      platformChannelSpecifics,
    );
  }

  static Future<void> cancelNotification(String jobId) async {
    if (kIsWeb) return;
    if (!Platform.isAndroid) return;

    final int id = _getNotificationId(jobId);
    await _notificationsPlugin.cancel(id);
  }
}
