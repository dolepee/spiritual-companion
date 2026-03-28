import 'package:hijri/hijri_calendar.dart';

class AppFormatters {
  static const _gregorianMonths = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  static const _weekdayNames = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  static String formatTime(DateTime time) {
    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  static String formatDate(DateTime date) {
    return '${date.day} ${_gregorianMonths[date.month - 1]} ${date.year}';
  }

  static String formatShortDate(DateTime date) {
    return '${_weekdayNames[date.weekday - 1]}, ${_gregorianMonths[date.month - 1].substring(0, 3)} ${date.day}';
  }

  static String formatHijri(HijriCalendar date) {
    return '${date.hDay} ${date.getLongMonthName()} ${date.hYear} AH';
  }

  static String weekdayName(int weekday) {
    return _weekdayNames[weekday - 1];
  }

  static String countdown(Duration duration) {
    final positive = duration.isNegative ? Duration.zero : duration;
    final hours = positive.inHours;
    final minutes = positive.inMinutes.remainder(60);
    final seconds = positive.inSeconds.remainder(60);
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
