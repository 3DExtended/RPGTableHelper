import 'dart:convert';
import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rpg_table_helper/constants.dart';
import 'package:rpg_table_helper/helpers/connection_details_provider.dart';
import 'package:rpg_table_helper/models/rpg_character_configuration.dart';
import 'package:rpg_table_helper/services/dependency_provider.dart';
import 'package:rpg_table_helper/services/server_methods_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SaveRpgCharacterConfigurationToStorageObserver extends ProviderObserver {
  SaveRpgCharacterConfigurationToStorageObserver();

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
    if (newValue is AsyncData<RpgCharacterConfiguration>) {
      _handleAsyncData(newValue);

      var connectionDetails =
          container.read(connectionDetailsProvider).valueOrNull;

      var isPlayer = (connectionDetails?.isPlayer ?? false) &&
          (connectionDetails?.isInSession ?? false) &&
          (connectionDetails?.isConnected ?? false);

      if (isPlayer) {
        log("Saving rpg character config");

        if (connectionDetails != null &&
            connectionDetails.isConnected &&
            connectionDetails.isPlayer) {
          // TODO this is ugly and should be rewritten... I am using a static singleton in DependencyProvider since i have no access to the buildcontext to receive our instance of the DependencyProvider
          DependencyProvider.getIt!
              .get<IServerMethodsService>()
              .sendUpdatedRpgCharacterConfig(
                  charConfig: newValue.requireValue,
                  gameCode:
                      connectionDetails.sessionConnectionNumberForPlayers!);
        }
      }
    }
  }

  void _handleAsyncData(AsyncData<RpgCharacterConfiguration> castedData) {
    if (castedData.hasValue == true) {
      Future.delayed(Duration.zero, () async {
        var serializedConfig = jsonEncode(castedData.requireValue);
        var prefs = await SharedPreferences.getInstance();
        await prefs.setString(
            sharedPrefsKeyRpgCharacterConfigJson, serializedConfig);
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
