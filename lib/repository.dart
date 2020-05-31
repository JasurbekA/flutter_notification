import 'package:shared_preferences/shared_preferences.dart';

const PRAY_TIMES_CHANNELS_KEY = "notification_channels";
const PRAY_TIMES_KEY = "pray_time";

class Repository {
  Repository._internal();

  static final Repository _singleton = Repository._internal();

  factory Repository() => _singleton;

  SharedPreferences preferences;

  Future<String> readNotificationChannels() async {
    await _initSharedPreferenceIfNull();
    if (preferences.containsKey(PRAY_TIMES_CHANNELS_KEY))
      return preferences.get(PRAY_TIMES_CHANNELS_KEY);
    else {
      String values = "1,0,1,1,1,1";
      await preferences.setString(PRAY_TIMES_CHANNELS_KEY, values);
      return preferences.get(PRAY_TIMES_CHANNELS_KEY);
    }
  }

  _initSharedPreferenceIfNull() async {
    if (preferences == null)
      preferences = await SharedPreferences.getInstance();
  }

  writePrayTimesNotificationChannelsSelection(
      List<int> notificationChannels) async {
    await _initSharedPreferenceIfNull();
    String channelSettings = notificationChannels.join(",");
    await preferences.setString(PRAY_TIMES_CHANNELS_KEY, channelSettings);
  }

  //Simulating notification
  List<String> readPrayTimes() {
    return ["03:25", "05:26", "12:34", "17:25", "19:40", "21:24"];
  }

  int calculateRemainTimeInSeconds(String nextTime) {
    DateTime _now = DateTime.now();
    int _nowInSeconds = _now.hour * 3600 + _now.minute * 60 + _now.second;
    List<String> untilTime = nextTime.split(":");
    int hour = int.parse(untilTime[0]);
    int minute = int.parse(untilTime[1]);
    return hour * 3600 + minute * 60 - _nowInSeconds;
  }

}
