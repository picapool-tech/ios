import 'package:picapool/models/main_heading_options_data.dart';
import 'package:picapool/screens/pooling_history/pooling_history.dart';
import 'package:picapool/screens/profile_page/functions/notification_preferences/notification_preferences.dart';

class SettingsOptionsList {
  static const List<MainHeadingOptionsData> optionsList = [
    MainHeadingOptionsData(
      imagePath: "assets/icons/Bell.png",
      text: "Notification Preferences",
      destinationPage: NotificationPreferences(),
    ),
    MainHeadingOptionsData(
      imagePath: "assets/icons/History.png",
      text: "Pooling History",
      destinationPage: PoolingHistory(),
    ),
    MainHeadingOptionsData(
      imagePath: "assets/icons/Letter Opened.png",
      text: "Feedback Form",
      destinationPage: NotificationPreferences(),
      showModelSheet: true,
      isDisabled: true,
    ),
    MainHeadingOptionsData(
      imagePath: "assets/icons/Frame 157.png",
      text: "Permissions",
      destinationPage: NotificationPreferences(),
      showModelSheet: true,
    ),
    MainHeadingOptionsData(
      imagePath: "assets/icons/Bell.png",
      text: "Notification Preferences",
      destinationPage: NotificationPreferences(),
    ),
    MainHeadingOptionsData(
      imagePath: "assets/icons/Bell.png",
      text: "Notification Preferences",
      destinationPage: NotificationPreferences(),
    ),
    MainHeadingOptionsData(
      imagePath: "assets/icons/Bell.png",
      text: "Notification Preferences",
      destinationPage: NotificationPreferences(),
    ),
  ];
}
