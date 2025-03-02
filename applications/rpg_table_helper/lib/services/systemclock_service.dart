import 'package:quest_keeper/services/time_ago_custom_messages.dart';
import 'package:timeago/timeago.dart' as timeago;

abstract class ISystemClockService {
  final bool isMock;
  ISystemClockService({required this.isMock}) {
    timeago.setLocaleMessages('en_short', TimeAgoCustomMessagesEn());
    timeago.setLocaleMessages('de_short', TimeAgoCustomMessagesDe());
  }

  DateTime now();
}

class SystemClockService extends ISystemClockService {
  SystemClockService() : super(isMock: false);

  @override
  DateTime now() {
    return DateTime.now();
  }
}

class MockSystemClockService extends ISystemClockService {
  DateTime? nowOverride;
  MockSystemClockService({
    this.nowOverride,
  }) : super(isMock: true);

  @override
  DateTime now() {
    return nowOverride ?? DateTime(2023, 12, 30, 15, 15, 15, 15, 15);
  }
}

// Empty service
/**

abstract class ISystemClockService {
  final bool isMock;
  const ISystemClockService({required this.isMock});

}

class SystemClockService extends ISystemClockService {
  const SystemClockService() : super(isMock: false);

}

class MockSystemClockService extends ISystemClockService {
  final DateTime? nowOverride;
  const MockSystemClockService({
    this.nowOverride,
  }) : super(isMock: true);
}

  */
