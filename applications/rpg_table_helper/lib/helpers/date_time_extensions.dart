extension DateTimeFormat on DateTime {
  /// Supports the following, inspired by: https://linux.die.net/man/3/strptime
  /// %Y: The year, including century (for example, 1991).
  /// %m: The month number (1-12).
  /// %d: The day of month (1-31).
  /// %H: The hour (0-23).
  /// %M: The minute (0-59).
  /// %S: The second (0-59).
  String format(String formatString) {
    var hourString = hour.toString();
    var dayString = day.toString();
    var monthString = month.toString();
    var minuteString = minute.toString();
    var secondString = second.toString();
    var yearString = year.toString();

    var map = {
      '%H': hourString.padLeft(3 - hourString.length,
          '0'), // the pad values here are the desired length + 1
      '%d': dayString.padLeft(3 - dayString.length, '0'),
      '%m': monthString.padLeft(3 - monthString.length, '0'),
      '%M': minuteString.padLeft(3 - minuteString.length, '0'),
      '%S': secondString.padLeft(3 - secondString.length, '0'),
      '%Y': yearString.padLeft(5 - yearString.length, '0'),
    };
    return map.entries.fold(
        formatString, (acc, entry) => acc.replaceAll(entry.key, entry.value));
  }
}
