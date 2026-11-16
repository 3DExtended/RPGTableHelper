// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a de locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'de';

  static String m0(date) => "Läuft ab: ${date}";

  static String m1(date) => "Zuletzt benutzt: ${date}";

  static String m2(prefix) => "Präfix: ${prefix}";

  static String m3(date) => "Widerrufen: ${date}";

  static String m4(count) => "${count} hinzufügen";

  static String m5(tabName) => "Reiter „${tabName}“";

  static String m6(date) => "Einstellungen geändert: ${date}";

  static String m7(date) => "Zuletzt bearbeitet: ${date}";

  static String m8(current, total, tabName) =>
      "Abschnitt ${current} von ${total}: ${tabName}";

  static String m9(number) => "Kästchen ${number}";

  static String m10(condition) => "(wenn ${condition})";

  static String m11(label) => "Mod(${label})";

  static String m12(username) => " (für ${username})";

  static String m13(email) =>
      "Wir haben dir einen Code an ${email} geschickt. Er gilt zwei Stunden.";

  static String m14(characterNames) =>
      "Die Items konnten nicht an ${characterNames} verteilt werden. Bitte versuche es erneut.";

  static String m15(label, formattedBonus) =>
      "Addiere ${label} ${formattedBonus} zu deinem Wurf";

  static String m16(campagneName) => "Einladung zu „${campagneName}“";

  static String m17(campagneName, code) =>
      "Spiel mit in meiner Runde „${campagneName}“! Öffne QuestKeeper, tippe auf „Kampagne beitreten“ und gib diesen Code ein: ${code}";

  static String m18(code) => "Beitrittscode: ${code}";

  static String m19(playerName, username) =>
      "${playerName} (${username}) möchte deiner Kampagne beitreten.";

  static String m20(count) =>
      "${Intl.plural(count, one: '1 offene Anfrage', other: '${count} offene Anfragen')}";

  static String m21(count) => "höchstens ${count} Zeichen";

  static String m22(count) => "mindestens ${count} Zeichen";

  static String m23(amount) =>
      "${Intl.plural(amount, one: 'Du hast ein neues Item erhalten:', other: 'Du hast ${amount} neue Items erhalten:')}";

  static String m24(privacyPolicyLink) =>
      "Wie wir mit deinen Daten umgehen, steht in unserer ${privacyPolicyLink}.";

  static String m25(index, count) => "${index} von ${count}";

  static String m26(tabName) => "Neu, kommt in den Reiter „${tabName}“";

  static String m27(count) => "${count} übernehmen";

  static String m28(count) =>
      "Die Vorlage hat inzwischen ${Intl.plural(count, one: 'eine Eigenschaft', other: '${count} Eigenschaften')} ergänzt oder überarbeitet. Du entscheidest, was du übernimmst.";

  static String m29(template) => "Neues in der Vorlage „${template}“";

  static String m30(count) =>
      "${Intl.plural(count, one: '1 neuer Eintrag', other: '${count} neue Einträge')}";

  static String m31(name) => "Neuer Name: ${name}";

  static String m32(statName) => "Einstellungen für ${statName}";

  static String m33(property) => "Der Wert von ${property}";

  static String m34(characterName) =>
      "Deine Anfrage für „${characterName}“ liegt bei deiner Spielleitung. Sobald sie zustimmt, kannst du hier mitspielen.";

  static String m35(count) =>
      "${Intl.plural(count, zero: 'In dieser Kategorie sind noch keine Items.', one: 'In dieser Kategorie ist ein Item.', other: 'In dieser Kategorie sind ${count} Items.')}";

  static String m36(count, name) =>
      "${Intl.plural(count, one: 'Eigenschaft „${name}“ löschen? Ein Charakter hat dafür schon einen Wert, er geht verloren.', other: 'Eigenschaft „${name}“ löschen? ${count} Charaktere haben dafür schon Werte, sie gehen verloren.')}";

  static String m37(count, tabName) =>
      "${Intl.plural(count, zero: 'Den leeren Tab „${tabName}“ löschen?', one: 'Tab „${tabName}“ mit einer Eigenschaft löschen? Werte der Charaktere gehen verloren.', other: 'Tab „${tabName}“ mit ${count} Eigenschaften löschen? Werte der Charaktere gehen verloren.')}";

  static String m38(number) => "Gruppe ${number}";

  static String m39(name) => " (für Kategorie ${name})";

  static String m40(count) =>
      "${Intl.plural(count, zero: 'An diesem Fundort gibt es noch keine Items.', one: 'An diesem Fundort kann ein Item gefunden werden.', other: 'An diesem Fundort können ${count} Items gefunden werden.')}";

  static String m41(number) => "Fundort #${number}";

  static String m42(name) => "Eigenschaft „${name}“ gelöscht";

  static String m43(number) => "Zutat #${number}";

  static String m44(number) => "Voraussetzung #${number}";

  static String m45(count) =>
      "${Intl.plural(count, zero: 'Keine Items', one: '1 Item', other: '${count} Items')}";

  static String m46(count) =>
      "${Intl.plural(count, one: '1 Eigenschaft', other: '${count} Eigenschaften')}";

  static String m47(count) =>
      "${Intl.plural(count, zero: 'Keine Rezepte', one: '1 Rezept', other: '${count} Rezepte')}";

  static String m48(count) =>
      "${Intl.plural(count, one: '1 Tab', other: '${count} Tabs')}";

  static String m49(tabs) => "Bogen mit den Reitern ${tabs}";

  static String m50(count) =>
      "${Intl.plural(count, one: '1 Item', other: '${count} Items')}";

  static String m51(count) =>
      "${Intl.plural(count, one: '1 Eigenschaft', other: '${count} Eigenschaften')}";

  static String m52(count) =>
      "${Intl.plural(count, one: '1 Rezept', other: '${count} Rezepte')}";

  static String m53(count) =>
      "${Intl.plural(count, zero: 'Du leitest noch keine Kampagne.', one: 'Du leitest 1 Kampagne.', other: 'Du leitest ${count} Kampagnen.')}";

  static String m54(count) =>
      "${Intl.plural(count, zero: 'Du hast noch keinen Charakter.', one: 'Du hast 1 Charakter.', other: 'Du hast ${count} Charaktere.')}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "aboutLicensesAttributionEnglish": MessageLookupByLibrary.simpleMessage(
      "Namensnennung (englisches Original)",
    ),
    "aboutLicensesAttributionGerman": MessageLookupByLibrary.simpleMessage(
      "Namensnennung (deutsche Fassung)",
    ),
    "aboutLicensesAuthoritativeHint": MessageLookupByLibrary.simpleMessage(
      "Die deutsche Fassung dient nur der Information. Maßgeblich ist die englische Fassung.",
    ),
    "aboutLicensesChanges": MessageLookupByLibrary.simpleMessage(
      "Änderungen: Material aus dem SRD 5.2.1 wurde ausgewählt, übersetzt oder aus der deutschen Fassung übernommen, gekürzt und an QuestKeeper angepasst. Kurzbeschreibungen und weitere Texte der Vorlage sind eigene Texte.",
    ),
    "aboutLicensesNotAffiliated": MessageLookupByLibrary.simpleMessage(
      "QuestKeeper ist ein unabhängiges Produkt und wird von keinem Rollenspielverlag herausgegeben oder unterstützt.",
    ),
    "aboutLicensesOpenLicense": MessageLookupByLibrary.simpleMessage(
      "Lizenz CC BY 4.0 öffnen",
    ),
    "aboutLicensesOpenSourceTitle": MessageLookupByLibrary.simpleMessage(
      "Open-Source-Lizenzen",
    ),
    "aboutLicensesSettingsSubtitle": MessageLookupByLibrary.simpleMessage(
      "Regelmaterial, Lizenzen und Open-Source-Hinweise",
    ),
    "aboutLicensesShowOpenSource": MessageLookupByLibrary.simpleMessage(
      "Alle Lizenzen anzeigen",
    ),
    "aboutLicensesSrdIntro": MessageLookupByLibrary.simpleMessage(
      "Die Vorlage „Fantasy 5E (SRD)“ enthält Material aus dem System Reference Document 5.2.1. Es steht unter der Lizenz Creative Commons Namensnennung 4.0 International (CC BY 4.0).",
    ),
    "aboutLicensesSrdTitle": MessageLookupByLibrary.simpleMessage(
      "Regelmaterial: SRD 5.2.1",
    ),
    "aboutLicensesTitle": MessageLookupByLibrary.simpleMessage(
      "Info & Lizenzen",
    ),
    "activeAlternateFormBannerTitle": MessageLookupByLibrary.simpleMessage(
      "Verwandelte Gestalt",
    ),
    "add": MessageLookupByLibrary.simpleMessage("Hinzufügen"),
    "addAdditionalEnemy": MessageLookupByLibrary.simpleMessage(
      "Neue Gegner hinzufügen",
    ),
    "addAnAdditionalEnemyBtnLabel": MessageLookupByLibrary.simpleMessage(
      "Weiterer Gegner",
    ),
    "addBalance": MessageLookupByLibrary.simpleMessage("Guthaben hinzufügen"),
    "addCharacterToCampagneModalTitle": MessageLookupByLibrary.simpleMessage(
      "Kampagne beitreten",
    ),
    "addComputedTerm": MessageLookupByLibrary.simpleMessage(
      "Baustein hinzufügen",
    ),
    "addImageBtnLabel": MessageLookupByLibrary.simpleMessage("Bild"),
    "addItems": MessageLookupByLibrary.simpleMessage("Items hinzufügen"),
    "addNewTransformationComponent": MessageLookupByLibrary.simpleMessage(
      "Verwandlung hinzufügen",
    ),
    "addParagraphBtnLabel": MessageLookupByLibrary.simpleMessage("Absatz"),
    "additionalElement": MessageLookupByLibrary.simpleMessage("Neues Element"),
    "additionalFightParticipants": MessageLookupByLibrary.simpleMessage(
      "Weitere Teilnehmer",
    ),
    "additionalSettings": MessageLookupByLibrary.simpleMessage(
      "Erweiterte Optionen",
    ),
    "allCardsHidden": MessageLookupByLibrary.simpleMessage(
      "Alle Karten sind ausgeblendet",
    ),
    "allPlayers": MessageLookupByLibrary.simpleMessage("Alle Spieler:"),
    "amount": MessageLookupByLibrary.simpleMessage("Anzahl"),
    "amountHeaderLabel": MessageLookupByLibrary.simpleMessage("Anzahl:"),
    "amountToCraftFieldLabel": MessageLookupByLibrary.simpleMessage("Anzahl"),
    "apiKeyCopied": MessageLookupByLibrary.simpleMessage(
      "In die Zwischenablage kopiert",
    ),
    "apiKeyCopy": MessageLookupByLibrary.simpleMessage("Kopieren"),
    "apiKeyCreateConfirm": MessageLookupByLibrary.simpleMessage("Erstellen"),
    "apiKeyCreateFailed": MessageLookupByLibrary.simpleMessage(
      "Der API-Schlüssel konnte nicht erstellt werden.",
    ),
    "apiKeyCreateHint": MessageLookupByLibrary.simpleMessage(
      "Gib Schlüssel nur an Apps, denen du vertraust. Sie handeln in deinem Namen.",
    ),
    "apiKeyCreateTitle": MessageLookupByLibrary.simpleMessage(
      "Neuer API-Schlüssel",
    ),
    "apiKeyCreatedBody": MessageLookupByLibrary.simpleMessage(
      "Kopiere den neuen Schlüssel jetzt. Er wird dir nicht noch einmal angezeigt.",
    ),
    "apiKeyCreatedTitle": MessageLookupByLibrary.simpleMessage(
      "API-Schlüssel erstellt",
    ),
    "apiKeyDone": MessageLookupByLibrary.simpleMessage("Fertig"),
    "apiKeyExpired": MessageLookupByLibrary.simpleMessage("Abgelaufen"),
    "apiKeyExpiresAt": m0,
    "apiKeyExpiry1Year": MessageLookupByLibrary.simpleMessage("1 Jahr"),
    "apiKeyExpiry30Days": MessageLookupByLibrary.simpleMessage("30 Tage"),
    "apiKeyExpiry90Days": MessageLookupByLibrary.simpleMessage("90 Tage"),
    "apiKeyExpiryLabel": MessageLookupByLibrary.simpleMessage("Gültig für"),
    "apiKeyExpiryNever": MessageLookupByLibrary.simpleMessage("Unbegrenzt"),
    "apiKeyLastUsedAt": m1,
    "apiKeyNameLabel": MessageLookupByLibrary.simpleMessage(
      "Name, z. B. die App, die ihn nutzt",
    ),
    "apiKeyNameRequired": MessageLookupByLibrary.simpleMessage(
      "Gib einen Namen ein.",
    ),
    "apiKeyNeverExpires": MessageLookupByLibrary.simpleMessage("Läuft nie ab"),
    "apiKeyNeverUsed": MessageLookupByLibrary.simpleMessage("Noch nie benutzt"),
    "apiKeyNoScopeSelected": MessageLookupByLibrary.simpleMessage(
      "Wähle mindestens ein Recht aus.",
    ),
    "apiKeyPermissionsLabel": MessageLookupByLibrary.simpleMessage("Rechte"),
    "apiKeyPermissionsNeedServerUpdate": MessageLookupByLibrary.simpleMessage(
      "Dieser Server gibt jedem Schlüssel Lesezugriff auf deine Kampagnen, Charaktere und Notizen. Rechte und Laufzeit kannst du wählen, sobald der Server aktualisiert ist.",
    ),
    "apiKeyPrefix": m2,
    "apiKeyPresetCompanion": MessageLookupByLibrary.simpleMessage(
      "Begleit-App für Spieler",
    ),
    "apiKeyPresetCustom": MessageLookupByLibrary.simpleMessage(
      "Benutzerdefiniert",
    ),
    "apiKeyPresetReadOnly": MessageLookupByLibrary.simpleMessage("Nur lesen"),
    "apiKeyRevokeBody": MessageLookupByLibrary.simpleMessage(
      "Das lässt sich nicht rückgängig machen. Jede App, die diesen Schlüssel nutzt, verliert sofort den Zugriff.",
    ),
    "apiKeyRevokeConfirm": MessageLookupByLibrary.simpleMessage("Widerrufen"),
    "apiKeyRevokeFailed": MessageLookupByLibrary.simpleMessage(
      "Der API-Schlüssel konnte nicht widerrufen werden.",
    ),
    "apiKeyRevokeTitle": MessageLookupByLibrary.simpleMessage(
      "API-Schlüssel widerrufen?",
    ),
    "apiKeyRevoked": MessageLookupByLibrary.simpleMessage("Widerrufen"),
    "apiKeyRevokedAt": m3,
    "apiKeyScopeCampaignsRead": MessageLookupByLibrary.simpleMessage(
      "Deine Kampagnen und Mitspieler sehen",
    ),
    "apiKeyScopeCharactersRead": MessageLookupByLibrary.simpleMessage(
      "Deine Charakterbögen lesen",
    ),
    "apiKeyScopeCharactersWrite": MessageLookupByLibrary.simpleMessage(
      "Deine Charakterbögen ändern, z. B. Lebenspunkte",
    ),
    "apiKeyScopeEvents": MessageLookupByLibrary.simpleMessage(
      "Live-Updates empfangen",
    ),
    "apiKeyScopeFightsPlay": MessageLookupByLibrary.simpleMessage(
      "Initiative würfeln, wenn die Spielleitung einen Kampf startet",
    ),
    "apiKeyScopeNotesRead": MessageLookupByLibrary.simpleMessage(
      "Die Notizen lesen, die du sehen darfst",
    ),
    "apiKeyScopeNotesWrite": MessageLookupByLibrary.simpleMessage(
      "Eigene Notizen schreiben und festlegen, wer sie sieht",
    ),
    "apiKeyUnnamed": MessageLookupByLibrary.simpleMessage(
      "Unbenannter Schlüssel",
    ),
    "apiKeysDocsDescription": MessageLookupByLibrary.simpleMessage(
      "Mit API-Schlüsseln kann eine andere App, etwa eine Begleit-App aus deiner Gruppe, für dich als Spieler handeln. Jeder Schlüssel darf nur, was du ihm erlaubst.",
    ),
    "apiKeysDocsTitle": MessageLookupByLibrary.simpleMessage(
      "API-Dokumentation",
    ),
    "apiKeysEmpty": MessageLookupByLibrary.simpleMessage(
      "Noch keine API-Schlüssel.",
    ),
    "apiKeysGenerate": MessageLookupByLibrary.simpleMessage(
      "Neuen API-Schlüssel erstellen",
    ),
    "apiKeysLoadFailed": MessageLookupByLibrary.simpleMessage(
      "Deine API-Schlüssel konnten nicht geladen werden.",
    ),
    "apiKeysSettingsSubtitle": MessageLookupByLibrary.simpleMessage(
      "Deine persönlichen API-Schlüssel verwalten",
    ),
    "apiKeysTitle": MessageLookupByLibrary.simpleMessage("API-Schlüssel"),
    "apiKeysViewDocs": MessageLookupByLibrary.simpleMessage(
      "API-Dokumentation öffnen",
    ),
    "appName": MessageLookupByLibrary.simpleMessage("QuestKeeper"),
    "assignCharacterToCampagneModalContent":
        MessageLookupByLibrary.simpleMessage(
          "Dein Charakter ist noch keiner Kampagne zugeordnet. Gib den Beitrittscode ein, den du von deiner Spielleitung bekommen hast. Sie bestätigt dann deine Anfrage.",
        ),
    "attachImageBtnLabel": MessageLookupByLibrary.simpleMessage(
      "Bild hinzufügen",
    ),
    "authNoConnection": MessageLookupByLibrary.simpleMessage(
      "Der Server ist gerade nicht erreichbar. Versuch es gleich noch einmal.",
    ),
    "authorLabel": MessageLookupByLibrary.simpleMessage("Autor:"),
    "automaticCardStatsHint": MessageLookupByLibrary.simpleMessage(
      "Automatisch: der erste Wert mit Maximum als Balken und die ersten Zahlen aus dem Standard-Tab.",
    ),
    "back": MessageLookupByLibrary.simpleMessage("Zurück"),
    "buildingBlocksAdd": MessageLookupByLibrary.simpleMessage("Hinzufügen"),
    "buildingBlocksAddCount": m4,
    "buildingBlocksAlreadyOnSheet": MessageLookupByLibrary.simpleMessage(
      "Schon im Bogen",
    ),
    "buildingBlocksCardDescription": MessageLookupByLibrary.simpleMessage(
      "Eigenschaften aus den Vorlagen übernehmen, z. B. Attribute, Rettungswürfe, Zauberplätze, Aspekte oder Stress.",
    ),
    "buildingBlocksHint": MessageLookupByLibrary.simpleMessage(
      "Hake an, was du übernehmen willst. Die Eigenschaften landen in diesem Reiter, und du kannst sie danach anpassen.",
    ),
    "buildingBlocksTabLabel": m5,
    "buildingBlocksTitle": MessageLookupByLibrary.simpleMessage(
      "Fertige Bausteine",
    ),
    "calculatedValue": MessageLookupByLibrary.simpleMessage("Berechneter Wert"),
    "calculatedValuePlaceholder": MessageLookupByLibrary.simpleMessage(
      "Der berechnete Wert",
    ),
    "calculatedValueShort": MessageLookupByLibrary.simpleMessage("ber."),
    "campagneSettingsChangedAt": m6,
    "campaignManagement": MessageLookupByLibrary.simpleMessage(
      "Kampagnenverwaltung",
    ),
    "campaignName": MessageLookupByLibrary.simpleMessage("Kampagnenname"),
    "campaigneName": MessageLookupByLibrary.simpleMessage("Name"),
    "cancel": MessageLookupByLibrary.simpleMessage("Abbrechen"),
    "cardBar": MessageLookupByLibrary.simpleMessage("Balken"),
    "cardNumbers": MessageLookupByLibrary.simpleMessage("Zahlen"),
    "cardStatsSection": MessageLookupByLibrary.simpleMessage(
      "Eigenschaften auf den Karten",
    ),
    "character": MessageLookupByLibrary.simpleMessage("Charakter:"),
    "characterConfigSaveFailedBody": MessageLookupByLibrary.simpleMessage(
      "Deine Änderungen am Charakter konnten nicht gespeichert werden. Prüfe deine Verbindung und versuche es erneut.",
    ),
    "characterConfigSaveFailedTitle": MessageLookupByLibrary.simpleMessage(
      "Charakter nicht gespeichert",
    ),
    "characterLastEditedAt": m7,
    "characterName": MessageLookupByLibrary.simpleMessage("Name"),
    "characterNameDefault": MessageLookupByLibrary.simpleMessage("Spielername"),
    "characterNameFieldLabel": MessageLookupByLibrary.simpleMessage(
      "Name deines Charakters",
    ),
    "characterNameLabel": MessageLookupByLibrary.simpleMessage("Name:"),
    "characterNameRequired": MessageLookupByLibrary.simpleMessage(
      "Bitte gib einen Namen ein.",
    ),
    "characterNameStatHelperText": MessageLookupByLibrary.simpleMessage(
      "Wie heißt dein Charakter?",
    ),
    "characterNameStatTitle": MessageLookupByLibrary.simpleMessage(
      "Charaktername",
    ),
    "characterNameWithLevelAndConfigurableDetails":
        MessageLookupByLibrary.simpleMessage(
          "Charakter-Grundwerte (Level, Name und weitere, optionale Angaben)",
        ),
    "characterNotInCampagneHint": MessageLookupByLibrary.simpleMessage(
      "Noch in keiner Kampagne. Tippe, um mit einem Code beizutreten.",
    ),
    "characterOverview": MessageLookupByLibrary.simpleMessage(
      "Charakterübersicht",
    ),
    "characterPortraitImagePrompt": MessageLookupByLibrary.simpleMessage(
      "Porträtbeschreibung",
    ),
    "characterPortraitImagePromptPlaceholder":
        MessageLookupByLibrary.simpleMessage(
          "Beschreibe deinen Charakter für die Bildgenerierung",
        ),
    "characterSetupFinish": MessageLookupByLibrary.simpleMessage("Fertig"),
    "characterSetupHint": MessageLookupByLibrary.simpleMessage(
      "Was du jetzt leer lässt, kannst du später direkt im Charakterbogen ausfüllen.",
    ),
    "characterSetupProgress": m8,
    "characterSetupTitle": MessageLookupByLibrary.simpleMessage(
      "Charakter einrichten",
    ),
    "characterSheetAppearanceTitle": MessageLookupByLibrary.simpleMessage(
      "Darstellung",
    ),
    "characterSheetSkinArcaneLedger": MessageLookupByLibrary.simpleMessage(
      "Arkaner Foliant",
    ),
    "characterSheetSkinCampaignDefaultLabel":
        MessageLookupByLibrary.simpleMessage("Kampagnen-Standard"),
    "characterSheetSkinClassicDark": MessageLookupByLibrary.simpleMessage(
      "Klassisch Dunkel",
    ),
    "characterSheetSkinClassicLight": MessageLookupByLibrary.simpleMessage(
      "Klassisch Hell",
    ),
    "characterSheetSkinNightCartographer": MessageLookupByLibrary.simpleMessage(
      "Nachtkartograph",
    ),
    "characterSheetSkinUseCampaignDefault":
        MessageLookupByLibrary.simpleMessage("Kampagnen-Standard verwenden"),
    "checkboxTrackBoxCountLabel": MessageLookupByLibrary.simpleMessage(
      "Anzahl",
    ),
    "checkboxTrackBoxLabel": m9,
    "checkboxTrackBoxesHeadline": MessageLookupByLibrary.simpleMessage(
      "Kästchen",
    ),
    "checkboxTrackLabelsHint": MessageLookupByLibrary.simpleMessage(
      "Beschriftungen sind optional, z. B. „1“, „2“, „3“ oder „Leicht“.",
    ),
    "checkboxTrackTapHint": MessageLookupByLibrary.simpleMessage(
      "Tippe ein Kästchen an, um es anzukreuzen oder freizugeben.",
    ),
    "chooseACampagne": MessageLookupByLibrary.simpleMessage(
      "Kampagne auswählen",
    ),
    "chooseACharacter": MessageLookupByLibrary.simpleMessage(
      "Charakter auswählen",
    ),
    "chooseCardStatsYourself": MessageLookupByLibrary.simpleMessage(
      "Eigenschaften selbst wählen",
    ),
    "closeAction": MessageLookupByLibrary.simpleMessage("Schließen"),
    "companion": MessageLookupByLibrary.simpleMessage("Begleiter"),
    "companionOverview": MessageLookupByLibrary.simpleMessage(
      "Begleiterübersicht",
    ),
    "companionSelectorIconHeadline": MessageLookupByLibrary.simpleMessage(
      "Icon",
    ),
    "companionSelectorIconHint": MessageLookupByLibrary.simpleMessage(
      "Wird auf dem Charakterbogen über diesen Begleitern angezeigt, z. B. ein Schiff für Fahrzeuge.",
    ),
    "completeRegistration": MessageLookupByLibrary.simpleMessage(
      "Registrierung abschließen",
    ),
    "computedAlways": MessageLookupByLibrary.simpleMessage("Immer"),
    "computedBase": MessageLookupByLibrary.simpleMessage("Startwert"),
    "computedCondition": MessageLookupByLibrary.simpleMessage(
      "Zählt nur, wenn gewählt",
    ),
    "computedFactor": MessageLookupByLibrary.simpleMessage("Faktor"),
    "computedIfPicked": m10,
    "computedMode": MessageLookupByLibrary.simpleMessage("Umrechnung"),
    "computedModeModifier": MessageLookupByLibrary.simpleMessage(
      "Modifikator (x−10)/2",
    ),
    "computedModeValue": MessageLookupByLibrary.simpleMessage("wie er ist"),
    "computedModifierOf": m11,
    "computedPreset": MessageLookupByLibrary.simpleMessage(
      "Vorlage (Fantasy 5E)",
    ),
    "computedPresetIncomplete": MessageLookupByLibrary.simpleMessage(
      "Nicht alle Werte der Vorlage gibt es in dieser Kampagne. Ergänze die fehlenden Bausteine selbst.",
    ),
    "computedPresetInitiative": MessageLookupByLibrary.simpleMessage(
      "Initiative",
    ),
    "computedPresetPassiveInsight": MessageLookupByLibrary.simpleMessage(
      "Passives Motiv erkennen",
    ),
    "computedPresetPassiveInvestigation": MessageLookupByLibrary.simpleMessage(
      "Passive Nachforschungen",
    ),
    "computedPresetPassivePerception": MessageLookupByLibrary.simpleMessage(
      "Passive Wahrnehmung",
    ),
    "computedPresetPassiveStealth": MessageLookupByLibrary.simpleMessage(
      "Passive Heimlichkeit",
    ),
    "computedPresetUnarmoredArmorClass": MessageLookupByLibrary.simpleMessage(
      "RK ohne Rüstung",
    ),
    "computedPreview": MessageLookupByLibrary.simpleMessage("Formel"),
    "computedSource": MessageLookupByLibrary.simpleMessage("Wert"),
    "computedTerms": MessageLookupByLibrary.simpleMessage("Bausteine"),
    "computedValue": MessageLookupByLibrary.simpleMessage("Wert berechnen"),
    "computedValueBadge": MessageLookupByLibrary.simpleMessage("berechnet"),
    "computedValueHint": MessageLookupByLibrary.simpleMessage(
      "Spieler tragen diesen Wert nicht ein: Er wird aus anderen Eigenschaften berechnet, z. B. passive Wahrnehmung = 10 + Mod(Weisheit) + Übungsbonus (wenn geübt). Modifikatoren werden abgerundet.",
    ),
    "computedValueNoSources": MessageLookupByLibrary.simpleMessage(
      "Lege zuerst Eigenschaften mit Zahlen an.",
    ),
    "configureProperties": MessageLookupByLibrary.simpleMessage(
      "Eigenschaften konfigurieren",
    ),
    "configurePropertiesForCharacterNameSuffix": m12,
    "confirmDeleteBtnLabel": MessageLookupByLibrary.simpleMessage("Löschen"),
    "connectionLostReconnecting": MessageLookupByLibrary.simpleMessage(
      "Verbindung unterbrochen – verbinde neu …",
    ),
    "copiedConfirmation": MessageLookupByLibrary.simpleMessage("Kopiert"),
    "copyCodeAction": MessageLookupByLibrary.simpleMessage("Code kopieren"),
    "count": MessageLookupByLibrary.simpleMessage("Anzahl"),
    "craft": MessageLookupByLibrary.simpleMessage("Herstellen"),
    "craftableAmountText": MessageLookupByLibrary.simpleMessage("Herstellbar:"),
    "craftableRecipeFilter": MessageLookupByLibrary.simpleMessage(
      "Herstellbar",
    ),
    "createAction": MessageLookupByLibrary.simpleMessage("Anlegen"),
    "createCampagneAction": MessageLookupByLibrary.simpleMessage(
      "Kampagne anlegen",
    ),
    "createNewAccount": MessageLookupByLibrary.simpleMessage(
      "Neues Konto anlegen",
    ),
    "createNewTransformationTitle": MessageLookupByLibrary.simpleMessage(
      "Neue Verwandlung erstellen",
    ),
    "createTransformationHelperText": MessageLookupByLibrary.simpleMessage(
      "Wähle die Eigenschaften aus, die sich durch diese Verwandlung ändern. Alle anderen bleiben, wie sie sind.",
    ),
    "currentBalance": MessageLookupByLibrary.simpleMessage(
      "Aktuelles Guthaben",
    ),
    "currentFightOrdering": MessageLookupByLibrary.simpleMessage(
      "Aktuelle Kampfreihenfolge",
    ),
    "currentValue": MessageLookupByLibrary.simpleMessage("Aktueller Wert"),
    "currentValuePlaceholder": MessageLookupByLibrary.simpleMessage(
      "Der aktuelle Wert für diese Eigenschaft",
    ),
    "customizeCards": MessageLookupByLibrary.simpleMessage("Karten anpassen"),
    "defaultGroupNameForDocuments": MessageLookupByLibrary.simpleMessage(
      "Sonstiges",
    ),
    "defaultTab": MessageLookupByLibrary.simpleMessage("Start-Tab"),
    "descriptionOfProperty": MessageLookupByLibrary.simpleMessage(
      "Hilfstext für die Eigenschaft",
    ),
    "diceChallengeAbbr": MessageLookupByLibrary.simpleMessage("SG"),
    "diceRoll": MessageLookupByLibrary.simpleMessage("Wurf"),
    "dm": MessageLookupByLibrary.simpleMessage("Spielleitung"),
    "documentDefaultNamePrefix": MessageLookupByLibrary.simpleMessage(
      "Dokument",
    ),
    "documentGroupLabel": MessageLookupByLibrary.simpleMessage("Gruppenname"),
    "documentTitleLabel": MessageLookupByLibrary.simpleMessage("Titel"),
    "editPageModalText": MessageLookupByLibrary.simpleMessage(
      "Hier änderst du den Titel und die Gruppe deiner Seite.",
    ),
    "editPageTitle": MessageLookupByLibrary.simpleMessage("Seite bearbeiten"),
    "email": MessageLookupByLibrary.simpleMessage("E-Mail"),
    "endFight": MessageLookupByLibrary.simpleMessage("Kampf beenden"),
    "endFightConfirmation": MessageLookupByLibrary.simpleMessage(
      "Kampf wirklich beenden? Wer noch nicht gewürfelt hat, wird dann nicht mehr gefragt.",
    ),
    "enemy": MessageLookupByLibrary.simpleMessage("Gegner"),
    "enemyName": MessageLookupByLibrary.simpleMessage("Gegnername"),
    "enterANameDefaultLabel": MessageLookupByLibrary.simpleMessage(
      "Gib einen Namen ein",
    ),
    "enterCodeAgainAction": MessageLookupByLibrary.simpleMessage(
      "Code neu eingeben",
    ),
    "enterSomeDescriptionOnTheLeft": MessageLookupByLibrary.simpleMessage(
      "Gib links eine Beschreibung ein.",
    ),
    "errorDetailsDescriptionLabel": MessageLookupByLibrary.simpleMessage(
      "Beschreibung:",
    ),
    "errorDetailsServerLabel": MessageLookupByLibrary.simpleMessage(
      "Server-Antwort:",
    ),
    "errorDetailsStatusLabel": MessageLookupByLibrary.simpleMessage(
      "HTTP-Status:",
    ),
    "errorMessageBadRequest": MessageLookupByLibrary.simpleMessage(
      "Der Server konnte die Eingabe nicht verarbeiten. Prüfe deine Angaben und versuche es noch einmal.",
    ),
    "errorMessageConflict": MessageLookupByLibrary.simpleMessage(
      "Das wurde gerade an anderer Stelle geändert. Lade neu und versuche es noch einmal.",
    ),
    "errorMessageNoConnection": MessageLookupByLibrary.simpleMessage(
      "Die Verbindung zum Server hat nicht geklappt. Prüfe deine Internetverbindung und versuche es noch einmal.",
    ),
    "errorMessageNotFound": MessageLookupByLibrary.simpleMessage(
      "Das gesuchte Element gibt es nicht (mehr).",
    ),
    "errorMessageServer": MessageLookupByLibrary.simpleMessage(
      "Auf dem Server ist ein Fehler aufgetreten. Versuche es später noch einmal.",
    ),
    "errorMessageUnauthorized": MessageLookupByLibrary.simpleMessage(
      "Dafür fehlt dir die Berechtigung. Melde dich gegebenenfalls neu an.",
    ),
    "errorMessageUnknown": MessageLookupByLibrary.simpleMessage(
      "Etwas ist schiefgelaufen. Versuche es noch einmal.",
    ),
    "fightInitiativeStepTitle": MessageLookupByLibrary.simpleMessage(
      "Kampf / Initiative",
    ),
    "fightInitiativeStepTutorial": MessageLookupByLibrary.simpleMessage(
      "Markiere, welcher Wert der Initiative-Bonus ist.\n\nWenn ein Spieler die Initiative würfeln soll, zeigt die App ihm diesen Bonus an. So muss er ihn nicht im Kopf haben, während das Wurffenster den Charakterbogen verdeckt.\n\nWähle **Keine**, falls dein System keinen Bonus verwendet. Sonst wähle unten einen Wert aus. Ist es eine Gruppe von Werten (z. B. Fähigkeiten), wähle zusätzlich den passenden Eintrag. Besteht der Wert aus zwei Zahlen (z. B. Wert und Modifikator oder aktuell und maximal), wähle, welche davon als Bonus zählt.",
    ),
    "fightingOrdering": MessageLookupByLibrary.simpleMessage(
      "Kampfreihenfolge",
    ),
    "fillInLater": MessageLookupByLibrary.simpleMessage("Später ausfüllen"),
    "firstValue": MessageLookupByLibrary.simpleMessage("Erster Wert"),
    "firstValuePlaceholder": MessageLookupByLibrary.simpleMessage(
      "Der erste Wert",
    ),
    "fixMarkedFieldsHint": MessageLookupByLibrary.simpleMessage(
      "Bitte korrigiere die markierten Felder.",
    ),
    "followingItemsArePossibleAtPlaceOfFinding":
        MessageLookupByLibrary.simpleMessage("Diese Items gibt es hier:"),
    "forCompanionSelector": MessageLookupByLibrary.simpleMessage(
      "für Begleiter",
    ),
    "forIntegerValueWithName": MessageLookupByLibrary.simpleMessage(
      "für Zahlenwert",
    ),
    "forgotPasswordBackToLogin": MessageLookupByLibrary.simpleMessage(
      "Zur Anmeldung",
    ),
    "forgotPasswordCodeSent": m13,
    "forgotPasswordLink": MessageLookupByLibrary.simpleMessage(
      "Passwort vergessen?",
    ),
    "forgotPasswordRequestButton": MessageLookupByLibrary.simpleMessage(
      "Code anfordern",
    ),
    "forgotPasswordRequestFailed": MessageLookupByLibrary.simpleMessage(
      "Wir konnten keinen Code schicken. Prüfe Nutzername und E-Mail-Adresse. Wenn du dich mit Apple anmeldest, brauchst du kein Passwort.",
    ),
    "forgotPasswordRequestIntro": MessageLookupByLibrary.simpleMessage(
      "Gib deinen Nutzernamen und die E-Mail-Adresse deines Kontos ein. Wir schicken dir einen Code.",
    ),
    "forgotPasswordRequestNewCode": MessageLookupByLibrary.simpleMessage(
      "Neuen Code anfordern",
    ),
    "forgotPasswordResetFailed": MessageLookupByLibrary.simpleMessage(
      "Das hat nicht geklappt: Der Code stimmt nicht oder ist abgelaufen. Fordere bei Bedarf einen neuen an.",
    ),
    "forgotPasswordSaveButton": MessageLookupByLibrary.simpleMessage(
      "Passwort speichern",
    ),
    "forgotPasswordSuccess": MessageLookupByLibrary.simpleMessage(
      "Dein Passwort ist geändert. Melde dich jetzt mit dem neuen Passwort an.",
    ),
    "forgotPasswordTitle": MessageLookupByLibrary.simpleMessage(
      "Passwort zurücksetzen",
    ),
    "generateImageBtnLabel": MessageLookupByLibrary.simpleMessage(
      "Bild generieren",
    ),
    "generateImageDescriptionHint": MessageLookupByLibrary.simpleMessage(
      "Beschreibe das Bild, das du generieren möchtest. Je genauer die Beschreibung, desto besser passt das Bild.",
    ),
    "generateImagePromptExample": MessageLookupByLibrary.simpleMessage(
      "z. B. „Ein mystischer Wald mit Elfen“",
    ),
    "generateImagePromptLabel": MessageLookupByLibrary.simpleMessage(
      "Bildbeschreibung",
    ),
    "generateLoreImageTitle": MessageLookupByLibrary.simpleMessage(
      "Bild generieren",
    ),
    "generatedImage": MessageLookupByLibrary.simpleMessage("Generiertes Bild"),
    "generatedImagesTabTitle": MessageLookupByLibrary.simpleMessage(
      "Generierte Bilder",
    ),
    "genericErrorModalHeader": MessageLookupByLibrary.simpleMessage(
      "Das hat nicht geklappt",
    ),
    "genericErrorModalTechnicalDetailsErrorCodeRowLabel":
        MessageLookupByLibrary.simpleMessage("Fehlercode:"),
    "genericErrorModalTechnicalDetailsExceptionRowLabel":
        MessageLookupByLibrary.simpleMessage("Fehlertext:"),
    "genericErrorModalTechnicalDetailsHeader":
        MessageLookupByLibrary.simpleMessage("Technische Details"),
    "grantItems": MessageLookupByLibrary.simpleMessage("Items verteilen"),
    "grantItemsFailedForPlayers": m14,
    "helperTextForNameOfCampaign": MessageLookupByLibrary.simpleMessage(
      "Wie soll die Kampagne heißen?",
    ),
    "hiddenCards": MessageLookupByLibrary.simpleMessage("Ausgeblendet"),
    "hideHeading": MessageLookupByLibrary.simpleMessage(
      "Überschrift ausblenden",
    ),
    "hidePropertyForCharacter": MessageLookupByLibrary.simpleMessage(
      "Eigenschaft für meinen Charakter ausblenden",
    ),
    "hourMinutesDayMonthYearFormatString": MessageLookupByLibrary.simpleMessage(
      "%H:%M %d.%m.%Y",
    ),
    "initiativeBonusFieldPickerLabel": MessageLookupByLibrary.simpleMessage(
      "Feld",
    ),
    "initiativeBonusHelperSentence": m15,
    "initiativeBonusIncompleteLeave": MessageLookupByLibrary.simpleMessage(
      "Trotzdem verlassen",
    ),
    "initiativeBonusIncompleteStay": MessageLookupByLibrary.simpleMessage(
      "Bleiben",
    ),
    "initiativeBonusIncompleteWarningBody":
        MessageLookupByLibrary.simpleMessage(
          "Deine Auswahl für den Initiative-Bonus ist unvollständig. Wenn du die Seite verlässt, wird sie gelöscht.",
        ),
    "initiativeBonusIncompleteWarningTitle":
        MessageLookupByLibrary.simpleMessage("Unvollständige Auswahl"),
    "initiativeBonusListEntryPickerLabel": MessageLookupByLibrary.simpleMessage(
      "Listeneintrag",
    ),
    "initiativeBonusNoneOption": MessageLookupByLibrary.simpleMessage("Keine"),
    "initiativeBonusStatPickerLabel": MessageLookupByLibrary.simpleMessage(
      "Eigenschaft",
    ),
    "initiativeRollForCharacterPrefix": MessageLookupByLibrary.simpleMessage(
      "Initiativewurf",
    ),
    "initiativeRollText": MessageLookupByLibrary.simpleMessage(
      "Ein Kampf beginnt. Würfle deine Initiative!",
    ),
    "initiativeRollTextFieldLabel": MessageLookupByLibrary.simpleMessage(
      "Dein Wurf",
    ),
    "insertParagraphMenuLabel": MessageLookupByLibrary.simpleMessage(
      "Absatz hier einfügen",
    ),
    "integerValue": MessageLookupByLibrary.simpleMessage("Zahlenwert"),
    "integerValueWithCalculatedValue": MessageLookupByLibrary.simpleMessage(
      "Zahlenwert mit zusätzlicher Zahl",
    ),
    "integerValueWithMaxValue": MessageLookupByLibrary.simpleMessage(
      "Zahlenwert mit Maximalwert",
    ),
    "invalidCurrencyMultiple": MessageLookupByLibrary.simpleMessage(
      "Gib eine ganze Zahl größer als 1 ein, z. B. 10.",
    ),
    "invalidImageFileSelected": MessageLookupByLibrary.simpleMessage(
      "Die gewählte Datei ist kein Bild.",
    ),
    "invalidLevelInput": MessageLookupByLibrary.simpleMessage(
      "Das Level muss eine ganze Zahl ab 0 sein, z. B. 3.",
    ),
    "invalidNonNegativeNumberShort": MessageLookupByLibrary.simpleMessage(
      "Zahl ab 0 eingeben",
    ),
    "invalidPositiveNumberShort": MessageLookupByLibrary.simpleMessage(
      "Zahl ab 1 eingeben",
    ),
    "invalidWholeNumberInput": MessageLookupByLibrary.simpleMessage(
      "Bitte gib eine ganze Zahl ein, z. B. -1 oder 3.",
    ),
    "invalidWholeNumberShort": MessageLookupByLibrary.simpleMessage(
      "Ganze Zahl eingeben",
    ),
    "invitePlayersAction": MessageLookupByLibrary.simpleMessage(
      "Spieler einladen",
    ),
    "invitePlayersApprovalHint": MessageLookupByLibrary.simpleMessage(
      "Die Anfragen erscheinen danach unter „Beitrittsanfragen“. Mit ✓ nimmst du jemanden auf.",
    ),
    "invitePlayersInstruction": MessageLookupByLibrary.simpleMessage(
      "In QuestKeeper auf „Kampagne beitreten“ tippen und diesen Code eingeben.",
    ),
    "inviteShareSubject": m16,
    "inviteShareText": m17,
    "item": MessageLookupByLibrary.simpleMessage("Item"),
    "itemCardDescRequires": MessageLookupByLibrary.simpleMessage("Braucht:"),
    "itemCategoryFilterAll": MessageLookupByLibrary.simpleMessage("Alles"),
    "itemDetailsDescriptionHeader": MessageLookupByLibrary.simpleMessage(
      "Beschreibung:",
    ),
    "itemDetailsForPrefix": MessageLookupByLibrary.simpleMessage(
      "Item-Details für",
    ),
    "itemDetailsPriceHeader": MessageLookupByLibrary.simpleMessage("Preis:"),
    "itemExampleDescription": MessageLookupByLibrary.simpleMessage(
      "Beschreibung eines Items",
    ),
    "itemSortByName": MessageLookupByLibrary.simpleMessage(
      "Nach Name sortieren (A–Z)",
    ),
    "itemSortByValueAscending": MessageLookupByLibrary.simpleMessage(
      "Nach Wert sortieren (aufsteigend)",
    ),
    "itemSortByValueDescending": MessageLookupByLibrary.simpleMessage(
      "Nach Wert sortieren (absteigend)",
    ),
    "itemsToBeFoundInPlaceMarkdown": MessageLookupByLibrary.simpleMessage(
      "## Items an diesem Fundort",
    ),
    "joinAction": MessageLookupByLibrary.simpleMessage("Beitreten"),
    "joinAsPlayer": MessageLookupByLibrary.simpleMessage("Als Spieler"),
    "joinCampagneAction": MessageLookupByLibrary.simpleMessage(
      "Kampagne beitreten",
    ),
    "joinCampagneNewCharacterIntro": MessageLookupByLibrary.simpleMessage(
      "Gib den Beitrittscode ein, den du von deiner Spielleitung bekommen hast, und wie dein Charakter heißen soll. Den Rest des Charakterbogens füllst du aus, sobald die Spielleitung dich aufgenommen hat.",
    ),
    "joinCode": MessageLookupByLibrary.simpleMessage("Beitrittscode"),
    "joinCodeEmptyError": MessageLookupByLibrary.simpleMessage(
      "Bitte gib den Beitrittscode ein.",
    ),
    "joinCodeForNewPlayers": m18,
    "joinCodeIncompleteError": MessageLookupByLibrary.simpleMessage(
      "Der Code hat sechs Ziffern, zum Beispiel 123-456.",
    ),
    "joinCodeUnknownError": MessageLookupByLibrary.simpleMessage(
      "Diesen Code gibt es nicht. Prüfe ihn mit deiner Spielleitung.",
    ),
    "joinRequestAcceptedMessage": MessageLookupByLibrary.simpleMessage(
      "Deine Beitrittsanfrage wurde angenommen. Du kannst jetzt mitspielen.",
    ),
    "joinRequestCreatedForDm": m19,
    "joinRequestDeniedMessage": MessageLookupByLibrary.simpleMessage(
      "Deine Beitrittsanfrage wurde abgelehnt.",
    ),
    "joinRequestSentConfirmation": MessageLookupByLibrary.simpleMessage(
      "Anfrage gesendet. Sobald deine Spielleitung zustimmt, kannst du mitspielen.",
    ),
    "kindOfProperty": MessageLookupByLibrary.simpleMessage(
      "Art der Eigenschaft",
    ),
    "lastGrantedItems": MessageLookupByLibrary.simpleMessage(
      "Letzte verteilte Items",
    ),
    "lastGrantedItemsMarkdownPrefix": MessageLookupByLibrary.simpleMessage(
      "Zuletzt wurden diese Items verteilt:",
    ),
    "ledgerManuscriptDateFormat": MessageLookupByLibrary.simpleMessage(
      "d. MMMM y, HH:mm",
    ),
    "level": MessageLookupByLibrary.simpleMessage("Level"),
    "levelAbbr": MessageLookupByLibrary.simpleMessage("LVL"),
    "listOfIntegersWithIcons": MessageLookupByLibrary.simpleMessage(
      "Liste von Zahlenwerten mit Icons",
    ),
    "listOfInterValuesWithCalculatedIntegerValues":
        MessageLookupByLibrary.simpleMessage(
          "Gruppe von Zahlenwerten mit zusätzlicher Zahl",
        ),
    "login": MessageLookupByLibrary.simpleMessage("Anmelden"),
    "loginIntroJoin": MessageLookupByLibrary.simpleMessage(
      "Melde dich an oder lege ein Konto an. Danach gibst du den Code deiner Spielleitung ein.",
    ),
    "loginIntroLead": MessageLookupByLibrary.simpleMessage(
      "Melde dich an oder lege ein Konto an. Danach legst du deine Kampagne an.",
    ),
    "loginMissingInput": MessageLookupByLibrary.simpleMessage(
      "Bitte gib Nutzername und Passwort ein.",
    ),
    "loginWrongCredentials": MessageLookupByLibrary.simpleMessage(
      "Nutzername oder Passwort stimmt nicht.",
    ),
    "logout": MessageLookupByLibrary.simpleMessage("Abmelden"),
    "lore": MessageLookupByLibrary.simpleMessage("Notizen"),
    "maxValue": MessageLookupByLibrary.simpleMessage("Maximaler Wert"),
    "maxValuePlaceholder": MessageLookupByLibrary.simpleMessage(
      "Der maximale Wert für diese Eigenschaft",
    ),
    "maxValueShort": MessageLookupByLibrary.simpleMessage("Max."),
    "missingStatTapToFill": MessageLookupByLibrary.simpleMessage(
      "Noch leer – tippen zum Ausfüllen",
    ),
    "missingStatUnnamed": MessageLookupByLibrary.simpleMessage(
      "Unbenannte Eigenschaft",
    ),
    "moneyModeDeposit": MessageLookupByLibrary.simpleMessage("+ Einzahlen"),
    "moneyModeSpend": MessageLookupByLibrary.simpleMessage("− Ausgeben"),
    "moreValues": MessageLookupByLibrary.simpleMessage("Weitere Werte"),
    "multilineText": MessageLookupByLibrary.simpleMessage("Mehrzeiliger Text"),
    "multiselectOption": MessageLookupByLibrary.simpleMessage(
      "Mehrfachauswahl",
    ),
    "multiselectOptionDescription": MessageLookupByLibrary.simpleMessage(
      "Beschreibung:",
    ),
    "multiselectOptionName": MessageLookupByLibrary.simpleMessage("Name:"),
    "multiselectOptionSummary": MessageLookupByLibrary.simpleMessage(
      "Kurzfassung:",
    ),
    "multiselectOptionSummaryHelper": MessageLookupByLibrary.simpleMessage(
      "Optional, ca. 90 Zeichen; erscheint auf dem Charakterbogen. Der volle Text bleibt in der Beschreibung.",
    ),
    "multiselectOptionsAreSelectableMultipleTimes":
        MessageLookupByLibrary.simpleMessage(
          "Optionen können mehrmals ausgewählt werden",
        ),
    "myNotesGroupName": MessageLookupByLibrary.simpleMessage("Meine Notizen"),
    "nameOfCharacterHelperText": MessageLookupByLibrary.simpleMessage(
      "Wie heißt dein Charakter?",
    ),
    "nameOfPropertyLabel": MessageLookupByLibrary.simpleMessage(
      "Name der Eigenschaft",
    ),
    "nameRequiredError": MessageLookupByLibrary.simpleMessage(
      "Bitte gib einen Namen ein",
    ),
    "navBarHeaderCrafting": MessageLookupByLibrary.simpleMessage("Herstellen"),
    "navBarHeaderInventory": MessageLookupByLibrary.simpleMessage("Inventar"),
    "navBarHeaderLore": MessageLookupByLibrary.simpleMessage("Notizen"),
    "navBarHeaderMoney": MessageLookupByLibrary.simpleMessage("Währung"),
    "newBalance": MessageLookupByLibrary.simpleMessage("Neues Guthaben"),
    "newCampagneIntro": MessageLookupByLibrary.simpleMessage(
      "Wie soll deine Kampagne heißen? Danach wählst du eine Vorlage, und der Assistent führt dich durch Charakterbogen, Währung und Gegenstände.",
    ),
    "newCampaign": MessageLookupByLibrary.simpleMessage("Neue Kampagne"),
    "newFightOrdering": MessageLookupByLibrary.simpleMessage(
      "Neue Kampfreihenfolge",
    ),
    "newGroup": MessageLookupByLibrary.simpleMessage("Neue Gruppe:"),
    "newGroupBtnLabel": MessageLookupByLibrary.simpleMessage("Neue Gruppe"),
    "newImageBtnLabel": MessageLookupByLibrary.simpleMessage("Neues Bild"),
    "newItem": MessageLookupByLibrary.simpleMessage("Neu"),
    "newItemsMarkdownPlural": MessageLookupByLibrary.simpleMessage(
      "# Neue Items",
    ),
    "newItemsMarkdownSingular": MessageLookupByLibrary.simpleMessage(
      "# Neues Item",
    ),
    "newPasswordLabel": MessageLookupByLibrary.simpleMessage("Neues Passwort"),
    "newPetBtnLabel": MessageLookupByLibrary.simpleMessage("Neuer Begleiter"),
    "newPropertyBtnLabel": MessageLookupByLibrary.simpleMessage(
      "Neue Eigenschaft",
    ),
    "newTabBtnLabel": MessageLookupByLibrary.simpleMessage("Neuer Tab"),
    "newTransformationDeletesOldText": MessageLookupByLibrary.simpleMessage(
      "Wenn du eine neue Verwandlung erstellst, werden alle alten gelöscht.",
    ),
    "newTransformationDeletesOldTitle": MessageLookupByLibrary.simpleMessage(
      "Alte Verwandlungen werden gelöscht",
    ),
    "newTransformationSelectionBtn": MessageLookupByLibrary.simpleMessage(
      "Neue Gestalt",
    ),
    "next": MessageLookupByLibrary.simpleMessage("Weiter"),
    "no": MessageLookupByLibrary.simpleMessage("Nein"),
    "noBar": MessageLookupByLibrary.simpleMessage("Kein Balken"),
    "noCampagnesYetHint": MessageLookupByLibrary.simpleMessage(
      "Leg eine Kampagne an, richte den Charakterbogen ein und lade deine Gruppe mit einem Code ein.",
    ),
    "noCardStatsAvailable": MessageLookupByLibrary.simpleMessage(
      "Diese Kampagne hat noch keine Eigenschaften mit Zahlen.",
    ),
    "noCharactersInCampagne": MessageLookupByLibrary.simpleMessage(
      "Noch keine Charaktere in dieser Kampagne",
    ),
    "noCharactersYetHint": MessageLookupByLibrary.simpleMessage(
      "Tritt mit dem Code deiner Spielleitung einer Kampagne bei. Deinen Charakter legst du dabei an.",
    ),
    "noFIghtStarted": MessageLookupByLibrary.simpleMessage(
      "Gerade läuft kein Kampf",
    ),
    "noImagesInCampagne": MessageLookupByLibrary.simpleMessage(
      "Du hast in dieser Kampagne noch keine Bilder generiert.",
    ),
    "noItemsGranted": MessageLookupByLibrary.simpleMessage(
      "Noch keine Items verteilt.",
    ),
    "noItemsGrantedToPlayerThisRound": MessageLookupByLibrary.simpleMessage(
      "Keine Items in dieser Runde",
    ),
    "noItemsInCategory": MessageLookupByLibrary.simpleMessage(
      "Keine Items unter dieser Kategorie",
    ),
    "noItemsInCategoryCraftable": MessageLookupByLibrary.simpleMessage(
      "In dieser Kategorie sind keine Items herstellbar",
    ),
    "noItemsInCategoryErrorText": MessageLookupByLibrary.simpleMessage(
      "Keine Items unter dieser Kategorie",
    ),
    "noItemsInCategoryNotCraftable": MessageLookupByLibrary.simpleMessage(
      "In dieser Kategorie sind alle Items herstellbar",
    ),
    "noMoneyDefaultText": MessageLookupByLibrary.simpleMessage("0 Gold"),
    "noOpenJoinRequests": MessageLookupByLibrary.simpleMessage(
      "Keine offenen Anfragen",
    ),
    "noPlaceOfFindingSelected": MessageLookupByLibrary.simpleMessage(
      "Es wurde noch kein Fundort ausgewählt.",
    ),
    "noPlayersOnline": MessageLookupByLibrary.simpleMessage(
      "Gerade ist kein Spieler online",
    ),
    "noPlayersYetHint": MessageLookupByLibrary.simpleMessage(
      "Noch keine Spieler dabei. Lade deine Gruppe über „Spieler einladen“ ein.",
    ),
    "noTransformationComponentsHint": MessageLookupByLibrary.simpleMessage(
      "Es gibt noch keine Verwandlungen. Lege sie zuerst in den Einstellungen deines Charakters an.",
    ),
    "notAtTheTable": MessageLookupByLibrary.simpleMessage("nicht am Tisch"),
    "notCraftableRecipeFilter": MessageLookupByLibrary.simpleMessage(
      "Nicht herstellbar",
    ),
    "notEnoughBalance": MessageLookupByLibrary.simpleMessage(
      "Zu wenig Geld für diese Ausgabe",
    ),
    "noteBlockTextLabel": MessageLookupByLibrary.simpleMessage("Text"),
    "noteblockVisibleFor": MessageLookupByLibrary.simpleMessage(
      "Sichtbar für:",
    ),
    "nothingSelected": MessageLookupByLibrary.simpleMessage(
      "- Nichts ausgewählt -",
    ),
    "offline": MessageLookupByLibrary.simpleMessage("Offline"),
    "ok": MessageLookupByLibrary.simpleMessage("OK"),
    "online": MessageLookupByLibrary.simpleMessage("Online"),
    "openJoinRequests": MessageLookupByLibrary.simpleMessage(
      "Beitrittsanfragen",
    ),
    "openJoinRequestsBadge": m20,
    "optionalPropertyForAlternateForms": MessageLookupByLibrary.simpleMessage(
      "Optionale Eigenschaft für andere Formen",
    ),
    "optionalPropertyForCompanions": MessageLookupByLibrary.simpleMessage(
      "Optionale Eigenschaft für Begleiter",
    ),
    "optionsForMultiselect": MessageLookupByLibrary.simpleMessage(
      "Optionen für die Mehrfachauswahl",
    ),
    "otherValue": MessageLookupByLibrary.simpleMessage("Anderer Wert"),
    "otherValuePlaceholder": MessageLookupByLibrary.simpleMessage(
      "Der andere Wert",
    ),
    "othersNotesGroupName": MessageLookupByLibrary.simpleMessage(
      "Notizen der Spieler",
    ),
    "ownedIngredientCountPrefix": MessageLookupByLibrary.simpleMessage(
      "im Besitz:",
    ),
    "pageTabShortCampaign": MessageLookupByLibrary.simpleMessage("Kampagne"),
    "pageTabShortCharacters": MessageLookupByLibrary.simpleMessage(
      "Charaktere",
    ),
    "pageTabShortFight": MessageLookupByLibrary.simpleMessage("Kampf"),
    "pageTabShortImages": MessageLookupByLibrary.simpleMessage("Bilder"),
    "pageTabShortItems": MessageLookupByLibrary.simpleMessage("Items"),
    "pageTabShortNotes": MessageLookupByLibrary.simpleMessage("Notizen"),
    "password": MessageLookupByLibrary.simpleMessage("Passwort"),
    "passwordRuleMaxLength": m21,
    "passwordRuleMet": MessageLookupByLibrary.simpleMessage("erfüllt"),
    "passwordRuleMinLength": m22,
    "passwordRuleNotMet": MessageLookupByLibrary.simpleMessage(
      "noch nicht erfüllt",
    ),
    "passwordRulesTitle": MessageLookupByLibrary.simpleMessage(
      "Dein Passwort braucht",
    ),
    "pathJoinAGameSubtitle": MessageLookupByLibrary.simpleMessage(
      "Mit dem Code deiner Spielleitung",
    ),
    "pathJoinAGameTitle": MessageLookupByLibrary.simpleMessage(
      "Ich trete einer Runde bei",
    ),
    "pathRunAGameSubtitle": MessageLookupByLibrary.simpleMessage(
      "Kampagne anlegen und Spieler einladen",
    ),
    "pathRunAGameTitle": MessageLookupByLibrary.simpleMessage(
      "Ich leite eine Runde",
    ),
    "pendingHubSyncBanner": MessageLookupByLibrary.simpleMessage(
      "Einige Änderungen werden noch mit der Sitzung synchronisiert…",
    ),
    "petDefaultNamePrefix": MessageLookupByLibrary.simpleMessage("Begleiter"),
    "placeOfFinding": MessageLookupByLibrary.simpleMessage("Fundort"),
    "player": MessageLookupByLibrary.simpleMessage("Spieler"),
    "playerPreviewButton": MessageLookupByLibrary.simpleMessage(
      "So sieht es der Spieler",
    ),
    "playerPreviewHint": MessageLookupByLibrary.simpleMessage(
      "Eine Beispielfigur mit Standardwerten. Hier wird nichts gespeichert.",
    ),
    "playerPreviewPhone": MessageLookupByLibrary.simpleMessage("Handy"),
    "playerPreviewSampleCharacterName": MessageLookupByLibrary.simpleMessage(
      "Beispielfigur",
    ),
    "playerPreviewTablet": MessageLookupByLibrary.simpleMessage("Tablet"),
    "playerPreviewTitle": MessageLookupByLibrary.simpleMessage(
      "Spieleransicht",
    ),
    "playerRolls": MessageLookupByLibrary.simpleMessage("Würfe der Spieler"),
    "preview": MessageLookupByLibrary.simpleMessage("Vorschau"),
    "previewAndVariantTileTitle": MessageLookupByLibrary.simpleMessage(
      "Vorschau und Darstellung",
    ),
    "previewTestHint": MessageLookupByLibrary.simpleMessage(
      "Probiere die Steuerung aus — Änderungen hier werden nicht gespeichert.",
    ),
    "previewTestReset": MessageLookupByLibrary.simpleMessage("Zurücksetzen"),
    "previousTransformationSelectionBtn": MessageLookupByLibrary.simpleMessage(
      "Alte Gestalt",
    ),
    "privacyPolicyLinkLabel": MessageLookupByLibrary.simpleMessage(
      "Datenschutzerklärung",
    ),
    "propertyEditTypeLabel": MessageLookupByLibrary.simpleMessage(
      "Änderungshäufigkeit",
    ),
    "propertyEditTypeOneTap": MessageLookupByLibrary.simpleMessage(
      "Häufig geändert (z. B. jede Sitzung)",
    ),
    "propertyEditTypeStatic": MessageLookupByLibrary.simpleMessage(
      "Selten geändert (z. B. beim Levelaufstieg)",
    ),
    "propertyIsCopied": MessageLookupByLibrary.simpleMessage(
      "Eigenschaft wurde kopiert",
    ),
    "propertyNameLabel": MessageLookupByLibrary.simpleMessage("Name:"),
    "propertyPreviewHint": MessageLookupByLibrary.simpleMessage(
      "So sieht die Eigenschaft auf dem Bogen aus, mit Beispielwerten.",
    ),
    "propertyPreviewNeedsEntries": MessageLookupByLibrary.simpleMessage(
      "Füge oben Einträge hinzu, dann erscheint hier die Vorschau.",
    ),
    "propertyPurposeAbilitiesDescription": MessageLookupByLibrary.simpleMessage(
      "Mehrere Werte mit Bonus, die sich selten ändern. Z. B. Stärke, Geschick, Weisheit.",
    ),
    "propertyPurposeAbilitiesTitle": MessageLookupByLibrary.simpleMessage(
      "Attribute",
    ),
    "propertyPurposeAdvancedDescription": MessageLookupByLibrary.simpleMessage(
      "Wähle den Feldtyp selbst aus der vollständigen Liste.",
    ),
    "propertyPurposeAdvancedTitle": MessageLookupByLibrary.simpleMessage(
      "Alle Feldtypen",
    ),
    "propertyPurposeChangeType": MessageLookupByLibrary.simpleMessage(
      "Feldtyp und Änderungshäufigkeit",
    ),
    "propertyPurposeChecklistDescription": MessageLookupByLibrary.simpleMessage(
      "Mehrere Optionen aus einer Liste ankreuzen. Z. B. Fertigkeiten, Rettungswürfe, Sprachen.",
    ),
    "propertyPurposeChecklistTitle": MessageLookupByLibrary.simpleMessage(
      "Mehrfachauswahl",
    ),
    "propertyPurposeCompanionsDescription":
        MessageLookupByLibrary.simpleMessage(
          "Begleiter mit eigenem Bogen. Z. B. Haustier, Vertrauter, Reittier.",
        ),
    "propertyPurposeCompanionsTitle": MessageLookupByLibrary.simpleMessage(
      "Begleiter",
    ),
    "propertyPurposeCounterDescription": MessageLookupByLibrary.simpleMessage(
      "Eine einzelne Zahl, die sich im Spiel ändert. Z. B. Erzählpunkte, Inspiration, Glück.",
    ),
    "propertyPurposeCounterTitle": MessageLookupByLibrary.simpleMessage(
      "Zähler",
    ),
    "propertyPurposeEntriesDescription": MessageLookupByLibrary.simpleMessage(
      "Kurze Einträge, feste oder eigene der Spieler. Z. B. Aspekte, Ziele, Kontakte.",
    ),
    "propertyPurposeEntriesTitle": MessageLookupByLibrary.simpleMessage(
      "Liste von Einträgen",
    ),
    "propertyPurposeImageDescription": MessageLookupByLibrary.simpleMessage(
      "Ein Bild mit Beschreibung. Z. B. Porträt, Wappen.",
    ),
    "propertyPurposeImageTitle": MessageLookupByLibrary.simpleMessage("Bild"),
    "propertyPurposeKeyNumbersDescription": MessageLookupByLibrary.simpleMessage(
      "Mehrere Zahlen mit Symbol. Z. B. Rüstungsklasse, Bewegung, Initiative.",
    ),
    "propertyPurposeKeyNumbersTitle": MessageLookupByLibrary.simpleMessage(
      "Kennzahlen",
    ),
    "propertyPurposeLongTextDescription": MessageLookupByLibrary.simpleMessage(
      "Mehrere Absätze. Z. B. Hintergrund, Persönlichkeit, Ausrüstung.",
    ),
    "propertyPurposeLongTextTitle": MessageLookupByLibrary.simpleMessage(
      "Längerer Text",
    ),
    "propertyPurposePickOneDescription": MessageLookupByLibrary.simpleMessage(
      "Genau eine Option aus einer Liste. Z. B. Klasse, Gesinnung, Herkunft.",
    ),
    "propertyPurposePickOneTitle": MessageLookupByLibrary.simpleMessage(
      "Eine Option wählen",
    ),
    "propertyPurposePickerHint": MessageLookupByLibrary.simpleMessage(
      "Wähle, wofür die Eigenschaft da ist. Feldtyp und Darstellung kannst du danach noch ändern.",
    ),
    "propertyPurposePickerQuestion": MessageLookupByLibrary.simpleMessage(
      "Was willst du erfassen?",
    ),
    "propertyPurposeResourceDescription": MessageLookupByLibrary.simpleMessage(
      "Ein Wert mit Maximum, den Spieler im Spiel mit + und − ändern. Z. B. Trefferpunkte, Mana, Munition.",
    ),
    "propertyPurposeResourceTitle": MessageLookupByLibrary.simpleMessage(
      "Lebenspunkte & Vorräte",
    ),
    "propertyPurposeShortTextDescription": MessageLookupByLibrary.simpleMessage(
      "Eine Zeile. Z. B. Gottheit, Titel, Heimatort.",
    ),
    "propertyPurposeShortTextTitle": MessageLookupByLibrary.simpleMessage(
      "Kurzer Text",
    ),
    "propertyPurposeTickBoxesDescription": MessageLookupByLibrary.simpleMessage(
      "Kästchen, die Spieler mit einem Tipp ankreuzen. Z. B. Stress, Erschöpfung, Todesrettungswürfe.",
    ),
    "propertyPurposeTickBoxesTitle": MessageLookupByLibrary.simpleMessage(
      "Leiste zum Ankreuzen",
    ),
    "propertyPurposeTransformationDescription":
        MessageLookupByLibrary.simpleMessage(
          "Ein Knopf, mit dem sich der Charakter in eine andere Gestalt verwandelt. Z. B. Tiergestalt.",
        ),
    "propertyPurposeTransformationTitle": MessageLookupByLibrary.simpleMessage(
      "Verwandlung",
    ),
    "propertyPurposeValueWithBonusDescription":
        MessageLookupByLibrary.simpleMessage(
          "Eine Zahl mit einer zweiten Zahl daneben. Z. B. ein Attribut mit Modifikator.",
        ),
    "propertyPurposeValueWithBonusTitle": MessageLookupByLibrary.simpleMessage(
      "Wert mit Bonus",
    ),
    "qrCodeHint": MessageLookupByLibrary.simpleMessage(
      "Der QR-Code enthält nur den Code.",
    ),
    "questKeeperIntro": MessageLookupByLibrary.simpleMessage(
      "QuestKeeper begleitet eure Pen-&-Paper-Runde am Tisch. Die Spielleitung richtet die Kampagne ein, alle anderen führen ihren Charakterbogen in der App. Trefferpunkte, Gegenstände und geteilte Notizen sind dabei für alle live aktuell.",
    ),
    "reactivateTransformationQuestion": MessageLookupByLibrary.simpleMessage(
      "Möchtest du deine letzte Verwandlung wieder aufnehmen oder eine neue Gestalt annehmen?",
    ),
    "reactivateTransformationTitle": MessageLookupByLibrary.simpleMessage(
      "Alte Verwandlung reaktivieren",
    ),
    "realtimeSessionIosHint": MessageLookupByLibrary.simpleMessage(
      "Auf dem iPad oder iPhone funktionieren Live-Updates am zuverlässigsten, wenn die App im Vordergrund geöffnet ist.",
    ),
    "receivedItemsModalHeader": MessageLookupByLibrary.simpleMessage(
      "Neue Items",
    ),
    "receivedOneNewItemText": MessageLookupByLibrary.simpleMessage(
      "Du hast ein neues Item erhalten:",
    ),
    "receivedXNewItems": m23,
    "recipeForTitlePrefix": MessageLookupByLibrary.simpleMessage("Rezept für"),
    "recipeIngredients": MessageLookupByLibrary.simpleMessage("Zutaten:"),
    "recipeRequirements": MessageLookupByLibrary.simpleMessage(
      "Voraussetzungen:",
    ),
    "reduceBalance": MessageLookupByLibrary.simpleMessage("Guthaben abziehen"),
    "register": MessageLookupByLibrary.simpleMessage("Registrieren"),
    "registerEmailInvalid": MessageLookupByLibrary.simpleMessage(
      "Bitte gib eine gültige E-Mail-Adresse ein.",
    ),
    "registerPasswordInvalid": MessageLookupByLibrary.simpleMessage(
      "Das Passwort erfüllt noch nicht alle Regeln.",
    ),
    "registerPrivacyNotice": m24,
    "registerPrivacyNoticeWithoutLink": MessageLookupByLibrary.simpleMessage(
      "Deine E-Mail-Adresse brauchen wir nur für dein Konto, zum Beispiel zum Zurücksetzen des Passworts.",
    ),
    "registerUsernameInvalid": MessageLookupByLibrary.simpleMessage(
      "Der Nutzername braucht 3 bis 13 Zeichen, nur Buchstaben und Ziffern.",
    ),
    "registerUsernameTaken": MessageLookupByLibrary.simpleMessage(
      "Diesen Nutzernamen gibt es schon. Bitte wähle einen anderen.",
    ),
    "removeImageBtnLabel": MessageLookupByLibrary.simpleMessage(
      "Bild entfernen",
    ),
    "replaceImageBtnLabel": MessageLookupByLibrary.simpleMessage(
      "Bild ersetzen",
    ),
    "requiredIngredientCountPrefix": MessageLookupByLibrary.simpleMessage(
      "Benötigt:",
    ),
    "resetCodeHint": MessageLookupByLibrary.simpleMessage("z. B. 123-456"),
    "resetCodeInvalid": MessageLookupByLibrary.simpleMessage(
      "Der Code hat sechs Ziffern, z. B. 123-456.",
    ),
    "resetCodeLabel": MessageLookupByLibrary.simpleMessage(
      "Code aus der E-Mail",
    ),
    "rollForInitiative": MessageLookupByLibrary.simpleMessage(
      "Kampfreihenfolge würfeln",
    ),
    "rollForInitiativeBtnLabel": MessageLookupByLibrary.simpleMessage(
      "Kampfreihenfolge würfeln",
    ),
    "rollOfInititive": MessageLookupByLibrary.simpleMessage("Initiativewurf"),
    "rpgConfigurationDmWizardStep2Tutorial":
        MessageLookupByLibrary.simpleMessage(
          "Nun kommen wir zu den Charakterbögen.\n\nJedes Rollenspiel hat unterschiedliche Eigenschaften, die die Spieler charakterisieren (z.B. wie viele Lebenspunkte ein Spieler hat).\n\nFür jede Eigenschaft musst du, als Spielleitung, definieren, wie die Spieler mit dieser Eigenschaft interagieren können. Hierbei benötigen wir für jede Eigenschaft drei Informationen von dir:\n\n1. Name der Eigenschaft: Wie soll dieser Wert auf dem Charakterbogen heißen? (z.B. „HP“, „SP“, „Name“, etc.)\n2. Werteart der Eigenschaft: Handelt es sich z.B. um einen Text, den der Spieler anpassen kann (z.B. Hintergrundgeschichte des Charakters) oder um einen Zahlenwert (z.B. die Lebenspunkte)?\n3. Änderungsart: Manche dieser Eigenschaften werden regelmäßig angepasst (z.B. die aktuellen Lebenspunkte), andere hingegen nur selten (z.B. die maximalen Lebenspunkte). Damit dies bei der Erstellung der Charakterbögen berücksichtigt werden kann, musst du uns diese Information mitteilen.\n\nEigenschaften ordnest du in Tabs und Gruppen. Halte eine Eigenschaft gedrückt, um sie zu verschieben.",
        ),
    "save": MessageLookupByLibrary.simpleMessage("Speichern"),
    "searchLabel": MessageLookupByLibrary.simpleMessage("Suche"),
    "secondValue": MessageLookupByLibrary.simpleMessage("Zweiter Wert"),
    "secondValuePlaceholder": MessageLookupByLibrary.simpleMessage(
      "Der zweite Wert",
    ),
    "select": MessageLookupByLibrary.simpleMessage("Auswählen"),
    "selectAColor": MessageLookupByLibrary.simpleMessage("Farbe auswählen:"),
    "selectAnIcon": MessageLookupByLibrary.simpleMessage("Icon auswählen:"),
    "selectGameMode": MessageLookupByLibrary.simpleMessage("Rolle auswählen"),
    "selectIconModalTitle": MessageLookupByLibrary.simpleMessage(
      "Icon auswählen",
    ),
    "selectTransformationComponentsHint": MessageLookupByLibrary.simpleMessage(
      "Wähle die Verwandlungen aus, aus denen deine neue Gestalt bestehen soll.",
    ),
    "selectTransformationTitle": MessageLookupByLibrary.simpleMessage(
      "Verwandlung auswählen",
    ),
    "send": MessageLookupByLibrary.simpleMessage("Absenden"),
    "sendItems": MessageLookupByLibrary.simpleMessage("Items verschicken"),
    "sessionExpiredMessage": MessageLookupByLibrary.simpleMessage(
      "Deine Sitzung ist abgelaufen. Bitte melde dich erneut an.",
    ),
    "settingsTitle": MessageLookupByLibrary.simpleMessage("Einstellungen"),
    "shareInviteAction": MessageLookupByLibrary.simpleMessage(
      "Einladung teilen",
    ),
    "showLevelHint": MessageLookupByLibrary.simpleMessage(
      "Aus: Das Charakterformular fragt kein Level ab und der Bogen zeigt keins.",
    ),
    "showLevelToggle": MessageLookupByLibrary.simpleMessage("Level anzeigen"),
    "signInWithApple": MessageLookupByLibrary.simpleMessage(
      "Mit Apple anmelden",
    ),
    "signInWithGoogle": MessageLookupByLibrary.simpleMessage(
      "Mit Google anmelden",
    ),
    "singleLineText": MessageLookupByLibrary.simpleMessage("Einzeiliger Text"),
    "singleSelectNothingChosen": MessageLookupByLibrary.simpleMessage(
      "Noch nichts gewählt",
    ),
    "singleSelectOptionsHeadline": MessageLookupByLibrary.simpleMessage(
      "Optionen",
    ),
    "startAsDm": MessageLookupByLibrary.simpleMessage("Als Spielleitung"),
    "statStyleActiveFormBanner": MessageLookupByLibrary.simpleMessage(
      "Banner der aktiven Form",
    ),
    "statStyleAllOptions": MessageLookupByLibrary.simpleMessage(
      "Alle Optionen",
    ),
    "statStyleBanner": MessageLookupByLibrary.simpleMessage("Banner"),
    "statStyleBoxes": MessageLookupByLibrary.simpleMessage("Kästchen"),
    "statStyleChips": MessageLookupByLibrary.simpleMessage("Chips"),
    "statStyleChosenOption": MessageLookupByLibrary.simpleMessage(
      "Nur die Wahl",
    ),
    "statStyleClassicBlock": MessageLookupByLibrary.simpleMessage(
      "Klassischer Block",
    ),
    "statStyleClassicBlocks": MessageLookupByLibrary.simpleMessage(
      "Klassische Blöcke",
    ),
    "statStyleCollapsible": MessageLookupByLibrary.simpleMessage("Aufklappbar"),
    "statStyleCombatChip": MessageLookupByLibrary.simpleMessage("Kompakt"),
    "statStyleCrystals": MessageLookupByLibrary.simpleMessage("Kristalle"),
    "statStyleHearts": MessageLookupByLibrary.simpleMessage("Herzen"),
    "statStyleIconAndValue": MessageLookupByLibrary.simpleMessage(
      "Symbol und Wert",
    ),
    "statStyleImage": MessageLookupByLibrary.simpleMessage("Bild"),
    "statStyleLargeNumber": MessageLookupByLibrary.simpleMessage("Große Zahl"),
    "statStyleLevelCircle": MessageLookupByLibrary.simpleMessage("Level-Kreis"),
    "statStyleList": MessageLookupByLibrary.simpleMessage("Liste"),
    "statStyleMainValueLarge": MessageLookupByLibrary.simpleMessage(
      "Erster Wert groß",
    ),
    "statStyleMedallions": MessageLookupByLibrary.simpleMessage("Medaillons"),
    "statStyleModifierFirst": MessageLookupByLibrary.simpleMessage(
      "Modifikator vorn",
    ),
    "statStyleModifierTiles": MessageLookupByLibrary.simpleMessage(
      "Kacheln, Modifikator vorn",
    ),
    "statStyleNext": MessageLookupByLibrary.simpleMessage("Nächster Stil"),
    "statStyleNumberAndMax": MessageLookupByLibrary.simpleMessage(
      "Zahl und Maximum",
    ),
    "statStyleNumberOverName": MessageLookupByLibrary.simpleMessage(
      "Zahl über Name",
    ),
    "statStyleParchment": MessageLookupByLibrary.simpleMessage("Pergament"),
    "statStylePawAndButtons": MessageLookupByLibrary.simpleMessage(
      "Pfote und Knöpfe",
    ),
    "statStylePentagon": MessageLookupByLibrary.simpleMessage("Fünfeck"),
    "statStylePentagons": MessageLookupByLibrary.simpleMessage("Fünfecke"),
    "statStylePips": MessageLookupByLibrary.simpleMessage("Punkte"),
    "statStylePortraitCard": MessageLookupByLibrary.simpleMessage(
      "Porträtkarte",
    ),
    "statStylePosition": m25,
    "statStylePrevious": MessageLookupByLibrary.simpleMessage(
      "Vorheriger Stil",
    ),
    "statStyleRibbon": MessageLookupByLibrary.simpleMessage("Band"),
    "statStyleRing": MessageLookupByLibrary.simpleMessage("Ring"),
    "statStyleRingHealthColors": MessageLookupByLibrary.simpleMessage(
      "Ring in Lebensfarben",
    ),
    "statStyleSegmentedBar": MessageLookupByLibrary.simpleMessage(
      "Balken in Abschnitten",
    ),
    "statStyleSelectedOnly": MessageLookupByLibrary.simpleMessage(
      "Nur die gewählten",
    ),
    "statStyleShields": MessageLookupByLibrary.simpleMessage("Wappenschilde"),
    "statStyleSingleLine": MessageLookupByLibrary.simpleMessage("Eine Zeile"),
    "statStyleSmallCards": MessageLookupByLibrary.simpleMessage(
      "Kleine Karten",
    ),
    "statStyleStacked": MessageLookupByLibrary.simpleMessage("Übereinander"),
    "statStyleSummary": MessageLookupByLibrary.simpleMessage("Zusammenfassung"),
    "statStyleText": MessageLookupByLibrary.simpleMessage("Text"),
    "statStyleTiles": MessageLookupByLibrary.simpleMessage("Kacheln"),
    "statStyleValueOverLabel": MessageLookupByLibrary.simpleMessage(
      "Wert über Name",
    ),
    "statStyleWand": MessageLookupByLibrary.simpleMessage("Zauberstab"),
    "statTypeCheckboxTrack": MessageLookupByLibrary.simpleMessage(
      "Kästchenleiste",
    ),
    "statTypeCheckboxTrackHelp": MessageLookupByLibrary.simpleMessage(
      "Eine Reihe Kästchen, die Spieler mit einem Tipp auf dem Bogen ankreuzen, z. B. Stress.",
    ),
    "statTypeSingleSelect": MessageLookupByLibrary.simpleMessage(
      "Auswahl (eine)",
    ),
    "statTypeSingleSelectHelp": MessageLookupByLibrary.simpleMessage(
      "Spieler wählen genau eine der Optionen, z. B. Herkunft oder Gesinnung.",
    ),
    "statTypeTextList": MessageLookupByLibrary.simpleMessage("Textliste"),
    "statTypeTextListHelp": MessageLookupByLibrary.simpleMessage(
      "Mehrere Texteinträge, optional mit festen, beschrifteten Plätzen, z. B. Aspekte oder Konsequenzen.",
    ),
    "statTypeUnsupported": MessageLookupByLibrary.simpleMessage(
      "Unbekannter Typ",
    ),
    "statTypeUnsupportedHint": MessageLookupByLibrary.simpleMessage(
      "Wird von dieser Version nicht unterstützt. Bitte aktualisiere die App.",
    ),
    "tabIconsConfigurationTitle": MessageLookupByLibrary.simpleMessage(
      "Tab-Icons",
    ),
    "templateUpdateAdded": m26,
    "templateUpdateApply": MessageLookupByLibrary.simpleMessage("Übernehmen"),
    "templateUpdateApplyCount": m27,
    "templateUpdateBannerText": m28,
    "templateUpdateBannerTitle": m29,
    "templateUpdateDismiss": MessageLookupByLibrary.simpleMessage("Ausblenden"),
    "templateUpdateEntriesRevised": MessageLookupByLibrary.simpleMessage(
      "Einträge überarbeitet",
    ),
    "templateUpdateHint": MessageLookupByLibrary.simpleMessage(
      "Hake an, was du übernehmen willst. Die Werte der Charaktere bleiben erhalten, ebenso deine eigenen Eigenschaften und eigene Einträge in Listen.",
    ),
    "templateUpdateNewEntries": m30,
    "templateUpdateNewHelperText": MessageLookupByLibrary.simpleMessage(
      "Neuer Hilfetext",
    ),
    "templateUpdateNewName": m31,
    "templateUpdateOtherSettings": MessageLookupByLibrary.simpleMessage(
      "Weitere Einstellungen",
    ),
    "templateUpdateReview": MessageLookupByLibrary.simpleMessage("Ansehen"),
    "templateUpdateTitle": MessageLookupByLibrary.simpleMessage(
      "Vorlage aktualisieren",
    ),
    "textListAddEntry": MessageLookupByLibrary.simpleMessage(
      "Eintrag hinzufügen",
    ),
    "textListAllowCustomEntries": MessageLookupByLibrary.simpleMessage(
      "Spieler dürfen eigene Einträge hinzufügen und löschen",
    ),
    "textListDeleteEntry": MessageLookupByLibrary.simpleMessage("Löschen"),
    "textListEditEntryTitle": MessageLookupByLibrary.simpleMessage(
      "Eintrag bearbeiten",
    ),
    "textListEmpty": MessageLookupByLibrary.simpleMessage(
      "Noch keine Einträge",
    ),
    "textListOwnEntryLabel": MessageLookupByLibrary.simpleMessage(
      "Eigener Eintrag",
    ),
    "textListSlotLabel": MessageLookupByLibrary.simpleMessage("Beschriftung:"),
    "textListSlotsHeadline": MessageLookupByLibrary.simpleMessage(
      "Feste Plätze",
    ),
    "textListSlotsHint": MessageLookupByLibrary.simpleMessage(
      "Optional, z. B. „Hauptaspekt“, „Dilemma“ oder „Leicht (2)“.",
    ),
    "tranformToAlternateForm": MessageLookupByLibrary.simpleMessage(
      "Verwandeln",
    ),
    "transformIntoAlternateForm": MessageLookupByLibrary.simpleMessage(
      "In eine andere Form verwandeln",
    ),
    "transformationDescription": MessageLookupByLibrary.simpleMessage(
      "Beschreibung",
    ),
    "transformationIsEditedWarningTitle": MessageLookupByLibrary.simpleMessage(
      "Verwandlung wird bearbeitet",
    ),
    "transformationName": MessageLookupByLibrary.simpleMessage(
      "Verwandlungsname",
    ),
    "transformationStatSettingsFor": m32,
    "uploadImageBtnLabel": MessageLookupByLibrary.simpleMessage(
      "Bild hochladen",
    ),
    "uploadImageMenuLabel": MessageLookupByLibrary.simpleMessage(
      "Bild hochladen",
    ),
    "user": MessageLookupByLibrary.simpleMessage("Benutzer:"),
    "username": MessageLookupByLibrary.simpleMessage("Nutzername"),
    "usernameRuleHint": MessageLookupByLibrary.simpleMessage(
      "3 bis 13 Zeichen, nur Buchstaben und Ziffern",
    ),
    "valueOfPropertyWithName": m33,
    "visibleCards": MessageLookupByLibrary.simpleMessage("Sichtbare Karten"),
    "visibleCardsHint": MessageLookupByLibrary.simpleMessage(
      "Ausgeblendete Karten bleiben auf diesem Gerät ausgeblendet, auch wenn ein Spieler zwischendurch offline war.",
    ),
    "waitingForApprovalText": m34,
    "waitingForApprovalTitle": MessageLookupByLibrary.simpleMessage(
      "Warte auf Freigabe",
    ),
    "waitingForDmApproval": MessageLookupByLibrary.simpleMessage(
      "Warte auf Freigabe durch die Spielleitung",
    ),
    "waitingForInitiative": MessageLookupByLibrary.simpleMessage(
      "Wartet auf Initiative",
    ),
    "warning": MessageLookupByLibrary.simpleMessage("Warnung"),
    "welcomeDescription": MessageLookupByLibrary.simpleMessage(
      "Die Spielleitung verwaltet die Kampagne. Die Spieler haben ihren Charakterbogen, ihre Notizen und die Live-Werte auf dem Handy.",
    ),
    "welcomeJoinButton": MessageLookupByLibrary.simpleMessage(
      "Ich trete einer Runde bei",
    ),
    "welcomeJoinHint": MessageLookupByLibrary.simpleMessage(
      "Nach der Anmeldung gibst du den Code deiner Spielleitung ein.",
    ),
    "welcomeLeadButton": MessageLookupByLibrary.simpleMessage(
      "Ich leite eine Runde",
    ),
    "welcomeLeadHint": MessageLookupByLibrary.simpleMessage(
      "Du legst eine Kampagne an und lädst deine Gruppe ein.",
    ),
    "welcomeTagline": MessageLookupByLibrary.simpleMessage(
      "Dein Begleiter für Pen-&-Paper-Runden am Tisch.",
    ),
    "welcomeToQuestKeeper": MessageLookupByLibrary.simpleMessage(
      "Willkommen bei QuestKeeper",
    ),
    "wizardCampaignNameStepHelper": MessageLookupByLibrary.simpleMessage(
      "## Kampagnenname\n\nWie heißt deine Kampagne? Du kannst den Namen später jederzeit ändern.\n\nDer Name braucht mindestens vier Zeichen.",
    ),
    "wizardCategoryItemCount": m35,
    "wizardCategoryNameLabel": MessageLookupByLibrary.simpleMessage(
      "Name der Kategorie:",
    ),
    "wizardCharacterSheetStepTitle": MessageLookupByLibrary.simpleMessage(
      "Charakterbogen",
    ),
    "wizardCurrencyMultipleLabel": MessageLookupByLibrary.simpleMessage(
      "Entspricht wie vielen der vorherigen Währung:",
    ),
    "wizardCurrencyStepHelper": MessageLookupByLibrary.simpleMessage(
      "## Währung\n\nStelle ein, welche Währungen es in deiner Welt gibt und wie sie umgerechnet werden.\n\nFang mit der kleinsten Einheit an (z. B. Kupfer) und arbeite dich bis zur größten hoch. Gib bei jeder weiteren Währung an, wie viele der vorherigen sie wert ist (in vielen Fantasy-Rollenspielen: 10 Kupfer = 1 Silber).",
    ),
    "wizardCurrencyStepTitle": MessageLookupByLibrary.simpleMessage("Währung"),
    "wizardDeletePropertyMessage": m36,
    "wizardDeletePropertyTitle": MessageLookupByLibrary.simpleMessage(
      "Eigenschaft löschen?",
    ),
    "wizardDeleteTabMessage": m37,
    "wizardDeleteTabTitle": MessageLookupByLibrary.simpleMessage(
      "Tab löschen?",
    ),
    "wizardEditItemTitle": MessageLookupByLibrary.simpleMessage(
      "Item bearbeiten",
    ),
    "wizardEditRecipeTitle": MessageLookupByLibrary.simpleMessage(
      "Rezept bearbeiten",
    ),
    "wizardFinishBtnLabel": MessageLookupByLibrary.simpleMessage("Fertig"),
    "wizardGroupLabel": m38,
    "wizardHideExplanation": MessageLookupByLibrary.simpleMessage(
      "Erklärung einklappen",
    ),
    "wizardIconForCategorySuffix": m39,
    "wizardInvalidImageFile": MessageLookupByLibrary.simpleMessage(
      "Diese Datei ist kein gültiges Bild.",
    ),
    "wizardItemCategoriesStepHelper": MessageLookupByLibrary.simpleMessage(
      "## Item-Kategorien (optional)\n\nDamit die Spieler ihre Items filtern können, sortieren wir sie in Kategorien ein. Dafür haben wir dir eine Reihe von Kategorien und Unterkategorien vorbereitet.\n\nPasse sie gern an, wenn sie nicht zu eurem Rollenspiel passen.",
    ),
    "wizardItemCategoriesStepTitle": MessageLookupByLibrary.simpleMessage(
      "Item-Kategorien",
    ),
    "wizardItemCategoryLabel": MessageLookupByLibrary.simpleMessage(
      "Kategorie",
    ),
    "wizardItemImageDescriptionLabel": MessageLookupByLibrary.simpleMessage(
      "Bildbeschreibung:",
    ),
    "wizardItemNameLabel": MessageLookupByLibrary.simpleMessage(
      "Name des Items:",
    ),
    "wizardItemPatchSizeLabel": MessageLookupByLibrary.simpleMessage(
      "Fundgröße (optional):",
    ),
    "wizardItemPlacesOfFindingHeader": MessageLookupByLibrary.simpleMessage(
      "Fundorte:",
    ),
    "wizardItemsStepHelper": MessageLookupByLibrary.simpleMessage(
      "## Items (optional)\n\nHier legst du die Items deiner Welt an: Heiltränke, Waffen, Questgegenstände oder Zutaten für Gifte, also alles, was in den Taschen deiner Spieler landen kann.\n\nAuch die Wirkung eines Tranks kannst du hier hinterlegen.\n\nTipp: Schreib Wirkung, Schaden und Ähnliches an den Anfang der Beschreibung. Dann sehen deine Spieler das Wichtigste auf einen Blick.",
    ),
    "wizardItemsStepTitle": MessageLookupByLibrary.simpleMessage("Items"),
    "wizardLocationItemCount": m40,
    "wizardLocationLabel": m41,
    "wizardLocationsStepHelper": MessageLookupByLibrary.simpleMessage(
      "## Fundorte (optional)\n\nAb hier geht es um Items und Crafting. Diesen und die folgenden Schritte (Fundorte, Item-Kategorien, Items, Rezepte) brauchst du nur, wenn ihr damit spielt. Mit **Überspringen** geht es direkt zur Zusammenfassung; schon angelegte Daten bleiben erhalten.\n\nManche Items lassen sich an bestimmten Orten finden: am Strand, in Höhlen, in Grotten und so weiter. Lege hier die Orte an, damit du sie in den nächsten Schritten mit Items verknüpfen kannst.",
    ),
    "wizardLocationsStepTitle": MessageLookupByLibrary.simpleMessage(
      "Fundorte",
    ),
    "wizardNewEntryDefaultName": MessageLookupByLibrary.simpleMessage("Neu"),
    "wizardNewImageBtnLabel": MessageLookupByLibrary.simpleMessage(
      "Neues Bild",
    ),
    "wizardNewLocationBtnLabel": MessageLookupByLibrary.simpleMessage(
      "Neuer Fundort",
    ),
    "wizardNewSubCategoryBtnLabel": MessageLookupByLibrary.simpleMessage(
      "Neue Unterkategorie",
    ),
    "wizardNextCurrencyLabel": MessageLookupByLibrary.simpleMessage(
      "Name der nächstgrößeren Währung:",
    ),
    "wizardOptionalStepLabel": MessageLookupByLibrary.simpleMessage(
      "Optionaler Schritt",
    ),
    "wizardPickImageBtnLabel": MessageLookupByLibrary.simpleMessage(
      "Bild auswählen",
    ),
    "wizardPropertyDeletedSnackbar": m42,
    "wizardRecipeAddIngredient": MessageLookupByLibrary.simpleMessage(
      "Weitere Zutat",
    ),
    "wizardRecipeAddRequirement": MessageLookupByLibrary.simpleMessage(
      "Weitere Voraussetzung",
    ),
    "wizardRecipeCreatedItemLabel": MessageLookupByLibrary.simpleMessage(
      "Herzustellendes Item",
    ),
    "wizardRecipeDeletePermanently": MessageLookupByLibrary.simpleMessage(
      "Endgültig löschen",
    ),
    "wizardRecipeDuplicateAndOpen": MessageLookupByLibrary.simpleMessage(
      "Duplizieren und öffnen",
    ),
    "wizardRecipeIngredientLabel": m43,
    "wizardRecipeOpenDetails": MessageLookupByLibrary.simpleMessage(
      "Details öffnen",
    ),
    "wizardRecipeRequirementLabel": m44,
    "wizardRecipesStepHelper": MessageLookupByLibrary.simpleMessage(
      "## Rezepte (optional)\n\nMit Rezepten können deine Spieler selbst Dinge herstellen, zum Beispiel Heiltränke.\n\nManche Rezepte setzen ein Werkzeug voraus, etwa ein Kräuterkunde-Set. Auch das kannst du im Rezept hinterlegen; die Spieler brauchen das Werkzeug dann, um das Rezept zu nutzen.\n\nTippe auf ein Rezept, um es zu bearbeiten. Halte es gedrückt für weitere Aktionen.",
    ),
    "wizardRecipesStepTitle": MessageLookupByLibrary.simpleMessage("Rezepte"),
    "wizardSavedSnackbar": MessageLookupByLibrary.simpleMessage(
      "Einrichtung gespeichert",
    ),
    "wizardShowExplanation": MessageLookupByLibrary.simpleMessage(
      "Erklärung anzeigen",
    ),
    "wizardSkinStepHelper": MessageLookupByLibrary.simpleMessage(
      "## Willkommen bei QuestKeeper!\n\nIn den nächsten Schritten richtest du deine Kampagne ein: Darstellung, Name, Charakterbogen, Initiative und Währung. Danach folgen optionale Schritte für Items und Crafting, die du überspringen kannst.\n\nAlles wird automatisch gespeichert. Mit dem X oben links schließt du den Assistenten jederzeit; über das Zahnrad oben rechts kommst du später wieder hierher.\n\n## Darstellung\n\nWähle das Standard-Aussehen der Charakterbögen in dieser Kampagne. Spieler können es später für ihre eigenen Charaktere ändern.",
    ),
    "wizardSkinStepHelperAfterTemplate": MessageLookupByLibrary.simpleMessage(
      "## Darstellung\n\nWähle das Standard-Aussehen der Charakterbögen in dieser Kampagne. Spieler können es später für ihre eigenen Charaktere ändern.",
    ),
    "wizardSkipBtnLabel": MessageLookupByLibrary.simpleMessage("Überspringen"),
    "wizardSmallestCurrencyLabel": MessageLookupByLibrary.simpleMessage(
      "Name der kleinsten Währung:",
    ),
    "wizardSubCategoryNameLabel": MessageLookupByLibrary.simpleMessage(
      "Name der Unterkategorie:",
    ),
    "wizardSummaryCampaignLabel": MessageLookupByLibrary.simpleMessage(
      "Kampagne",
    ),
    "wizardSummaryItemCount": m45,
    "wizardSummaryNotSet": MessageLookupByLibrary.simpleMessage(
      "Noch nicht festgelegt",
    ),
    "wizardSummaryPropertyCount": m46,
    "wizardSummaryRecipeCount": m47,
    "wizardSummaryStepHelper": MessageLookupByLibrary.simpleMessage(
      "## Fertig!\n\nDeine Kampagne ist eingerichtet und alles ist gespeichert. Die Übersicht zeigt, was eingerichtet ist.\n\nÄndern kannst du alles später über das Zahnrad oben rechts.\n\nMit **Fertig** schließt du den Assistenten.",
    ),
    "wizardSummaryStepTitle": MessageLookupByLibrary.simpleMessage(
      "Zusammenfassung",
    ),
    "wizardSummaryTabCount": m48,
    "wizardTabNameLabel": MessageLookupByLibrary.simpleMessage("Name des Tabs"),
    "wizardTemplateContentsLabel": MessageLookupByLibrary.simpleMessage(
      "Enthält",
    ),
    "wizardTemplateEmptyContents": MessageLookupByLibrary.simpleMessage(
      "Name, Level, eine Währung",
    ),
    "wizardTemplateEmptyDescription": MessageLookupByLibrary.simpleMessage(
      "Ein schlichter Bogen mit Name, Level und Beschreibung. Alles Weitere legst du selbst an.",
    ),
    "wizardTemplateEmptyName": MessageLookupByLibrary.simpleMessage("Leer"),
    "wizardTemplateFantasyContents": MessageLookupByLibrary.simpleMessage(
      "Attribute, Fertigkeiten, Zauber, Kupfer bis Platin",
    ),
    "wizardTemplateFantasyDescription": MessageLookupByLibrary.simpleMessage(
      "Klassische Fantasy mit Attributen, Trefferpunkten und Zaubern.",
    ),
    "wizardTemplateFantasyName": MessageLookupByLibrary.simpleMessage(
      "Fantasy 5E (SRD)",
    ),
    "wizardTemplateFromCampagneDescription": m49,
    "wizardTemplateFromCampagneHeader": MessageLookupByLibrary.simpleMessage(
      "Aus einer deiner Kampagnen",
    ),
    "wizardTemplateFromCampagneHint": MessageLookupByLibrary.simpleMessage(
      "Übernimmt Charakterbogen, Währung, Items und Rezepte. Charaktere, Notizen und Spieler bleiben in der anderen Kampagne.",
    ),
    "wizardTemplateFromCampagneItems": m50,
    "wizardTemplateFromCampagneProperties": m51,
    "wizardTemplateFromCampagneRecipes": m52,
    "wizardTemplateNarrativeContents": MessageLookupByLibrary.simpleMessage(
      "Aspekte, Fertigkeiten, Stunts, Stress, Konsequenzen, Erzählpunkte",
    ),
    "wizardTemplateNarrativeDescription": MessageLookupByLibrary.simpleMessage(
      "Für Runden, in denen die Geschichte zählt: Aspekte beschreiben die Charaktere, Stress fängt Treffer ab.",
    ),
    "wizardTemplateNarrativeName": MessageLookupByLibrary.simpleMessage(
      "Erzählerisch (Aspekte & Stress)",
    ),
    "wizardTemplateReplaceConfirm": MessageLookupByLibrary.simpleMessage(
      "Vorlage wechseln",
    ),
    "wizardTemplateReplaceMessage": MessageLookupByLibrary.simpleMessage(
      "Du hast seit der Vorlagenwahl etwas angepasst. Diese Änderungen gehen verloren. Kampagnenname und Darstellung bleiben.",
    ),
    "wizardTemplateReplaceTitle": MessageLookupByLibrary.simpleMessage(
      "Vorlage wechseln?",
    ),
    "wizardTemplateStepHelper": MessageLookupByLibrary.simpleMessage(
      "## Willkommen bei QuestKeeper!\n\nIn den nächsten Schritten richtest du deine Kampagne ein: Vorlage, Darstellung, Name, Charakterbogen, Initiative und Währung. Danach folgen optionale Schritte für Items und Crafting, die du überspringen kannst.\n\nAlles wird automatisch gespeichert. Mit dem X oben links schließt du den Assistenten jederzeit; über das Zahnrad oben rechts kommst du später wieder hierher.\n\n## Vorlage\n\nWähle, womit du startest. Die Vorlage füllt Charakterbogen und Währung vor. In den nächsten Schritten passt du alles an.\n\nDie Vorlage wählst du nur beim Anlegen. Über das Zahnrad änderst du später jeden Teil einzeln.",
    ),
    "wizardTemplateStepTitle": MessageLookupByLibrary.simpleMessage("Vorlage"),
    "wizardUndo": MessageLookupByLibrary.simpleMessage("Rückgängig"),
    "wizardUnnamedProperty": MessageLookupByLibrary.simpleMessage(
      "Unbenannte Eigenschaft",
    ),
    "wizardUnnamedTab": MessageLookupByLibrary.simpleMessage("Unbenannter Tab"),
    "yes": MessageLookupByLibrary.simpleMessage("Ja"),
    "you": MessageLookupByLibrary.simpleMessage("Du"),
    "youAreEditingACopiedPropertyChangesWillNotAffect":
        MessageLookupByLibrary.simpleMessage(
          "Du bearbeitest gerade eine kopierte Eigenschaft. Änderungen gelten nur hier und werden nicht auf den Hauptcharakter übertragen.",
        ),
    "youAreEditingAnAlternateFormWarningText":
        MessageLookupByLibrary.simpleMessage(
          "Du bearbeitest gerade eine Verwandlung. Änderungen gelten nur für diese Verwandlung und gehen verloren, wenn du dich zurückverwandelst. Für dauerhafte Änderungen verwandle dich zurück und bearbeite deine Grundform.",
        ),
    "youOwnXCampaigns": m53,
    "youOwnXCharacters": m54,
    "yourAreDisconnectedBody": MessageLookupByLibrary.simpleMessage(
      "Die Verbindung ist unterbrochen. Entweder du oder deine Spielleitung ist offline.",
    ),
  };
}
