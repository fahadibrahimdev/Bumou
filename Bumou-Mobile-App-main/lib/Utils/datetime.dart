import 'package:app/Data/Local/hive_storage.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

// DateTime extension to return formatted date as Mar 3 2021 , 10:00 AM

extension DateTimeExtension on DateTime? {
  String get formattedDateTime {
    if (this == null) {
      return '';
    }
    return DateFormat('MMM d y, hh:mm a', LocalStorage.getLanguageCode).format(this!);
  }

  String get formattedTime {
    if (this == null) {
      return '';
    }
    return DateFormat('hh:mm a', LocalStorage.getLanguageCode).format(this!);
  }

  String get formattedTimeDateMonth {
    if (this == null) {
      return '';
    }
    return DateFormat('MMM d, hh:mm a', LocalStorage.getLanguageCode).format(this!);
  }

  String get formattedDayOfWeekAndTime {
    if (this == null) {
      return '';
    }
    return DateFormat('EEE, hh:mm a', LocalStorage.getLanguageCode).format(this!);
  }

  String get dateTimeString {
    if (this == null) {
      return '';
    }
    final now = DateTime.now();
    if (now.year == this!.year && now.month == this!.month && now.day == this!.day) {
      return DateFormat('hh:mm a', LocalStorage.getLanguageCode).format(this!);
    } else if (now.year == this!.year) {
      return DateFormat('MMM d, hh:mm a', LocalStorage.getLanguageCode).format(this!);
    } else {
      return DateFormat('MMM d y, hh:mm a', LocalStorage.getLanguageCode).format(this!);
    }
  }

  // extension to return the minutes or hours or days or months or years ago
  String get timeAgo {
    if (this == null) {
      return '';
    }
    final now = DateTime.now();
    final difference = now.difference(this!);
    final days = difference.inDays;
    final hours = difference.inHours;
    final minutes = difference.inMinutes;
    if (days > 0) {
      return dateTimeString;
    } else if (hours > 0) {
      return '$hours ${'hours ago'.tr}';
    } else if (minutes > 0) {
      return '$minutes ${'minutes ago'.tr}';
    } else {
      return 'Just now'.tr;
    }
  }

  // extension to return days hours and minutes left for a date
  // String get timeLeft {
  //   if (this == null) {
  //     return '';
  //   }
  //   final now = DateTime.now();
  //   final difference = this!.difference(now);
  //   final days = difference.inDays;
  //   final hours = difference.inHours - (days * 24);
  //   final minutes = difference.inMinutes - (days * 24 * 60) - (hours * 60);
  //   return '$days days $hours hours $minutes minutes';
  // }

  // extension to return days or hours or minutes left or over. whichever is greater
  // String get timeLeftAgo {
  //   if (this == null) {
  //     return '';
  //   }
  //   final now = DateTime.now();
  //   final difference = this!.difference(now);
  //   final days = difference.inDays;
  //   final hours = difference.inHours - (days * 24);
  //   final minutes = difference.inMinutes - (days * 24 * 60) - (hours * 60);
  //   if (days > 0) {
  //     return '$days days left';
  //   } else if (hours > 0) {
  //     return '$hours hours left';
  //   } else if (minutes > 0) {
  //     return '$minutes minutes left';
  //   } else {
  //     return 'Overdue';
  //   }
  // }
}

// extension on int to return weekday name
extension IntExtension on int {
  String get weekdayName {
    switch (this) {
      case 1:
        return 'M';
      case 2:
        return 'T';
      case 3:
        return 'W';
      case 4:
        return 'T';
      case 5:
        return 'F';
      case 6:
        return 'S';
      case 7:
        return 'S';
      default:
        return '';
    }
  }
}
