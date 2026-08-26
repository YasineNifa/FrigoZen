import 'dart:ui';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:frigo_zen/l10n/generated/app_localizations.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// Schedules a local notification reminding the user that their free trial
/// is about to end. Uses the device locale for the notification text.
class NotificationService {
  static const String _channelId = 'trial_reminder';
  static const int _trialReminderId = 1001;

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz_data.initializeTimeZones();
    final tzInfo = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(tzInfo.identifier));

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestSoundPermission: true,
      requestBadgePermission: true,
    );
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await _plugin.initialize(settings: initSettings);
  }

  Future<void> scheduleTrialReminder(DateTime trialEnd, {int daysBefore = 2}) async {
    final scheduled = trialEnd.subtract(Duration(days: daysBefore));
    if (scheduled.isBefore(DateTime.now())) return;

    final l10n = _localized();
    final scheduledTz = tz.TZDateTime.from(scheduled, tz.local);
    await _plugin.zonedSchedule(
      id: _trialReminderId,
      title: l10n.trialReminderTitle,
      body: l10n.trialReminderBody(trialEnd.difference(DateTime.now()).inDays),
      scheduledDate: scheduledTz,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          'Trial Reminder',
          channelDescription: 'Reminds you before your free trial ends',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  Future<void> cancelTrialReminder() async {
    await _plugin.cancel(id: _trialReminderId);
  }

  AppLocalizations _localized() {
    final locale = PlatformDispatcher.instance.locale;
    final supported = {'ar', 'de', 'en', 'es', 'fr'};
    final code = supported.contains(locale.languageCode) ? locale.languageCode : 'en';
    return lookupAppLocalizations(Locale(code));
  }
}
