import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:quest_keeper/generated/swaggen/swagger.models.swagger.dart';
import 'package:quest_keeper/models/humanreadable_response.dart';
import 'package:quest_keeper/services/auth/api_connector_service.dart';
import 'package:quest_keeper/services/rpg_entity_service.dart';
import 'package:quest_keeper/services/session/session_presence_keeper.dart';
import 'package:quest_keeper/services/sse/events_client.dart';

class _RecordingRpgEntityService extends MockRpgEntityService {
  _RecordingRpgEntityService() : super(apiConnectorService: MockApiConnectorService());

  final enteredCampagneIds = <String>[];

  @override
  Future<HRResponse<List<String>>> enterSession({
    required CampagneIdentifier campagneId,
  }) async {
    enteredCampagneIds.add(campagneId.$value!);
    return HRResponse.fromResult(['me']);
  }
}

void main() {
  late StreamController<List<int>> current;
  late EventsClient eventsClient;

  setUp(() {
    eventsClient = EventsClient(
      getJwt: () async => 't',
      baseUrl: 'http://example.test/',
      openStream: ({required uri, required jwt}) async {
        current = StreamController<List<int>>();
        return http.ByteStream(current.stream);
      },
      sleep: (_) async {},
    );
  });

  tearDown(() => eventsClient.dispose());

  test('re-enters the session and catches up after the SSE stream reconnects',
      () async {
    await eventsClient.start();
    final rpg = _RecordingRpgEntityService();
    var catchUps = 0;
    final keeper = SessionPresenceKeeper(
      eventsClient: eventsClient,
      rpgEntityService: rpg,
      campagneId: CampagneIdentifier($value: 'campagne-1'),
      onReentered: () async => catchUps++,
    )..start();

    // Connection drops (e.g. iPad locked) and comes back.
    await current.close();
    await Future<void>.delayed(const Duration(milliseconds: 20));

    expect(rpg.enteredCampagneIds, ['campagne-1']);
    expect(catchUps, 1);

    await keeper.stop();
  });

  test('does nothing after stop', () async {
    await eventsClient.start();
    final rpg = _RecordingRpgEntityService();
    final keeper = SessionPresenceKeeper(
      eventsClient: eventsClient,
      rpgEntityService: rpg,
      campagneId: CampagneIdentifier($value: 'campagne-1'),
    )..start();
    await keeper.stop();

    await current.close();
    await Future<void>.delayed(const Duration(milliseconds: 20));

    expect(rpg.enteredCampagneIds, isEmpty);
  });
}
