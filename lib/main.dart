import 'dart:async';
import 'dart:convert';
import 'package:background_fetch/background_fetch.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutterbackgroundfetch/notification/notification.dart' as custom;
import 'package:flutterbackgroundfetch/notification/notification_channel.dart';
import 'package:flutterbackgroundfetch/notification/notification_manager.dart' ;
import 'package:shared_preferences/shared_preferences.dart';

const EVENTS_KEY = "fetch_events";

/// This "Headless Task" is run when app is terminated.
void backgroundFetchHeadlessTask(String taskId) async {
  print("[BackgroundFetch] Headless event received: $taskId");

  DateTime timestamp = DateTime.now();
  NotificationManager manager = NotificationManager();
  await manager.initNotificationManager();
  NotificationChannel channel = manager.scheduledNotificationChannels.last;
  custom.Notification notification = custom.Notification(channel: channel,
    notificationTitle: "Muborak vaqti",
  notificationID:  0,
  notificationBody: "${timestamp.hour}:${timestamp.minute}");
  manager.scheduleNotification(notification);
  manager.showNotification();

  SharedPreferences prefs = await SharedPreferences.getInstance();

  // Read fetch_events from SharedPreferences
  List<String> events = [];
  String json = prefs.getString(EVENTS_KEY);
  if (json != null) {
    events = jsonDecode(json).cast<String>();
  }
  // Add new event.
  events.insert(0, "$taskId task@$timestamp [Headless]");
  // Persist fetch events in SharedPreferences
  prefs.setString(EVENTS_KEY, jsonEncode(events));

  BackgroundFetch.finish(taskId);

}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(new MyApp());
  BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _enabled = true;
  int _status = 0;
  List<String> _events = [];

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String json = prefs.getString(EVENTS_KEY);
    if (json != null) {
      setState(() {
        _events = jsonDecode(json).cast<String>();
      });
    }

    // Configure BackgroundFetch.
    BackgroundFetch.configure(
            BackgroundFetchConfig(
              minimumFetchInterval: 15,
              forceAlarmManager: true,
              stopOnTerminate: false,
              startOnBoot: true,
              enableHeadless: true,
              requiresBatteryNotLow: false,
              requiresCharging: false,
              requiresStorageNotLow: false,
              requiresDeviceIdle: false,
              requiredNetworkType: NetworkType.NONE,
            ),
            _onBackgroundFetch)
        .then((int status) async{
      print('[BackgroundFetch] configure success: $status');
      DateTime timestamp = new DateTime.now();
      NotificationManager manager = NotificationManager();
      await manager.initNotificationManager();
      NotificationChannel channel = manager.scheduledNotificationChannels.last;
      custom.Notification notification = custom.Notification(channel: channel,
          notificationTitle: "Muborak vaqti",
          notificationID:  0,
          notificationBody: "${timestamp.hour}:${timestamp.minute}");
      manager.scheduleNotification(notification);
      manager.showNotification();
      setState(() {
        _status = status;
      });
    }).catchError((e) {
      print('[BackgroundFetch] configure ERROR: $e');
      setState(() {
        _status = e;
      });
    });
    int status = await BackgroundFetch.status;
    setState(() {
      _status = status;
    });
    if (!mounted) return;
  }

  void _onBackgroundFetch(String taskId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    DateTime timestamp = new DateTime.now();
    // This is the fetch-event callback.
    print("[BackgroundFetch] Event received: $taskId");
    setState(() {
      _events.insert(0, "$taskId jasurbek@${timestamp.toString()}");
    });
    prefs.setString(EVENTS_KEY, jsonEncode(_events));

    NotificationManager manager = NotificationManager();
    await manager.initNotificationManager();
    NotificationChannel channel = manager.scheduledNotificationChannels.last;
    custom.Notification notification = custom.Notification(channel: channel,
        notificationTitle: "Muborak vaqti",
        notificationID:  0,
        notificationBody: "${timestamp.hour}:${timestamp.minute}");
    manager.scheduleNotification(notification);
    manager.showNotification();
    BackgroundFetch.finish(taskId);
  }

  void _onClickEnable(enabled) {
    setState(() {
      _enabled = enabled;
    });
    if (enabled) {
      BackgroundFetch.start().then((int status) {
        print('[BackgroundFetch] start success: $status');
      }).catchError((e) {
        print('[BackgroundFetch] start FAILURE: $e');
      });
    } else {
      BackgroundFetch.stop().then((int status) {
        print('[BackgroundFetch] stop success: $status');
      });
    }
  }

  void _onClickStatus() async {
    int status = await BackgroundFetch.status;
    print('[BackgroundFetch] status: $status');
    setState(() {
      _status = status;
    });
  }

  void _onClickClear() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove(EVENTS_KEY);
    setState(() {
      _events = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    const EMPTY_TEXT = Center(
        child: Text(
            'Waiting for fetch events.  Simulate one.\n [Android] \$ ./scripts/simulate-fetch\n [iOS] XCode->Debug->Simulate Background Fetch'));

    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
            title: const Text('BackgroundFetch Example',
                style: TextStyle(color: Colors.black)),
            backgroundColor: Colors.amberAccent,
            brightness: Brightness.light,
            actions: <Widget>[
              Switch(value: _enabled, onChanged: _onClickEnable),
            ]),
        body: (_events.isEmpty)
            ? EMPTY_TEXT
            : Container(
                child: ListView.builder(
                    itemCount: _events.length,
                    itemBuilder: (BuildContext context, int index) {
                      List<String> event = _events[index].split("@");
                      return InputDecorator(
                          decoration: InputDecoration(
                              contentPadding: EdgeInsets.only(
                                  left: 5.0, top: 5.0, bottom: 5.0),
                              labelStyle:
                                  TextStyle(color: Colors.blue, fontSize: 20.0),
                              labelText: "[${event[0].toString()}]"),
                          child: Text(event[1],
                              style: TextStyle(
                                  color: Colors.black, fontSize: 16.0)));
                    }),
              ),
        bottomNavigationBar: BottomAppBar(
            child: Container(
                padding: EdgeInsets.only(left: 5.0, right: 5.0),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      RaisedButton(
                          onPressed: _onClickStatus,
                          child: Text('Status: $_status')),
                      RaisedButton(
                          onPressed: _onClickClear, child: Text('Clear'))
                    ]))),
      ),
    );
  }
}
