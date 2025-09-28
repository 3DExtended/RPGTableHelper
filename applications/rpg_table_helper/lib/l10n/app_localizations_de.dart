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
  String get firstValuePlaceholder => 'Der erster Wert';

  @override
  String get currentValue => 'Aktueller Wert';

  @override
  String get currentValuePlaceholder =>
      'Der aktuelle Wert für diese Eigenschaft';

  @override
  String get maxValue => 'Maximaler Wert';

  @override
  String get maxValuePlaceholder => 'Der maximaler Wert für diese Eigenschaft';

  @override
  String get secondValue => 'Zweiter Wert';

  @override
  String get secondValuePlaceholder => 'Der zweiter Wert';

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
  String get newImageBtnLabel => 'Neues Bild';

  @override
  String get additionalSettings => 'Erweiterte Optionen';

  @override
  String get hidePropertyForCharacter =>
      'Eigenschaft für meinen Charakter ausblenden';

  @override
  String get hideHeading => 'Überschrift ausblenden';

  @override
  String get addCharacterToCampagneModalTitle =>
      'Charakter zur Kampagne hinzufügen';

  @override
  String get assignCharacterToCampagneModalContent =>
      'Du hast zwar einen Charakter erstellt, dieser ist aber noch keine Season bzw. Kampagne zugeordnet. Gebe hier den Join Code ein, den du von deinem DM erhältst, um eine Anfrage an deinen DM zu senden.';

  @override
  String get joinCode => 'Join Code:';

  @override
  String get genericErrorModalHeader => 'Fehler';

  @override
  String get genericErrorModalTechnicalDetailsHeader => 'Technische Details: ';

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
  String get propertyEditTypeOneTap => 'Häufig verändert (bspw. jede Session)';

  @override
  String get propertyEditTypeStatic => 'Selten verändert (bspw. je Level-Up)';

  @override
  String get propertyEditTypeLabel => 'Veränderungshäufigkeit';

  @override
  String get generatedImage => 'Generiertes Bild';

  @override
  String get multilineText => 'Mehrzeiliger Text';

  @override
  String get singleLineText => 'Einzeiliger Text';

  @override
  String get integerValue => 'Zahlen-Wert';

  @override
  String get listOfIntegersWithIcons => 'Liste von Zahlen-Werten mit Icons';

  @override
  String get integerValueWithMaxValue => 'Zahlen-Wert mit maximal Wert';

  @override
  String get listOfInterValuesWithCalculatedIntegerValues =>
      'Gruppe von Zahlen-Werten mit zusätzlicher Zahl';

  @override
  String get integerValueWithCalculatedValue =>
      'Zahlen-Wert mit zusätzlicher Zahl';

  @override
  String get characterNameWithLevelAndConfigurableDetails =>
      'Charakter Basis Eigenschaften (LVL, Name und weitere optionale)';

  @override
  String get multiselectOption => 'Mehrfach-Auswahl';

  @override
  String get companionOverview => 'Begleiter Übersicht';

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
  String get optionsForMultiselect => 'Optionen für Mehrfach-Auswahl';

  @override
  String get multiselectOptionName => 'Name:';

  @override
  String get multiselectOptionDescription => 'Beschreibung:';

  @override
  String get additionalElement => 'Neues Element';

  @override
  String get moreValues => 'Weitere Werte';

  @override
  String get forIntegerValueWithName => 'für Zahlen-Wert';

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
  String get campaignManagement => 'Kampagnen Management';

  @override
  String get characterOverview => 'Charakter Übersicht';

  @override
  String get fightingOrdering => 'Kampf Reihenfolge';

  @override
  String get grantItems => 'Items verteilen';

  @override
  String get lore => 'Weltgeschichte';

  @override
  String get online => 'Online';

  @override
  String get offline => 'Offline';

  @override
  String get allPlayers => 'Alle Spieler:';

  @override
  String get openJoinRequests => 'Join Anfragen:';

  @override
  String get joinCodeForNewPlayers => 'Join Code (für neue Spieler):';

  @override
  String get noOpenJoinRequests => 'Keine offenen Anfragen';

  @override
  String get user => 'User:';

  @override
  String get character => 'Charakter:';

  @override
  String get lastGrantedItems => 'Letzte verteilte Items';

  @override
  String get noItemsGranted => 'Noch keine Items verteilt...';

  @override
  String get placeOfFinding => 'Fundort';

  @override
  String get playerRolls => 'Spieler Würfe';

  @override
  String get diceRoll => 'Wurf';

  @override
  String get player => 'Spieler';

  @override
  String get sendItems => 'Items verschicken';

  @override
  String get itemsToBeFoundInPlaceMarkdown =>
      '## Auffindbare Items in Fundort: ';

  @override
  String get noPlaceOfFindingSelected =>
      'Es wurde noch kein Fundort ausgewählt.';

  @override
  String get followingItemsArePossibleAtPlaceOfFinding =>
      'Diese Items gibt es am/im Fundort:';

  @override
  String get diceChallengeAbbr => 'SG';

  @override
  String get lastGrantedItemsMarkdownPrefix =>
      'Zuletzt wurden diese Items verteilt:';

  @override
  String get noItemsGrantedToPlayerThisRound => 'Keine Items in dieser Runde';

  @override
  String get login => 'Login';

  @override
  String get signInWithApple => 'Mit Apple anmelden';

  @override
  String get signInWithGoogle => 'Mit Google anmelden';

  @override
  String get createNewAccount => 'Neuen Account anlegen';

  @override
  String get email => 'E-Mail';

  @override
  String get register => 'Registrieren';

  @override
  String get itemDetailsForPrefix => 'Item Details für';

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
    return 'Du hast $amount neue Items erhalten:';
  }

  @override
  String get ok => 'Ok';

  @override
  String get rpgConfigurationDmWizardStep2Tutorial =>
      'Nun kommen wir zu den Charakterbögen.\n\nJedes Rollenspiel hat unterschiedliche Eigenschaften, die die Spieler charakterisieren (z.B. wie viele Lebenspunkte ein Spieler hat).\n\nFür jede Eigenschaft musst du, als Spielleiter, definieren, wie die Spieler mit dieser Eigenschaft interagieren können. Hierbei benötigen wir für jede Eigenschaft drei Informationen von dir:\n\n1. Name der Eigenschaft: Wie soll dieser Wert auf dem Charakterbogen heißen? (z.B. „HP“, „SP“, „Name“, etc.)\n2. Werteart der Eigenschaft: Handelt es sich z.B. um einen Text, den der Spieler anpassen kann (z.B. Hintergrundgeschichte des Charakters) oder um einen Zahlenwert (z.B. die Lebenspunkte)?\n3. Änderungsart: Manche dieser Eigenschaften werden regelmäßig angepasst (z.B. die aktuellen Lebenspunkte), andere hingegen nur selten (z.B. die maximalen Lebenspunkte). Damit dies bei der Erstellung der Charakterbögen berücksichtigt werden kann, musst du uns diese Information mitteilen.\n\nFalls du mehr Erklärungen benötigst, findest du hier eine Beispielseite mit allen Konfigurationen und dem entsprechenden Aussehen auf den Charakterbögen:';

  @override
  String get levelAbbr => 'LVL';

  @override
  String get addAdditionalEnemy => 'Neue Gegner hinzufügen';

  @override
  String get enemyName => 'Gegnername';

  @override
  String get rollOfInititive => 'Reihenfolgenwurf';

  @override
  String get addAnAdditionalEnemyBtnLabel => 'Weiterer Gegner';

  @override
  String get enemy => 'Gegner';

  @override
  String get add => 'Hinzufügen';

  @override
  String get initiativeRollForCharacterPrefix => 'Kampf Reihenfolge Wurf';

  @override
  String get initiativeRollText =>
      'Ein Kampf startet: Würfel deinen Platz in der Reihenfolge!';

  @override
  String get initiativeRollTextFieldLabel => 'Kampf Wurf';

  @override
  String get send => 'Absenden';

  @override
  String get editPageTitle => 'Seite bearbeiten';

  @override
  String get editPageModalText =>
      'Hier kannst du sowohl den Titel als auch die Gruppierung deiner Seite verändern.';

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
  String get ownedIngredientCountPrefix => 'in Besitz:';

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
  String get dm => 'DM';

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
  String get defaultTab => 'Default Tab';

  @override
  String get amountHeaderLabel => 'Anzahl:';

  @override
  String get noItemsInCategoryErrorText => 'Keine Items unter dieser Kategorie';

  @override
  String get searchLabel => 'Suche';

  @override
  String get itemCategoryFilterAll => 'Alles';

  @override
  String get craftableRecipeFilter => 'Herstellbar';

  @override
  String get noItemsInCategoryCraftable =>
      'In dieser Kategorie sind keine Items herstellbar';

  @override
  String get noItemsInCategory => 'Keine Items unter dieser Kategorie';

  @override
  String get craftableAmountText => 'Herstellbar:';

  @override
  String get navBarHeaderCrafting => 'Herstellen';

  @override
  String get navBarHeaderLore => 'Weltgeschichte';

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
  String get startAsDm => 'Als DM spielen';

  @override
  String youOwnXCampaigns(int count) {
    return 'Dir gehören $count Kampagnen';
  }

  @override
  String get joinAsPlayer => 'Tritt als Spieler bei';

  @override
  String get chooseACharacter => 'Charakter auswählen';

  @override
  String youOwnXCharacters(int count) {
    return 'Dir gehören $count Charaktere';
  }

  @override
  String get campaigneName => 'Name';

  @override
  String get helperTextForNameOfCampaign => 'Wie soll die Kampagne heißen?';

  @override
  String get newCampaign => 'Neue Kampagne';

  @override
  String get noPlayersOnline => 'Aktuell keine Spieler online';

  @override
  String get currentFightOrdering => 'Aktuelle Kampfreihenfolge';

  @override
  String get noFIghtStarted => 'Aktuell kein Kampf gestartet';

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
  String get campaignName => 'Kampagnen Name';

  @override
  String get tranformToAlternateForm => 'Verwandeln';

  @override
  String get transformIntoAlternateForm => 'Verwandeln in eine andere Form';

  @override
  String get addNewTransformationComponent =>
      'Füge neue Verwandlungsformen hinzu';

  @override
  String get createNewTransformationTitle => 'Neue Verwandlung erstellen';

  @override
  String get transformationName => 'Verwandlungsname';

  @override
  String get transformationDescription => 'Beschreibung';

  @override
  String get createTransformationHelperText =>
      'Um eine neue Transformation zu erstellen, musst du die Eigenschaften auswählen, die durch diese Verwandlung verändert werden. (Wenn die Eigenschaft nicht verändert wird, muss sie auch nicht ausgewählt werden.)';

  @override
  String get back => 'Zurück';

  @override
  String get next => 'Weiter';

  @override
  String get warning => 'Warnung';

  @override
  String get youAreEditingAnAlternateFormWarningText =>
      'Du bearbeitest gerade eine Verwandlungs-Form. Änderungen werden nur auf dieser Verwandlung gespeichert und werden resettet, wenn du dich zurück verwandelst. Wenn du dauerhafte Veränderungen deiner Form möchtest, bearbeite die Basis-Form (indem du dich zurück verwandelst und dort die Veränderungen einpflegst).';

  @override
  String get transformationIsEditedWarningTitle =>
      'Verwandlung wird bearbeitet';

  @override
  String get propertyIsCopied => 'Eigenschaft wurde kopiert';

  @override
  String get youAreEditingACopiedPropertyChangesWillNotAffect =>
      'Du bearbeitest gerade eine kopierte Eigenschaft. Änderungen werden nur auf dieser Eigenschaft gespeichert und werden nicht auf den Haupt-Charakter übertragen.';

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
      'Du bist nicht mehr verbunden... Entweder bist du oder der DM offline...';

  @override
  String get characterNameStatTitle => 'Charakter-Name';

  @override
  String get characterNameStatHelperText => 'Wie heißt dein Charakter?';

  @override
  String get generateImageBtnLabel => 'Bild generieren';

  @override
  String get generateLoreImageTitle => 'Generiere ein Bild';

  @override
  String get generatedImagesTabTitle => 'Generierte Bilder';

  @override
  String get noImagesInCampagne =>
      'In dieser Kampagne sind noch keine Bilder von dir generiert worden.';

  @override
  String get enterANameDefaultLabel => 'Gebe Namen ein';

  @override
  String get enterSomeDescriptionOnTheLeft =>
      'Gebe eine Beschreibung auf der linken Seite ein.';

  @override
  String get tabIconsConfigurationTitle => 'Tab Icons';
}
