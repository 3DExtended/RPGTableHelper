import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quest_keeper/helpers/agent_debug_log.dart';
import 'package:quest_keeper/helpers/connection_details_provider.dart';
import 'package:quest_keeper/models/rpg_configuration_model.dart';
import 'package:quest_keeper/services/dependency_provider.dart';
import 'package:quest_keeper/services/server_methods_service.dart';

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
      // TODO i am not sure this is correct here...
      _handleAsyncData(newValue);

      var connectionDetails =
          container.read(connectionDetailsProvider).valueOrNull;

      var isPlayer = (connectionDetails?.isPlayer ?? false) &&
          (connectionDetails?.isInSession ?? false) &&
          (connectionDetails?.isConnected ?? false);

      if (!isPlayer) {
        log("Saving rpg config");
        // _handleAsyncData(newValue);

        // DM campagne edits must sync even when SignalR is briefly disconnected
        // (wizard editing, reconnect, large payload). Critical invokes queue offline.
        final willSend = connectionDetails != null &&
            connectionDetails.isDm &&
            connectionDetails.campagneId != null;
        agentDebugLog(
          location: 'save_rpg_configuration_to_storage_observer.dart:didUpdateProvider',
          message: 'rpg config provider updated',
          hypothesisId: 'B',
          data: {
            'willSendToServer': willSend,
            'isConnected': connectionDetails?.isConnected,
            'isDm': connectionDetails?.isDm,
            'isConnecting': connectionDetails?.isConnecting,
            'campagneId': connectionDetails?.campagneId,
            'runId': 'post-fix',
            'statTabCount':
                newValue.requireValue.characterStatTabsDefinition?.length,
            'statCount': newValue.requireValue.characterStatTabsDefinition
                    ?.fold<int>(
                  0,
                  (sum, tab) => sum + tab.statsInTab.length,
                ) ??
                0,
          },
        );
        if (willSend) {
          // TODO this is ugly and should be rewritten... I am using a static singleton in DependencyProvider since i have no access to the buildcontext to receive our instance of the DependencyProvider
          DependencyProvider.getIt!
              .get<IServerMethodsService>()
              .sendUpdatedRpgConfig(
                  rpgConfig: newValue.requireValue,
                  campagneId: connectionDetails.campagneId!);
        }
      }
    }
  }

  void _handleAsyncData(AsyncData<RpgConfigurationModel> castedData) {
    if (castedData.hasValue == true) {
      Future.delayed(Duration.zero, () async {
        // TODO remove me
        // var serializedConfig = jsonEncode(castedData.requireValue);
        // var prefs = await SharedPreferences.getInstance();
        // do I even need this class still?
        // await prefs.setString(sharedPrefsKeyRpgConfigJson, serializedConfig);
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
