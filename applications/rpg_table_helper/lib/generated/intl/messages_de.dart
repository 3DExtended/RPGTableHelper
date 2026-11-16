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

  static String m4(condition) => "(wenn ${condition})";

  static String m5(label) => "Mod(${label})";

  static String m6(username) => " (für ${username})";

  static String m7(email) =>
      "Wir haben dir einen Code an ${email} geschickt. Er gilt zwei Stunden.";

  static String m8(characterNames) =>
      "Die Items konnten nicht an ${characterNames} verteilt werden. Bitte versuche es erneut.";

  static String m9(label, formattedBonus) =>
      "Addiere ${label} ${formattedBonus} zu deinem Wurf";

  static String m10(count) => "höchstens ${count} Zeichen";

  static String m11(count) => "mindestens ${count} Zeichen";

  static String m12(amount) => "Du hast ${amount} neue Items erhalten:";

  static String m13(privacyPolicyLink) =>
      "Wie wir mit deinen Daten umgehen, steht in unserer ${privacyPolicyLink}.";

  static String m14(property) => "Der Wert von ${property}";

  static String m15(count) =>
      "${Intl.plural(count, zero: 'In dieser Kategorie sind noch keine Items.', one: 'In dieser Kategorie ist ein Item.', other: 'In dieser Kategorie sind ${count} Items.')}";

  static String m16(count, name) =>
      "${Intl.plural(count, one: 'Eigenschaft „${name}“ löschen? Ein Charakter hat dafür schon einen Wert, er geht verloren.', other: 'Eigenschaft „${name}“ löschen? ${count} Charaktere haben dafür schon Werte, sie gehen verloren.')}";

  static String m17(count, tabName) =>
      "${Intl.plural(count, zero: 'Den leeren Tab „${tabName}“ löschen?', one: 'Tab „${tabName}“ mit einer Eigenschaft löschen? Werte der Charaktere gehen verloren.', other: 'Tab „${tabName}“ mit ${count} Eigenschaften löschen? Werte der Charaktere gehen verloren.')}";

  static String m18(number) => "Gruppe ${number}";

  static String m19(name) => " (für Kategorie ${name})";

  static String m20(count) =>
      "${Intl.plural(count, zero: 'An diesem Fundort gibt es noch keine Items.', one: 'An diesem Fundort kann ein Item gefunden werden.', other: 'An diesem Fundort können ${count} Items gefunden werden.')}";

  static String m21(number) => "Fundort #${number}";

  static String m22(name) => "Eigenschaft „${name}“ gelöscht";

  static String m23(number) => "Zutat #${number}";

  static String m24(number) => "Voraussetzung #${number}";

  static String m25(count) =>
      "${Intl.plural(count, zero: 'Keine Items', one: '1 Item', other: '${count} Items')}";

  static String m26(count) =>
      "${Intl.plural(count, one: '1 Eigenschaft', other: '${count} Eigenschaften')}";

  static String m27(count) =>
      "${Intl.plural(count, zero: 'Keine Rezepte', one: '1 Rezept', other: '${count} Rezepte')}";

  static String m28(count) =>
      "${Intl.plural(count, one: '1 Tab', other: '${count} Tabs')}";

  static String m29(count) => "Dir gehören ${count} Kampagnen";

  static String m30(count) => "Dir gehören ${count} Charaktere";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "add": MessageLookupByLibrary.simpleMessage("Hinzufügen"),
    "addAdditionalEnemy": MessageLookupByLibrary.simpleMessage(
      "Neue Gegner hinzufügen",
    ),
    "addAnAdditionalEnemyBtnLabel": MessageLookupByLibrary.simpleMessage(
      "Weiterer Gegner",
    ),
    "addBalance": MessageLookupByLibrary.simpleMessage("Guthaben hinzufügen"),
    "addCharacterToCampagneModalTitle": MessageLookupByLibrary.simpleMessage(
      "Charakter zur Kampagne hinzufügen",
    ),
    "addComputedTerm": MessageLookupByLibrary.simpleMessage(
      "Baustein hinzufügen",
    ),
    "addImageBtnLabel": MessageLookupByLibrary.simpleMessage("Bild"),
    "addItems": MessageLookupByLibrary.simpleMessage("Items hinzufügen"),
    "addNewTransformationComponent": MessageLookupByLibrary.simpleMessage(
      "Füge neue Verwandlungsformen hinzu",
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
      "Initiative würfeln, wenn der DM einen Kampf startet",
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
    "apiKeysTitle": MessageLookupByLibrary.simpleMessage("API-Schlüssel"),
    "apiKeysViewDocs": MessageLookupByLibrary.simpleMessage(
      "API-Dokumentation öffnen",
    ),
    "appName": MessageLookupByLibrary.simpleMessage("QuestKeeper"),
    "assignCharacterToCampagneModalContent":
        MessageLookupByLibrary.simpleMessage(
          "Du hast zwar einen Charakter erstellt, dieser ist aber noch keine Season bzw. Kampagne zugeordnet. Gebe hier den Join Code ein, den du von deinem DM erhältst, um eine Anfrage an deinen DM zu senden.",
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
    "campaignManagement": MessageLookupByLibrary.simpleMessage(
      "Kampagnen Management",
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
      "Deine Charakteränderungen konnten nicht auf dem Server gespeichert werden. Prüfe deine Verbindung und versuche es erneut — es wurde nichts persistiert.",
    ),
    "characterConfigSaveFailedTitle": MessageLookupByLibrary.simpleMessage(
      "Charakter nicht gespeichert",
    ),
    "characterName": MessageLookupByLibrary.simpleMessage("Name"),
    "characterNameDefault": MessageLookupByLibrary.simpleMessage("Spielername"),
    "characterNameLabel": MessageLookupByLibrary.simpleMessage("Name:"),
    "characterNameStatHelperText": MessageLookupByLibrary.simpleMessage(
      "Wie heißt dein Charakter?",
    ),
    "characterNameStatTitle": MessageLookupByLibrary.simpleMessage(
      "Charakter-Name",
    ),
    "characterNameWithLevelAndConfigurableDetails":
        MessageLookupByLibrary.simpleMessage(
          "Charakter Basis Eigenschaften (LVL, Name und weitere optionale)",
        ),
    "characterOverview": MessageLookupByLibrary.simpleMessage(
      "Charakter Übersicht",
    ),
    "characterPortraitImagePrompt": MessageLookupByLibrary.simpleMessage(
      "Porträtbeschreibung",
    ),
    "characterPortraitImagePromptPlaceholder":
        MessageLookupByLibrary.simpleMessage(
          "Beschreibe deinen Charakter für die Bildgenerierung",
        ),
    "characterSheetAppearanceTitle": MessageLookupByLibrary.simpleMessage(
      "Darstellung",
    ),
    "characterSheetSkinArcaneLedger": MessageLookupByLibrary.simpleMessage(
      "Arkanes Foliant",
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
    "chooseACampagne": MessageLookupByLibrary.simpleMessage(
      "Kampagne auswählen",
    ),
    "chooseACharacter": MessageLookupByLibrary.simpleMessage(
      "Charakter auswählen",
    ),
    "chooseCardStatsYourself": MessageLookupByLibrary.simpleMessage(
      "Eigenschaften selbst wählen",
    ),
    "companion": MessageLookupByLibrary.simpleMessage("Begleiter"),
    "companionOverview": MessageLookupByLibrary.simpleMessage(
      "Begleiter Übersicht",
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
    "computedIfPicked": m4,
    "computedMode": MessageLookupByLibrary.simpleMessage("Umrechnung"),
    "computedModeModifier": MessageLookupByLibrary.simpleMessage(
      "Modifikator (x−10)/2",
    ),
    "computedModeValue": MessageLookupByLibrary.simpleMessage("wie er ist"),
    "computedModifierOf": m5,
    "computedPreset": MessageLookupByLibrary.simpleMessage("Vorlage (D&D 5e)"),
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
    "configurePropertiesForCharacterNameSuffix": m6,
    "confirmDeleteBtnLabel": MessageLookupByLibrary.simpleMessage("Löschen"),
    "connectionLostReconnecting": MessageLookupByLibrary.simpleMessage(
      "Keine Verbindung – verbinde neu …",
    ),
    "count": MessageLookupByLibrary.simpleMessage("Anzahl"),
    "craft": MessageLookupByLibrary.simpleMessage("Herstellen"),
    "craftableAmountText": MessageLookupByLibrary.simpleMessage("Herstellbar:"),
    "craftableRecipeFilter": MessageLookupByLibrary.simpleMessage(
      "Herstellbar",
    ),
    "createNewAccount": MessageLookupByLibrary.simpleMessage(
      "Neuen Account anlegen",
    ),
    "createNewTransformationTitle": MessageLookupByLibrary.simpleMessage(
      "Neue Verwandlung erstellen",
    ),
    "createTransformationHelperText": MessageLookupByLibrary.simpleMessage(
      "Um eine neue Transformation zu erstellen, musst du die Eigenschaften auswählen, die durch diese Verwandlung verändert werden. (Wenn die Eigenschaft nicht verändert wird, muss sie auch nicht ausgewählt werden.)",
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
    "dm": MessageLookupByLibrary.simpleMessage("DM"),
    "documentDefaultNamePrefix": MessageLookupByLibrary.simpleMessage(
      "Dokument",
    ),
    "documentGroupLabel": MessageLookupByLibrary.simpleMessage("Gruppenname"),
    "documentTitleLabel": MessageLookupByLibrary.simpleMessage("Titel"),
    "editPageModalText": MessageLookupByLibrary.simpleMessage(
      "Hier kannst du sowohl den Titel als auch die Gruppierung deiner Seite verändern.",
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
      "Gebe Namen ein",
    ),
    "enterSomeDescriptionOnTheLeft": MessageLookupByLibrary.simpleMessage(
      "Gebe eine Beschreibung auf der linken Seite ein.",
    ),
    "fightInitiativeStepTitle": MessageLookupByLibrary.simpleMessage(
      "Kampf / Initiative",
    ),
    "fightInitiativeStepTutorial": MessageLookupByLibrary.simpleMessage(
      "Markiere, welcher Wert der Initiative-Bonus ist.\n\nWenn ein Spieler zum Würfeln der Initiative aufgefordert wird, sieht er einen Hinweis mit diesem Bonus, damit er ihn sich nicht merken muss, während das Wurf-Popup den Charakterbogen verdeckt.\n\nWähle **Keine**, falls dein System keinen Bonus verwendet. Wähle ansonsten unten einen Wert aus. Handelt es sich um eine Gruppe von Werten (z. B. Fähigkeiten), wähle zusätzlich den passenden Eintrag. Besteht der Wert aus zwei Zahlen (z. B. Wert und Modifikator, oder aktuell und maximal), wähle, welche davon als Bonus zählt.",
    ),
    "fightingOrdering": MessageLookupByLibrary.simpleMessage(
      "Kampf Reihenfolge",
    ),
    "firstValue": MessageLookupByLibrary.simpleMessage("Erster Wert"),
    "firstValuePlaceholder": MessageLookupByLibrary.simpleMessage(
      "Der erster Wert",
    ),
    "followingItemsArePossibleAtPlaceOfFinding":
        MessageLookupByLibrary.simpleMessage(
          "Diese Items gibt es am/im Fundort:",
        ),
    "forCompanionSelector": MessageLookupByLibrary.simpleMessage(
      "für Begleiter",
    ),
    "forIntegerValueWithName": MessageLookupByLibrary.simpleMessage(
      "für Zahlen-Wert",
    ),
    "forgotPasswordBackToLogin": MessageLookupByLibrary.simpleMessage(
      "Zur Anmeldung",
    ),
    "forgotPasswordCodeSent": m7,
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
    "generateLoreImageTitle": MessageLookupByLibrary.simpleMessage(
      "Generiere ein Bild",
    ),
    "generatedImage": MessageLookupByLibrary.simpleMessage("Generiertes Bild"),
    "generatedImagesTabTitle": MessageLookupByLibrary.simpleMessage(
      "Generierte Bilder",
    ),
    "genericErrorModalHeader": MessageLookupByLibrary.simpleMessage("Fehler"),
    "genericErrorModalTechnicalDetailsErrorCodeRowLabel":
        MessageLookupByLibrary.simpleMessage("Fehlercode:"),
    "genericErrorModalTechnicalDetailsExceptionRowLabel":
        MessageLookupByLibrary.simpleMessage("Fehlertext:"),
    "genericErrorModalTechnicalDetailsHeader":
        MessageLookupByLibrary.simpleMessage("Technische Details: "),
    "grantItems": MessageLookupByLibrary.simpleMessage("Items verteilen"),
    "grantItemsFailedForPlayers": m8,
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
    "initiativeBonusHelperSentence": m9,
    "initiativeBonusIncompleteLeave": MessageLookupByLibrary.simpleMessage(
      "Trotzdem verlassen",
    ),
    "initiativeBonusIncompleteStay": MessageLookupByLibrary.simpleMessage(
      "Bleiben",
    ),
    "initiativeBonusIncompleteWarningBody":
        MessageLookupByLibrary.simpleMessage(
          "Deine Initiative-Bonus-Auswahl ist unvollständig und wird gelöscht, wenn du fortfährst.",
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
      "Kampf Reihenfolge Wurf",
    ),
    "initiativeRollText": MessageLookupByLibrary.simpleMessage(
      "Ein Kampf startet: Würfel deinen Platz in der Reihenfolge!",
    ),
    "initiativeRollTextFieldLabel": MessageLookupByLibrary.simpleMessage(
      "Kampf Wurf",
    ),
    "insertParagraphMenuLabel": MessageLookupByLibrary.simpleMessage(
      "Absatz hier einfügen",
    ),
    "integerValue": MessageLookupByLibrary.simpleMessage("Zahlen-Wert"),
    "integerValueWithCalculatedValue": MessageLookupByLibrary.simpleMessage(
      "Zahlen-Wert mit zusätzlicher Zahl",
    ),
    "integerValueWithMaxValue": MessageLookupByLibrary.simpleMessage(
      "Zahlen-Wert mit maximal Wert",
    ),
    "invalidImageFileSelected": MessageLookupByLibrary.simpleMessage(
      "Ungültige Bilddatei ausgewählt.",
    ),
    "item": MessageLookupByLibrary.simpleMessage("Item"),
    "itemCardDescRequires": MessageLookupByLibrary.simpleMessage("Braucht:"),
    "itemCategoryFilterAll": MessageLookupByLibrary.simpleMessage("Alles"),
    "itemDetailsDescriptionHeader": MessageLookupByLibrary.simpleMessage(
      "Beschreibung:",
    ),
    "itemDetailsForPrefix": MessageLookupByLibrary.simpleMessage(
      "Item Details für",
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
      "## Auffindbare Items in Fundort: ",
    ),
    "joinAsPlayer": MessageLookupByLibrary.simpleMessage(
      "Tritt als Spieler bei",
    ),
    "joinCode": MessageLookupByLibrary.simpleMessage("Join Code:"),
    "joinCodeForNewPlayers": MessageLookupByLibrary.simpleMessage(
      "Join Code (für neue Spieler):",
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
    "level": MessageLookupByLibrary.simpleMessage("Level"),
    "levelAbbr": MessageLookupByLibrary.simpleMessage("LVL"),
    "listOfIntegersWithIcons": MessageLookupByLibrary.simpleMessage(
      "Liste von Zahlen-Werten mit Icons",
    ),
    "listOfInterValuesWithCalculatedIntegerValues":
        MessageLookupByLibrary.simpleMessage(
          "Gruppe von Zahlen-Werten mit zusätzlicher Zahl",
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
    "lore": MessageLookupByLibrary.simpleMessage("Weltgeschichte"),
    "maxValue": MessageLookupByLibrary.simpleMessage("Maximaler Wert"),
    "maxValuePlaceholder": MessageLookupByLibrary.simpleMessage(
      "Der maximaler Wert für diese Eigenschaft",
    ),
    "maxValueShort": MessageLookupByLibrary.simpleMessage("Max."),
    "moreValues": MessageLookupByLibrary.simpleMessage("Weitere Werte"),
    "multilineText": MessageLookupByLibrary.simpleMessage("Mehrzeiliger Text"),
    "multiselectOption": MessageLookupByLibrary.simpleMessage(
      "Mehrfach-Auswahl",
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
    "nameOfCharacterHelperText": MessageLookupByLibrary.simpleMessage(
      "Wie heißt dein Charakter?",
    ),
    "nameOfPropertyLabel": MessageLookupByLibrary.simpleMessage(
      "Name der Eigenschaft",
    ),
    "navBarHeaderCrafting": MessageLookupByLibrary.simpleMessage("Herstellen"),
    "navBarHeaderInventory": MessageLookupByLibrary.simpleMessage("Inventar"),
    "navBarHeaderLore": MessageLookupByLibrary.simpleMessage("Weltgeschichte"),
    "navBarHeaderMoney": MessageLookupByLibrary.simpleMessage("Währung"),
    "newBalance": MessageLookupByLibrary.simpleMessage("Neues Guthaben"),
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
    "newTransformationSelectionBtn": MessageLookupByLibrary.simpleMessage(
      "Neue Gestalt",
    ),
    "next": MessageLookupByLibrary.simpleMessage("Weiter"),
    "no": MessageLookupByLibrary.simpleMessage("Nein"),
    "noBar": MessageLookupByLibrary.simpleMessage("Kein Balken"),
    "noCardStatsAvailable": MessageLookupByLibrary.simpleMessage(
      "Diese Kampagne hat noch keine Eigenschaften mit Zahlen.",
    ),
    "noCharactersInCampagne": MessageLookupByLibrary.simpleMessage(
      "Noch keine Charaktere in dieser Kampagne",
    ),
    "noFIghtStarted": MessageLookupByLibrary.simpleMessage(
      "Aktuell kein Kampf gestartet",
    ),
    "noImagesInCampagne": MessageLookupByLibrary.simpleMessage(
      "In dieser Kampagne sind noch keine Bilder von dir generiert worden.",
    ),
    "noItemsGranted": MessageLookupByLibrary.simpleMessage(
      "Noch keine Items verteilt...",
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
      "Aktuell keine Spieler online",
    ),
    "notAtTheTable": MessageLookupByLibrary.simpleMessage("nicht am Tisch"),
    "notCraftableRecipeFilter": MessageLookupByLibrary.simpleMessage(
      "Nicht herstellbar",
    ),
    "notEnoughBalance": MessageLookupByLibrary.simpleMessage(
      "Zu wenig Geld für diese Ausgabe",
    ),
    "noteblockVisibleFor": MessageLookupByLibrary.simpleMessage(
      "Sichtbar für:",
    ),
    "nothingSelected": MessageLookupByLibrary.simpleMessage(
      "- Nichts ausgewählt -",
    ),
    "offline": MessageLookupByLibrary.simpleMessage("Offline"),
    "ok": MessageLookupByLibrary.simpleMessage("Ok"),
    "online": MessageLookupByLibrary.simpleMessage("Online"),
    "openJoinRequests": MessageLookupByLibrary.simpleMessage("Join Anfragen:"),
    "optionalPropertyForAlternateForms": MessageLookupByLibrary.simpleMessage(
      "Optionale Eigenschaft für andere Formen",
    ),
    "optionalPropertyForCompanions": MessageLookupByLibrary.simpleMessage(
      "Optionale Eigenschaft für Begleiter",
    ),
    "optionsForMultiselect": MessageLookupByLibrary.simpleMessage(
      "Optionen für Mehrfach-Auswahl",
    ),
    "otherValue": MessageLookupByLibrary.simpleMessage("Anderer Wert"),
    "otherValuePlaceholder": MessageLookupByLibrary.simpleMessage(
      "Der andere Wert",
    ),
    "ownedIngredientCountPrefix": MessageLookupByLibrary.simpleMessage(
      "in Besitz:",
    ),
    "password": MessageLookupByLibrary.simpleMessage("Passwort"),
    "passwordRuleMaxLength": m10,
    "passwordRuleMet": MessageLookupByLibrary.simpleMessage("erfüllt"),
    "passwordRuleMinLength": m11,
    "passwordRuleNotMet": MessageLookupByLibrary.simpleMessage(
      "noch nicht erfüllt",
    ),
    "passwordRulesTitle": MessageLookupByLibrary.simpleMessage(
      "Dein Passwort braucht",
    ),
    "pendingHubSyncBanner": MessageLookupByLibrary.simpleMessage(
      "Einige Änderungen werden noch mit der Sitzung synchronisiert…",
    ),
    "petDefaultNamePrefix": MessageLookupByLibrary.simpleMessage("Begleiter"),
    "placeOfFinding": MessageLookupByLibrary.simpleMessage("Fundort"),
    "player": MessageLookupByLibrary.simpleMessage("Spieler"),
    "playerRolls": MessageLookupByLibrary.simpleMessage("Spieler Würfe"),
    "preview": MessageLookupByLibrary.simpleMessage("Vorschau"),
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
      "Veränderungshäufigkeit",
    ),
    "propertyEditTypeOneTap": MessageLookupByLibrary.simpleMessage(
      "Häufig verändert (bspw. jede Session)",
    ),
    "propertyEditTypeStatic": MessageLookupByLibrary.simpleMessage(
      "Selten verändert (bspw. je Level-Up)",
    ),
    "propertyIsCopied": MessageLookupByLibrary.simpleMessage(
      "Eigenschaft wurde kopiert",
    ),
    "propertyNameLabel": MessageLookupByLibrary.simpleMessage("Name:"),
    "realtimeSessionIosHint": MessageLookupByLibrary.simpleMessage(
      "Auf dem iPad oder iPhone funktionieren Live-Updates am zuverlässigsten, wenn die App im Vordergrund geöffnet ist.",
    ),
    "receivedItemsModalHeader": MessageLookupByLibrary.simpleMessage(
      "Neue Items",
    ),
    "receivedOneNewItemText": MessageLookupByLibrary.simpleMessage(
      "Du hast ein neues Item erhalten:",
    ),
    "receivedXNewItems": m12,
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
    "registerPrivacyNotice": m13,
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
    "rollOfInititive": MessageLookupByLibrary.simpleMessage("Reihenfolgenwurf"),
    "rpgConfigurationDmWizardStep2Tutorial":
        MessageLookupByLibrary.simpleMessage(
          "Nun kommen wir zu den Charakterbögen.\n\nJedes Rollenspiel hat unterschiedliche Eigenschaften, die die Spieler charakterisieren (z.B. wie viele Lebenspunkte ein Spieler hat).\n\nFür jede Eigenschaft musst du, als Spielleitung, definieren, wie die Spieler mit dieser Eigenschaft interagieren können. Hierbei benötigen wir für jede Eigenschaft drei Informationen von dir:\n\n1. Name der Eigenschaft: Wie soll dieser Wert auf dem Charakterbogen heißen? (z.B. „HP“, „SP“, „Name“, etc.)\n2. Werteart der Eigenschaft: Handelt es sich z.B. um einen Text, den der Spieler anpassen kann (z.B. Hintergrundgeschichte des Charakters) oder um einen Zahlenwert (z.B. die Lebenspunkte)?\n3. Änderungsart: Manche dieser Eigenschaften werden regelmäßig angepasst (z.B. die aktuellen Lebenspunkte), andere hingegen nur selten (z.B. die maximalen Lebenspunkte). Damit dies bei der Erstellung der Charakterbögen berücksichtigt werden kann, musst du uns diese Information mitteilen.\n\nEigenschaften ordnest du in Tabs und Gruppen. Halte eine Eigenschaft gedrückt, um sie zu verschieben.",
        ),
    "save": MessageLookupByLibrary.simpleMessage("Speichern"),
    "searchLabel": MessageLookupByLibrary.simpleMessage("Suche"),
    "secondValue": MessageLookupByLibrary.simpleMessage("Zweiter Wert"),
    "secondValuePlaceholder": MessageLookupByLibrary.simpleMessage(
      "Der zweiter Wert",
    ),
    "select": MessageLookupByLibrary.simpleMessage("Auswählen"),
    "selectAColor": MessageLookupByLibrary.simpleMessage("Farbe auswählen:"),
    "selectAnIcon": MessageLookupByLibrary.simpleMessage("Icon auswählen:"),
    "selectGameMode": MessageLookupByLibrary.simpleMessage("Rolle auswählen"),
    "selectIconModalTitle": MessageLookupByLibrary.simpleMessage(
      "Icon auswählen",
    ),
    "send": MessageLookupByLibrary.simpleMessage("Absenden"),
    "sendItems": MessageLookupByLibrary.simpleMessage("Items verschicken"),
    "sessionExpiredMessage": MessageLookupByLibrary.simpleMessage(
      "Deine Sitzung ist abgelaufen. Bitte melde dich erneut an.",
    ),
    "signInWithApple": MessageLookupByLibrary.simpleMessage(
      "Mit Apple anmelden",
    ),
    "signInWithGoogle": MessageLookupByLibrary.simpleMessage(
      "Mit Google anmelden",
    ),
    "singleLineText": MessageLookupByLibrary.simpleMessage("Einzeiliger Text"),
    "startAsDm": MessageLookupByLibrary.simpleMessage("Als DM spielen"),
    "tabIconsConfigurationTitle": MessageLookupByLibrary.simpleMessage(
      "Tab Icons",
    ),
    "tranformToAlternateForm": MessageLookupByLibrary.simpleMessage(
      "Verwandeln",
    ),
    "transformIntoAlternateForm": MessageLookupByLibrary.simpleMessage(
      "Verwandeln in eine andere Form",
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
    "uploadImageBtnLabel": MessageLookupByLibrary.simpleMessage(
      "Bild hochladen",
    ),
    "uploadImageMenuLabel": MessageLookupByLibrary.simpleMessage(
      "Bild hochladen",
    ),
    "user": MessageLookupByLibrary.simpleMessage("User:"),
    "username": MessageLookupByLibrary.simpleMessage("Nutzername"),
    "usernameRuleHint": MessageLookupByLibrary.simpleMessage(
      "3 bis 13 Zeichen, nur Buchstaben und Ziffern",
    ),
    "valueOfPropertyWithName": m14,
    "visibleCards": MessageLookupByLibrary.simpleMessage("Sichtbare Karten"),
    "visibleCardsHint": MessageLookupByLibrary.simpleMessage(
      "Ausgeblendete Karten bleiben auf diesem Gerät ausgeblendet, auch wenn ein Spieler zwischendurch offline war.",
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
    "wizardCampaignNameStepHelper": MessageLookupByLibrary.simpleMessage(
      "## Kampagnenname\n\nWir beginnen mit der wohl schwierigsten Frage überhaupt: Wie heißt deine Kampagne?\n\nDer Name braucht mindestens vier Zeichen.",
    ),
    "wizardCategoryItemCount": m15,
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
      "## Währung\n\nStelle ein, welche Währungen es in deiner Welt gibt und wie sie umgerechnet werden.\n\nFang mit der kleinsten Einheit an (z. B. Kupfer) und arbeite dich bis zur größten hoch. Gib bei jeder weiteren Währung an, wie viele der vorherigen sie wert ist (bei D&D: 10 Kupfer = 1 Silber).",
    ),
    "wizardCurrencyStepTitle": MessageLookupByLibrary.simpleMessage("Währung"),
    "wizardDeletePropertyMessage": m16,
    "wizardDeletePropertyTitle": MessageLookupByLibrary.simpleMessage(
      "Eigenschaft löschen?",
    ),
    "wizardDeleteTabMessage": m17,
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
    "wizardGroupLabel": m18,
    "wizardHideExplanation": MessageLookupByLibrary.simpleMessage(
      "Erklärung einklappen",
    ),
    "wizardIconForCategorySuffix": m19,
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
    "wizardLocationItemCount": m20,
    "wizardLocationLabel": m21,
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
    "wizardPropertyDeletedSnackbar": m22,
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
    "wizardRecipeIngredientLabel": m23,
    "wizardRecipeOpenDetails": MessageLookupByLibrary.simpleMessage(
      "Details öffnen",
    ),
    "wizardRecipeRequirementLabel": m24,
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
    "wizardSummaryItemCount": m25,
    "wizardSummaryNotSet": MessageLookupByLibrary.simpleMessage(
      "Noch nicht festgelegt",
    ),
    "wizardSummaryPropertyCount": m26,
    "wizardSummaryRecipeCount": m27,
    "wizardSummaryStepHelper": MessageLookupByLibrary.simpleMessage(
      "## Fertig!\n\nDeine Kampagne ist eingerichtet und alles ist gespeichert. Die Übersicht zeigt, was eingerichtet ist.\n\nÄndern kannst du alles später über das Zahnrad oben rechts.\n\nMit **Fertig** schließt du den Assistenten.",
    ),
    "wizardSummaryStepTitle": MessageLookupByLibrary.simpleMessage(
      "Zusammenfassung",
    ),
    "wizardSummaryTabCount": m28,
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
          "Du bearbeitest gerade eine kopierte Eigenschaft. Änderungen werden nur auf dieser Eigenschaft gespeichert und werden nicht auf den Haupt-Charakter übertragen.",
        ),
    "youAreEditingAnAlternateFormWarningText":
        MessageLookupByLibrary.simpleMessage(
          "Du bearbeitest gerade eine Verwandlungs-Form. Änderungen werden nur auf dieser Verwandlung gespeichert und werden resettet, wenn du dich zurück verwandelst. Wenn du dauerhafte Veränderungen deiner Form möchtest, bearbeite die Basis-Form (indem du dich zurück verwandelst und dort die Veränderungen einpflegst).",
        ),
    "youOwnXCampaigns": m29,
    "youOwnXCharacters": m30,
    "yourAreDisconnectedBody": MessageLookupByLibrary.simpleMessage(
      "Du bist nicht mehr verbunden... Entweder bist du oder der DM offline...",
    ),
  };
}
