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

  static String m4(date) => "Einstellungen geändert: ${date}";

  static String m5(date) => "Zuletzt bearbeitet: ${date}";

  static String m6(current, total, tabName) =>
      "Abschnitt ${current} von ${total}: ${tabName}";

  static String m7(number) => "Kästchen ${number}";

  static String m8(condition) => "(wenn ${condition})";

  static String m9(label) => "Mod(${label})";

  static String m10(username) => " (für ${username})";

  static String m11(email) =>
      "Wir haben dir einen Code an ${email} geschickt. Er gilt zwei Stunden.";

  static String m12(characterNames) =>
      "Die Items konnten nicht an ${characterNames} verteilt werden. Bitte versuche es erneut.";

  static String m13(label, formattedBonus) =>
      "Addiere ${label} ${formattedBonus} zu deinem Wurf";

  static String m14(campagneName) => "Einladung zu „${campagneName}“";

  static String m15(campagneName, code) =>
      "Spiel mit in meiner Runde „${campagneName}“! Öffne QuestKeeper, tippe auf „Kampagne beitreten“ und gib diesen Code ein: ${code}";

  static String m16(code) => "Beitrittscode: ${code}";

  static String m17(playerName, username) =>
      "${playerName} (${username}) möchte deiner Kampagne beitreten.";

  static String m18(count) =>
      "${Intl.plural(count, one: '1 offene Anfrage', other: '${count} offene Anfragen')}";

  static String m19(count) => "höchstens ${count} Zeichen";

  static String m20(count) => "mindestens ${count} Zeichen";

  static String m21(amount) =>
      "${Intl.plural(amount, one: 'Du hast ein neues Item erhalten:', other: 'Du hast ${amount} neue Items erhalten:')}";

  static String m22(privacyPolicyLink) =>
      "Wie wir mit deinen Daten umgehen, steht in unserer ${privacyPolicyLink}.";

  static String m23(statName) => "Einstellungen für ${statName}";

  static String m24(property) => "Der Wert von ${property}";

  static String m25(characterName) =>
      "Deine Anfrage für „${characterName}“ liegt bei deiner Spielleitung. Sobald sie zustimmt, kannst du hier mitspielen.";

  static String m26(count) =>
      "${Intl.plural(count, zero: 'In dieser Kategorie sind noch keine Items.', one: 'In dieser Kategorie ist ein Item.', other: 'In dieser Kategorie sind ${count} Items.')}";

  static String m27(count, name) =>
      "${Intl.plural(count, one: 'Eigenschaft „${name}“ löschen? Ein Charakter hat dafür schon einen Wert, er geht verloren.', other: 'Eigenschaft „${name}“ löschen? ${count} Charaktere haben dafür schon Werte, sie gehen verloren.')}";

  static String m28(count, tabName) =>
      "${Intl.plural(count, zero: 'Den leeren Tab „${tabName}“ löschen?', one: 'Tab „${tabName}“ mit einer Eigenschaft löschen? Werte der Charaktere gehen verloren.', other: 'Tab „${tabName}“ mit ${count} Eigenschaften löschen? Werte der Charaktere gehen verloren.')}";

  static String m29(number) => "Gruppe ${number}";

  static String m30(name) => " (für Kategorie ${name})";

  static String m31(count) =>
      "${Intl.plural(count, zero: 'An diesem Fundort gibt es noch keine Items.', one: 'An diesem Fundort kann ein Item gefunden werden.', other: 'An diesem Fundort können ${count} Items gefunden werden.')}";

  static String m32(number) => "Fundort #${number}";

  static String m33(name) => "Eigenschaft „${name}“ gelöscht";

  static String m34(number) => "Zutat #${number}";

  static String m35(number) => "Voraussetzung #${number}";

  static String m36(count) =>
      "${Intl.plural(count, zero: 'Keine Items', one: '1 Item', other: '${count} Items')}";

  static String m37(count) =>
      "${Intl.plural(count, one: '1 Eigenschaft', other: '${count} Eigenschaften')}";

  static String m38(count) =>
      "${Intl.plural(count, zero: 'Keine Rezepte', one: '1 Rezept', other: '${count} Rezepte')}";

  static String m39(count) =>
      "${Intl.plural(count, one: '1 Tab', other: '${count} Tabs')}";

  static String m40(count) =>
      "${Intl.plural(count, zero: 'Du leitest noch keine Kampagne.', one: 'Du leitest 1 Kampagne.', other: 'Du leitest ${count} Kampagnen.')}";

  static String m41(count) =>
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
    "calculatedValue": MessageLookupByLibrary.simpleMessage("Berechneter Wert"),
    "calculatedValuePlaceholder": MessageLookupByLibrary.simpleMessage(
      "Der berechnete Wert",
    ),
    "calculatedValueShort": MessageLookupByLibrary.simpleMessage("ber."),
    "campagneSettingsChangedAt": m4,
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
    "characterLastEditedAt": m5,
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
    "characterSetupProgress": m6,
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
    "checkboxTrackBoxLabel": m7,
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
    "computedIfPicked": m8,
    "computedMode": MessageLookupByLibrary.simpleMessage("Umrechnung"),
    "computedModeModifier": MessageLookupByLibrary.simpleMessage(
      "Modifikator (x−10)/2",
    ),
    "computedModeValue": MessageLookupByLibrary.simpleMessage("wie er ist"),
    "computedModifierOf": m9,
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
    "configurePropertiesForCharacterNameSuffix": m10,
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
    "forgotPasswordCodeSent": m11,
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
    "grantItemsFailedForPlayers": m12,
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
    "initiativeBonusHelperSentence": m13,
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
    "inviteShareSubject": m14,
    "inviteShareText": m15,
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
    "joinCodeForNewPlayers": m16,
    "joinCodeIncompleteError": MessageLookupByLibrary.simpleMessage(
      "Der Code hat sechs Ziffern, zum Beispiel 123-456.",
    ),
    "joinCodeUnknownError": MessageLookupByLibrary.simpleMessage(
      "Diesen Code gibt es nicht. Prüfe ihn mit deiner Spielleitung.",
    ),
    "joinRequestAcceptedMessage": MessageLookupByLibrary.simpleMessage(
      "Deine Beitrittsanfrage wurde angenommen. Du kannst jetzt mitspielen.",
    ),
    "joinRequestCreatedForDm": m17,
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
      "Wie soll deine Kampagne heißen? Danach führt dich der Assistent durch Charakterbogen, Währung und Gegenstände.",
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
    "openJoinRequestsBadge": m18,
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
    "passwordRuleMaxLength": m19,
    "passwordRuleMet": MessageLookupByLibrary.simpleMessage("erfüllt"),
    "passwordRuleMinLength": m20,
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
    "receivedXNewItems": m21,
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
    "registerPrivacyNotice": m22,
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
    "transformationStatSettingsFor": m23,
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
    "valueOfPropertyWithName": m24,
    "visibleCards": MessageLookupByLibrary.simpleMessage("Sichtbare Karten"),
    "visibleCardsHint": MessageLookupByLibrary.simpleMessage(
      "Ausgeblendete Karten bleiben auf diesem Gerät ausgeblendet, auch wenn ein Spieler zwischendurch offline war.",
    ),
    "waitingForApprovalText": m25,
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
      "## Kampagnenname\n\nWir beginnen mit der wohl schwierigsten Frage überhaupt: Wie heißt deine Kampagne?\n\nDer Name braucht mindestens vier Zeichen.",
    ),
    "wizardCategoryItemCount": m26,
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
    "wizardDeletePropertyMessage": m27,
    "wizardDeletePropertyTitle": MessageLookupByLibrary.simpleMessage(
      "Eigenschaft löschen?",
    ),
    "wizardDeleteTabMessage": m28,
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
    "wizardGroupLabel": m29,
    "wizardHideExplanation": MessageLookupByLibrary.simpleMessage(
      "Erklärung einklappen",
    ),
    "wizardIconForCategorySuffix": m30,
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
    "wizardLocationItemCount": m31,
    "wizardLocationLabel": m32,
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
    "wizardPropertyDeletedSnackbar": m33,
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
    "wizardRecipeIngredientLabel": m34,
    "wizardRecipeOpenDetails": MessageLookupByLibrary.simpleMessage(
      "Details öffnen",
    ),
    "wizardRecipeRequirementLabel": m35,
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
    "wizardSummaryItemCount": m36,
    "wizardSummaryNotSet": MessageLookupByLibrary.simpleMessage(
      "Noch nicht festgelegt",
    ),
    "wizardSummaryPropertyCount": m37,
    "wizardSummaryRecipeCount": m38,
    "wizardSummaryStepHelper": MessageLookupByLibrary.simpleMessage(
      "## Fertig!\n\nDeine Kampagne ist eingerichtet und alles ist gespeichert. Die Übersicht zeigt, was eingerichtet ist.\n\nÄndern kannst du alles später über das Zahnrad oben rechts.\n\nMit **Fertig** schließt du den Assistenten.",
    ),
    "wizardSummaryStepTitle": MessageLookupByLibrary.simpleMessage(
      "Zusammenfassung",
    ),
    "wizardSummaryTabCount": m39,
    "wizardTabNameLabel": MessageLookupByLibrary.simpleMessage("Name des Tabs"),
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
    "youOwnXCampaigns": m40,
    "youOwnXCharacters": m41,
    "yourAreDisconnectedBody": MessageLookupByLibrary.simpleMessage(
      "Die Verbindung ist unterbrochen. Entweder du oder deine Spielleitung ist offline.",
    ),
  };
}
