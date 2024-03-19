import 'package:moontree/domain/utils/validate/phone.dart';

const thirteenYears = Duration(days: 365 * 13);
bool password(String text, [int minlen = 6]) =>
    Password(text, minimumLength: minlen).valid;
bool phone(String text) => Phone(text).valid;
bool birthday(String text) => Birthday(text, cutOffPeriod: thirteenYears).valid;

class Phone {
  final String text;
  Phone(this.text);
  String? get whichRegion => detectPhoneFormat(text);
  bool get validFormat => isPhoneNumber(text);
  bool get valid => validFormat;
  List<String> get errors => [if (!validFormat) 'invalid phone number'];
}

class Password {
  final String text;
  final int minimumLength;
  final int maximumLength;

  Password(this.text, {this.minimumLength = 0, this.maximumLength = 256});
  bool get validLengthShort => text.length >= minimumLength;
  bool get validLengthLong => text.length <= maximumLength;
  bool get validSpecial => true;
  //bool get validBlacklist =>
  //    !['admin', 'password', 'hypyr'].contains(text.toLowerCase());
  bool get valid => validLengthShort && validLengthLong && validSpecial;
  //&& validBlacklist;
  List<String> get errors => [
        if (!validLengthShort)
          'Must be at least $minimumLength characters long',
        if (!validLengthLong)
          'Must be no longer than $maximumLength characters',
        if (!validSpecial) 'Must have special characters',
        //if (!validBlacklist) 'that password is too easy to guess',
      ];

  ///is not empty is string max leng 256
}

class Birthday {
  final String text;
  final Duration? cutOffPeriod;
  int? month;
  int? day;
  int? year;
  Birthday(this.text, {this.cutOffPeriod}) {
    final items = parts;
    try {
      month = int.tryParse(items[0]);
    } catch (e) {
      month = null;
    }
    try {
      day = int.tryParse(items[1]);
    } catch (e) {
      day = null;
    }
    try {
      year = int.tryParse(items[2]);
    } catch (e) {
      year = null;
    }
  }

  static bool leapYear(int year) {
    if (year % 4 != 0) {
      return false;
    } else if (year % 100 != 0) {
      return true;
    } else if (year % 400 != 0) {
      return false;
    } else {
      return true;
    }
  }

  List<String> get parts => text.split(new RegExp(r'[\/.-]'));

  bool get _isLeapYear => year != null && leapYear(year!);
  int get _maxDay {
    switch (month) {
      case 1:
        return 31;
      case 2:
        if (_isLeapYear) {
          return 29;
        } else {
          return 28;
        }
      case 3:
        return 31;
      case 4:
        return 30;
      case 5:
        return 31;
      case 6:
        return 30;
      case 7:
        return 31;
      case 8:
        return 31;
      case 9:
        return 30;
      case 10:
        return 31;
      case 11:
        return 30;
      case 12:
        return 31;
      default:
        return 28;
    }
  }

  /// Matches common date formats: MM/DD/YYYY, MM-DD-YYYY, or MM.DD.YYYY
  bool get validFormat =>
      RegExp(r'^\d{2}[\/.-]\d{2}[\/.-]\d{4}$').hasMatch(text);
  bool get validMonth => month != null && month! >= 1 && month! <= 12;
  bool get validDay => day != null && day! >= 1 && day! <= _maxDay;
  bool get validYear => year != null && year! >= 1900;
  bool get inPast =>
      validDay &&
      validMonth &&
      validYear &&
      DateTime.now().isAfter(DateTime(year!, month!, day!));
  bool get noOlderThan =>
      inPast &&
      //DateTime.now().difference(birthday) < Duration(days: 365 * 13)
      (cutOffPeriod == null ||
          DateTime(year!, month!, day!)
              .isBefore(DateTime.now().subtract(cutOffPeriod!)));
  bool get valid =>
      validFormat &&
      validMonth &&
      validDay &&
      validYear &&
      inPast &&
      noOlderThan;
  List<String> get errors => [
        if (!validFormat) 'Invalid date format: MM/DD/YYYY',
        if (!validMonth) 'Invalid month: must be 1-12',
        if (!validYear)
          'Invalid year${year == null ? '' : ': you are not ${DateTime.now().year - year!} years old'}',
        if (!validDay) 'Invalid day: must be 1-$_maxDay',
        if (!inPast) 'Invalid date: must be past',
        if (!noOlderThan) 'Sorry, you are not old enough for Hypyr yet',
      ];
}
