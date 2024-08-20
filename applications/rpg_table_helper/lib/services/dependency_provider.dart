import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:rpg_table_helper/services/systemclock_service.dart';

class DependencyProvider extends InheritedWidget {
  static DependencyProvider of(BuildContext context) {
    var dependOnInheritedWidgetOfExactType =
        context.dependOnInheritedWidgetOfExactType<DependencyProvider>();

    if (dependOnInheritedWidgetOfExactType == null) {
      throw MissingPluginException(
          'Custom error: Could not find DependencyProvider in dependOnInheritedWidgetOfExactType');
    }

    return dependOnInheritedWidgetOfExactType;
  }

  final bool isMocked;

  final ISystemClockService systemclockService;

  const DependencyProvider({
    super.key,
    required this.isMocked,
    required this.systemclockService,
    required super.child,
  });

  static DependencyProvider getMockedDependecyProvider(Widget child) =>
      DependencyProvider(
        isMocked: true,
        systemclockService: MockSystemClockService(),
        child: child,
      );

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) {
    return false;
  }

  DependencyProvider copyWith({
    ISystemClockService? systemclockService,
  }) {
    return DependencyProvider(
      isMocked: isMocked,
      systemclockService: systemclockService ?? this.systemclockService,
      child: child,
    );
  }
}
