

import 'dart:ui';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;


class NotificationServices
{
  final notificationPlugin=FlutterLocalNotificationsPlugin();

  bool _isInitialized=false;

  bool get isInitialized=>_isInitialized;


  //it will only be done for every app start .every when app start. when user set a reminder the not is store in the system and used .
  // first time initialize
  Future<void> initNotification()async
  {
    if(isInitialized) return;

    //Loads all world time zone data into memory (like “Asia/Karachi”, “America/New_York”).
    tz.initializeTimeZones();
    //Gets the phone’s current time zone (e.g., "Asia/Karachi").
    final String currentTimeZone= await FlutterTimezone.getLocalTimezone();
    //get location give object. like how+utc e.t.c Location: Asia/Karachi (UTC+5)
    //make that timezone the "home timezone" your app uses.//whenever do tz.get we get app home. not utc time
    tz.setLocalLocation(tz.getLocation(currentTimeZone));


    //initialize setting
    const initSettingAndroid=AndroidInitializationSettings("@mipmap/ic_launcher");

    const initSettingIOS=DarwinInitializationSettings(
      requestAlertPermission: true,
      requestSoundPermission: true,
      requestBadgePermission: true
    );

    // buttons for the ios. plain only text and text like for reply. in drwawer setting.
    // DarwinNotificationCategory(
    //   'chat',
    //   actions: [
    //     DarwinNotificationAction.plain(
    //       'open',
    //       'Open App',
    //     ),
    //     DarwinNotificationAction.text(
    //       'reply',
    //       'Reply',
    //     ),
    //   ],
    // );

  //   4️⃣ DOES INITIALIZATION MEAN “ALL APP”? 🤔
  // ❌ WRONG THINKING
  //
  // “I initialized categories, so all notifications get buttons”
  //
  // ✅ CORRECT THINKING
  //
  // “I registered button types that I MAY use”

    // DarwinNotificationDetails(
    //   categoryIdentifier: 'chat',
    // );

    //later


    const initSetting=InitializationSettings(
      android: initSettingAndroid,
      iOS: initSettingIOS
    );

    //plugin active
    await notificationPlugin.initialize(initSetting);
    _isInitialized=true;



  }

  //notification detail

  NotificationDetails notificationDetails()
  {

    return const NotificationDetails(
      android: AndroidNotificationDetails(
        //channelId → Internal unique key. it must be unique. if yo made multilpe then andriod will ignore the second an duse the first one
          "daily_channel_id",
         // channelName → Shown to the user in system settings.
          "Daily Notification",
          // channelDescription → Explains purpose (helps user decide whether to enable/disable).
        channelDescription: "Daily Notification Channel",
        importance: Importance.max,
        priority: Priority.max,
        playSound: true,
      ),
      iOS: DarwinNotificationDetails()

    );

  }

  NotificationDetails scheduleNotificationDetails()
  {

    return const NotificationDetails(
        android: AndroidNotificationDetails(
          //channelId → Internal unique key. it must be unique. if yo made multilpe then andriod will ignore the second an duse the first one
          "daily_channel_id8",
          // channelName → Shown to the user in system settings.
          "Daily Schedule Notification",
          // channelDescription → Explains purpose (helps user decide whether to enable/disable).
          channelDescription: "Daily Schedule Notification Channel",
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
        ),
        iOS: DarwinNotificationDetails()

    );

  }

  //show notification

 Future<void> showNotification({int id=0, String? title,String? body})async
 {
   return  await notificationPlugin.show(id, title, body, notificationDetails());

 }


 // schedule notification
  Future<void> showScheduleNotification (
      {
        int id=0,
        String? title,
        String? body,
        int? hour,
        int ?minute
      }
      )async {
    final now=tz.TZDateTime.now(tz.local);

    // final scheduleTime=tz.TZDateTime(
    //   tz.local,
    //   now.year,
    //   now.month,
    //   now.day,
    //   hour!,
    //   minute!
    // );

    final tz.TZDateTime scheduleTime=now.add(Duration(seconds: 10));
    print(scheduleTime);
    return await notificationPlugin.zonedSchedule(
        id,
        title,
        body,
        scheduleTime,
        scheduleNotificationDetails(),
        //if idle then show notification. like also show notification when low power


      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,


    );

  }


 Future<void> requestNotificationPermission()async
 {
    notificationPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();
 }

 // for permission . allow exact alarms
  Future<void> requestExactAlarmPermission() async {
    final androidPlugin =
    notificationPlugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.requestExactAlarmsPermission();
  }







}































///--------with this. it is .show data is show. and when expanded then the this data will be shown

// styleInformation: BigTextStyleInformation(
// "This is a big expandable notification text! "
// "It is intentionally made very long so that it does not fit in one line. "
// "When you swipe down, you should see this full expanded content.",
// contentTitle: "Reminder",
// summaryText: "Expandable details",
// ),



//-----------picker---------------------------
// Future<void> pickDateTimeAndSchedule(BuildContext context) async {
//   // 1. Pick a date
//   final DateTime? pickedDate = await showDatePicker(
//     context: context,
//     initialDate: DateTime.now(),
//     firstDate: DateTime.now(),
//     lastDate: DateTime(2100),
//   );
//
//   if (pickedDate == null) return;
//
//   // 2. Pick a time
//   final TimeOfDay? pickedTime = await showTimePicker(
//     context: context,
//     initialTime: TimeOfDay.now(),
//   );
//
//   if (pickedTime == null) return;
//
//   // 3. Combine date + time into one DateTime
//   final DateTime fullDateTime = DateTime(
//     pickedDate.year,
//     pickedDate.month,
//     pickedDate.day,
//     pickedTime.hour,
//     pickedTime.minute,
//   );
//
//   // 4. Convert to tz.TZDateTime
//   final scheduleTime = tz.TZDateTime.from(fullDateTime, tz.local);
//
//   // 5. Schedule notification
//   await notificationsPlugin.zonedSchedule(
//     1,
//     "Reminder",
//     "This is your scheduled notification!",
//     scheduleTime,
//     const NotificationDetails(
//       android: AndroidNotificationDetails(
//         "reminder_channel",
//         "Reminders",
//         importance: Importance.max,
//         priority: Priority.max,
//         playSound: true,
//       ),
//       iOS: DarwinNotificationDetails(),
//     ),
//     androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
//     uiLocalNotificationDateInterpretation:
//     UILocalNotificationDateInterpretation.absoluteTime,
//     matchDateTimeComponents: null, // null = one-time notification
//   );
// }


//
// final androidImplementation =
// notificationPlugin.resolvePlatformSpecificImplementation<
//     AndroidFlutterLocalNotificationsPlugin>();
//
// final bool? granted =
//     await androidImplementation?.areNotificationsEnabled();
//
// return granted ?? false;



// NotificationDetails notificationDetails() {
//   return NotificationDetails(
//     android: AndroidNotificationDetails(
//       "reminder_channel",
//       "Reminders",
//       channelDescription: "Channel for reminders",
//       importance: Importance.max,
//       priority: Priority.high,
//       playSound: true,
//       enableVibration: true,
//       vibrationPattern: Int64List.fromList([0, 500, 1000, 500]),
//       sound: RawResourceAndroidNotificationSound('custom_sound'),
//       enableLights: true,
//       ledColor: const Color.fromARGB(255, 0, 255, 0),
//       ledOnMs: 1000,
//       ledOffMs: 500,
//       autoCancel: true,
//       ongoing: false,
//       styleInformation: BigTextStyleInformation(
//         "This is a big expandable notification text!",
//         contentTitle: "Reminder",
//         summaryText: "Expandable details",
//       ),
//       visibility: NotificationVisibility.public,
//       color: const Color(0xFF2196F3),
//       colorized: true,
//     ),
//     iOS: DarwinNotificationDetails(
//       presentAlert: true,
//       presentBadge: true,
//       presentSound: true,
//       sound: "custom_ios_sound.wav",
//       interruptionLevel: DarwinNotificationInterruptionLevel.timeSensitive,
//       relevanceScore: 0.9,
//     ),
//   );
// }




// // ------------------------------
// // Normal notification
// // ------------------------------
// NotificationDetails normalDetails() {
//   const androidDetails = AndroidNotificationDetails(
//     "normal_channel",
//     "Normal Notifications",
//     channelDescription: "Default channel for normal notifications",
//     importance: Importance.max,
//     priority: Priority.max,
//   );
//   return const NotificationDetails(android: androidDetails);
// }
//
// // ------------------------------
// // Expandable BigText notification
// // ------------------------------
// NotificationDetails bigTextDetails(String body, String title) {
//   final bigTextStyle = BigTextStyleInformation(
//     body, // 👈 body text here
//     contentTitle: title, // 👈 title here
//     summaryText: "Swipe down to see more", // optional
//   );
//
//   final androidDetails = AndroidNotificationDetails(
//     "bigtext_channel",
//     "BigText Notifications",
//     channelDescription: "Channel for expandable notifications",
//     importance: Importance.max,
//     priority: Priority.max,
//     styleInformation: bigTextStyle,
//   );
//
//   return NotificationDetails(android: androidDetails);
// }
//
// // ------------------------------
// // Show normal notification
// // ------------------------------
// Future<void> showNormalNotification(
//     {int id = 0, String? title, String? body}) async {
//   await notificationPlugin.show(id, title, body, normalDetails());
// }
//
// // ------------------------------
// // Show expandable notification
// // ------------------------------
// Future<void> showBigTextNotification(
//     {int id = 1, required String title, required String body}) async {
//   await notificationPlugin.show(id, null, null, bigTextDetails(body, title));
// }
// }
// 📌 Usage
// dart
// Copy code
// final notificationService = NotificationServices();
//
// await notificationService.initNotification();
//
// // 🔹 Normal
// notificationService.showNormalNotification(
// title: "Normal Reminder",
// body: "This is a simple notification",
// );
//
// // 🔹 Expandable BigText
// notificationService.showBigTextNotification(
// title: "Expandable Reminder",
// body:
// "This is a very long message that you can swipe down to expand and read in full detail...",
// );