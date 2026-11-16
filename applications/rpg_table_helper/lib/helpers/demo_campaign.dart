import 'dart:convert';

import 'package:quest_keeper/generated/swaggen/swagger.models.swagger.dart';
import 'package:quest_keeper/models/prepared_character.dart';
import 'package:quest_keeper/models/rpg_character_configuration.dart';
import 'package:quest_keeper/models/rpg_configuration_model.dart';
import 'package:quest_keeper/models/rpg_configuration_templates.dart';
import 'package:quest_keeper/services/note_documents_service.dart';
import 'package:uuid/v7.dart';

/// "Demo-Kampagne": a campaign to try the app alone before inviting anyone.
/// It is an ordinary campaign of the game master with the Fantasy 5E (SRD)
/// sheet, three ready characters to look at or hand to players, and a
/// welcome note on what to try.
RpgConfigurationModel demoCampaignConfig(String campaignName) =>
    RpgConfigurationTemplates.build(
      RpgConfigurationTemplateId.fantasySrd,
    ).copyWith(rpgName: campaignName, preparedCharacters: demoCharacters());

// Properties of the Fantasy 5E (SRD) template.
const _summary = '8b92f020-58f4-41d8-9844-580de13e607d';
const _className = '019317b8-49eb-7575-9f8e-c28c9c8eded2';
const _species = '019317b8-4bb6-7881-a4db-2a8ec3c751f6';
const _attributes = '44ab4bcc-0f90-42e0-b9f5-9d4dffc9ffc3';
const _combat = '01933514-7eef-7523-a4cc-974802dc96e7';
const _hitPoints = '803f55cb-5d7e-425d-8054-0cb293620481';
const _savingThrows = '1ce2f567-d540-498a-a677-9776d518622d';
const _skills = 'c5ef782a-8d8b-4a88-98b2-be277f741e4c';
const _origin = '30e18433-748d-458c-bd5e-373c38e762bf';
const _background = '0070b224-95ac-4f0f-ab07-1ddb0d3d2ac8';
const _drive = '37862834-261a-47b5-bd5c-9e315b8d26aa';
const _looks = 'a464bfe4-d99f-475d-a4af-0f1e5f73290e';
const _languages = '5accd34c-eade-4754-b955-21e1d902c4d9';
const _features = '893bab17-6c13-4ed5-a287-8eaa135a54ef';
const _attacks = '3219934b-09fc-409b-8413-9e56b864c664';
const _spellSlots = '2438aac8-4a67-41ca-aad9-3c838b7c5cf3';
const _cantrips = 'c1b7a131-c239-4d56-8008-b3d4b654189d';
const _spellSlots1 = '18877c24-515a-4788-a657-d50915a5c0cc';
const _spells1 = '31a52ed2-3e7b-42ac-8f3e-490b3a04027a';

// Entries of "Attribute", in the order STR, DEX, CON, INT, WIS, CHA.
const _str = '529d0912-e1ae-41e2-beea-55bd194bfb20';
const _dex = 'a7aa4151-8c7c-41d4-91d2-2ff0a3d084a4';
const _con = '81ffc65e-156a-4042-8bd6-5ed4d400e4bc';
const _int = '0f6557a8-c3b6-4832-a673-a8903f87ff24';
const _wis = '167b94e6-d674-43a4-a25b-fca1309a12b0';
const _cha = '76183b57-d6f3-4414-962c-837488ed0384';

// Entries of "Kampfwerte".
const _armorClass = '01933512-97e4-70fe-877d-0e1f64224a00';
const _speed = '01933512-997d-7628-9de3-72827cf4f419';
const _proficiency = '01933512-9cb6-7466-9977-0768e0dda2a7';
const _tempHitPoints = '01933512-a096-701e-875d-05ad93810ba2';

// Options of "Rettungswürfe".
const _saveStr = 'a632fa33-faab-4247-9152-8ee5ba52cfeb';
const _saveDex = '3dbb5cb6-f256-4dfd-acae-ead1baedb27f';
const _saveCon = '86f66619-857a-47d5-8447-b3016da2a6a4';
const _saveInt = 'a3c9cd51-bd58-4d01-b7bb-fe9dcd27f349';
const _saveWis = 'af398b67-d335-499b-b74e-39aeaff4dccd';

// Options of "Fertigkeiten".
const _acrobatics = 'de1fb5bc-3e3e-42e1-8b11-9dfafebfdfbc';
const _arcana = '4da1f35a-0ee9-44b0-84de-3341ee7eaad6';
const _athletics = '89f12e22-178a-4d87-8517-4fe4787335f3';
const _intimidation = '1d477c82-7289-4524-b807-3734f9e1e297';
const _sleightOfHand = '9ab19470-306b-4be0-a23d-ab8bc9c79e0d';
const _history = '3f952394-664f-44e1-8b36-116106266c0f';
const _stealth = 'b62eeed4-fe7f-47ce-b14c-041b6b1467d6';
const _investigation = 'd6833b01-0f6e-4bc3-9590-60a6bc3cdc01';
const _deception = '072ea46a-043c-4548-bb2d-9d340691d940';
const _perception = '827f2550-9683-45cf-b8fb-cad229c47fe8';

// Options of "Zaubertricks" and "Zauber 1. Grades".
const _message = '1e720492-1520-4bf3-86a3-98c4f61be329';
const _mageHand = 'bc6ddcc2-ccf5-4a70-9b0f-afbf17c7be47';
const _chillTouch = 'c247bc4f-f04b-4301-a401-fe0908eb3ca9';
const _burningHands = 'e79adcb9-4d57-45e6-9d05-29aeb2bbfe1a';
const _magicMissile = 'f28e6faa-1cce-4f99-8f4f-30e9b89defd7';
const _detectMagic = 'be12d521-1a3c-440f-90bc-1ab262df56c9';

/// The three characters of the demo, level 1 and ready to play. German like
/// the template they are written for.
List<PreparedCharacter> demoCharacters() => [
  _character(
    name: 'Brom Eisenfaust',
    className: 'Kämpfer',
    species: 'Zwerg',
    attributes: [16, 12, 15, 8, 13, 10],
    armorClass: 16,
    hitPoints: 12,
    savingThrows: [_saveStr, _saveCon],
    skills: [_athletics, _intimidation, _perception],
    origin: 'Aus den Eisenhallen unter dem Grauberg, Sohn einer Schmiedin.',
    background:
        'Zehn Jahre bei der Bergwache, bis ein Stollen über seinem Trupp '
        'einstürzte. Brom kam als Einziger heraus.',
    drive: 'Will herausfinden, wer die Stützbalken angesägt hat.',
    looks:
        'Breit wie ein Fass, rotbrauner Zopfbart, eine Narbe über dem '
        'linken Auge.',
    languages: 'Gemeinsprache, Zwergisch; Schmiedewerkzeug',
    features:
        'Verteidigung: +1 auf die RK, solange er Rüstung trägt.\n'
        'Kurz verschnaufen: einmal pro Rast als Bonusaktion 1W10 + 1 TP '
        'zurückholen.\n'
        'Dunkelsicht; widerstandsfähig gegen Gift.',
    attacks:
        'Langschwert: +5 auf Treffer, 1W8 + 3 Hiebschaden\n'
        'Leichte Armbrust: +3 auf Treffer, 1W8 + 1 Stichschaden, '
        'Reichweite 24/96 m',
  ),
  _character(
    name: 'Lyra Silbersang',
    className: 'Magierin',
    species: 'Elfe',
    attributes: [8, 14, 13, 16, 12, 10],
    armorClass: 12,
    hitPoints: 7,
    savingThrows: [_saveInt, _saveWis],
    skills: [_arcana, _history, _investigation],
    origin: 'Aus dem Silberhain, einer Stadt hoch in den Baumkronen.',
    background:
        'Lehrling an der Akademie von Calimar, bis sie zu viele Fragen über '
        'die verbotene Bibliothek stellte.',
    drive: 'Sucht das verschollene Zauberbuch ihrer Großmutter.',
    looks: 'Schmal, silbernes Haar, Tintenflecken an allen Fingern.',
    languages: 'Gemeinsprache, Elfisch, Drakonisch',
    features:
        'Zauberbuch mit sechs Zaubern 1. Grades.\n'
        'Arkane Erholung: nach einer kurzen Rast einen verbrauchten '
        'Zauberplatz zurückholen.\n'
        'Dunkelsicht; Trance statt Schlaf.',
    attacks:
        'Kalte Hand: Nahkampf-Zauberangriff +5, 1W10 nekrotischer Schaden\n'
        'Dolch: +4 auf Treffer, 1W4 + 2 Stichschaden',
    spells: (
      slots: 2,
      cantrips: [_mageHand, _message, _chillTouch],
      level1: [_magicMissile, _burningHands, _detectMagic],
    ),
  ),
  _character(
    name: 'Pip Flinkfuß',
    className: 'Schurke',
    species: 'Halbling',
    attributes: [8, 16, 13, 12, 10, 14],
    armorClass: 14,
    hitPoints: 9,
    savingThrows: [_saveDex, _saveInt],
    skills: [_stealth, _sleightOfHand, _acrobatics, _deception],
    origin: 'Aus Kleinbachingen, einem Halblingsdorf an der Handelsstraße.',
    background: 'Hat sich jahrelang als Taschendieb auf dem Markt von '
        'Calimar durchgeschlagen.',
    drive: 'Will genug Gold, um seiner Familie die Mühle zurückzukaufen.',
    looks: 'Klein, lockiges Haar, ein freches Grinsen, viel zu große Stiefel.',
    languages: 'Gemeinsprache, Halblingisch; Diebeswerkzeug',
    features:
        'Expertise in Heimlichkeit und Fingerfertigkeit.\n'
        'Glückspilz: eine gewürfelte 1 darf er neu würfeln.\n'
        'Mutig: im Vorteil gegen Angst.',
    attacks:
        'Kurzschwert: +5 auf Treffer, 1W6 + 3 Stichschaden\n'
        'Kurzbogen: +5 auf Treffer, 1W6 + 3 Stichschaden, Reichweite 24/96 m\n'
        'Hinterhältiger Angriff: +1W6 Schaden, wenn er im Vorteil ist oder '
        'ein Verbündeter neben dem Ziel steht.',
  ),
];

PreparedCharacter _character({
  required String name,
  required String className,
  required String species,
  required List<int> attributes,
  required int armorClass,
  required int hitPoints,
  required List<String> savingThrows,
  required List<String> skills,
  required String origin,
  required String background,
  required String drive,
  required String looks,
  required String languages,
  required String features,
  required String attacks,
  ({int slots, List<String> cantrips, List<String> level1})? spells,
}) {
  RpgCharacterStatValue value(String statUuid, Map<String, dynamic> json) =>
      RpgCharacterStatValue(
        statUuid: statUuid,
        serializedValue: jsonEncode(json),
        hideFromCharacterScreen: false,
        variant: 0,
        hideLabelOfStat: false,
      );
  RpgCharacterStatValue text(String statUuid, String text) =>
      value(statUuid, {'value': text});

  const attributeOrder = [_str, _dex, _con, _int, _wis, _cha];
  return PreparedCharacter(
    uuid: const UuidV7().generate(),
    characterName: name,
    characterStats: [
      value(_summary, {
        'level': 1,
        'values': [
          {'uuid': _className, 'value': className},
          {'uuid': _species, 'value': species},
        ],
      }),
      value(_attributes, {
        'values': [
          for (var i = 0; i < attributeOrder.length; i++)
            {
              'uuid': attributeOrder[i],
              'value': attributes[i],
              'otherValue': ((attributes[i] - 10) / 2).floor(),
            },
        ],
      }),
      value(_combat, {
        'values': [
          {'uuid': _armorClass, 'value': armorClass},
          {'uuid': _speed, 'value': 9},
          {'uuid': _proficiency, 'value': 2},
          {'uuid': _tempHitPoints, 'value': 0},
        ],
      }),
      value(_hitPoints, {'value': hitPoints, 'maxValue': hitPoints}),
      value(_savingThrows, {'values': savingThrows}),
      value(_skills, {'values': skills}),
      text(_origin, origin),
      text(_background, background),
      text(_drive, drive),
      text(_looks, looks),
      text(_languages, languages),
      text(_features, features),
      text(_attacks, attacks),
      if (spells != null) ...[
        value(_spellSlots, {'value': spells.slots, 'maxValue': spells.slots}),
        value(_spellSlots1, {'value': spells.slots, 'maxValue': spells.slots}),
        value(_cantrips, {'values': spells.cantrips}),
        value(_spells1, {'values': spells.level1}),
      ],
    ],
  );
}

/// Puts the welcome note into the demo campaign [campagneId]: a document in
/// the game master's notes with one text block. False when it could not be
/// created; the demo works without it.
Future<bool> createDemoWelcomeNote({
  required INoteDocumentService service,
  required CampagneIdentifier campagneId,
  required String groupName,
  required String title,
  required String markdown,
  required DateTime now,
}) async {
  const newId = '00000000-0000-0000-0000-000000000000';
  final document = await service.createNewDocumentForCampagne(
    dto: NoteDocumentDto(
      groupName: groupName,
      title: title,
      createdForCampagneId: campagneId,
      lastModifiedAt: now,
      creationDate: now,
      isDeleted: false,
      imageBlocks: [],
      textBlocks: [],
      id: NoteDocumentIdentifier(value: newId),
    ),
  );
  final documentId = document.result;
  if (!document.isSuccessful || documentId == null) return false;

  final block = await service.createNewTextBlockForDocument(
    textBlockToCreate: TextBlock(
      creationDate: now,
      lastModifiedAt: now,
      id: NoteBlockModelBaseIdentifier(value: newId),
      isDeleted: false,
      permittedUsers: [],
      markdownText: markdown,
      noteDocumentId: documentId,
    ),
    notedocumentid: documentId,
  );
  return block.isSuccessful;
}
