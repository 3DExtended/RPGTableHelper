import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
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

  static DependencyProvider getMockedDependecyProvider(
          {required Widget child,
          Map<Type, dynamic Function()>? mockOverrides}) =>
      DependencyProvider(
        isMocked: true,
        mockOverrides: mockOverrides,
        child: child,
      );

  late final GetIt getIt;
  final bool isMocked;
  final Map<Type, dynamic Function()>? mockOverrides;

  T getService<T extends Object>() {
    var result = getIt.get<T>();

    return result;
  }

  DependencyProvider({
    super.key,
    required this.isMocked,
    required super.child,
    this.mockOverrides,
  }) {
    getIt = GetIt.asNewInstance();

    // TODO add all services here
    _registerService<ISystemClockService>(
        () => SystemClockService(), () => MockSystemClockService());
  }

  void _registerService<T extends Object>(T Function() realServiceFactoryFunc,
      T Function() mockServiceFactoryFunc) {
    if (mockOverrides != null && mockOverrides!.keys.any((t) => T == t)) {
      getIt.registerLazySingleton<T>(() => mockOverrides![T]!());
    } else {
      if (isMocked) {
        getIt.registerLazySingleton<T>(mockServiceFactoryFunc);
      } else {
        getIt.registerLazySingleton<T>(realServiceFactoryFunc);
      }
    }
  }

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) {
    return false;
  }
}
