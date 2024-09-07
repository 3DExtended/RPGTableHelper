import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rpg_table_helper/constants.dart';
import 'package:rpg_table_helper/models/rpg_configuration_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SaveRpgConfigurationToStorageObserver extends ProviderObserver {
  SaveRpgConfigurationToStorageObserver();

  @override
  void didAddProvider(
    ProviderBase<Object?> provider,
    Object? value,
    ProviderContainer container,
  ) {}

  @override
  void didDisposeProvider(
    ProviderBase<Object?> provider,
    ProviderContainer container,
  ) {}

  @override
  void didUpdateProvider(
    ProviderBase<Object?> provider,
    Object? previousValue,
    Object? newValue,
    ProviderContainer container,
  ) {
    if (newValue is AsyncData<RpgConfigurationModel>) {
      _handleAsyncData(newValue);
    }
  }

  void _handleAsyncData(AsyncData<RpgConfigurationModel> castedData) {
    if (castedData.hasValue == true) {
      Future.delayed(Duration.zero, () async {
        var serializedConfig = jsonEncode(castedData.requireValue);
        var prefs = await SharedPreferences.getInstance();
        await prefs.setString(sharedPrefsKeyRpgConfigJson, serializedConfig);
      });
    }
  }

  @override
  void providerDidFail(
    ProviderBase<Object?> provider,
    Object error,
    StackTrace stackTrace,
    ProviderContainer container,
  ) {}
}
