import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Manages a media-style notification with play/pause/prev/next controls for TTS.
class TtsNotificationService {
  static const _channelId = 'tts_controls';
  static const _notifId = 42;

  static final _plugin = FlutterLocalNotificationsPlugin();
  static void Function()? onPause;
  static void Function()? onResume;
  static void Function()? onStop;
  static void Function()? onNext;
  static void Function()? onPrev;

  static Future<void> init() async {
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
      onDidReceiveNotificationResponse: _onAction,
    );
  }

  static void _onAction(NotificationResponse response) {
    switch (response.actionId) {
      case 'prev': onPrev?.call();
      case 'pause': onPause?.call();
      case 'resume': onResume?.call();
      case 'stop': onStop?.call();
      case 'next': onNext?.call();
    }
  }

  static Future<void> show({
    required String title,
    required String body,
    required bool isPlaying,
  }) async {
    if (!Platform.isAndroid) return;
    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId, 'TTS Controls',
        channelDescription: 'Playback controls for text-to-speech',
        importance: Importance.low,
        priority: Priority.low,
        ongoing: true,
        autoCancel: false,
        playSound: false,
        enableVibration: false,
        actions: [
          const AndroidNotificationAction('prev', '⏮', showsUserInterface: false),
          AndroidNotificationAction(
            isPlaying ? 'pause' : 'resume',
            isPlaying ? '⏸' : '▶',
            showsUserInterface: false,
          ),
          const AndroidNotificationAction('next', '⏭', showsUserInterface: false),
          const AndroidNotificationAction('stop', '⏹', showsUserInterface: false, cancelNotification: true),
        ],
      ),
    );
    await _plugin.show(id: _notifId, title: title, body: body, notificationDetails: details);
  }

  static Future<void> dismiss() async {
    await _plugin.cancel(id: _notifId);
  }
}
