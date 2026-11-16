import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quest_keeper/generated/swaggen/swagger.models.swagger.dart';
import 'package:quest_keeper/helpers/modal_helpers.dart';
import 'package:quest_keeper/helpers/modals/ask_for_campagne_join_code.dart';
import 'package:quest_keeper/models/humanreadable_response.dart';
import 'package:quest_keeper/services/auth/api_connector_service.dart';
import 'package:quest_keeper/services/dependency_provider.dart';
import 'package:quest_keeper/services/rpg_entity_service.dart';

import '../fakes/fake_join_rpg_entity_service.dart';
import '../fakes/modal_test_host.dart';

Finder _textFieldIn(Key key) =>
    find.descendant(of: find.byKey(key), matching: find.byType(TextField));

final _codeField = _textFieldIn(
  AskForCampagneJoinCodeModalContent.codeFieldKey,
);
final _nameField = _textFieldIn(
  AskForCampagneJoinCodeModalContent.nameFieldKey,
);
final _submit = find.byKey(AskForCampagneJoinCodeModalContent.submitButtonKey);

void main() {
  late FakeJoinRpgEntityService service;
  JoinCampagneResult? result;
  var closed = false;

  Future<void> openDialog(
    WidgetTester tester, {
    List<HRResponse<CampagneJoinRequestIdentifier>> responses = const [],
    PlayerCharacterIdentifier? existingCharacterId,
  }) async {
    result = null;
    closed = false;
    await pumpModalHost(
      tester,
      mockOverrides: {
        IRpgEntityService: () => service = FakeJoinRpgEntityService(
          apiConnectorService: DependencyProvider.getIt!
              .get<IApiConnectorService>(),
          joinRequestResponses: responses,
        ),
      },
      open: (context) async {
        result = await askForCampagneJoinCode(
          context,
          existingCharacterId: existingCharacterId,
        );
        closed = true;
      },
    );
    await tester.tap(find.byKey(openModalButtonKey));
    await tester.pumpAndSettle();
  }

  testWidgets('code field: number keyboard and ###-### mask', (tester) async {
    await openDialog(tester);

    expect(
      tester.widget<TextField>(_codeField).keyboardType,
      TextInputType.number,
    );

    await tester.enterText(_codeField, '699457');
    await tester.pump();
    expect(tester.widget<TextField>(_codeField).controller!.text, '699-457');

    await tester.enterText(_codeField, 'Code 12 34 5');
    await tester.pump();
    expect(tester.widget<TextField>(_codeField).controller!.text, '123-45');
  });

  testWidgets('empty code and name are shown inline, nothing is sent', (
    tester,
  ) async {
    await openDialog(tester);

    await tester.tap(_submit);
    await tester.pumpAndSettle();

    expect(find.text('Bitte gib den Beitrittscode ein.'), findsOneWidget);
    expect(find.text('Bitte gib einen Namen ein'), findsOneWidget);
    expect(service.joinRequests, isEmpty);
    expect(closed, isFalse);
  });

  testWidgets('an incomplete code is shown inline', (tester) async {
    await openDialog(tester);

    await tester.enterText(_codeField, '69945');
    await tester.enterText(_nameField, 'Mira Dornwald');
    await tester.tap(_submit);
    await tester.pumpAndSettle();

    expect(
      find.text('Der Code hat sechs Ziffern, zum Beispiel 123-456.'),
      findsOneWidget,
    );
    expect(service.createdCharacterNames, isEmpty);
  });

  testWidgets('a wrong code is an inline message, not the error dialog; '
      'the retry reuses the character', (tester) async {
    await openDialog(
      tester,
      responses: [
        unknownJoinCodeResponse(),
        HRResponse.fromResult(
          CampagneJoinRequestIdentifier(value: 'request-2'),
        ),
      ],
    );

    await tester.enterText(_codeField, '999999');
    await tester.enterText(_nameField, 'Mira Dornwald');
    await tester.tap(_submit);
    await tester.pumpAndSettle();

    expect(
      find.text(
        'Diesen Code gibt es nicht. Prüfe ihn mit deiner Spielleitung.',
      ),
      findsOneWidget,
    );
    expect(find.byType(GenericErrorDialog), findsNothing);
    expect(closed, isFalse);
    expect(service.createdCharacterNames, ['Mira Dornwald']);

    await tester.enterText(_codeField, '699457');
    await tester.pumpAndSettle();
    // editing the code clears the old message
    expect(
      find.text(
        'Diesen Code gibt es nicht. Prüfe ihn mit deiner Spielleitung.',
      ),
      findsNothing,
    );

    await tester.tap(_submit);
    await tester.pumpAndSettle();

    expect(closed, isTrue);
    expect(result!.joinCode, '699-457');
    expect(result!.campagneJoinRequestId, 'request-2');
    expect(
      result!.playerCharacterId.value,
      FakeJoinRpgEntityService.createdCharacterId,
    );
    expect(service.createdCharacterNames, [
      'Mira Dornwald',
    ], reason: 'no second character for the retry');
    expect(service.joinRequests.map((r) => r.joinCode), ['999-999', '699-457']);
  });

  testWidgets('other server errors go to the error dialog', (tester) async {
    await openDialog(
      tester,
      responses: [
        HRResponse.error<CampagneJoinRequestIdentifier>(
          'x',
          'y',
          errorFromServer: 'boom',
          statusCode: 500,
        ),
      ],
    );

    await tester.enterText(_codeField, '699457');
    await tester.enterText(_nameField, 'Mira');
    await tester.tap(_submit);
    await tester.pumpAndSettle();

    expect(find.byType(GenericErrorDialog), findsOneWidget);
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(find.byType(GenericErrorDialog), findsNothing);
    expect(closed, isFalse, reason: 'the join dialog stays open');
  });

  testWidgets('an existing character only needs the code', (tester) async {
    await openDialog(
      tester,
      existingCharacterId: PlayerCharacterIdentifier(value: 'kardan'),
    );

    expect(_nameField, findsNothing);

    await tester.enterText(_codeField, '699457');
    await tester.tap(_submit);
    await tester.pumpAndSettle();

    expect(closed, isTrue);
    expect(service.createdCharacterNames, isEmpty);
    expect(service.joinRequests.single.characterId, 'kardan');
  });
}
