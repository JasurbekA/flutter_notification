
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:workmanager/workmanager.dart';
/*

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Workmanager.initialize(
      callbackDispatcher, // The top level function, aka callbackDispatcher
      isInDebugMode:
      true // If enabled it will post a notification whenever the task is running. Handy for debugging tasks
  );
  print('init work manager');
  await Workmanager.registerOneOffTask(
    "1",
    simpleTaskKey,
    existingWorkPolicy: ExistingWorkPolicy.replace,
//    initialDelay: Duration(seconds: 5),
  );

  runApp(MyApp());
}
*/

const simpleTaskKey = "simpleTask";
const simpleDelayedTask = "simpleDelayedTask";
const simplePeriodicTask = "simplePeriodicTask";
const simplePeriodic1HourTask = "simplePeriodic1HourTask";

void callbackDispatcher() {
  print('callbackDispatcher');
  Workmanager.executeTask((task, inputData) {
    Timer.periodic(Duration(seconds: 15), (Timer t) {
      print('message each 15 second');
    });
    print(
        "Native called background task: pusher"); //simpleTask will be emitted here.
    return Future.value(true);
  });
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

enum _Platform { android, ios }

class PlatformEnabledButton extends RaisedButton {
  final _Platform platform;

  PlatformEnabledButton({
    this.platform,
    @required Widget child,
    @required VoidCallback onPressed,
  })  : assert(child != null, onPressed != null),
        super(
          child: child,
          onPressed: (Platform.isAndroid && platform == _Platform.android ||
              Platform.isIOS && platform == _Platform.ios)
              ? onPressed
              : null);
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text("Flutter WorkManager Example"),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text("Plugin initialization",
                  style: Theme.of(context).textTheme.headline6),
              RaisedButton(
                  child: Text("Start the Flutter background service"),
                  onPressed: () {
                    Workmanager.initialize(
                      callbackDispatcher,
                      isInDebugMode: true,
                    );
                  }),
              SizedBox(height: 16),
              Text("One Off Tasks (Android only)",
                  style: Theme.of(context).textTheme.headline6),
              //This task runs once.
              //Most likely this will trigger immediately
              PlatformEnabledButton(
                  platform: _Platform.android,
                  child: Text("Register OneOff Task"),
                  onPressed: () {
                    Workmanager.registerOneOffTask(
                      "1",
                      simpleTaskKey,
                      inputData: <String, dynamic>{
                        'int': 1,
                        'bool': true,
                        'double': 1.0,
                        'string': 'string',
                        'array': [1, 2, 3],
                      },
                    );
                  }),
              //This task runs once
              //This wait at least 10 seconds before running
              PlatformEnabledButton(
                  platform: _Platform.android,
                  child: Text("Register Delayed OneOff Task"),
                  onPressed: () {
                    Workmanager.registerOneOffTask(
                      "2",
                      simpleDelayedTask,
                      initialDelay: Duration(seconds: 10),
                    );
                  }),
              SizedBox(height: 8),
              Text("Periodic Tasks (Android only)",
                  style: Theme.of(context).textTheme.headline6),
              //This task runs periodically
              //It will wait at least 10 seconds before its first launch
              //Since we have not provided a frequency it will be the default 15 minutes
              PlatformEnabledButton(
                  platform: _Platform.android,
                  child: Text("Register Periodic Task"),
                  onPressed: () {
                    Workmanager.registerPeriodicTask(
                      "3",
                      simplePeriodicTask,
                      initialDelay: Duration(seconds: 10),
                    );
                  }),
              //This task runs periodically
              //It will run about every hour
              PlatformEnabledButton(
                  platform: _Platform.android,
                  child: Text("Register 1 hour Periodic Task"),
                  onPressed: () => Workmanager.registerPeriodicTask(
                      "5", simplePeriodic1HourTask,
                      frequency: Duration(minutes: 15),
                      backoffPolicy: BackoffPolicy.linear,
                      existingWorkPolicy: ExistingWorkPolicy.replace,
                      constraints: Constraints(
                          networkType: NetworkType.not_required,
                          requiresCharging: false,
                          requiresBatteryNotLow: false,
                          requiresDeviceIdle: false,
                          requiresStorageNotLow: false))),
              PlatformEnabledButton(
                platform: _Platform.android,
                child: Text("Cancel All"),
                onPressed: () async {
                  await Workmanager.cancelAll();
                  print('Cancel all tasks completed');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
