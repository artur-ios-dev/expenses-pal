import 'package:flutter/material.dart';

class DateHelper {
  static bool isSameDay(DateTime d1, DateTime d2) {
    return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
  }

  static String formatDate(DateTime compared,
      {bool fullDate = false, bool withTime = false}) {
    DateTime t = DateTime.now();
    DateTime today = DateTime.utc(t.year, t.month, t.day);
    DateTime tm = DateTime.utc(compared.year, compared.month, compared.day);

    String month;

    switch (tm.month) {
      case 1:
        month = "January";
        break;
      case 2:
        month = "February";
        break;
      case 3:
        month = "March";
        break;
      case 4:
        month = "April";
        break;
      case 5:
        month = "May";
        break;
      case 6:
        month = "June";
        break;
      case 7:
        month = "July";
        break;
      case 8:
        month = "August";
        break;
      case 9:
        month = "September";
        break;
      case 10:
        month = "October";
        break;
      case 11:
        month = "November";
        break;
      case 12:
        month = "December";
        break;
    }

    int difference = today.difference(tm).inDays;

    if (fullDate) {
      String formatted = '${tm.day} $month ${tm.year}';
      if (withTime) {
        formatted = formatted +
            ', ${compared.hour}'.padLeft(2, '0') +
            ':' +
            '${compared.minute}'.padLeft(2, '0');
      }
      return formatted;
    } else if (difference < 1) {
      return "Today";
    } else if (difference < 2) {
      return "Yesterday";
    } else if (difference < 7) {
      switch (tm.weekday) {
        case 1:
          return "Monday";
        case 2:
          return "Tuesday";
        case 3:
          return "Wednesday";
        case 4:
          return "Thurdsday";
        case 5:
          return "Friday";
        case 6:
          return "Saturday";
        case 7:
          return "Sunday";
      }
    } else if (tm.year == today.year) {
      return '${tm.day} $month';
    } else {
      return '${tm.day} $month ${tm.year}';
    }

    return tm.toIso8601String();
  }
}

class HexColor extends Color {
  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor;
    }

    return int.parse(hexColor, radix: 16);
  }

  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));
}

double screenAwareSize(double size, BuildContext context) {
  const double baseHeight = 812.0;
  return size * MediaQuery.of(context).size.height / baseHeight;
}

double screenAwareFontSize(double size, BuildContext context) {
  const double baseHeight = 812.0;
  return size * MediaQuery.of(context).size.height / baseHeight;
}
