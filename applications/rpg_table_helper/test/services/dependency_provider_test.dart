import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rpg_table_helper/services/dependency_provider.dart';
import 'package:rpg_table_helper/services/systemclock_service.dart';

void main() {
  test('Initializes the provider correctly', () {
    // arrange
    final provider = DependencyProvider(
      isMocked: false,
      child: Container(),
    );

    // act
    var systemClock = provider.getService<ISystemClockService>();

    // assert
    expect(provider.isMocked, false);
    expect(systemClock is SystemClockService, true);
    expect(systemClock is MockSystemClockService, false);
  });

  test('Initializes the mocked provider correctly', () {
    // arrange
    final provider = DependencyProvider(
      isMocked: true,
      child: Container(),
    );

    // act
    var systemClock = provider.getService<ISystemClockService>();

    // assert
    expect(provider.isMocked, true);
    expect(systemClock is SystemClockService, false);
    expect(systemClock is MockSystemClockService, true);

    var overrittenDate = systemClock.now();
    expect(overrittenDate != DateTime(2024, 08, 21, 19, 43), true);
  });

  test('Initializes the mocked provider correctly with overrides', () {
    // arrange
    final provider = DependencyProvider(
      isMocked: true,
      mockOverrides: <Type, dynamic Function()>{
        ISystemClockService: () =>
            MockSystemClockService(nowOverride: DateTime(2024, 08, 21, 19, 43))
      },
      child: Container(),
    );

    // act
    var systemClock = provider.getService<ISystemClockService>();

    // assert
    expect(provider.isMocked, true);
    expect(systemClock is SystemClockService, false);
    expect(systemClock is MockSystemClockService, true);

    var overrittenDate = systemClock.now();
    expect(overrittenDate, DateTime(2024, 08, 21, 19, 43));
  });
}
