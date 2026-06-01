import 'dart:math';

import "package:flutter_local_notifications/flutter_local_notifications.dart";
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../models/subscription.dart';

class NotificationService {
  static const _enabledKey = 'setting_notification_on';
  static const _channelId = 'offsub_billing_reminders';
  static const _channelName = '구독 결제 알림';
  static const _channelDescription = '구독 결제 예정일을 미리 알려줍니다.';

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;

    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Seoul'));

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const settings = InitializationSettings(android: android, iOS: ios);
    await _plugin.initialize(settings);
    _initialized = true;
  }

  static Future<bool> requestPermission() async {
    await initialize();

    final androidGranted = await _plugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.requestNotificationsPermission() ??
        true;

    final iosGranted = await _plugin
            .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin>()
            ?.requestPermissions(alert: true, badge: true, sound: true) ??
        true;

    return androidGranted && iosGranted;
  }

  static Future<bool> isEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_enabledKey) ?? true;
  }

  static Future<void> setEnabled(
    bool value,
    List<Subscription> subscriptions,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_enabledKey, value);

    if (!value) {
      await cancelAllBillingNotifications();
      return;
    }

    final granted = await requestPermission();
    if (!granted) {
      await prefs.setBool(_enabledKey, false);
      await cancelAllBillingNotifications();
      return;
    }

    await scheduleBillingNotifications(subscriptions);
  }

  static Future<void> rescheduleIfEnabled(
    List<Subscription> subscriptions,
  ) async {
    if (!await isEnabled()) return;
    await scheduleBillingNotifications(subscriptions);
  }

  static Future<void> scheduleBillingNotifications(
    List<Subscription> subscriptions,
  ) async {
    await initialize();
    await cancelAllBillingNotifications();

    for (final subscription in subscriptions) {
      await _scheduleForSubscription(subscription, daysBefore: 1);
      await _scheduleForSubscription(subscription, daysBefore: 0);
    }
  }

  static Future<void> cancelAllBillingNotifications() async {
    await initialize();

    // 이 앱에서 예약하는 알림 ID는 100000~999999 범위로 고정합니다.
    // flutter_local_notifications는 범위 삭제 API가 없어 pending 목록을 기준으로 취소합니다.
    final pending = await _plugin.pendingNotificationRequests();
    for (final item in pending) {
      if (item.id >= 100000 && item.id <= 999999) {
        await _plugin.cancel(item.id);
      }
    }
  }

  static Future<void> _scheduleForSubscription(
    Subscription subscription, {
    required int daysBefore,
  }) async {
    final scheduledAt = _nextBillingNotificationDate(
      subscription.billingDay,
      daysBefore: daysBefore,
    );

    final id = _notificationId(subscription.id, daysBefore);
    final title = daysBefore == 0
        ? '${subscription.name} 결제일이에요'
        : '${subscription.name} 결제가 내일 예정돼 있어요';
    final body = daysBefore == 0
        ? '오늘 ${_formatWon(subscription.monthlyAmount)} 결제가 예정되어 있어요.'
        : '내일 ${_formatWon(subscription.monthlyAmount)} 결제가 예정되어 있어요.';

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      ),
      iOS: DarwinNotificationDetails(),
    );

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      scheduledAt,
      details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dayOfMonthAndTime,
      payload: subscription.id,
    );
  }

  static tz.TZDateTime _nextBillingNotificationDate(
    int billingDay, {
    required int daysBefore,
  }) {
    final now = tz.TZDateTime.now(tz.local);
    final today = tz.TZDateTime(tz.local, now.year, now.month, now.day);

    var billingDate = _safeDate(now.year, now.month, billingDay);
    var notificationDate = billingDate.subtract(Duration(days: daysBefore));

    // 오전 9시에 알려줍니다.
    notificationDate = tz.TZDateTime(
      tz.local,
      notificationDate.year,
      notificationDate.month,
      notificationDate.day,
      9,
    );

    if (!notificationDate.isAfter(now)) {
      final nextMonth = tz.TZDateTime(tz.local, now.year, now.month + 1);
      billingDate = _safeDate(nextMonth.year, nextMonth.month, billingDay);
      notificationDate = billingDate.subtract(Duration(days: daysBefore));
      notificationDate = tz.TZDateTime(
        tz.local,
        notificationDate.year,
        notificationDate.month,
        notificationDate.day,
        9,
      );
    }

    // 결제일이 1일이고 하루 전 알림이면 전월 말일이 됩니다. 반복 알림의 월별 컴포넌트는
    // 이 최초 예약 날짜를 기준으로 돌아가므로 초기 날짜만 안전하게 계산합니다.
    if (notificationDate.isBefore(today.subtract(const Duration(days: 1)))) {
      return tz.TZDateTime(tz.local, now.year, now.month + 1, 1, 9);
    }

    return notificationDate;
  }

  static tz.TZDateTime _safeDate(int year, int month, int day) {
    final lastDay = DateTime(year, month + 1, 0).day;
    return tz.TZDateTime(tz.local, year, month, min(day, lastDay));
  }

  static int _notificationId(String subscriptionId, int daysBefore) {
    final raw = subscriptionId.hashCode.abs() % 400000;
    return 100000 + raw + (daysBefore == 0 ? 400000 : 0);
  }

  static String _formatWon(int amount) {
    final text = amount.toString().replaceAllMapped(
          RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (_) => ',',
        );
    return '$text원';
  }
}
