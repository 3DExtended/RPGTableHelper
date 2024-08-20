import 'package:timeago/timeago.dart';

class TimeAgoCustomMessagesEn implements LookupMessages {
  @override
  String prefixAgo() => '';
  @override
  String prefixFromNow() => '';
  @override
  String suffixAgo() => '';
  @override
  String suffixFromNow() => '';
  @override
  String lessThanOneMinute(int seconds) => 'just now';
  @override
  String aboutAMinute(int minutes) => '$minutes min';
  @override
  String minutes(int minutes) => '$minutes min';
  @override
  String aboutAnHour(int minutes) => 'about 1 hour';
  @override
  String hours(int hours) => '$hours hours';
  @override
  String aDay(int hours) => '$hours hours';
  @override
  String days(int days) => '$days days';
  @override
  String aboutAMonth(int days) => '$days days';
  @override
  String months(int months) => '$months month';
  @override
  String aboutAYear(int year) => '$year years';
  @override
  String years(int years) => '$years years';
  @override
  String wordSeparator() => ' ';
}

class TimeAgoCustomMessagesDe implements LookupMessages {
  @override
  String prefixAgo() => '';
  @override
  String prefixFromNow() => '';
  @override
  String suffixAgo() => '';
  @override
  String suffixFromNow() => '';
  @override
  String lessThanOneMinute(int seconds) => 'gerade';
  @override
  String aboutAMinute(int minutes) => '$minutes Min';
  @override
  String minutes(int minutes) => '$minutes Min';
  @override
  String aboutAnHour(int minutes) => 'ca. 1 Std';
  @override
  String hours(int hours) => '$hours Std';
  @override
  String aDay(int hours) => '$hours Std';
  @override
  String days(int days) => '$days Tage';
  @override
  String aboutAMonth(int days) => '$days Tage';
  @override
  String months(int months) => '$months Monate';
  @override
  String aboutAYear(int year) => '$year Jahre';
  @override
  String years(int years) => '$years Jahre';
  @override
  String wordSeparator() => ' ';
}
