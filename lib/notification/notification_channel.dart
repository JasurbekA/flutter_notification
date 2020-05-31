
import 'package:flutter/material.dart';

class NotificationChannel {
  final String channelID;
  final String channelName;
  final String channelDescription;
  final String soundName;
  final bool hasSound;

  NotificationChannel({@required this.channelID,
    @required this.channelName,
    @required this.channelDescription,
    @required this.soundName,
    @required this.hasSound});
}