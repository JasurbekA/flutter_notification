import 'package:flutter/foundation.dart';
import '../notification/notification_channel.dart';

class Notification {
  final int notificationID;
  final String notificationTitle;
  final String notificationBody;
  final NotificationChannel channel;

  Notification(
      {@required this.notificationID,
      @required this.notificationTitle,
      @required this.notificationBody,
      @required this.channel});
}
