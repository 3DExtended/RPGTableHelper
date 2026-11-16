import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:quest_keeper/models/rpg_configuration_model.dart';

/// The "Fantasy 5E (SRD)" template (P7a): SRD 5.2.1 skills, spell texts and
/// coin values, no trademarks, and every uuid campaigns may point at kept.
void main() {
  final config = RpgConfigurationModel.getBaseConfiguration();
  final allStats = config.characterStatTabsDefinition!
      .expand((t) => t.statsInTab)
      .toList();

  List<Map<String, dynamic>> entriesOf(CharacterStatDefinition stat) {
    if (stat.jsonSerializedAdditionalData == null) return [];
    final data =
        jsonDecode(stat.jsonSerializedAdditionalData!) as Map<String, dynamic>;
    return [
      ...((data["values"] as List<dynamic>?) ?? const []),
      ...((data["options"] as List<dynamic>?) ?? const []),
    ].cast<Map<String, dynamic>>();
  }

  CharacterStatDefinition stat(String uuid) =>
      allStats.singleWhere((s) => s.statUuid == uuid);

  /// Every uuid the template defines (not mere references).
  Set<String> definedUuids(RpgConfigurationModel c) {
    final categories = ItemCategory.flattenCategoriesRecursive(
      categories: c.itemCategories,
    );
    return {
      ...c.placesOfFindings.map((p) => p.uuid),
      ...categories.map((cat) => cat.uuid),
      ...c.allItems.map((i) => i.uuid),
      ...c.craftingRecipes.map((r) => r.recipeUuid),
      for (final tab in c.characterStatTabsDefinition!) ...[
        tab.uuid,
        for (final s in tab.statsInTab) ...[
          s.statUuid,
          ...entriesOf(s).map((e) => e["uuid"] as String),
        ],
      ],
    };
  }

  group('uuids', () {
    test('every uuid of the template before P7a still exists', () {
      final now = definedUuids(config);
      final missing = _uuidsBeforeP7a
          .where((u) => !_removedOnPurpose.containsKey(u))
          .where((u) => !now.contains(u))
          .toList();
      expect(missing, isEmpty);
    });

    test('only the spells that are not in the SRD 5.2.1 were removed', () {
      final now = definedUuids(config);
      for (final removed in _removedOnPurpose.keys) {
        expect(
          now,
          isNot(contains(removed)),
          reason: _removedOnPurpose[removed],
        );
      }
      expect(jsonEncode(config.toJson()), isNot(contains('Dornenpeitsche')));
    });

    test('defined uuids are unique', () {
      final list = [
        ...config.placesOfFindings.map((p) => p.uuid),
        ...ItemCategory.flattenCategoriesRecursive(
          categories: config.itemCategories,
        ).map((c) => c.uuid),
        ...config.allItems.map((i) => i.uuid),
        for (final tab in config.characterStatTabsDefinition!) ...[
          tab.uuid,
          for (final s in tab.statsInTab) ...[
            s.statUuid,
            ...entriesOf(s).map((e) => e["uuid"] as String),
          ],
        ],
      ];
      expect(list.toSet(), hasLength(list.length));
    });

    test('references point at existing entries', () {
      final now = definedUuids(config);
      for (final item in config.allItems) {
        expect(now, contains(item.categoryId), reason: item.name);
        for (final place in item.placeOfFindings) {
          expect(now, contains(place.placeOfFindingId), reason: item.name);
        }
      }
      for (final recipe in config.craftingRecipes) {
        for (final id in [
          ...recipe.ingredients.map((i) => i.itemUuid),
          recipe.createdItem.itemUuid,
          ...recipe.requiredItemIds,
        ]) {
          expect(now, contains(id), reason: recipe.recipeUuid);
        }
      }
      expect(now, contains(config.initiativeBonusStatUuid));
      expect(now, contains(config.initiativeBonusListEntryUuid));
    });
  });

  group('SRD 5.2.1 content', () {
    test('skills: the 18 skills with their abilities', () {
      final skills = entriesOf(stat(_skillsStat));
      expect(skills.map((s) => s["label"]), [
        'Akrobatik (Ges)',
        'Arkane Kunde (Int)',
        'Athletik (Stä)',
        'Auftreten (Cha)',
        'Einschüchtern (Cha)',
        'Fingerfertigkeit (Ges)',
        'Geschichte (Int)',
        'Heilkunde (Wei)',
        'Heimlichkeit (Ges)',
        'Mit Tieren umgehen (Wei)',
        'Motiv erkennen (Wei)',
        'Nachforschungen (Int)',
        'Naturkunde (Int)',
        'Religion (Int)',
        'Täuschen (Cha)',
        'Überlebenskunst (Wei)',
        'Überzeugen (Cha)',
        'Wahrnehmung (Wei)',
      ]);
      // Heilkunde kept its uuid, only the ability changed.
      expect(
        skills.singleWhere((s) => s["label"] == 'Heilkunde (Wei)')["uuid"],
        'f5c38dde-e288-473b-9113-0ae7a960af23',
      );
    });

    test('abilities and saving throws are the six SRD abilities', () {
      const abilities = {
        'Stärke',
        'Geschicklichkeit',
        'Konstitution',
        'Intelligenz',
        'Weisheit',
        'Charisma',
      };
      final attributes = stat('44ab4bcc-0f90-42e0-b9f5-9d4dffc9ffc3');
      expect(attributes.name, 'Attribute');
      expect(entriesOf(attributes).map((e) => e["label"]).toSet(), abilities);
      expect(
        entriesOf(stat('1ce2f567-d540-498a-a677-9776d518622d'))
            .map((e) => e["label"])
            .toSet(),
        abilities,
      );
    });

    test('tab and stat names are German', () {
      expect(config.characterStatTabsDefinition!.map((t) => t.tabName), [
        'Hintergrund',
        'Werte',
        'Merkmale',
        'Angriffe',
        'Zauber',
      ]);
      for (final s in allStats) {
        expect(s.name.trim(), isNotEmpty, reason: s.statUuid);
      }
      expect(
        entriesOf(stat('01933514-7eef-7523-a4cc-974802dc96e7'))
            .map((e) => e["label"]),
        ['RK', 'Bewegung', 'ÜB', 'Temp. TP'],
      );
      expect(stat('803f55cb-5d7e-425d-8054-0cb293620481').name, 'TP');
    });

    test('every spell has a SRD 5.2.1 rules text and a summary', () {
      final schoolLine = RegExp(
        r'^(Zaubertrick der \S+|\S+zauber \d\. Grades) \(',
      );
      var count = 0;
      for (final uuid in _spellStats) {
        for (final spell in entriesOf(stat(uuid))) {
          count++;
          final description = spell["description"] as String;
          expect(description, matches(schoolLine), reason: spell["label"]);
          for (final field in [
            '\nZeitaufwand: ',
            '\nReichweite: ',
            '\nKomponenten: ',
            '\nWirkungsdauer: ',
          ]) {
            expect(description, contains(field), reason: spell["label"]);
          }
          expect((spell["summary"] as String).trim(), isNotEmpty);
        }
      }
      expect(count, 23);
    });

    test('spell values follow the SRD 5.2.1 (spot checks)', () {
      String text(String label) =>
          _spellStats
                  .expand((uuid) => entriesOf(stat(uuid)))
                  .singleWhere((s) => s["label"] == label)["description"]
              as String;

      expect(text('Heilendes Wort'), contains('2W4'));
      expect(text('Kalte Hand'), contains('1W10'));
      expect(text('Kalte Hand'), contains('Reichweite: Berührung'));
      expect(text('Gift versprühen'), contains('Fernkampf-Zauberangriff'));
      expect(
        text('Flammenschlag'),
        contains('5W6 Feuerschaden und 5W6 gleißenden Schaden'),
      );
      expect(text('Botschaft'), contains('Komponenten: G, M'));
      // EN: "5-foot-diameter sphere" (the DE edition says radius).
      expect(text('Flammenkugel'), contains('Durchmesser von 1,5 Metern'));
      expect(text('Elementar beschwören'), contains('8W8'));
    });
  });

  group('currency', () {
    test('Kupfer, Silber, Gold, Platin, each worth 10 of the previous', () {
      final types = config.currencyDefinition.currencyTypes;
      expect(types.map((t) => t.name), ['Kupfer', 'Silber', 'Gold', 'Platin']);
      expect(types.map((t) => t.multipleOfPreviousValue), [null, 10, 10, 10]);
      expect(
        CurrencyDefinition.valueOfItemForDefinition(
          config.currencyDefinition,
          1234,
        ),
        [1, 2, 3, 4],
      );
    });

    test('prices keep their gold value (1 GM = 100 Kupfer)', () {
      int price(String uuid) =>
          config.allItems.singleWhere((i) => i.uuid == uuid).baseCurrencyPrice;
      // Kl. Heiltrank: 1 GM, as before.
      expect(price('a7537746-260d-4aed-b182-26768a9c2d51'), 100);
      // Kräuterkundeausrüstung: 5 GM (SRD 5.2.1).
      expect(price('dc497952-1989-40d1-9d50-a5b4e53dd1be'), 500);
      // Glücksklee: 1 GM, as before.
      expect(price('01921424-0eca-74bb-bc3d-be2c82996103'), 100);
    });
  });

  group('names and trademarks', () {
    final forbidden = RegExp(
      r'D&D|Dungeons|Dungeon Master',
      caseSensitive: false,
    );

    test('the template names no trademark', () {
      expect(config.rpgName, 'Fantasy 5E (SRD)');
      expect(jsonEncode(config.toJson()), isNot(matches(forbidden)));
    });

    for (final lang in ['de', 'en']) {
      test('no trademark in the $lang ARB values', () {
        final arb = jsonDecode(
          File('lib/l10n/intl_$lang.arb').readAsStringSync(),
        ) as Map<String, dynamic>;
        final offending = arb.entries
            .where((e) => !e.key.startsWith('@'))
            .where((e) => forbidden.hasMatch(e.value.toString()))
            .map((e) => e.key)
            .toList();
        expect(offending, isEmpty);
      });
    }
  });

  test('the template round-trips through JSON unchanged', () {
    final json = jsonEncode(config.toJson());
    final decoded = RpgConfigurationModel.fromJson(
      jsonDecode(json) as Map<String, dynamic>,
    );
    expect(jsonEncode(decoded.toJson()), json);
  });
}

const _skillsStat = 'c5ef782a-8d8b-4a88-98b2-be277f741e4c';

/// Cantrips and the spells of grade 1 to 5.
const _spellStats = [
  'c1b7a131-c239-4d56-8008-b3d4b654189d',
  '31a52ed2-3e7b-42ac-8f3e-490b3a04027a',
  '212b9948-bc45-48f1-af39-bc84d6c5283f',
  'f8b49ed4-a24a-45fb-8077-369fde7ef37c',
  '612f5698-fdda-4485-b138-599ae3532520',
  '347e51fa-caf0-4054-8eb9-dac3ba48c281',
];

/// Removed on purpose, with the reason.
const _removedOnPurpose = {
  '1e7c68b0-c76b-421c-98ca-d41e7a4fdaa4':
      'Dornenpeitsche (Thorn Whip) is not in the SRD 5.2.1',
};

/// Every uuid the template defined before P7a (places, categories, items,
/// recipes, tabs, stats, list entries and options).
const _uuidsBeforeP7a = [
  '5b9690c1-afc9-436d-8912-d223c440eb6a',
  '4a9abc76-df97-4790-9abe-cee5f6bec8a7',
  'f4e2605a-1d22-45e8-92d6-44534eafdc44',
  '2ed1f4ca-8ae0-4945-8771-5f74cf7ac546',
  '8ea924d4-7160-48dd-9d7f-5afa04c27048',
  'd0a0168f-02d0-4205-b0af-689b52f24186',
  '263dc67f-bfae-4559-a909-1479e24354a6',
  '544cdaac-a8d2-4ee6-8a8f-4772bfb95a93',
  'b895a30a-2c0a-4aba-8629-9a363e405281',
  '4bba577f-c4c0-43a4-bc70-cbb39cbb7bee',
  '79773521-2fd6-4aff-942e-87b9e4bb6599',
  '64031e58-a816-4c84-9ca8-d80cd514a908',
  'b0b0b636-6637-48c2-a899-4bd62435dba0',
  '04b75751-0a85-4d82-8b66-361f47743797',
  'f9cc6513-36b4-4e4e-b3ba-dd9f40fca078',
  '1666d606-b839-4664-930d-2f51b552111c',
  '4ab9bded-a516-4a1b-a66d-fd5d972957cf',
  '8d86c1df-fe26-420d-8ccf-f5ef0af535a3',
  '1d21556e-8993-4883-a9a5-f9853697f21e',
  'c7690cb0-39b4-45d2-b7c5-75b6e8eeb88f',
  'f9f4ba0d-9314-4f70-b7ba-fa6375490c70',
  'a7537746-260d-4aed-b182-26768a9c2d51',
  '8abe00a8-fa94-4e5d-9c99-2a68b9de60e7',
  '73b51a58-8a07-4de2-828c-d0952d42af34',
  'dc497952-1989-40d1-9d50-a5b4e53dd1be',
  '01920bc1-5c79-74fd-b604-c7c825067186',
  '01920bc5-599a-783f-8d88-38257ecf78f5',
  '01921424-0eca-74bb-bc3d-be2c82996103',
  '01921428-f433-7519-880f-d012289b60da',
  '1e660b2d-cc7b-4e4d-9acf-b1bc4b41eb14',
  '7790055d-7421-4608-a824-59d3b1a12d0f',
  'b8a86775-8680-47a5-b55c-cd2287d3584e',
  '8e725f17-ce7c-41d9-a9fd-b83566075096',
  '30e18433-748d-458c-bd5e-373c38e762bf',
  '0070b224-95ac-4f0f-ab07-1ddb0d3d2ac8',
  '37862834-261a-47b5-bd5c-9e315b8d26aa',
  'a464bfe4-d99f-475d-a4af-0f1e5f73290e',
  '5accd34c-eade-4754-b955-21e1d902c4d9',
  'ebf46bc6-1e1e-4ea2-b580-caa992480e80',
  '8b92f020-58f4-41d8-9844-580de13e607d',
  '019317b8-49eb-7575-9f8e-c28c9c8eded2',
  '019317b8-4bb6-7881-a4db-2a8ec3c751f6',
  '273f7ce3-59db-4c34-bc90-83c53f3ea553',
  '44ab4bcc-0f90-42e0-b9f5-9d4dffc9ffc3',
  '76183b57-d6f3-4414-962c-837488ed0384',
  '529d0912-e1ae-41e2-beea-55bd194bfb20',
  '0f6557a8-c3b6-4832-a673-a8903f87ff24',
  'a7aa4151-8c7c-41d4-91d2-2ff0a3d084a4',
  '81ffc65e-156a-4042-8bd6-5ed4d400e4bc',
  '167b94e6-d674-43a4-a25b-fca1309a12b0',
  '01933514-7eef-7523-a4cc-974802dc96e7',
  '01933512-97e4-70fe-877d-0e1f64224a00',
  '01933512-997d-7628-9de3-72827cf4f419',
  '01933512-9cb6-7466-9977-0768e0dda2a7',
  '01933512-a096-701e-875d-05ad93810ba2',
  '803f55cb-5d7e-425d-8054-0cb293620481',
  '1ce2f567-d540-498a-a677-9776d518622d',
  'a632fa33-faab-4247-9152-8ee5ba52cfeb',
  '3dbb5cb6-f256-4dfd-acae-ead1baedb27f',
  '86f66619-857a-47d5-8447-b3016da2a6a4',
  'a3c9cd51-bd58-4d01-b7bb-fe9dcd27f349',
  'af398b67-d335-499b-b74e-39aeaff4dccd',
  'c723e604-ddec-4bb4-b329-6c1478b7bd60',
  'c5ef782a-8d8b-4a88-98b2-be277f741e4c',
  'de1fb5bc-3e3e-42e1-8b11-9dfafebfdfbc',
  '4da1f35a-0ee9-44b0-84de-3341ee7eaad6',
  '89f12e22-178a-4d87-8517-4fe4787335f3',
  '3196199d-f023-4289-a8ce-e5659d54deae',
  '1d477c82-7289-4524-b807-3734f9e1e297',
  '9ab19470-306b-4be0-a23d-ab8bc9c79e0d',
  '3f952394-664f-44e1-8b36-116106266c0f',
  'f5c38dde-e288-473b-9113-0ae7a960af23',
  '9a187aa5-71bb-40c3-b749-d12ace0471b9',
  'a3040091-cf15-4e63-87b7-3c449a9b3dd4',
  'd6833b01-0f6e-4bc3-9590-60a6bc3cdc01',
  'c6e1f42a-44ef-406e-b009-245ceb9637f8',
  '21468550-7899-4188-a3cf-fdec85deb1ca',
  '072ea46a-043c-4548-bb2d-9d340691d940',
  'bc922713-6614-4bd7-8d62-0607bcf03146',
  '8957fe9f-9142-44fd-8354-d50c06c9b1a5',
  '827f2550-9683-45cf-b8fb-cad229c47fe8',
  '11cc5da3-624b-40d4-9477-468a0a6b4670',
  '893bab17-6c13-4ed5-a287-8eaa135a54ef',
  'f0c39bb7-1d95-4d7a-aaf2-80bf31f2662a',
  '3219934b-09fc-409b-8413-9e56b864c664',
  '9421920d-99c2-4882-8a39-53564e7b2920',
  '2438aac8-4a67-41ca-aad9-3c838b7c5cf3',
  'c1b7a131-c239-4d56-8008-b3d4b654189d',
  '1e720492-1520-4bf3-86a3-98c4f61be329',
  'bc6ddcc2-ccf5-4a70-9b0f-afbf17c7be47',
  '5b9c7345-8cda-469b-8e00-4ff47f50ce9c',
  '4ee11bf7-1f97-4209-b2e4-d05346b04ed9',
  'c247bc4f-f04b-4301-a401-fe0908eb3ca9',
  'c3fa6593-ac9c-44d0-b158-09555d0f3f5e',
  '1e7c68b0-c76b-421c-98ca-d41e7a4fdaa4',
  '30928f34-7632-469a-bd3d-6f76ee660f98',
  '18877c24-515a-4788-a657-d50915a5c0cc',
  '31a52ed2-3e7b-42ac-8f3e-490b3a04027a',
  'e79adcb9-4d57-45e6-9d05-29aeb2bbfe1a',
  'f28e6faa-1cce-4f99-8f4f-30e9b89defd7',
  '94a4169b-80c3-4819-bb9f-4e4fc40fb294',
  '6c0490b7-2da1-41d2-84e1-c0e4deb98ab3',
  'be12d521-1a3c-440f-90bc-1ab262df56c9',
  '94746221-d26a-496a-bdc6-44a457db8eaf',
  'cae3e22b-5674-4728-82d4-c8a28615fcdd',
  '212b9948-bc45-48f1-af39-bc84d6c5283f',
  '10978c13-95c7-4179-bd91-e4270547ebe2',
  '7f182652-7da8-4b11-9e1c-de0393fd30b6',
  '774a0a67-ff6d-478e-ae6b-38158e1c5db0',
  'b2aa3dc4-ac1d-4be4-bd81-db41e7501ae5',
  '66f0e8dd-1fed-47d8-9e4d-88e0b8b2e2b0',
  'f8b49ed4-a24a-45fb-8077-369fde7ef37c',
  'f663078d-730f-422c-8d8f-dacdc8896981',
  '327f07de-4191-43db-9ac5-a8c65382cff7',
  'f4268470-6c7c-4fc8-8412-cf2fea4e19b1',
  '612f5698-fdda-4485-b138-599ae3532520',
  'ea4263df-f701-427a-a3fe-ff55288237a1',
  '2edae70c-e48f-45d4-b601-565f8ddbee83',
  '940ef581-e6a5-4dcd-bb9d-567a0294a76d',
  '347e51fa-caf0-4054-8eb9-dac3ba48c281',
  'e4927331-9272-4685-94bb-b243507142f5',
  'cb5deac0-8f79-43dd-9358-3dc3179e43db',
];
