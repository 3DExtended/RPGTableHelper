import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en')
  ];

  /// No description provided for @username.
  ///
  /// In de, this message translates to:
  /// **'Nutzername'**
  String get username;

  /// No description provided for @password.
  ///
  /// In de, this message translates to:
  /// **'Passwort'**
  String get password;

  /// No description provided for @characterNameDefault.
  ///
  /// In de, this message translates to:
  /// **'Spielername'**
  String get characterNameDefault;

  /// No description provided for @save.
  ///
  /// In de, this message translates to:
  /// **'Speichern'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In de, this message translates to:
  /// **'Abbrechen'**
  String get cancel;

  /// No description provided for @firstValue.
  ///
  /// In de, this message translates to:
  /// **'Erster Wert'**
  String get firstValue;

  /// No description provided for @firstValuePlaceholder.
  ///
  /// In de, this message translates to:
  /// **'Der erster Wert'**
  String get firstValuePlaceholder;

  /// No description provided for @currentValue.
  ///
  /// In de, this message translates to:
  /// **'Aktueller Wert'**
  String get currentValue;

  /// No description provided for @currentValuePlaceholder.
  ///
  /// In de, this message translates to:
  /// **'Der aktuelle Wert für diese Eigenschaft'**
  String get currentValuePlaceholder;

  /// No description provided for @maxValue.
  ///
  /// In de, this message translates to:
  /// **'Maximaler Wert'**
  String get maxValue;

  /// No description provided for @maxValuePlaceholder.
  ///
  /// In de, this message translates to:
  /// **'Der maximaler Wert für diese Eigenschaft'**
  String get maxValuePlaceholder;

  /// No description provided for @secondValue.
  ///
  /// In de, this message translates to:
  /// **'Zweiter Wert'**
  String get secondValue;

  /// No description provided for @secondValuePlaceholder.
  ///
  /// In de, this message translates to:
  /// **'Der zweiter Wert'**
  String get secondValuePlaceholder;

  /// No description provided for @otherValue.
  ///
  /// In de, this message translates to:
  /// **'Anderer Wert'**
  String get otherValue;

  /// No description provided for @otherValuePlaceholder.
  ///
  /// In de, this message translates to:
  /// **'Der andere Wert'**
  String get otherValuePlaceholder;

  /// No description provided for @calculatedValue.
  ///
  /// In de, this message translates to:
  /// **'Berechneter Wert'**
  String get calculatedValue;

  /// No description provided for @calculatedValuePlaceholder.
  ///
  /// In de, this message translates to:
  /// **'Der berechnete Wert'**
  String get calculatedValuePlaceholder;

  /// No description provided for @configureProperties.
  ///
  /// In de, this message translates to:
  /// **'Eigenschaften konfigurieren'**
  String get configureProperties;

  /// No description provided for @configurePropertiesForCharacterNameSuffix.
  ///
  /// In de, this message translates to:
  /// **' (für {username})'**
  String configurePropertiesForCharacterNameSuffix(String username);

  /// No description provided for @valueOfPropertyWithName.
  ///
  /// In de, this message translates to:
  /// **'Der Wert von {property}'**
  String valueOfPropertyWithName(String property);

  /// No description provided for @newPetBtnLabel.
  ///
  /// In de, this message translates to:
  /// **'Neuer Begleiter'**
  String get newPetBtnLabel;

  /// No description provided for @petDefaultNamePrefix.
  ///
  /// In de, this message translates to:
  /// **'Begleiter'**
  String get petDefaultNamePrefix;

  /// No description provided for @preview.
  ///
  /// In de, this message translates to:
  /// **'Vorschau'**
  String get preview;

  /// No description provided for @newImageBtnLabel.
  ///
  /// In de, this message translates to:
  /// **'Neues Bild'**
  String get newImageBtnLabel;

  /// No description provided for @additionalSettings.
  ///
  /// In de, this message translates to:
  /// **'Erweiterte Optionen'**
  String get additionalSettings;

  /// No description provided for @hidePropertyForCharacter.
  ///
  /// In de, this message translates to:
  /// **'Eigenschaft für meinen Charakter ausblenden'**
  String get hidePropertyForCharacter;

  /// No description provided for @hideHeading.
  ///
  /// In de, this message translates to:
  /// **'Überschrift ausblenden'**
  String get hideHeading;

  /// No description provided for @addCharacterToCampagneModalTitle.
  ///
  /// In de, this message translates to:
  /// **'Charakter zur Kampagne hinzufügen'**
  String get addCharacterToCampagneModalTitle;

  /// No description provided for @assignCharacterToCampagneModalContent.
  ///
  /// In de, this message translates to:
  /// **'Du hast zwar einen Charakter erstellt, dieser ist aber noch keine Season bzw. Kampagne zugeordnet. Gebe hier den Join Code ein, den du von deinem DM erhältst, um eine Anfrage an deinen DM zu senden.'**
  String get assignCharacterToCampagneModalContent;

  /// No description provided for @joinCode.
  ///
  /// In de, this message translates to:
  /// **'Join Code:'**
  String get joinCode;

  /// No description provided for @genericErrorModalHeader.
  ///
  /// In de, this message translates to:
  /// **'Fehler'**
  String get genericErrorModalHeader;

  /// No description provided for @genericErrorModalTechnicalDetailsHeader.
  ///
  /// In de, this message translates to:
  /// **'Technische Details: '**
  String get genericErrorModalTechnicalDetailsHeader;

  /// No description provided for @genericErrorModalTechnicalDetailsErrorCodeRowLabel.
  ///
  /// In de, this message translates to:
  /// **'Fehlercode:'**
  String get genericErrorModalTechnicalDetailsErrorCodeRowLabel;

  /// No description provided for @genericErrorModalTechnicalDetailsExceptionRowLabel.
  ///
  /// In de, this message translates to:
  /// **'Fehlertext:'**
  String get genericErrorModalTechnicalDetailsExceptionRowLabel;

  /// No description provided for @nameOfPropertyLabel.
  ///
  /// In de, this message translates to:
  /// **'Name der Eigenschaft'**
  String get nameOfPropertyLabel;

  /// No description provided for @descriptionOfProperty.
  ///
  /// In de, this message translates to:
  /// **'Hilfstext für die Eigenschaft'**
  String get descriptionOfProperty;

  /// No description provided for @propertyEditTypeOneTap.
  ///
  /// In de, this message translates to:
  /// **'Häufig verändert (bspw. jede Session)'**
  String get propertyEditTypeOneTap;

  /// No description provided for @propertyEditTypeStatic.
  ///
  /// In de, this message translates to:
  /// **'Selten verändert (bspw. je Level-Up)'**
  String get propertyEditTypeStatic;

  /// No description provided for @propertyEditTypeLabel.
  ///
  /// In de, this message translates to:
  /// **'Veränderungshäufigkeit'**
  String get propertyEditTypeLabel;

  /// No description provided for @generatedImage.
  ///
  /// In de, this message translates to:
  /// **'Generiertes Bild'**
  String get generatedImage;

  /// No description provided for @multilineText.
  ///
  /// In de, this message translates to:
  /// **'Mehrzeiliger Text'**
  String get multilineText;

  /// No description provided for @singleLineText.
  ///
  /// In de, this message translates to:
  /// **'Einzeiliger Text'**
  String get singleLineText;

  /// No description provided for @integerValue.
  ///
  /// In de, this message translates to:
  /// **'Zahlen-Wert'**
  String get integerValue;

  /// No description provided for @listOfIntegersWithIcons.
  ///
  /// In de, this message translates to:
  /// **'Liste von Zahlen-Werten mit Icons'**
  String get listOfIntegersWithIcons;

  /// No description provided for @integerValueWithMaxValue.
  ///
  /// In de, this message translates to:
  /// **'Zahlen-Wert mit maximal Wert'**
  String get integerValueWithMaxValue;

  /// No description provided for @listOfInterValuesWithCalculatedIntegerValues.
  ///
  /// In de, this message translates to:
  /// **'Gruppe von Zahlen-Werten mit zusätzlicher Zahl'**
  String get listOfInterValuesWithCalculatedIntegerValues;

  /// No description provided for @integerValueWithCalculatedValue.
  ///
  /// In de, this message translates to:
  /// **'Zahlen-Wert mit zusätzlicher Zahl'**
  String get integerValueWithCalculatedValue;

  /// No description provided for @characterNameWithLevelAndConfigurableDetails.
  ///
  /// In de, this message translates to:
  /// **'Charakter Basis Eigenschaften (LVL, Name und weitere optionale)'**
  String get characterNameWithLevelAndConfigurableDetails;

  /// No description provided for @multiselectOption.
  ///
  /// In de, this message translates to:
  /// **'Mehrfach-Auswahl'**
  String get multiselectOption;

  /// No description provided for @companionOverview.
  ///
  /// In de, this message translates to:
  /// **'Begleiter Übersicht'**
  String get companionOverview;

  /// No description provided for @kindOfProperty.
  ///
  /// In de, this message translates to:
  /// **'Art der Eigenschaft'**
  String get kindOfProperty;

  /// No description provided for @multiselectOptionsAreSelectableMultipleTimes.
  ///
  /// In de, this message translates to:
  /// **'Optionen können mehrmals ausgewählt werden'**
  String get multiselectOptionsAreSelectableMultipleTimes;

  /// No description provided for @optionalPropertyForCompanions.
  ///
  /// In de, this message translates to:
  /// **'Optionale Eigenschaft für Begleiter'**
  String get optionalPropertyForCompanions;

  /// No description provided for @optionalPropertyForAlternateForms.
  ///
  /// In de, this message translates to:
  /// **'Optionale Eigenschaft für andere Formen'**
  String get optionalPropertyForAlternateForms;

  /// No description provided for @optionsForMultiselect.
  ///
  /// In de, this message translates to:
  /// **'Optionen für Mehrfach-Auswahl'**
  String get optionsForMultiselect;

  /// No description provided for @multiselectOptionName.
  ///
  /// In de, this message translates to:
  /// **'Name:'**
  String get multiselectOptionName;

  /// No description provided for @multiselectOptionDescription.
  ///
  /// In de, this message translates to:
  /// **'Beschreibung:'**
  String get multiselectOptionDescription;

  /// No description provided for @additionalElement.
  ///
  /// In de, this message translates to:
  /// **'Neues Element'**
  String get additionalElement;

  /// No description provided for @moreValues.
  ///
  /// In de, this message translates to:
  /// **'Weitere Werte'**
  String get moreValues;

  /// No description provided for @forIntegerValueWithName.
  ///
  /// In de, this message translates to:
  /// **'für Zahlen-Wert'**
  String get forIntegerValueWithName;

  /// No description provided for @propertyNameLabel.
  ///
  /// In de, this message translates to:
  /// **'Name:'**
  String get propertyNameLabel;

  /// No description provided for @completeRegistration.
  ///
  /// In de, this message translates to:
  /// **'Registrierung abschließen'**
  String get completeRegistration;

  /// No description provided for @selectIconModalTitle.
  ///
  /// In de, this message translates to:
  /// **'Icon auswählen'**
  String get selectIconModalTitle;

  /// No description provided for @selectAColor.
  ///
  /// In de, this message translates to:
  /// **'Farbe auswählen:'**
  String get selectAColor;

  /// No description provided for @selectAnIcon.
  ///
  /// In de, this message translates to:
  /// **'Icon auswählen:'**
  String get selectAnIcon;

  /// No description provided for @item.
  ///
  /// In de, this message translates to:
  /// **'Item'**
  String get item;

  /// No description provided for @itemExampleDescription.
  ///
  /// In de, this message translates to:
  /// **'Beschreibung eines Items'**
  String get itemExampleDescription;

  /// No description provided for @select.
  ///
  /// In de, this message translates to:
  /// **'Auswählen'**
  String get select;

  /// No description provided for @campaignManagement.
  ///
  /// In de, this message translates to:
  /// **'Kampagnen Management'**
  String get campaignManagement;

  /// No description provided for @characterOverview.
  ///
  /// In de, this message translates to:
  /// **'Charakter Übersicht'**
  String get characterOverview;

  /// No description provided for @fightingOrdering.
  ///
  /// In de, this message translates to:
  /// **'Kampf Reihenfolge'**
  String get fightingOrdering;

  /// No description provided for @grantItems.
  ///
  /// In de, this message translates to:
  /// **'Items verteilen'**
  String get grantItems;

  /// No description provided for @lore.
  ///
  /// In de, this message translates to:
  /// **'Weltgeschichte'**
  String get lore;

  /// No description provided for @online.
  ///
  /// In de, this message translates to:
  /// **'Online'**
  String get online;

  /// No description provided for @offline.
  ///
  /// In de, this message translates to:
  /// **'Offline'**
  String get offline;

  /// No description provided for @allPlayers.
  ///
  /// In de, this message translates to:
  /// **'Alle Spieler:'**
  String get allPlayers;

  /// No description provided for @openJoinRequests.
  ///
  /// In de, this message translates to:
  /// **'Join Anfragen:'**
  String get openJoinRequests;

  /// No description provided for @joinCodeForNewPlayers.
  ///
  /// In de, this message translates to:
  /// **'Join Code (für neue Spieler):'**
  String get joinCodeForNewPlayers;

  /// No description provided for @noOpenJoinRequests.
  ///
  /// In de, this message translates to:
  /// **'Keine offenen Anfragen'**
  String get noOpenJoinRequests;

  /// No description provided for @user.
  ///
  /// In de, this message translates to:
  /// **'User:'**
  String get user;

  /// No description provided for @character.
  ///
  /// In de, this message translates to:
  /// **'Charakter:'**
  String get character;

  /// No description provided for @lastGrantedItems.
  ///
  /// In de, this message translates to:
  /// **'Letzte verteilte Items'**
  String get lastGrantedItems;

  /// No description provided for @noItemsGranted.
  ///
  /// In de, this message translates to:
  /// **'Noch keine Items verteilt...'**
  String get noItemsGranted;

  /// No description provided for @placeOfFinding.
  ///
  /// In de, this message translates to:
  /// **'Fundort'**
  String get placeOfFinding;

  /// No description provided for @playerRolls.
  ///
  /// In de, this message translates to:
  /// **'Spieler Würfe'**
  String get playerRolls;

  /// No description provided for @diceRoll.
  ///
  /// In de, this message translates to:
  /// **'Wurf'**
  String get diceRoll;

  /// No description provided for @player.
  ///
  /// In de, this message translates to:
  /// **'Spieler'**
  String get player;

  /// No description provided for @sendItems.
  ///
  /// In de, this message translates to:
  /// **'Items verschicken'**
  String get sendItems;

  /// No description provided for @itemsToBeFoundInPlaceMarkdown.
  ///
  /// In de, this message translates to:
  /// **'## Auffindbare Items in Fundort: '**
  String get itemsToBeFoundInPlaceMarkdown;

  /// No description provided for @noPlaceOfFindingSelected.
  ///
  /// In de, this message translates to:
  /// **'Es wurde noch kein Fundort ausgewählt.'**
  String get noPlaceOfFindingSelected;

  /// No description provided for @followingItemsArePossibleAtPlaceOfFinding.
  ///
  /// In de, this message translates to:
  /// **'Diese Items gibt es am/im Fundort:'**
  String get followingItemsArePossibleAtPlaceOfFinding;

  /// No description provided for @diceChallengeAbbr.
  ///
  /// In de, this message translates to:
  /// **'SG'**
  String get diceChallengeAbbr;

  /// No description provided for @lastGrantedItemsMarkdownPrefix.
  ///
  /// In de, this message translates to:
  /// **'Zuletzt wurden diese Items verteilt:'**
  String get lastGrantedItemsMarkdownPrefix;

  /// No description provided for @noItemsGrantedToPlayerThisRound.
  ///
  /// In de, this message translates to:
  /// **'Keine Items in dieser Runde'**
  String get noItemsGrantedToPlayerThisRound;

  /// No description provided for @login.
  ///
  /// In de, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @signInWithApple.
  ///
  /// In de, this message translates to:
  /// **'Mit Apple anmelden'**
  String get signInWithApple;

  /// No description provided for @signInWithGoogle.
  ///
  /// In de, this message translates to:
  /// **'Mit Google anmelden'**
  String get signInWithGoogle;

  /// No description provided for @createNewAccount.
  ///
  /// In de, this message translates to:
  /// **'Neuen Account anlegen'**
  String get createNewAccount;

  /// No description provided for @email.
  ///
  /// In de, this message translates to:
  /// **'E-Mail'**
  String get email;

  /// No description provided for @register.
  ///
  /// In de, this message translates to:
  /// **'Registrieren'**
  String get register;

  /// No description provided for @itemDetailsForPrefix.
  ///
  /// In de, this message translates to:
  /// **'Item Details für'**
  String get itemDetailsForPrefix;

  /// No description provided for @itemDetailsDescriptionHeader.
  ///
  /// In de, this message translates to:
  /// **'Beschreibung:'**
  String get itemDetailsDescriptionHeader;

  /// No description provided for @itemDetailsPriceHeader.
  ///
  /// In de, this message translates to:
  /// **'Preis:'**
  String get itemDetailsPriceHeader;

  /// No description provided for @amount.
  ///
  /// In de, this message translates to:
  /// **'Anzahl'**
  String get amount;

  /// No description provided for @receivedItemsModalHeader.
  ///
  /// In de, this message translates to:
  /// **'Neue Items'**
  String get receivedItemsModalHeader;

  /// No description provided for @newItemsMarkdownPlural.
  ///
  /// In de, this message translates to:
  /// **'# Neue Items'**
  String get newItemsMarkdownPlural;

  /// No description provided for @newItemsMarkdownSingular.
  ///
  /// In de, this message translates to:
  /// **'# Neues Item'**
  String get newItemsMarkdownSingular;

  /// No description provided for @receivedOneNewItemText.
  ///
  /// In de, this message translates to:
  /// **'Du hast ein neues Item erhalten:'**
  String get receivedOneNewItemText;

  /// No description provided for @receivedXNewItems.
  ///
  /// In de, this message translates to:
  /// **'Du hast {amount} neue Items erhalten:'**
  String receivedXNewItems(int amount);

  /// No description provided for @ok.
  ///
  /// In de, this message translates to:
  /// **'Ok'**
  String get ok;

  /// No description provided for @rpgConfigurationDmWizardStep2Tutorial.
  ///
  /// In de, this message translates to:
  /// **'Nun kommen wir zu den Charakterbögen.\n\nJedes Rollenspiel hat unterschiedliche Eigenschaften, die die Spieler charakterisieren (z.B. wie viele Lebenspunkte ein Spieler hat).\n\nFür jede Eigenschaft musst du, als Spielleiter, definieren, wie die Spieler mit dieser Eigenschaft interagieren können. Hierbei benötigen wir für jede Eigenschaft drei Informationen von dir:\n\n1. Name der Eigenschaft: Wie soll dieser Wert auf dem Charakterbogen heißen? (z.B. „HP“, „SP“, „Name“, etc.)\n2. Werteart der Eigenschaft: Handelt es sich z.B. um einen Text, den der Spieler anpassen kann (z.B. Hintergrundgeschichte des Charakters) oder um einen Zahlenwert (z.B. die Lebenspunkte)?\n3. Änderungsart: Manche dieser Eigenschaften werden regelmäßig angepasst (z.B. die aktuellen Lebenspunkte), andere hingegen nur selten (z.B. die maximalen Lebenspunkte). Damit dies bei der Erstellung der Charakterbögen berücksichtigt werden kann, musst du uns diese Information mitteilen.\n\nFalls du mehr Erklärungen benötigst, findest du hier eine Beispielseite mit allen Konfigurationen und dem entsprechenden Aussehen auf den Charakterbögen:'**
  String get rpgConfigurationDmWizardStep2Tutorial;

  /// No description provided for @levelAbbr.
  ///
  /// In de, this message translates to:
  /// **'LVL'**
  String get levelAbbr;

  /// No description provided for @addAdditionalEnemy.
  ///
  /// In de, this message translates to:
  /// **'Neue Gegner hinzufügen'**
  String get addAdditionalEnemy;

  /// No description provided for @enemyName.
  ///
  /// In de, this message translates to:
  /// **'Gegnername'**
  String get enemyName;

  /// No description provided for @rollOfInititive.
  ///
  /// In de, this message translates to:
  /// **'Reihenfolgenwurf'**
  String get rollOfInititive;

  /// No description provided for @addAnAdditionalEnemyBtnLabel.
  ///
  /// In de, this message translates to:
  /// **'Weiterer Gegner'**
  String get addAnAdditionalEnemyBtnLabel;

  /// No description provided for @enemy.
  ///
  /// In de, this message translates to:
  /// **'Gegner'**
  String get enemy;

  /// No description provided for @add.
  ///
  /// In de, this message translates to:
  /// **'Hinzufügen'**
  String get add;

  /// No description provided for @initiativeRollForCharacterPrefix.
  ///
  /// In de, this message translates to:
  /// **'Kampf Reihenfolge Wurf'**
  String get initiativeRollForCharacterPrefix;

  /// No description provided for @initiativeRollText.
  ///
  /// In de, this message translates to:
  /// **'Ein Kampf startet: Würfel deinen Platz in der Reihenfolge!'**
  String get initiativeRollText;

  /// No description provided for @initiativeRollTextFieldLabel.
  ///
  /// In de, this message translates to:
  /// **'Kampf Wurf'**
  String get initiativeRollTextFieldLabel;

  /// No description provided for @send.
  ///
  /// In de, this message translates to:
  /// **'Absenden'**
  String get send;

  /// No description provided for @editPageTitle.
  ///
  /// In de, this message translates to:
  /// **'Seite bearbeiten'**
  String get editPageTitle;

  /// No description provided for @editPageModalText.
  ///
  /// In de, this message translates to:
  /// **'Hier kannst du sowohl den Titel als auch die Gruppierung deiner Seite verändern.'**
  String get editPageModalText;

  /// No description provided for @documentTitleLabel.
  ///
  /// In de, this message translates to:
  /// **'Titel'**
  String get documentTitleLabel;

  /// No description provided for @documentGroupLabel.
  ///
  /// In de, this message translates to:
  /// **'Gruppenname'**
  String get documentGroupLabel;

  /// No description provided for @recipeForTitlePrefix.
  ///
  /// In de, this message translates to:
  /// **'Rezept für'**
  String get recipeForTitlePrefix;

  /// No description provided for @recipeRequirements.
  ///
  /// In de, this message translates to:
  /// **'Voraussetzungen:'**
  String get recipeRequirements;

  /// No description provided for @recipeIngredients.
  ///
  /// In de, this message translates to:
  /// **'Zutaten:'**
  String get recipeIngredients;

  /// No description provided for @requiredIngredientCountPrefix.
  ///
  /// In de, this message translates to:
  /// **'Benötigt:'**
  String get requiredIngredientCountPrefix;

  /// No description provided for @ownedIngredientCountPrefix.
  ///
  /// In de, this message translates to:
  /// **'in Besitz:'**
  String get ownedIngredientCountPrefix;

  /// No description provided for @amountToCraftFieldLabel.
  ///
  /// In de, this message translates to:
  /// **'Anzahl'**
  String get amountToCraftFieldLabel;

  /// No description provided for @craft.
  ///
  /// In de, this message translates to:
  /// **'Herstellen'**
  String get craft;

  /// No description provided for @newItem.
  ///
  /// In de, this message translates to:
  /// **'Neu'**
  String get newItem;

  /// No description provided for @defaultGroupNameForDocuments.
  ///
  /// In de, this message translates to:
  /// **'Sonstiges'**
  String get defaultGroupNameForDocuments;

  /// No description provided for @documentDefaultNamePrefix.
  ///
  /// In de, this message translates to:
  /// **'Dokument'**
  String get documentDefaultNamePrefix;

  /// No description provided for @authorLabel.
  ///
  /// In de, this message translates to:
  /// **'Autor:'**
  String get authorLabel;

  /// No description provided for @you.
  ///
  /// In de, this message translates to:
  /// **'Du'**
  String get you;

  /// No description provided for @dm.
  ///
  /// In de, this message translates to:
  /// **'DM'**
  String get dm;

  /// No description provided for @hourMinutesDayMonthYearFormatString.
  ///
  /// In de, this message translates to:
  /// **'%H:%M %d.%m.%Y'**
  String get hourMinutesDayMonthYearFormatString;

  /// No description provided for @addParagraphBtnLabel.
  ///
  /// In de, this message translates to:
  /// **'Absatz'**
  String get addParagraphBtnLabel;

  /// No description provided for @addImageBtnLabel.
  ///
  /// In de, this message translates to:
  /// **'Bild'**
  String get addImageBtnLabel;

  /// No description provided for @newGroup.
  ///
  /// In de, this message translates to:
  /// **'Neue Gruppe:'**
  String get newGroup;

  /// No description provided for @newGroupBtnLabel.
  ///
  /// In de, this message translates to:
  /// **'Neue Gruppe'**
  String get newGroupBtnLabel;

  /// No description provided for @newPropertyBtnLabel.
  ///
  /// In de, this message translates to:
  /// **'Neue Eigenschaft'**
  String get newPropertyBtnLabel;

  /// No description provided for @newTabBtnLabel.
  ///
  /// In de, this message translates to:
  /// **'Neuer Tab'**
  String get newTabBtnLabel;

  /// No description provided for @itemCardDescRequires.
  ///
  /// In de, this message translates to:
  /// **'Braucht:'**
  String get itemCardDescRequires;

  /// No description provided for @defaultTab.
  ///
  /// In de, this message translates to:
  /// **'Default Tab'**
  String get defaultTab;

  /// No description provided for @amountHeaderLabel.
  ///
  /// In de, this message translates to:
  /// **'Anzahl:'**
  String get amountHeaderLabel;

  /// No description provided for @noItemsInCategoryErrorText.
  ///
  /// In de, this message translates to:
  /// **'Keine Items unter dieser Kategorie'**
  String get noItemsInCategoryErrorText;

  /// No description provided for @searchLabel.
  ///
  /// In de, this message translates to:
  /// **'Suche'**
  String get searchLabel;

  /// No description provided for @itemCategoryFilterAll.
  ///
  /// In de, this message translates to:
  /// **'Alles'**
  String get itemCategoryFilterAll;

  /// No description provided for @craftableRecipeFilter.
  ///
  /// In de, this message translates to:
  /// **'Herstellbar'**
  String get craftableRecipeFilter;

  /// No description provided for @noItemsInCategoryCraftable.
  ///
  /// In de, this message translates to:
  /// **'In dieser Kategorie sind keine Items herstellbar'**
  String get noItemsInCategoryCraftable;

  /// No description provided for @noItemsInCategory.
  ///
  /// In de, this message translates to:
  /// **'Keine Items unter dieser Kategorie'**
  String get noItemsInCategory;

  /// No description provided for @craftableAmountText.
  ///
  /// In de, this message translates to:
  /// **'Herstellbar:'**
  String get craftableAmountText;

  /// No description provided for @navBarHeaderCrafting.
  ///
  /// In de, this message translates to:
  /// **'Herstellen'**
  String get navBarHeaderCrafting;

  /// No description provided for @navBarHeaderLore.
  ///
  /// In de, this message translates to:
  /// **'Weltgeschichte'**
  String get navBarHeaderLore;

  /// No description provided for @navBarHeaderInventory.
  ///
  /// In de, this message translates to:
  /// **'Inventar'**
  String get navBarHeaderInventory;

  /// No description provided for @navBarHeaderMoney.
  ///
  /// In de, this message translates to:
  /// **'Währung'**
  String get navBarHeaderMoney;

  /// No description provided for @noMoneyDefaultText.
  ///
  /// In de, this message translates to:
  /// **'0 Gold'**
  String get noMoneyDefaultText;

  /// No description provided for @currentBalance.
  ///
  /// In de, this message translates to:
  /// **'Aktuelles Guthaben'**
  String get currentBalance;

  /// No description provided for @addBalance.
  ///
  /// In de, this message translates to:
  /// **'Guthaben hinzufügen'**
  String get addBalance;

  /// No description provided for @reduceBalance.
  ///
  /// In de, this message translates to:
  /// **'Guthaben abziehen'**
  String get reduceBalance;

  /// No description provided for @newBalance.
  ///
  /// In de, this message translates to:
  /// **'Neues Guthaben'**
  String get newBalance;

  /// No description provided for @notEnoughBalance.
  ///
  /// In de, this message translates to:
  /// **'Zu wenig Geld für diese Ausgabe'**
  String get notEnoughBalance;

  /// No description provided for @noteblockVisibleFor.
  ///
  /// In de, this message translates to:
  /// **'Sichtbar für:'**
  String get noteblockVisibleFor;

  /// No description provided for @nothingSelected.
  ///
  /// In de, this message translates to:
  /// **'- Nichts ausgewählt -'**
  String get nothingSelected;

  /// No description provided for @characterNameLabel.
  ///
  /// In de, this message translates to:
  /// **'Name:'**
  String get characterNameLabel;

  /// No description provided for @level.
  ///
  /// In de, this message translates to:
  /// **'Level'**
  String get level;

  /// No description provided for @count.
  ///
  /// In de, this message translates to:
  /// **'Anzahl'**
  String get count;

  /// No description provided for @addItems.
  ///
  /// In de, this message translates to:
  /// **'Items hinzufügen'**
  String get addItems;

  /// No description provided for @selectGameMode.
  ///
  /// In de, this message translates to:
  /// **'Rolle auswählen'**
  String get selectGameMode;

  /// No description provided for @chooseACampagne.
  ///
  /// In de, this message translates to:
  /// **'Kampagne auswählen'**
  String get chooseACampagne;

  /// No description provided for @startAsDm.
  ///
  /// In de, this message translates to:
  /// **'Als DM spielen'**
  String get startAsDm;

  /// No description provided for @youOwnXCampaigns.
  ///
  /// In de, this message translates to:
  /// **'Dir gehören {count} Kampagnen'**
  String youOwnXCampaigns(int count);

  /// No description provided for @joinAsPlayer.
  ///
  /// In de, this message translates to:
  /// **'Tritt als Spieler bei'**
  String get joinAsPlayer;

  /// No description provided for @chooseACharacter.
  ///
  /// In de, this message translates to:
  /// **'Charakter auswählen'**
  String get chooseACharacter;

  /// No description provided for @youOwnXCharacters.
  ///
  /// In de, this message translates to:
  /// **'Dir gehören {count} Charaktere'**
  String youOwnXCharacters(int count);

  /// No description provided for @campaigneName.
  ///
  /// In de, this message translates to:
  /// **'Name'**
  String get campaigneName;

  /// No description provided for @helperTextForNameOfCampaign.
  ///
  /// In de, this message translates to:
  /// **'Wie soll die Kampagne heißen?'**
  String get helperTextForNameOfCampaign;

  /// No description provided for @newCampaign.
  ///
  /// In de, this message translates to:
  /// **'Neue Kampagne'**
  String get newCampaign;

  /// No description provided for @noPlayersOnline.
  ///
  /// In de, this message translates to:
  /// **'Aktuell keine Spieler online'**
  String get noPlayersOnline;

  /// No description provided for @currentFightOrdering.
  ///
  /// In de, this message translates to:
  /// **'Aktuelle Kampfreihenfolge'**
  String get currentFightOrdering;

  /// No description provided for @noFIghtStarted.
  ///
  /// In de, this message translates to:
  /// **'Aktuell kein Kampf gestartet'**
  String get noFIghtStarted;

  /// No description provided for @newFightOrdering.
  ///
  /// In de, this message translates to:
  /// **'Neue Kampfreihenfolge'**
  String get newFightOrdering;

  /// No description provided for @additionalFightParticipants.
  ///
  /// In de, this message translates to:
  /// **'Weitere Teilnehmer'**
  String get additionalFightParticipants;

  /// No description provided for @rollForInitiativeBtnLabel.
  ///
  /// In de, this message translates to:
  /// **'Kampfreihenfolge würfeln'**
  String get rollForInitiativeBtnLabel;

  /// No description provided for @rollForInitiative.
  ///
  /// In de, this message translates to:
  /// **'Kampfreihenfolge würfeln'**
  String get rollForInitiative;

  /// No description provided for @characterName.
  ///
  /// In de, this message translates to:
  /// **'Name'**
  String get characterName;

  /// No description provided for @nameOfCharacterHelperText.
  ///
  /// In de, this message translates to:
  /// **'Wie heißt dein Charakter?'**
  String get nameOfCharacterHelperText;

  /// No description provided for @campaignName.
  ///
  /// In de, this message translates to:
  /// **'Kampagnen Name'**
  String get campaignName;

  /// No description provided for @tranformToAlternateForm.
  ///
  /// In de, this message translates to:
  /// **'Verwandeln'**
  String get tranformToAlternateForm;

  /// No description provided for @transformIntoAlternateForm.
  ///
  /// In de, this message translates to:
  /// **'Verwandeln in eine andere Form'**
  String get transformIntoAlternateForm;

  /// No description provided for @addNewTransformationComponent.
  ///
  /// In de, this message translates to:
  /// **'Füge neue Verwandlungsformen hinzu'**
  String get addNewTransformationComponent;

  /// No description provided for @createNewTransformationTitle.
  ///
  /// In de, this message translates to:
  /// **'Neue Verwandlung erstellen'**
  String get createNewTransformationTitle;

  /// No description provided for @transformationName.
  ///
  /// In de, this message translates to:
  /// **'Verwandlungsname'**
  String get transformationName;

  /// No description provided for @transformationDescription.
  ///
  /// In de, this message translates to:
  /// **'Beschreibung'**
  String get transformationDescription;

  /// No description provided for @createTransformationHelperText.
  ///
  /// In de, this message translates to:
  /// **'Um eine neue Transformation zu erstellen, musst du die Eigenschaften auswählen, die durch diese Verwandlung verändert werden. (Wenn die Eigenschaft nicht verändert wird, muss sie auch nicht ausgewählt werden.)'**
  String get createTransformationHelperText;

  /// No description provided for @back.
  ///
  /// In de, this message translates to:
  /// **'Zurück'**
  String get back;

  /// No description provided for @next.
  ///
  /// In de, this message translates to:
  /// **'Weiter'**
  String get next;

  /// No description provided for @warning.
  ///
  /// In de, this message translates to:
  /// **'Warnung'**
  String get warning;

  /// No description provided for @youAreEditingAnAlternateFormWarningText.
  ///
  /// In de, this message translates to:
  /// **'Du bearbeitest gerade eine Verwandlungs-Form. Änderungen werden nur auf dieser Verwandlung gespeichert und werden resettet, wenn du dich zurück verwandelst. Wenn du dauerhafte Veränderungen deiner Form möchtest, bearbeite die Basis-Form (indem du dich zurück verwandelst und dort die Veränderungen einpflegst).'**
  String get youAreEditingAnAlternateFormWarningText;

  /// No description provided for @transformationIsEditedWarningTitle.
  ///
  /// In de, this message translates to:
  /// **'Verwandlung wird bearbeitet'**
  String get transformationIsEditedWarningTitle;

  /// No description provided for @propertyIsCopied.
  ///
  /// In de, this message translates to:
  /// **'Eigenschaft wurde kopiert'**
  String get propertyIsCopied;

  /// No description provided for @youAreEditingACopiedPropertyChangesWillNotAffect.
  ///
  /// In de, this message translates to:
  /// **'Du bearbeitest gerade eine kopierte Eigenschaft. Änderungen werden nur auf dieser Eigenschaft gespeichert und werden nicht auf den Haupt-Charakter übertragen.'**
  String get youAreEditingACopiedPropertyChangesWillNotAffect;

  /// No description provided for @previousTransformationSelectionBtn.
  ///
  /// In de, this message translates to:
  /// **'Alte Gestalt'**
  String get previousTransformationSelectionBtn;

  /// No description provided for @newTransformationSelectionBtn.
  ///
  /// In de, this message translates to:
  /// **'Neue Gestalt'**
  String get newTransformationSelectionBtn;

  /// No description provided for @no.
  ///
  /// In de, this message translates to:
  /// **'Nein'**
  String get no;

  /// No description provided for @yes.
  ///
  /// In de, this message translates to:
  /// **'Ja'**
  String get yes;

  /// No description provided for @yourAreDisconnectedBody.
  ///
  /// In de, this message translates to:
  /// **'Du bist nicht mehr verbunden... Entweder bist du oder der DM offline...'**
  String get yourAreDisconnectedBody;

  /// No description provided for @characterNameStatTitle.
  ///
  /// In de, this message translates to:
  /// **'Charakter-Name'**
  String get characterNameStatTitle;

  /// No description provided for @characterNameStatHelperText.
  ///
  /// In de, this message translates to:
  /// **'Wie heißt dein Charakter?'**
  String get characterNameStatHelperText;

  /// No description provided for @generateImageBtnLabel.
  ///
  /// In de, this message translates to:
  /// **'Bild generieren'**
  String get generateImageBtnLabel;

  /// No description provided for @generateLoreImageTitle.
  ///
  /// In de, this message translates to:
  /// **'Generiere ein Bild'**
  String get generateLoreImageTitle;

  /// No description provided for @generatedImagesTabTitle.
  ///
  /// In de, this message translates to:
  /// **'Generierte Bilder'**
  String get generatedImagesTabTitle;

  /// No description provided for @noImagesInCampagne.
  ///
  /// In de, this message translates to:
  /// **'In dieser Kampagne sind noch keine Bilder von dir generiert worden.'**
  String get noImagesInCampagne;

  /// No description provided for @enterANameDefaultLabel.
  ///
  /// In de, this message translates to:
  /// **'Gebe Namen ein'**
  String get enterANameDefaultLabel;

  /// No description provided for @enterSomeDescriptionOnTheLeft.
  ///
  /// In de, this message translates to:
  /// **'Gebe eine Beschreibung auf der linken Seite ein.'**
  String get enterSomeDescriptionOnTheLeft;

  /// No description provided for @tabIconsConfigurationTitle.
  ///
  /// In de, this message translates to:
  /// **'Tab Icons'**
  String get tabIconsConfigurationTitle;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
