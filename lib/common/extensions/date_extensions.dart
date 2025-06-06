import 'package:picapool/utils/date_time_helper.dart';

extension TimeRemove on DateTime {
  DateTime get removeTime {
    return DateTime(year, month, day);
  }

  String formattedTime({String formatString = "hh:mm a"}) =>
      DateTimeHelper.formatDateTime(this, formatString);
}