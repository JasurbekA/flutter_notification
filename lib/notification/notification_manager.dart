import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'notification.dart' as custom;
import 'notification_channel.dart';

class NotificationManager {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  AndroidInitializationSettings initializationSettingsAndroid;
  IOSInitializationSettings initializationSettingsIOS;
  InitializationSettings initializationSettings;

  final List<NotificationChannel> scheduledNotificationChannels = [
    NotificationChannel(
        channelID: "Hijoz azoni",
        channelDescription: "Hijoz azoni yangarashi uchun",
        channelName: "Hijoz azoni channel",
        soundName: "hijoz_azoni",
        hasSound: true),
    NotificationChannel(
        channelID: "Misr azoni",
        channelDescription: "Misr azoni yangarashi uchun",
        channelName: "Misr azoni channel",
        soundName: "misr_azoni",
        hasSound: true),
    NotificationChannel(
        channelID: "Custom",
        channelDescription: "Custom sound yangarashi uchun",
        channelName: "Custom sound channel",
        soundName: "slow_spring_board",
        hasSound: true),
    NotificationChannel(
        channelID: "No Sound",
        channelDescription: "No sound from the channel",
        channelName: "No sound channel",
        soundName: "slow_spring_board",
        hasSound: false),
  ];


  Future initNotificationManager() async{
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    initializationSettingsAndroid =
        AndroidInitializationSettings('ic_launcher');
    initializationSettingsIOS = IOSInitializationSettings();
    initializationSettings = InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> scheduleNotification(custom.Notification notification) async {
    var scheduledNotificationDateTime =
        DateTime.now().add(Duration(seconds: 5));
    var vibrationPattern = Int64List(4);
    vibrationPattern[0] = 0;
    vibrationPattern[1] = 1000;
    vibrationPattern[2] = 5000;
    vibrationPattern[3] = 2000;

    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        notification.channel.channelID,
        notification.channel.channelName,
        notification.channel.channelDescription,
        icon: 'ic_launcher',
        sound:
            RawResourceAndroidNotificationSound(notification.channel.soundName),
        largeIcon: DrawableResourceAndroidBitmap('ic_launcher'),
        vibrationPattern: vibrationPattern,
        autoCancel: false,
        enableLights: true,
        playSound: notification.channel.hasSound,
        color: Colors.green,
        ledColor: const Color.fromARGB(255, 255, 0, 0),
        ledOnMs: 1000,
        ledOffMs: 500);
    var iOSPlatformChannelSpecifics =
        IOSNotificationDetails(sound: 'slow_spring_board.aiff');
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.schedule(
        notification.notificationID,
        notification.notificationTitle,
        notification.notificationBody,
        scheduledNotificationDateTime,
        platformChannelSpecifics);
  }

  notifications() async {
    List<PendingNotificationRequest> request = await flutterLocalNotificationsPlugin.pendingNotificationRequests();


  }

  Future<void> showNotification() async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'your channel id', 'your channel name', 'your channel description',
        importance: Importance.Max, priority: Priority.High, ticker: 'ticker');
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
        0, 'plain title', 'plain body', platformChannelSpecifics,
        payload: 'item x');
  }


}
