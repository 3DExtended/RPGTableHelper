import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quest_keeper/generated/l10n.dart';
import 'package:quest_keeper/l10n/app_localizations_de.dart';
import 'package:quest_keeper/l10n/app_localizations_en.dart';

void main() {
  group('German plurals (intl_utils S)', () {
    late S s;
    setUp(() async => s = await S.load(const Locale('de')));

    test('campagnes', () {
      expect(s.youOwnXCampaigns(0), 'Du leitest noch keine Kampagne.');
      expect(s.youOwnXCampaigns(1), 'Du leitest 1 Kampagne.');
      expect(s.youOwnXCampaigns(3), 'Du leitest 3 Kampagnen.');
    });

    test('characters', () {
      expect(s.youOwnXCharacters(0), 'Du hast noch keinen Charakter.');
      expect(s.youOwnXCharacters(1), 'Du hast 1 Charakter.');
      expect(s.youOwnXCharacters(2), 'Du hast 2 Charaktere.');
    });

    test('open join requests badge', () {
      expect(s.openJoinRequestsBadge(1), '1 offene Anfrage');
      expect(s.openJoinRequestsBadge(4), '4 offene Anfragen');
    });
  });

  test('English plurals (intl_utils S)', () async {
    final s = await S.load(const Locale('en'));
    expect(s.youOwnXCampaigns(1), 'You run 1 campaign.');
    expect(s.youOwnXCampaigns(2), 'You run 2 campaigns.');
    expect(s.openJoinRequestsBadge(1), '1 open request');
  });

  test('gen-l10n output agrees', () {
    expect(AppLocalizationsDe().youOwnXCampaigns(1), 'Du leitest 1 Kampagne.');
    expect(AppLocalizationsDe().youOwnXCharacters(5), 'Du hast 5 Charaktere.');
    expect(AppLocalizationsEn().openJoinRequestsBadge(2), '2 open requests');
  });
}
