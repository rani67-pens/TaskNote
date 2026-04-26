import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await _plugin.initialize(initializationSettings);
  }

  // ✅ SMART MULTI-LAYER REMINDERS
  static Future<void> scheduleSmartReminders({
    required int id,
    required String title,
    required String taskDescription,
    required DateTime deadline,
    required String priority, // 'critical', 'high', 'medium', 'low'
  }) async {
    // Hitung waktu-waktu pengingat
    final now = DateTime.now();
    final oneDayBefore = deadline.subtract(const Duration(days: 1));
    final threeHoursBefore = deadline.subtract(const Duration(hours: 3));
    final oneHourBefore = deadline.subtract(const Duration(hours: 1));
    final fifteenMinBefore = deadline.subtract(const Duration(minutes: 15));

    // Fungsi bantu buat jadwal notif
    Future<void> scheduleOne({
      required int notifId,
      required String notifTitle,
      required String notifBody,
      required DateTime scheduleTime,
    }) async {
      if (scheduleTime.isBefore(now)) return; // Jangan jadwal yang udah lewat

      await _plugin.zonedSchedule(
        notifId,
        notifTitle,
        notifBody,
        tz.TZDateTime.from(scheduleTime, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'task_channel',
            'TaskNote Reminders',
            channelDescription: 'Pengingat deadline tugas kamu',
            importance: Importance.max,
            priority: Priority.high,
            playSound: true,
          ),
        ),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }

    // 🔴 CRITICAL: Notif lebih sering
    if (priority == 'critical') {
      await scheduleOne(
        notifId: id * 10 + 1,
        notifTitle: '🔴 PENTING: $title',
        notifBody: 'Tugas CRITICAL! Deadline: ${_formatDate(deadline)}. Segerakan!',
        scheduleTime: threeHoursBefore,
      );
      await scheduleOne(
        notifId: id * 10 + 2,
        notifTitle: '⚠️ $title - Hampir Deadline!',
        notifBody: 'Tinggal 1 jam lagi! Fokus kerjain sekarang!',
        scheduleTime: oneHourBefore,
      );
      await scheduleOne(
        notifId: id * 10 + 3,
        notifTitle: '🚨 $title - 15 MENIT LAGI!',
        notifBody: 'BURUAN! Deadline tinggal 15 menit!',
        scheduleTime: fifteenMinBefore,
      );
    }
    // 🟠 HIGH: 3 notifikasi standar
    else if (priority == 'high') {
      await scheduleOne(
        notifId: id * 10 + 1,
        notifTitle: '📋 Ingat: $title',
        notifBody: 'Besok deadline: ${_formatDate(deadline)}. Siapin dari sekarang!',
        scheduleTime: oneDayBefore,
      );
      await scheduleOne(
        notifId: id * 10 + 2,
        notifTitle: '⏰ $title - 3 Jam Lagi',
        notifBody: 'Waktu makin tipis! Yuk diselesaikan.',
        scheduleTime: threeHoursBefore,
      );
      await scheduleOne(
        notifId: id * 10 + 3,
        notifTitle: '🔔 $title - 1 Jam Lagi',
        notifBody: 'Deadline sebentar lagi! Semangat! 💪',
        scheduleTime: oneHourBefore,
      );
    }
    // 🟡 MEDIUM: 2 notifikasi
    else if (priority == 'medium') {
      await scheduleOne(
        notifId: id * 10 + 1,
        notifTitle: '💭 $title',
        notifBody: 'Ingat, deadline tugas ini: ${_formatDate(deadline)}',
        scheduleTime: oneDayBefore,
      );
      await scheduleOne(
        notifId: id * 10 + 2,
        notifTitle: '⏰ $title',
        notifBody: '1 jam lagi deadline. Yuk kerjain!',
        scheduleTime: oneHourBefore,
      );
    }
    // 🟢 LOW: 1 notifikasi aja
    else {
      await scheduleOne(
        notifId: id * 10 + 1,
        notifTitle: '✨ $title',
        notifBody: 'Deadline hari ini: ${_formatDate(deadline)}. Jangan lupa ya!',
        scheduleTime: oneHourBefore,
      );
    }
  }

  // ✅ NOTIFIKASI KALO DEADLINE LEWAT
  static Future<void> scheduleOverdueNotification({
    required int id,
    required String title,
    required DateTime deadline,
  }) async {
    // Jadwalkan 5 menit SETELAH deadline
    final overdueTime = deadline.add(const Duration(minutes: 5));
    final now = DateTime.now();

    if (overdueTime.isBefore(now)) return;

    await _plugin.zonedSchedule(
      id * 10 + 99,
      '⚠️ Tugas Terlewat: $title',
      'Deadline sudah lewat sejak ${_formatTime(deadline)}. Segera kerjain!',
      tz.TZDateTime.from(overdueTime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'task_channel',
          'TaskNote Reminders',
          channelDescription: 'Pengingat deadline tugas kamu',
          importance: Importance.max,
          priority: Priority.high,
          styleInformation: BigTextStyleInformation(''),
        ),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  // ✅ Hapus semua notif untuk task tertentu
  static Future<void> cancelTaskNotifications(int id) async {
    for (int i = 1; i <= 99; i++) {
      await _plugin.cancel(id * 10 + i);
    }
  }

  // Helper format tanggal
  static String _formatDate(DateTime date) {
    return '${date.day} ${_monthName(date.month)} ${date.year}, ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  static String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  static String _monthName(int month) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return months[month];
  }
}