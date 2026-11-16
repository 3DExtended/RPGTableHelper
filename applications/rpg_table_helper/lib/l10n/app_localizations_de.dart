// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get username => 'Nutzername';

  @override
  String get password => 'Passwort';

  @override
  String get characterNameDefault => 'Spielername';

  @override
  String get save => 'Speichern';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get firstValue => 'Erster Wert';

  @override
  String get firstValuePlaceholder => 'Der erste Wert';

  @override
  String get currentValue => 'Aktueller Wert';

  @override
  String get currentValuePlaceholder =>
      'Der aktuelle Wert für diese Eigenschaft';

  @override
  String get maxValue => 'Maximaler Wert';

  @override
  String get maxValuePlaceholder => 'Der maximale Wert für diese Eigenschaft';

  @override
  String get secondValue => 'Zweiter Wert';

  @override
  String get secondValuePlaceholder => 'Der zweite Wert';

  @override
  String get otherValue => 'Anderer Wert';

  @override
  String get otherValuePlaceholder => 'Der andere Wert';

  @override
  String get calculatedValue => 'Berechneter Wert';

  @override
  String get calculatedValuePlaceholder => 'Der berechnete Wert';

  @override
  String get configureProperties => 'Eigenschaften konfigurieren';

  @override
  String configurePropertiesForCharacterNameSuffix(String username) {
    return ' (für $username)';
  }

  @override
  String valueOfPropertyWithName(String property) {
    return 'Der Wert von $property';
  }

  @override
  String get newPetBtnLabel => 'Neuer Begleiter';

  @override
  String get petDefaultNamePrefix => 'Begleiter';

  @override
  String get preview => 'Vorschau';

  @override
  String get previewTestHint =>
      'Probiere die Steuerung aus — Änderungen hier werden nicht gespeichert.';

  @override
  String get previewTestReset => 'Zurücksetzen';

  @override
  String get newImageBtnLabel => 'Neues Bild';

  @override
  String get uploadImageBtnLabel => 'Bild hochladen';

  @override
  String get invalidImageFileSelected => 'Die gewählte Datei ist kein Bild.';

  @override
  String get additionalSettings => 'Erweiterte Optionen';

  @override
  String get hidePropertyForCharacter =>
      'Eigenschaft für meinen Charakter ausblenden';

  @override
  String get hideHeading => 'Überschrift ausblenden';

  @override
  String get addCharacterToCampagneModalTitle => 'Kampagne beitreten';

  @override
  String get assignCharacterToCampagneModalContent =>
      'Dein Charakter ist noch keiner Kampagne zugeordnet. Gib den Beitrittscode ein, den du von deiner Spielleitung bekommen hast. Sie bestätigt dann deine Anfrage.';

  @override
  String get joinCode => 'Beitrittscode';

  @override
  String get genericErrorModalHeader => 'Das hat nicht geklappt';

  @override
  String get genericErrorModalTechnicalDetailsHeader => 'Technische Details';

  @override
  String get genericErrorModalTechnicalDetailsErrorCodeRowLabel =>
      'Fehlercode:';

  @override
  String get genericErrorModalTechnicalDetailsExceptionRowLabel =>
      'Fehlertext:';

  @override
  String get nameOfPropertyLabel => 'Name der Eigenschaft';

  @override
  String get descriptionOfProperty => 'Hilfstext für die Eigenschaft';

  @override
  String get propertyEditTypeOneTap => 'Häufig geändert (z. B. jede Sitzung)';

  @override
  String get propertyEditTypeStatic =>
      'Selten geändert (z. B. beim Levelaufstieg)';

  @override
  String get propertyEditTypeLabel => 'Änderungshäufigkeit';

  @override
  String get generatedImage => 'Generiertes Bild';

  @override
  String get multilineText => 'Mehrzeiliger Text';

  @override
  String get singleLineText => 'Einzeiliger Text';

  @override
  String get integerValue => 'Zahlenwert';

  @override
  String get listOfIntegersWithIcons => 'Liste von Zahlenwerten mit Icons';

  @override
  String get integerValueWithMaxValue => 'Zahlenwert mit Maximalwert';

  @override
  String get listOfInterValuesWithCalculatedIntegerValues =>
      'Gruppe von Zahlenwerten mit zusätzlicher Zahl';

  @override
  String get integerValueWithCalculatedValue =>
      'Zahlenwert mit zusätzlicher Zahl';

  @override
  String get characterNameWithLevelAndConfigurableDetails =>
      'Charakter-Grundwerte (Level, Name und weitere, optionale Angaben)';

  @override
  String get multiselectOption => 'Mehrfachauswahl';

  @override
  String get companionOverview => 'Begleiterübersicht';

  @override
  String get companionSelectorIconHeadline => 'Icon';

  @override
  String get companionSelectorIconHint =>
      'Wird auf dem Charakterbogen über diesen Begleitern angezeigt, z. B. ein Schiff für Fahrzeuge.';

  @override
  String get forCompanionSelector => 'für Begleiter';

  @override
  String get kindOfProperty => 'Art der Eigenschaft';

  @override
  String get multiselectOptionsAreSelectableMultipleTimes =>
      'Optionen können mehrmals ausgewählt werden';

  @override
  String get optionalPropertyForCompanions =>
      'Optionale Eigenschaft für Begleiter';

  @override
  String get optionalPropertyForAlternateForms =>
      'Optionale Eigenschaft für andere Formen';

  @override
  String get optionsForMultiselect => 'Optionen für die Mehrfachauswahl';

  @override
  String get multiselectOptionName => 'Name:';

  @override
  String get multiselectOptionDescription => 'Beschreibung:';

  @override
  String get multiselectOptionSummary => 'Kurzfassung:';

  @override
  String get multiselectOptionSummaryHelper =>
      'Optional, ca. 90 Zeichen; erscheint auf dem Charakterbogen. Der volle Text bleibt in der Beschreibung.';

  @override
  String get additionalElement => 'Neues Element';

  @override
  String get moreValues => 'Weitere Werte';

  @override
  String get forIntegerValueWithName => 'für Zahlenwert';

  @override
  String get propertyNameLabel => 'Name:';

  @override
  String get completeRegistration => 'Registrierung abschließen';

  @override
  String get selectIconModalTitle => 'Icon auswählen';

  @override
  String get selectAColor => 'Farbe auswählen:';

  @override
  String get selectAnIcon => 'Icon auswählen:';

  @override
  String get item => 'Item';

  @override
  String get itemExampleDescription => 'Beschreibung eines Items';

  @override
  String get select => 'Auswählen';

  @override
  String get campaignManagement => 'Kampagnenverwaltung';

  @override
  String get characterOverview => 'Charakterübersicht';

  @override
  String get fightingOrdering => 'Kampfreihenfolge';

  @override
  String get grantItems => 'Items verteilen';

  @override
  String get lore => 'Notizen';

  @override
  String get online => 'Online';

  @override
  String get offline => 'Offline';

  @override
  String get allPlayers => 'Alle Spieler:';

  @override
  String get openJoinRequests => 'Beitrittsanfragen';

  @override
  String joinCodeForNewPlayers(String code) {
    return 'Beitrittscode: $code';
  }

  @override
  String get noOpenJoinRequests => 'Keine offenen Anfragen';

  @override
  String get user => 'Benutzer:';

  @override
  String get character => 'Charakter:';

  @override
  String get lastGrantedItems => 'Letzte verteilte Items';

  @override
  String get noItemsGranted => 'Noch keine Items verteilt.';

  @override
  String get placeOfFinding => 'Fundort';

  @override
  String get playerRolls => 'Würfe der Spieler';

  @override
  String get diceRoll => 'Wurf';

  @override
  String get player => 'Spieler';

  @override
  String get sendItems => 'Items verschicken';

  @override
  String get itemsToBeFoundInPlaceMarkdown => '## Items an diesem Fundort';

  @override
  String get noPlaceOfFindingSelected =>
      'Es wurde noch kein Fundort ausgewählt.';

  @override
  String get followingItemsArePossibleAtPlaceOfFinding =>
      'Diese Items gibt es hier:';

  @override
  String get diceChallengeAbbr => 'SG';

  @override
  String get lastGrantedItemsMarkdownPrefix =>
      'Zuletzt wurden diese Items verteilt:';

  @override
  String get noItemsGrantedToPlayerThisRound => 'Keine Items in dieser Runde';

  @override
  String grantItemsFailedForPlayers(String characterNames) {
    return 'Die Items konnten nicht an $characterNames verteilt werden. Bitte versuche es erneut.';
  }

  @override
  String get login => 'Anmelden';

  @override
  String get signInWithApple => 'Mit Apple anmelden';

  @override
  String get signInWithGoogle => 'Mit Google anmelden';

  @override
  String get createNewAccount => 'Neues Konto anlegen';

  @override
  String get email => 'E-Mail';

  @override
  String get register => 'Registrieren';

  @override
  String get itemDetailsForPrefix => 'Item-Details für';

  @override
  String get itemDetailsDescriptionHeader => 'Beschreibung:';

  @override
  String get itemDetailsPriceHeader => 'Preis:';

  @override
  String get amount => 'Anzahl';

  @override
  String get receivedItemsModalHeader => 'Neue Items';

  @override
  String get newItemsMarkdownPlural => '# Neue Items';

  @override
  String get newItemsMarkdownSingular => '# Neues Item';

  @override
  String get receivedOneNewItemText => 'Du hast ein neues Item erhalten:';

  @override
  String receivedXNewItems(int amount) {
    String _temp0 = intl.Intl.pluralLogic(
      amount,
      locale: localeName,
      other: 'Du hast $amount neue Items erhalten:',
      one: 'Du hast ein neues Item erhalten:',
    );
    return '$_temp0';
  }

  @override
  String get ok => 'OK';

  @override
  String get rpgConfigurationDmWizardStep2Tutorial =>
      'Nun kommen wir zu den Charakterbögen.\n\nJedes Rollenspiel hat unterschiedliche Eigenschaften, die die Spieler charakterisieren (z.B. wie viele Lebenspunkte ein Spieler hat).\n\nFür jede Eigenschaft musst du, als Spielleitung, definieren, wie die Spieler mit dieser Eigenschaft interagieren können. Hierbei benötigen wir für jede Eigenschaft drei Informationen von dir:\n\n1. Name der Eigenschaft: Wie soll dieser Wert auf dem Charakterbogen heißen? (z.B. „HP“, „SP“, „Name“, etc.)\n2. Werteart der Eigenschaft: Handelt es sich z.B. um einen Text, den der Spieler anpassen kann (z.B. Hintergrundgeschichte des Charakters) oder um einen Zahlenwert (z.B. die Lebenspunkte)?\n3. Änderungsart: Manche dieser Eigenschaften werden regelmäßig angepasst (z.B. die aktuellen Lebenspunkte), andere hingegen nur selten (z.B. die maximalen Lebenspunkte). Damit dies bei der Erstellung der Charakterbögen berücksichtigt werden kann, musst du uns diese Information mitteilen.\n\nEigenschaften ordnest du in Tabs und Gruppen. Halte eine Eigenschaft gedrückt, um sie zu verschieben.';

  @override
  String get levelAbbr => 'LVL';

  @override
  String get addAdditionalEnemy => 'Neue Gegner hinzufügen';

  @override
  String get enemyName => 'Gegnername';

  @override
  String get rollOfInititive => 'Initiativewurf';

  @override
  String get addAnAdditionalEnemyBtnLabel => 'Weiterer Gegner';

  @override
  String get enemy => 'Gegner';

  @override
  String get add => 'Hinzufügen';

  @override
  String get initiativeRollForCharacterPrefix => 'Initiativewurf';

  @override
  String get initiativeRollText =>
      'Ein Kampf beginnt. Würfle deine Initiative!';

  @override
  String get initiativeRollTextFieldLabel => 'Dein Wurf';

  @override
  String initiativeBonusHelperSentence(Object formattedBonus, Object label) {
    return 'Addiere $label $formattedBonus zu deinem Wurf';
  }

  @override
  String get fightInitiativeStepTitle => 'Kampf / Initiative';

  @override
  String get fightInitiativeStepTutorial =>
      'Markiere, welcher Wert der Initiative-Bonus ist.\n\nWenn ein Spieler die Initiative würfeln soll, zeigt die App ihm diesen Bonus an. So muss er ihn nicht im Kopf haben, während das Wurffenster den Charakterbogen verdeckt.\n\nWähle **Keine**, falls dein System keinen Bonus verwendet. Sonst wähle unten einen Wert aus. Ist es eine Gruppe von Werten (z. B. Fähigkeiten), wähle zusätzlich den passenden Eintrag. Besteht der Wert aus zwei Zahlen (z. B. Wert und Modifikator oder aktuell und maximal), wähle, welche davon als Bonus zählt.';

  @override
  String get initiativeBonusNoneOption => 'Keine';

  @override
  String get initiativeBonusStatPickerLabel => 'Eigenschaft';

  @override
  String get initiativeBonusListEntryPickerLabel => 'Listeneintrag';

  @override
  String get initiativeBonusFieldPickerLabel => 'Feld';

  @override
  String get initiativeBonusIncompleteWarningTitle => 'Unvollständige Auswahl';

  @override
  String get initiativeBonusIncompleteWarningBody =>
      'Deine Auswahl für den Initiative-Bonus ist unvollständig. Wenn du die Seite verlässt, wird sie gelöscht.';

  @override
  String get initiativeBonusIncompleteStay => 'Bleiben';

  @override
  String get initiativeBonusIncompleteLeave => 'Trotzdem verlassen';

  @override
  String get send => 'Absenden';

  @override
  String get editPageTitle => 'Seite bearbeiten';

  @override
  String get editPageModalText =>
      'Hier änderst du den Titel und die Gruppe deiner Seite.';

  @override
  String get documentTitleLabel => 'Titel';

  @override
  String get documentGroupLabel => 'Gruppenname';

  @override
  String get recipeForTitlePrefix => 'Rezept für';

  @override
  String get recipeRequirements => 'Voraussetzungen:';

  @override
  String get recipeIngredients => 'Zutaten:';

  @override
  String get requiredIngredientCountPrefix => 'Benötigt:';

  @override
  String get ownedIngredientCountPrefix => 'im Besitz:';

  @override
  String get amountToCraftFieldLabel => 'Anzahl';

  @override
  String get craft => 'Herstellen';

  @override
  String get newItem => 'Neu';

  @override
  String get defaultGroupNameForDocuments => 'Sonstiges';

  @override
  String get documentDefaultNamePrefix => 'Dokument';

  @override
  String get authorLabel => 'Autor:';

  @override
  String get you => 'Du';

  @override
  String get dm => 'Spielleitung';

  @override
  String get hourMinutesDayMonthYearFormatString => '%H:%M %d.%m.%Y';

  @override
  String get addParagraphBtnLabel => 'Absatz';

  @override
  String get addImageBtnLabel => 'Bild';

  @override
  String get newGroup => 'Neue Gruppe:';

  @override
  String get newGroupBtnLabel => 'Neue Gruppe';

  @override
  String get newPropertyBtnLabel => 'Neue Eigenschaft';

  @override
  String get newTabBtnLabel => 'Neuer Tab';

  @override
  String get itemCardDescRequires => 'Braucht:';

  @override
  String get defaultTab => 'Start-Tab';

  @override
  String get amountHeaderLabel => 'Anzahl:';

  @override
  String get noItemsInCategoryErrorText => 'Keine Items unter dieser Kategorie';

  @override
  String get searchLabel => 'Suche';

  @override
  String get itemSortByName => 'Nach Name sortieren (A–Z)';

  @override
  String get itemSortByValueAscending => 'Nach Wert sortieren (aufsteigend)';

  @override
  String get itemSortByValueDescending => 'Nach Wert sortieren (absteigend)';

  @override
  String get itemCategoryFilterAll => 'Alles';

  @override
  String get craftableRecipeFilter => 'Herstellbar';

  @override
  String get notCraftableRecipeFilter => 'Nicht herstellbar';

  @override
  String get noItemsInCategoryCraftable =>
      'In dieser Kategorie sind keine Items herstellbar';

  @override
  String get noItemsInCategoryNotCraftable =>
      'In dieser Kategorie sind alle Items herstellbar';

  @override
  String get noItemsInCategory => 'Keine Items unter dieser Kategorie';

  @override
  String get craftableAmountText => 'Herstellbar:';

  @override
  String get navBarHeaderCrafting => 'Herstellen';

  @override
  String get navBarHeaderLore => 'Notizen';

  @override
  String get navBarHeaderInventory => 'Inventar';

  @override
  String get navBarHeaderMoney => 'Währung';

  @override
  String get noMoneyDefaultText => '0 Gold';

  @override
  String get currentBalance => 'Aktuelles Guthaben';

  @override
  String get addBalance => 'Guthaben hinzufügen';

  @override
  String get reduceBalance => 'Guthaben abziehen';

  @override
  String get newBalance => 'Neues Guthaben';

  @override
  String get notEnoughBalance => 'Zu wenig Geld für diese Ausgabe';

  @override
  String get noteblockVisibleFor => 'Sichtbar für:';

  @override
  String get nothingSelected => '- Nichts ausgewählt -';

  @override
  String get characterNameLabel => 'Name:';

  @override
  String get level => 'Level';

  @override
  String get count => 'Anzahl';

  @override
  String get addItems => 'Items hinzufügen';

  @override
  String get selectGameMode => 'Rolle auswählen';

  @override
  String get chooseACampagne => 'Kampagne auswählen';

  @override
  String get startAsDm => 'Als Spielleitung';

  @override
  String youOwnXCampaigns(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Du leitest $count Kampagnen.',
      one: 'Du leitest 1 Kampagne.',
      zero: 'Du leitest noch keine Kampagne.',
    );
    return '$_temp0';
  }

  @override
  String get joinAsPlayer => 'Als Spieler';

  @override
  String get chooseACharacter => 'Charakter auswählen';

  @override
  String youOwnXCharacters(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Du hast $count Charaktere.',
      one: 'Du hast 1 Charakter.',
      zero: 'Du hast noch keinen Charakter.',
    );
    return '$_temp0';
  }

  @override
  String get campaigneName => 'Name';

  @override
  String get helperTextForNameOfCampaign => 'Wie soll die Kampagne heißen?';

  @override
  String get newCampaign => 'Neue Kampagne';

  @override
  String get noPlayersOnline => 'Gerade ist kein Spieler online';

  @override
  String get currentFightOrdering => 'Aktuelle Kampfreihenfolge';

  @override
  String get noFIghtStarted => 'Gerade läuft kein Kampf';

  @override
  String get newFightOrdering => 'Neue Kampfreihenfolge';

  @override
  String get additionalFightParticipants => 'Weitere Teilnehmer';

  @override
  String get rollForInitiativeBtnLabel => 'Kampfreihenfolge würfeln';

  @override
  String get rollForInitiative => 'Kampfreihenfolge würfeln';

  @override
  String get characterName => 'Name';

  @override
  String get nameOfCharacterHelperText => 'Wie heißt dein Charakter?';

  @override
  String get campaignName => 'Kampagnenname';

  @override
  String get tranformToAlternateForm => 'Verwandeln';

  @override
  String get transformIntoAlternateForm => 'In eine andere Form verwandeln';

  @override
  String get addNewTransformationComponent => 'Verwandlung hinzufügen';

  @override
  String get createNewTransformationTitle => 'Neue Verwandlung erstellen';

  @override
  String get transformationName => 'Verwandlungsname';

  @override
  String get transformationDescription => 'Beschreibung';

  @override
  String get createTransformationHelperText =>
      'Wähle die Eigenschaften aus, die sich durch diese Verwandlung ändern. Alle anderen bleiben, wie sie sind.';

  @override
  String get back => 'Zurück';

  @override
  String get next => 'Weiter';

  @override
  String get warning => 'Warnung';

  @override
  String get youAreEditingAnAlternateFormWarningText =>
      'Du bearbeitest gerade eine Verwandlung. Änderungen gelten nur für diese Verwandlung und gehen verloren, wenn du dich zurückverwandelst. Für dauerhafte Änderungen verwandle dich zurück und bearbeite deine Grundform.';

  @override
  String get transformationIsEditedWarningTitle =>
      'Verwandlung wird bearbeitet';

  @override
  String get propertyIsCopied => 'Eigenschaft wurde kopiert';

  @override
  String get youAreEditingACopiedPropertyChangesWillNotAffect =>
      'Du bearbeitest gerade eine kopierte Eigenschaft. Änderungen gelten nur hier und werden nicht auf den Hauptcharakter übertragen.';

  @override
  String get previousTransformationSelectionBtn => 'Alte Gestalt';

  @override
  String get newTransformationSelectionBtn => 'Neue Gestalt';

  @override
  String get no => 'Nein';

  @override
  String get yes => 'Ja';

  @override
  String get yourAreDisconnectedBody =>
      'Die Verbindung ist unterbrochen. Entweder du oder deine Spielleitung ist offline.';

  @override
  String get characterNameStatTitle => 'Charaktername';

  @override
  String get characterNameStatHelperText => 'Wie heißt dein Charakter?';

  @override
  String get generateImageBtnLabel => 'Bild generieren';

  @override
  String get generateLoreImageTitle => 'Bild generieren';

  @override
  String get characterPortraitImagePrompt => 'Porträtbeschreibung';

  @override
  String get characterPortraitImagePromptPlaceholder =>
      'Beschreibe deinen Charakter für die Bildgenerierung';

  @override
  String get generatedImagesTabTitle => 'Generierte Bilder';

  @override
  String get noImagesInCampagne =>
      'Du hast in dieser Kampagne noch keine Bilder generiert.';

  @override
  String get enterANameDefaultLabel => 'Gib einen Namen ein';

  @override
  String get enterSomeDescriptionOnTheLeft =>
      'Gib links eine Beschreibung ein.';

  @override
  String get tabIconsConfigurationTitle => 'Tab-Icons';

  @override
  String get realtimeSessionIosHint =>
      'Auf dem iPad oder iPhone funktionieren Live-Updates am zuverlässigsten, wenn die App im Vordergrund geöffnet ist.';

  @override
  String get pendingHubSyncBanner =>
      'Einige Änderungen werden noch mit der Sitzung synchronisiert…';

  @override
  String get characterConfigSaveFailedTitle => 'Charakter nicht gespeichert';

  @override
  String get characterConfigSaveFailedBody =>
      'Deine Änderungen am Charakter konnten nicht gespeichert werden. Prüfe deine Verbindung und versuche es erneut.';

  @override
  String get logout => 'Abmelden';

  @override
  String get sessionExpiredMessage =>
      'Deine Sitzung ist abgelaufen. Bitte melde dich erneut an.';

  @override
  String get characterSheetSkinClassicLight => 'Klassisch Hell';

  @override
  String get characterSheetSkinClassicDark => 'Klassisch Dunkel';

  @override
  String get characterSheetSkinArcaneLedger => 'Arkaner Foliant';

  @override
  String get characterSheetSkinNightCartographer => 'Nachtkartograph';

  @override
  String get characterSheetSkinUseCampaignDefault =>
      'Kampagnen-Standard verwenden';

  @override
  String get characterSheetSkinCampaignDefaultLabel => 'Kampagnen-Standard';

  @override
  String get characterSheetAppearanceTitle => 'Darstellung';

  @override
  String get apiKeysTitle => 'API-Schlüssel';

  @override
  String get apiKeysDocsTitle => 'API-Dokumentation';

  @override
  String get apiKeysDocsDescription =>
      'Mit API-Schlüsseln kann eine andere App, etwa eine Begleit-App aus deiner Gruppe, für dich als Spieler handeln. Jeder Schlüssel darf nur, was du ihm erlaubst.';

  @override
  String get apiKeysViewDocs => 'API-Dokumentation öffnen';

  @override
  String get apiKeysGenerate => 'Neuen API-Schlüssel erstellen';

  @override
  String get apiKeysEmpty => 'Noch keine API-Schlüssel.';

  @override
  String get apiKeysLoadFailed =>
      'Deine API-Schlüssel konnten nicht geladen werden.';

  @override
  String get apiKeyUnnamed => 'Unbenannter Schlüssel';

  @override
  String get apiKeyRevoked => 'Widerrufen';

  @override
  String get apiKeyExpired => 'Abgelaufen';

  @override
  String apiKeyPrefix(String prefix) {
    return 'Präfix: $prefix';
  }

  @override
  String apiKeyRevokedAt(String date) {
    return 'Widerrufen: $date';
  }

  @override
  String apiKeyLastUsedAt(String date) {
    return 'Zuletzt benutzt: $date';
  }

  @override
  String get apiKeyNeverUsed => 'Noch nie benutzt';

  @override
  String apiKeyExpiresAt(String date) {
    return 'Läuft ab: $date';
  }

  @override
  String get apiKeyNeverExpires => 'Läuft nie ab';

  @override
  String get apiKeyRevokeTitle => 'API-Schlüssel widerrufen?';

  @override
  String get apiKeyRevokeBody =>
      'Das lässt sich nicht rückgängig machen. Jede App, die diesen Schlüssel nutzt, verliert sofort den Zugriff.';

  @override
  String get apiKeyRevokeConfirm => 'Widerrufen';

  @override
  String get apiKeyRevokeFailed =>
      'Der API-Schlüssel konnte nicht widerrufen werden.';

  @override
  String get apiKeyCreateTitle => 'Neuer API-Schlüssel';

  @override
  String get apiKeyCreateHint =>
      'Gib Schlüssel nur an Apps, denen du vertraust. Sie handeln in deinem Namen.';

  @override
  String get apiKeyNameLabel => 'Name, z. B. die App, die ihn nutzt';

  @override
  String get apiKeyPermissionsLabel => 'Rechte';

  @override
  String get apiKeyPresetReadOnly => 'Nur lesen';

  @override
  String get apiKeyPresetCompanion => 'Begleit-App für Spieler';

  @override
  String get apiKeyPresetCustom => 'Benutzerdefiniert';

  @override
  String get apiKeyScopeCampaignsRead => 'Deine Kampagnen und Mitspieler sehen';

  @override
  String get apiKeyScopeCharactersRead => 'Deine Charakterbögen lesen';

  @override
  String get apiKeyScopeCharactersWrite =>
      'Deine Charakterbögen ändern, z. B. Lebenspunkte';

  @override
  String get apiKeyScopeNotesRead => 'Die Notizen lesen, die du sehen darfst';

  @override
  String get apiKeyScopeNotesWrite =>
      'Eigene Notizen schreiben und festlegen, wer sie sieht';

  @override
  String get apiKeyScopeFightsPlay =>
      'Initiative würfeln, wenn die Spielleitung einen Kampf startet';

  @override
  String get apiKeyScopeEvents => 'Live-Updates empfangen';

  @override
  String get apiKeyExpiryLabel => 'Gültig für';

  @override
  String get apiKeyPermissionsNeedServerUpdate =>
      'Dieser Server gibt jedem Schlüssel Lesezugriff auf deine Kampagnen, Charaktere und Notizen. Rechte und Laufzeit kannst du wählen, sobald der Server aktualisiert ist.';

  @override
  String get apiKeyExpiryNever => 'Unbegrenzt';

  @override
  String get apiKeyExpiry30Days => '30 Tage';

  @override
  String get apiKeyExpiry90Days => '90 Tage';

  @override
  String get apiKeyExpiry1Year => '1 Jahr';

  @override
  String get apiKeyCreateConfirm => 'Erstellen';

  @override
  String get apiKeyNameRequired => 'Gib einen Namen ein.';

  @override
  String get apiKeyNoScopeSelected => 'Wähle mindestens ein Recht aus.';

  @override
  String get apiKeyCreateFailed =>
      'Der API-Schlüssel konnte nicht erstellt werden.';

  @override
  String get apiKeyCreatedTitle => 'API-Schlüssel erstellt';

  @override
  String get apiKeyCreatedBody =>
      'Kopiere den neuen Schlüssel jetzt. Er wird dir nicht noch einmal angezeigt.';

  @override
  String get apiKeyCopy => 'Kopieren';

  @override
  String get apiKeyCopied => 'In die Zwischenablage kopiert';

  @override
  String get apiKeyDone => 'Fertig';

  @override
  String get endFight => 'Kampf beenden';

  @override
  String get endFightConfirmation =>
      'Kampf wirklich beenden? Wer noch nicht gewürfelt hat, wird dann nicht mehr gefragt.';

  @override
  String get waitingForInitiative => 'Wartet auf Initiative';

  @override
  String get notAtTheTable => 'nicht am Tisch';

  @override
  String get noCharactersInCampagne =>
      'Noch keine Charaktere in dieser Kampagne';

  @override
  String get customizeCards => 'Karten anpassen';

  @override
  String get hiddenCards => 'Ausgeblendet';

  @override
  String get allCardsHidden => 'Alle Karten sind ausgeblendet';

  @override
  String get visibleCards => 'Sichtbare Karten';

  @override
  String get visibleCardsHint =>
      'Ausgeblendete Karten bleiben auf diesem Gerät ausgeblendet, auch wenn ein Spieler zwischendurch offline war.';

  @override
  String get cardStatsSection => 'Eigenschaften auf den Karten';

  @override
  String get chooseCardStatsYourself => 'Eigenschaften selbst wählen';

  @override
  String get automaticCardStatsHint =>
      'Automatisch: der erste Wert mit Maximum als Balken und die ersten Zahlen aus dem Standard-Tab.';

  @override
  String get cardBar => 'Balken';

  @override
  String get noBar => 'Kein Balken';

  @override
  String get cardNumbers => 'Zahlen';

  @override
  String get companion => 'Begleiter';

  @override
  String get calculatedValueShort => 'ber.';

  @override
  String get noCardStatsAvailable =>
      'Diese Kampagne hat noch keine Eigenschaften mit Zahlen.';

  @override
  String get maxValueShort => 'Max.';

  @override
  String get computedValue => 'Wert berechnen';

  @override
  String get computedValueHint =>
      'Spieler tragen diesen Wert nicht ein: Er wird aus anderen Eigenschaften berechnet, z. B. passive Wahrnehmung = 10 + Mod(Weisheit) + Übungsbonus (wenn geübt). Modifikatoren werden abgerundet.';

  @override
  String get computedBase => 'Startwert';

  @override
  String get computedTerms => 'Bausteine';

  @override
  String get addComputedTerm => 'Baustein hinzufügen';

  @override
  String get computedSource => 'Wert';

  @override
  String get computedMode => 'Umrechnung';

  @override
  String get computedModeValue => 'wie er ist';

  @override
  String get computedModeModifier => 'Modifikator (x−10)/2';

  @override
  String get computedFactor => 'Faktor';

  @override
  String get computedCondition => 'Zählt nur, wenn gewählt';

  @override
  String get computedAlways => 'Immer';

  @override
  String get computedPreview => 'Formel';

  @override
  String get computedValueNoSources =>
      'Lege zuerst Eigenschaften mit Zahlen an.';

  @override
  String computedModifierOf(String label) {
    return 'Mod($label)';
  }

  @override
  String computedIfPicked(String condition) {
    return '(wenn $condition)';
  }

  @override
  String get computedValueBadge => 'berechnet';

  @override
  String get computedPreset => 'Vorlage (Fantasy 5E)';

  @override
  String get computedPresetPassivePerception => 'Passive Wahrnehmung';

  @override
  String get computedPresetPassiveInsight => 'Passives Motiv erkennen';

  @override
  String get computedPresetPassiveInvestigation => 'Passive Nachforschungen';

  @override
  String get computedPresetPassiveStealth => 'Passive Heimlichkeit';

  @override
  String get computedPresetInitiative => 'Initiative';

  @override
  String get computedPresetUnarmoredArmorClass => 'RK ohne Rüstung';

  @override
  String get computedPresetIncomplete =>
      'Nicht alle Werte der Vorlage gibt es in dieser Kampagne. Ergänze die fehlenden Bausteine selbst.';

  @override
  String get attachImageBtnLabel => 'Bild hinzufügen';

  @override
  String get replaceImageBtnLabel => 'Bild ersetzen';

  @override
  String get removeImageBtnLabel => 'Bild entfernen';

  @override
  String get uploadImageMenuLabel => 'Bild hochladen';

  @override
  String get insertParagraphMenuLabel => 'Absatz hier einfügen';

  @override
  String get connectionLostReconnecting =>
      'Verbindung unterbrochen – verbinde neu …';

  @override
  String get appName => 'QuestKeeper';

  @override
  String get welcomeTagline =>
      'Dein Begleiter für Pen-&-Paper-Runden am Tisch.';

  @override
  String get welcomeDescription =>
      'Die Spielleitung verwaltet die Kampagne. Die Spieler haben ihren Charakterbogen, ihre Notizen und die Live-Werte auf dem Handy.';

  @override
  String get welcomeLeadButton => 'Ich leite eine Runde';

  @override
  String get welcomeLeadHint =>
      'Du legst eine Kampagne an und lädst deine Gruppe ein.';

  @override
  String get welcomeJoinButton => 'Ich trete einer Runde bei';

  @override
  String get welcomeJoinHint =>
      'Nach der Anmeldung gibst du den Code deiner Spielleitung ein.';

  @override
  String get loginIntroLead =>
      'Melde dich an oder lege ein Konto an. Danach legst du deine Kampagne an.';

  @override
  String get loginIntroJoin =>
      'Melde dich an oder lege ein Konto an. Danach gibst du den Code deiner Spielleitung ein.';

  @override
  String get loginMissingInput => 'Bitte gib Nutzername und Passwort ein.';

  @override
  String get loginWrongCredentials => 'Nutzername oder Passwort stimmt nicht.';

  @override
  String get forgotPasswordLink => 'Passwort vergessen?';

  @override
  String get usernameRuleHint => '3 bis 13 Zeichen, nur Buchstaben und Ziffern';

  @override
  String get passwordRulesTitle => 'Dein Passwort braucht';

  @override
  String passwordRuleMinLength(int count) {
    return 'mindestens $count Zeichen';
  }

  @override
  String passwordRuleMaxLength(int count) {
    return 'höchstens $count Zeichen';
  }

  @override
  String get passwordRuleMet => 'erfüllt';

  @override
  String get passwordRuleNotMet => 'noch nicht erfüllt';

  @override
  String get registerUsernameInvalid =>
      'Der Nutzername braucht 3 bis 13 Zeichen, nur Buchstaben und Ziffern.';

  @override
  String get registerEmailInvalid =>
      'Bitte gib eine gültige E-Mail-Adresse ein.';

  @override
  String get registerPasswordInvalid =>
      'Das Passwort erfüllt noch nicht alle Regeln.';

  @override
  String get registerUsernameTaken =>
      'Diesen Nutzernamen gibt es schon. Bitte wähle einen anderen.';

  @override
  String registerPrivacyNotice(String privacyPolicyLink) {
    return 'Wie wir mit deinen Daten umgehen, steht in unserer $privacyPolicyLink.';
  }

  @override
  String get privacyPolicyLinkLabel => 'Datenschutzerklärung';

  @override
  String get registerPrivacyNoticeWithoutLink =>
      'Deine E-Mail-Adresse brauchen wir nur für dein Konto, zum Beispiel zum Zurücksetzen des Passworts.';

  @override
  String get forgotPasswordTitle => 'Passwort zurücksetzen';

  @override
  String get forgotPasswordRequestIntro =>
      'Gib deinen Nutzernamen und die E-Mail-Adresse deines Kontos ein. Wir schicken dir einen Code.';

  @override
  String get forgotPasswordRequestButton => 'Code anfordern';

  @override
  String get forgotPasswordRequestFailed =>
      'Wir konnten keinen Code schicken. Prüfe Nutzername und E-Mail-Adresse. Wenn du dich mit Apple anmeldest, brauchst du kein Passwort.';

  @override
  String forgotPasswordCodeSent(String email) {
    return 'Wir haben dir einen Code an $email geschickt. Er gilt zwei Stunden.';
  }

  @override
  String get resetCodeLabel => 'Code aus der E-Mail';

  @override
  String get resetCodeHint => 'z. B. 123-456';

  @override
  String get resetCodeInvalid => 'Der Code hat sechs Ziffern, z. B. 123-456.';

  @override
  String get newPasswordLabel => 'Neues Passwort';

  @override
  String get forgotPasswordSaveButton => 'Passwort speichern';

  @override
  String get forgotPasswordResetFailed =>
      'Das hat nicht geklappt: Der Code stimmt nicht oder ist abgelaufen. Fordere bei Bedarf einen neuen an.';

  @override
  String get forgotPasswordRequestNewCode => 'Neuen Code anfordern';

  @override
  String get forgotPasswordSuccess =>
      'Dein Passwort ist geändert. Melde dich jetzt mit dem neuen Passwort an.';

  @override
  String get forgotPasswordBackToLogin => 'Zur Anmeldung';

  @override
  String get authNoConnection =>
      'Der Server ist gerade nicht erreichbar. Versuch es gleich noch einmal.';

  @override
  String get wizardFinishBtnLabel => 'Fertig';

  @override
  String get wizardSkipBtnLabel => 'Überspringen';

  @override
  String get wizardOptionalStepLabel => 'Optionaler Schritt';

  @override
  String get wizardShowExplanation => 'Erklärung anzeigen';

  @override
  String get wizardHideExplanation => 'Erklärung einklappen';

  @override
  String get wizardSavedSnackbar => 'Einrichtung gespeichert';

  @override
  String get confirmDeleteBtnLabel => 'Löschen';

  @override
  String get wizardUndo => 'Rückgängig';

  @override
  String get wizardSkinStepHelper =>
      '## Willkommen bei QuestKeeper!\n\nIn den nächsten Schritten richtest du deine Kampagne ein: Darstellung, Name, Charakterbogen, Initiative und Währung. Danach folgen optionale Schritte für Items und Crafting, die du überspringen kannst.\n\nAlles wird automatisch gespeichert. Mit dem X oben links schließt du den Assistenten jederzeit; über das Zahnrad oben rechts kommst du später wieder hierher.\n\n## Darstellung\n\nWähle das Standard-Aussehen der Charakterbögen in dieser Kampagne. Spieler können es später für ihre eigenen Charaktere ändern.';

  @override
  String get wizardCampaignNameStepHelper =>
      '## Kampagnenname\n\nWir beginnen mit der wohl schwierigsten Frage überhaupt: Wie heißt deine Kampagne?\n\nDer Name braucht mindestens vier Zeichen.';

  @override
  String get wizardCharacterSheetStepTitle => 'Charakterbogen';

  @override
  String get wizardTabNameLabel => 'Name des Tabs';

  @override
  String get wizardUnnamedTab => 'Unbenannter Tab';

  @override
  String get wizardUnnamedProperty => 'Unbenannte Eigenschaft';

  @override
  String wizardGroupLabel(int number) {
    return 'Gruppe $number';
  }

  @override
  String get wizardDeleteTabTitle => 'Tab löschen?';

  @override
  String wizardDeleteTabMessage(int count, String tabName) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Tab „$tabName“ mit $count Eigenschaften löschen? Werte der Charaktere gehen verloren.',
      one:
          'Tab „$tabName“ mit einer Eigenschaft löschen? Werte der Charaktere gehen verloren.',
      zero: 'Den leeren Tab „$tabName“ löschen?',
    );
    return '$_temp0';
  }

  @override
  String get wizardDeletePropertyTitle => 'Eigenschaft löschen?';

  @override
  String wizardDeletePropertyMessage(int count, String name) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Eigenschaft „$name“ löschen? $count Charaktere haben dafür schon Werte, sie gehen verloren.',
      one:
          'Eigenschaft „$name“ löschen? Ein Charakter hat dafür schon einen Wert, er geht verloren.',
    );
    return '$_temp0';
  }

  @override
  String wizardPropertyDeletedSnackbar(String name) {
    return 'Eigenschaft „$name“ gelöscht';
  }

  @override
  String get wizardCurrencyStepTitle => 'Währung';

  @override
  String get wizardCurrencyStepHelper =>
      '## Währung\n\nStelle ein, welche Währungen es in deiner Welt gibt und wie sie umgerechnet werden.\n\nFang mit der kleinsten Einheit an (z. B. Kupfer) und arbeite dich bis zur größten hoch. Gib bei jeder weiteren Währung an, wie viele der vorherigen sie wert ist (in vielen Fantasy-Rollenspielen: 10 Kupfer = 1 Silber).';

  @override
  String get wizardSmallestCurrencyLabel => 'Name der kleinsten Währung:';

  @override
  String get wizardNextCurrencyLabel => 'Name der nächstgrößeren Währung:';

  @override
  String get wizardCurrencyMultipleLabel =>
      'Entspricht wie vielen der vorherigen Währung:';

  @override
  String get wizardNewEntryDefaultName => 'Neu';

  @override
  String get wizardLocationsStepTitle => 'Fundorte';

  @override
  String get wizardLocationsStepHelper =>
      '## Fundorte (optional)\n\nAb hier geht es um Items und Crafting. Diesen und die folgenden Schritte (Fundorte, Item-Kategorien, Items, Rezepte) brauchst du nur, wenn ihr damit spielt. Mit **Überspringen** geht es direkt zur Zusammenfassung; schon angelegte Daten bleiben erhalten.\n\nManche Items lassen sich an bestimmten Orten finden: am Strand, in Höhlen, in Grotten und so weiter. Lege hier die Orte an, damit du sie in den nächsten Schritten mit Items verknüpfen kannst.';

  @override
  String wizardLocationLabel(int number) {
    return 'Fundort #$number';
  }

  @override
  String wizardLocationItemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'An diesem Fundort können $count Items gefunden werden.',
      one: 'An diesem Fundort kann ein Item gefunden werden.',
      zero: 'An diesem Fundort gibt es noch keine Items.',
    );
    return '$_temp0';
  }

  @override
  String get wizardItemCategoriesStepTitle => 'Item-Kategorien';

  @override
  String get wizardItemCategoriesStepHelper =>
      '## Item-Kategorien (optional)\n\nDamit die Spieler ihre Items filtern können, sortieren wir sie in Kategorien ein. Dafür haben wir dir eine Reihe von Kategorien und Unterkategorien vorbereitet.\n\nPasse sie gern an, wenn sie nicht zu eurem Rollenspiel passen.';

  @override
  String get wizardCategoryNameLabel => 'Name der Kategorie:';

  @override
  String get wizardSubCategoryNameLabel => 'Name der Unterkategorie:';

  @override
  String wizardCategoryItemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'In dieser Kategorie sind $count Items.',
      one: 'In dieser Kategorie ist ein Item.',
      zero: 'In dieser Kategorie sind noch keine Items.',
    );
    return '$_temp0';
  }

  @override
  String get wizardNewSubCategoryBtnLabel => 'Neue Unterkategorie';

  @override
  String wizardIconForCategorySuffix(String name) {
    return ' (für Kategorie $name)';
  }

  @override
  String get wizardItemsStepTitle => 'Items';

  @override
  String get wizardItemsStepHelper =>
      '## Items (optional)\n\nHier legst du die Items deiner Welt an: Heiltränke, Waffen, Questgegenstände oder Zutaten für Gifte, also alles, was in den Taschen deiner Spieler landen kann.\n\nAuch die Wirkung eines Tranks kannst du hier hinterlegen.\n\nTipp: Schreib Wirkung, Schaden und Ähnliches an den Anfang der Beschreibung. Dann sehen deine Spieler das Wichtigste auf einen Blick.';

  @override
  String get wizardEditItemTitle => 'Item bearbeiten';

  @override
  String get wizardItemNameLabel => 'Name des Items:';

  @override
  String get wizardItemCategoryLabel => 'Kategorie';

  @override
  String get wizardItemPatchSizeLabel => 'Fundgröße (optional):';

  @override
  String get wizardItemImageDescriptionLabel => 'Bildbeschreibung:';

  @override
  String get wizardItemPlacesOfFindingHeader => 'Fundorte:';

  @override
  String get wizardNewLocationBtnLabel => 'Neuer Fundort';

  @override
  String get wizardNewImageBtnLabel => 'Neues Bild';

  @override
  String get wizardPickImageBtnLabel => 'Bild auswählen';

  @override
  String get wizardInvalidImageFile => 'Diese Datei ist kein gültiges Bild.';

  @override
  String get wizardRecipesStepTitle => 'Rezepte';

  @override
  String get wizardRecipesStepHelper =>
      '## Rezepte (optional)\n\nMit Rezepten können deine Spieler selbst Dinge herstellen, zum Beispiel Heiltränke.\n\nManche Rezepte setzen ein Werkzeug voraus, etwa ein Kräuterkunde-Set. Auch das kannst du im Rezept hinterlegen; die Spieler brauchen das Werkzeug dann, um das Rezept zu nutzen.\n\nTippe auf ein Rezept, um es zu bearbeiten. Halte es gedrückt für weitere Aktionen.';

  @override
  String get wizardRecipeOpenDetails => 'Details öffnen';

  @override
  String get wizardRecipeDuplicateAndOpen => 'Duplizieren und öffnen';

  @override
  String get wizardRecipeDeletePermanently => 'Endgültig löschen';

  @override
  String get wizardEditRecipeTitle => 'Rezept bearbeiten';

  @override
  String get wizardRecipeCreatedItemLabel => 'Herzustellendes Item';

  @override
  String wizardRecipeRequirementLabel(int number) {
    return 'Voraussetzung #$number';
  }

  @override
  String get wizardRecipeAddRequirement => 'Weitere Voraussetzung';

  @override
  String wizardRecipeIngredientLabel(int number) {
    return 'Zutat #$number';
  }

  @override
  String get wizardRecipeAddIngredient => 'Weitere Zutat';

  @override
  String get wizardSummaryStepTitle => 'Zusammenfassung';

  @override
  String get wizardSummaryStepHelper =>
      '## Fertig!\n\nDeine Kampagne ist eingerichtet und alles ist gespeichert. Die Übersicht zeigt, was eingerichtet ist.\n\nÄndern kannst du alles später über das Zahnrad oben rechts.\n\nMit **Fertig** schließt du den Assistenten.';

  @override
  String get wizardSummaryCampaignLabel => 'Kampagne';

  @override
  String get wizardSummaryNotSet => 'Noch nicht festgelegt';

  @override
  String wizardSummaryTabCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Tabs',
      one: '1 Tab',
    );
    return '$_temp0';
  }

  @override
  String wizardSummaryPropertyCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Eigenschaften',
      one: '1 Eigenschaft',
    );
    return '$_temp0';
  }

  @override
  String wizardSummaryItemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Items',
      one: '1 Item',
      zero: 'Keine Items',
    );
    return '$_temp0';
  }

  @override
  String wizardSummaryRecipeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Rezepte',
      one: '1 Rezept',
      zero: 'Keine Rezepte',
    );
    return '$_temp0';
  }

  @override
  String get welcomeToQuestKeeper => 'Willkommen bei QuestKeeper';

  @override
  String get questKeeperIntro =>
      'QuestKeeper begleitet eure Pen-&-Paper-Runde am Tisch. Die Spielleitung richtet die Kampagne ein, alle anderen führen ihren Charakterbogen in der App. Trefferpunkte, Gegenstände und geteilte Notizen sind dabei für alle live aktuell.';

  @override
  String get pathRunAGameTitle => 'Ich leite eine Runde';

  @override
  String get pathRunAGameSubtitle => 'Kampagne anlegen und Spieler einladen';

  @override
  String get pathJoinAGameTitle => 'Ich trete einer Runde bei';

  @override
  String get pathJoinAGameSubtitle => 'Mit dem Code deiner Spielleitung';

  @override
  String get joinCampagneAction => 'Kampagne beitreten';

  @override
  String get createCampagneAction => 'Kampagne anlegen';

  @override
  String get noCampagnesYetHint =>
      'Leg eine Kampagne an, richte den Charakterbogen ein und lade deine Gruppe mit einem Code ein.';

  @override
  String get noCharactersYetHint =>
      'Tritt mit dem Code deiner Spielleitung einer Kampagne bei. Deinen Charakter legst du dabei an.';

  @override
  String campagneSettingsChangedAt(String date) {
    return 'Einstellungen geändert: $date';
  }

  @override
  String openJoinRequestsBadge(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count offene Anfragen',
      one: '1 offene Anfrage',
    );
    return '$_temp0';
  }

  @override
  String characterLastEditedAt(String date) {
    return 'Zuletzt bearbeitet: $date';
  }

  @override
  String get waitingForDmApproval =>
      'Warte auf Freigabe durch die Spielleitung';

  @override
  String get characterNotInCampagneHint =>
      'Noch in keiner Kampagne. Tippe, um mit einem Code beizutreten.';

  @override
  String get joinCampagneNewCharacterIntro =>
      'Gib den Beitrittscode ein, den du von deiner Spielleitung bekommen hast, und wie dein Charakter heißen soll. Den Rest des Charakterbogens füllst du aus, sobald die Spielleitung dich aufgenommen hat.';

  @override
  String get joinCodeEmptyError => 'Bitte gib den Beitrittscode ein.';

  @override
  String get joinCodeIncompleteError =>
      'Der Code hat sechs Ziffern, zum Beispiel 123-456.';

  @override
  String get joinCodeUnknownError =>
      'Diesen Code gibt es nicht. Prüfe ihn mit deiner Spielleitung.';

  @override
  String get characterNameFieldLabel => 'Name deines Charakters';

  @override
  String get nameRequiredError => 'Bitte gib einen Namen ein';

  @override
  String get joinAction => 'Beitreten';

  @override
  String get joinRequestSentConfirmation =>
      'Anfrage gesendet. Sobald deine Spielleitung zustimmt, kannst du mitspielen.';

  @override
  String get joinRequestAcceptedMessage =>
      'Deine Beitrittsanfrage wurde angenommen. Du kannst jetzt mitspielen.';

  @override
  String get joinRequestDeniedMessage =>
      'Deine Beitrittsanfrage wurde abgelehnt.';

  @override
  String joinRequestCreatedForDm(String playerName, String username) {
    return '$playerName ($username) möchte deiner Kampagne beitreten.';
  }

  @override
  String get waitingForApprovalTitle => 'Warte auf Freigabe';

  @override
  String waitingForApprovalText(String characterName) {
    return 'Deine Anfrage für „$characterName“ liegt bei deiner Spielleitung. Sobald sie zustimmt, kannst du hier mitspielen.';
  }

  @override
  String get enterCodeAgainAction => 'Code neu eingeben';

  @override
  String get newCampagneIntro =>
      'Wie soll deine Kampagne heißen? Danach führt dich der Assistent durch Charakterbogen, Währung und Gegenstände.';

  @override
  String get createAction => 'Anlegen';

  @override
  String get invitePlayersAction => 'Spieler einladen';

  @override
  String get noPlayersYetHint =>
      'Noch keine Spieler dabei. Lade deine Gruppe über „Spieler einladen“ ein.';

  @override
  String get invitePlayersInstruction =>
      'In QuestKeeper auf „Kampagne beitreten“ tippen und diesen Code eingeben.';

  @override
  String get invitePlayersApprovalHint =>
      'Die Anfragen erscheinen danach unter „Beitrittsanfragen“. Mit ✓ nimmst du jemanden auf.';

  @override
  String get copyCodeAction => 'Code kopieren';

  @override
  String get copiedConfirmation => 'Kopiert';

  @override
  String get shareInviteAction => 'Einladung teilen';

  @override
  String inviteShareText(String campagneName, String code) {
    return 'Spiel mit in meiner Runde „$campagneName“! Öffne QuestKeeper, tippe auf „Kampagne beitreten“ und gib diesen Code ein: $code';
  }

  @override
  String inviteShareSubject(String campagneName) {
    return 'Einladung zu „$campagneName“';
  }

  @override
  String get qrCodeHint => 'Der QR-Code enthält nur den Code.';

  @override
  String get closeAction => 'Schließen';

  @override
  String get errorDetailsStatusLabel => 'HTTP-Status:';

  @override
  String get errorDetailsServerLabel => 'Server-Antwort:';

  @override
  String get errorDetailsDescriptionLabel => 'Beschreibung:';

  @override
  String get errorMessageNoConnection =>
      'Die Verbindung zum Server hat nicht geklappt. Prüfe deine Internetverbindung und versuche es noch einmal.';

  @override
  String get errorMessageBadRequest =>
      'Der Server konnte die Eingabe nicht verarbeiten. Prüfe deine Angaben und versuche es noch einmal.';

  @override
  String get errorMessageUnauthorized =>
      'Dafür fehlt dir die Berechtigung. Melde dich gegebenenfalls neu an.';

  @override
  String get errorMessageNotFound =>
      'Das gesuchte Element gibt es nicht (mehr).';

  @override
  String get errorMessageConflict =>
      'Das wurde gerade an anderer Stelle geändert. Lade neu und versuche es noch einmal.';

  @override
  String get errorMessageServer =>
      'Auf dem Server ist ein Fehler aufgetreten. Versuche es später noch einmal.';

  @override
  String get errorMessageUnknown =>
      'Etwas ist schiefgelaufen. Versuche es noch einmal.';

  @override
  String get myNotesGroupName => 'Meine Notizen';

  @override
  String get pageTabShortCampaign => 'Kampagne';

  @override
  String get pageTabShortCharacters => 'Charaktere';

  @override
  String get pageTabShortFight => 'Kampf';

  @override
  String get pageTabShortItems => 'Items';

  @override
  String get pageTabShortNotes => 'Notizen';

  @override
  String get pageTabShortImages => 'Bilder';

  @override
  String get ledgerManuscriptDateFormat => 'd. MMMM y, HH:mm';

  @override
  String get invalidWholeNumberInput =>
      'Bitte gib eine ganze Zahl ein, z. B. -1 oder 3.';

  @override
  String get invalidLevelInput =>
      'Das Level muss eine ganze Zahl ab 0 sein, z. B. 3.';

  @override
  String get previewAndVariantTileTitle => 'Vorschau und Darstellung';

  @override
  String get characterSetupTitle => 'Charakter einrichten';

  @override
  String characterSetupProgress(int current, int total, String tabName) {
    return 'Abschnitt $current von $total: $tabName';
  }

  @override
  String get characterSetupHint =>
      'Was du jetzt leer lässt, kannst du später direkt im Charakterbogen ausfüllen.';

  @override
  String get characterSetupFinish => 'Fertig';

  @override
  String get fillInLater => 'Später ausfüllen';

  @override
  String get characterNameRequired => 'Bitte gib einen Namen ein.';

  @override
  String get fixMarkedFieldsHint => 'Bitte korrigiere die markierten Felder.';

  @override
  String get moneyModeDeposit => '+ Einzahlen';

  @override
  String get moneyModeSpend => '− Ausgeben';

  @override
  String get activeAlternateFormBannerTitle => 'Verwandelte Gestalt';

  @override
  String get missingStatTapToFill => 'Noch leer – tippen zum Ausfüllen';

  @override
  String get missingStatUnnamed => 'Unbenannte Eigenschaft';

  @override
  String get settingsTitle => 'Einstellungen';

  @override
  String get apiKeysSettingsSubtitle =>
      'Deine persönlichen API-Schlüssel verwalten';

  @override
  String get noteBlockTextLabel => 'Text';

  @override
  String get generateImageDescriptionHint =>
      'Beschreibe das Bild, das du generieren möchtest. Je genauer die Beschreibung, desto besser passt das Bild.';

  @override
  String get generateImagePromptLabel => 'Bildbeschreibung';

  @override
  String get generateImagePromptExample =>
      'z. B. „Ein mystischer Wald mit Elfen“';

  @override
  String get reactivateTransformationTitle => 'Alte Verwandlung reaktivieren';

  @override
  String get reactivateTransformationQuestion =>
      'Möchtest du deine letzte Verwandlung wieder aufnehmen oder eine neue Gestalt annehmen?';

  @override
  String get newTransformationDeletesOldTitle =>
      'Alte Verwandlungen werden gelöscht';

  @override
  String get newTransformationDeletesOldText =>
      'Wenn du eine neue Verwandlung erstellst, werden alle alten gelöscht.';

  @override
  String get selectTransformationTitle => 'Verwandlung auswählen';

  @override
  String get selectTransformationComponentsHint =>
      'Wähle die Verwandlungen aus, aus denen deine neue Gestalt bestehen soll.';

  @override
  String get noTransformationComponentsHint =>
      'Es gibt noch keine Verwandlungen. Lege sie zuerst in den Einstellungen deines Charakters an.';

  @override
  String transformationStatSettingsFor(String statName) {
    return 'Einstellungen für $statName';
  }

  @override
  String get invalidWholeNumberShort => 'Ganze Zahl eingeben';

  @override
  String get invalidNonNegativeNumberShort => 'Zahl ab 0 eingeben';

  @override
  String get invalidPositiveNumberShort => 'Zahl ab 1 eingeben';

  @override
  String get invalidCurrencyMultiple =>
      'Gib eine ganze Zahl größer als 1 ein, z. B. 10.';

  @override
  String get aboutLicensesTitle => 'Info & Lizenzen';

  @override
  String get aboutLicensesSrdTitle => 'Regelmaterial: SRD 5.2.1';

  @override
  String get aboutLicensesSrdIntro =>
      'Die Vorlage „Fantasy 5E (SRD)“ enthält Material aus dem System Reference Document 5.2.1. Es steht unter der Lizenz Creative Commons Namensnennung 4.0 International (CC BY 4.0).';

  @override
  String get aboutLicensesAttributionEnglish =>
      'Namensnennung (englisches Original)';

  @override
  String get aboutLicensesAttributionGerman =>
      'Namensnennung (deutsche Fassung)';

  @override
  String get aboutLicensesAuthoritativeHint =>
      'Die deutsche Fassung dient nur der Information. Maßgeblich ist die englische Fassung.';

  @override
  String get aboutLicensesChanges =>
      'Änderungen: Material aus dem SRD 5.2.1 wurde ausgewählt, übersetzt oder aus der deutschen Fassung übernommen, gekürzt und an QuestKeeper angepasst. Kurzbeschreibungen und weitere Texte der Vorlage sind eigene Texte.';

  @override
  String get aboutLicensesOpenLicense => 'Lizenz CC BY 4.0 öffnen';

  @override
  String get aboutLicensesNotAffiliated =>
      'QuestKeeper ist ein unabhängiges Produkt und wird von keinem Rollenspielverlag herausgegeben oder unterstützt.';

  @override
  String get aboutLicensesOpenSourceTitle => 'Open-Source-Lizenzen';

  @override
  String get aboutLicensesShowOpenSource => 'Alle Lizenzen anzeigen';

  @override
  String get aboutLicensesSettingsSubtitle =>
      'Regelmaterial, Lizenzen und Open-Source-Hinweise';

  @override
  String get statTypeCheckboxTrack => 'Kästchenleiste';

  @override
  String get statTypeCheckboxTrackHelp =>
      'Eine Reihe Kästchen, die Spieler mit einem Tipp auf dem Bogen ankreuzen, z. B. Stress.';

  @override
  String get statTypeTextList => 'Textliste';

  @override
  String get statTypeTextListHelp =>
      'Mehrere Texteinträge, optional mit festen, beschrifteten Plätzen, z. B. Aspekte oder Konsequenzen.';

  @override
  String get statTypeSingleSelect => 'Auswahl (eine)';

  @override
  String get statTypeSingleSelectHelp =>
      'Spieler wählen genau eine der Optionen, z. B. Herkunft oder Gesinnung.';

  @override
  String get statTypeUnsupported => 'Unbekannter Typ';

  @override
  String get statTypeUnsupportedHint =>
      'Wird von dieser Version nicht unterstützt. Bitte aktualisiere die App.';

  @override
  String get checkboxTrackBoxesHeadline => 'Kästchen';

  @override
  String get checkboxTrackBoxCountLabel => 'Anzahl';

  @override
  String get checkboxTrackLabelsHint =>
      'Beschriftungen sind optional, z. B. „1“, „2“, „3“ oder „Leicht“.';

  @override
  String checkboxTrackBoxLabel(int number) {
    return 'Kästchen $number';
  }

  @override
  String get checkboxTrackTapHint =>
      'Tippe ein Kästchen an, um es anzukreuzen oder freizugeben.';

  @override
  String get textListSlotsHeadline => 'Feste Plätze';

  @override
  String get textListSlotsHint =>
      'Optional, z. B. „Hauptaspekt“, „Dilemma“ oder „Leicht (2)“.';

  @override
  String get textListSlotLabel => 'Beschriftung:';

  @override
  String get textListAllowCustomEntries =>
      'Spieler dürfen eigene Einträge hinzufügen und löschen';

  @override
  String get textListAddEntry => 'Eintrag hinzufügen';

  @override
  String get textListOwnEntryLabel => 'Eigener Eintrag';

  @override
  String get textListEmpty => 'Noch keine Einträge';

  @override
  String get textListEditEntryTitle => 'Eintrag bearbeiten';

  @override
  String get textListDeleteEntry => 'Löschen';

  @override
  String get singleSelectOptionsHeadline => 'Optionen';

  @override
  String get singleSelectNothingChosen => 'Noch nichts gewählt';

  @override
  String get showLevelToggle => 'Level anzeigen';

  @override
  String get showLevelHint =>
      'Aus: Das Charakterformular fragt kein Level ab und der Bogen zeigt keins.';

  @override
  String get playerPreviewButton => 'So sieht es der Spieler';

  @override
  String get playerPreviewTitle => 'Spieleransicht';

  @override
  String get playerPreviewPhone => 'Handy';

  @override
  String get playerPreviewTablet => 'Tablet';

  @override
  String get playerPreviewHint =>
      'Eine Beispielfigur mit Standardwerten. Hier wird nichts gespeichert.';

  @override
  String get playerPreviewSampleCharacterName => 'Beispielfigur';

  @override
  String get othersNotesGroupName => 'Notizen der Spieler';

  @override
  String get wizardTemplateStepTitle => 'Vorlage';

  @override
  String get wizardTemplateStepHelper =>
      '## Willkommen bei QuestKeeper!\n\nIn den nächsten Schritten richtest du deine Kampagne ein: Vorlage, Darstellung, Name, Charakterbogen, Initiative und Währung. Danach folgen optionale Schritte für Items und Crafting, die du überspringen kannst.\n\nAlles wird automatisch gespeichert. Mit dem X oben links schließt du den Assistenten jederzeit; über das Zahnrad oben rechts kommst du später wieder hierher.\n\n## Vorlage\n\nWähle, womit du startest. Die Vorlage füllt Charakterbogen und Währung vor. In den nächsten Schritten passt du alles an.\n\nDie Vorlage wählst du nur beim Anlegen. Über das Zahnrad änderst du später jeden Teil einzeln.';

  @override
  String get wizardTemplateContentsLabel => 'Enthält';

  @override
  String get wizardTemplateEmptyName => 'Leer';

  @override
  String get wizardTemplateEmptyDescription =>
      'Ein schlichter Bogen mit Name und Level. Alles Weitere legst du selbst an.';

  @override
  String get wizardTemplateEmptyContents => 'Name, Level, eine Währung';

  @override
  String get wizardTemplateFantasyName => 'Fantasy 5E (SRD)';

  @override
  String get wizardTemplateFantasyDescription =>
      'Klassische Fantasy mit Attributen, Trefferpunkten und Zaubern.';

  @override
  String get wizardTemplateFantasyContents =>
      'Attribute, Fertigkeiten, Zauber, Kupfer bis Platin';

  @override
  String get wizardTemplateNarrativeName => 'Erzählerisch (Aspekte & Stress)';

  @override
  String get wizardTemplateNarrativeDescription =>
      'Für Runden, in denen die Geschichte zählt: Aspekte beschreiben die Charaktere, Stress fängt Treffer ab.';

  @override
  String get wizardTemplateNarrativeContents =>
      'Aspekte, Fertigkeiten, Stunts, Stress, Konsequenzen, Erzählpunkte';

  @override
  String get wizardTemplateReplaceTitle => 'Vorlage wechseln?';

  @override
  String get wizardTemplateReplaceMessage =>
      'Du hast seit der Vorlagenwahl etwas angepasst. Diese Änderungen gehen verloren. Kampagnenname und Darstellung bleiben.';

  @override
  String get wizardTemplateReplaceConfirm => 'Vorlage wechseln';

  @override
  String get wizardSkinStepHelperAfterTemplate =>
      '## Darstellung\n\nWähle das Standard-Aussehen der Charakterbögen in dieser Kampagne. Spieler können es später für ihre eigenen Charaktere ändern.';
}
