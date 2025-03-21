class DateTimeUtils {
  static String formatDateWithZone(DateTime dateTime) {
    return "${dateTime.toUtc().toIso8601String().split('.').first}.000Z";
  }
}
