import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quest_keeper/helpers/connection_details_provider.dart';
import 'package:quest_keeper/models/rpg_character_configuration.dart';
import 'package:quest_keeper/services/dependency_provider.dart';
import 'package:quest_keeper/services/server_methods_service.dart';

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

      // Player character edits are persisted via ConfigSync (debounced REST
      // PATCH/PUT with revision + 409 rebase). Do NOT gate on isConnected so
      // edits still flush once HTTP recovers after suspend/flaky Wi‑Fi.
      final willSend = connectionDetails != null &&
          connectionDetails.isPlayer &&
          connectionDetails.isInSession &&
          connectionDetails.playerCharacterId != null;

      if (willSend) {
        log("Saving rpg character config");
        // TODO this is ugly and should be rewritten... I am using a static singleton in DependencyProvider since i have no access to the buildcontext to receive our instance of the DependencyProvider
        DependencyProvider.getIt!
            .get<IServerMethodsService>()
            .sendUpdatedRpgCharacterConfig(
                charConfig: newValue.requireValue,
                playercharacterid: connectionDetails.playerCharacterId!);
      }
    }
  }

  void _handleAsyncData(AsyncData<RpgCharacterConfiguration> castedData) {
    if (castedData.hasValue == true) {
      Future.delayed(Duration.zero, () async {
        // var serializedConfig = jsonEncode(castedData.requireValue);
        // var prefs = await SharedPreferences.getInstance();
        // await prefs.setString(
        //     sharedPrefsKeyRpgCharacterConfigJson, serializedConfig);
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
