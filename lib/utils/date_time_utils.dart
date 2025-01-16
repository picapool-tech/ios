class DateTimeUtils {

  static String formatDateWithZone(DateTime dateTime) {
   return "${dateTime.toIso8601String().split('.').first}.000Z";
  }
}