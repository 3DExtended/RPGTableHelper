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
    Locale('en'),
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
  /// **'Der erste Wert'**
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
  /// **'Der maximale Wert für diese Eigenschaft'**
  String get maxValuePlaceholder;

  /// No description provided for @secondValue.
  ///
  /// In de, this message translates to:
  /// **'Zweiter Wert'**
  String get secondValue;

  /// No description provided for @secondValuePlaceholder.
  ///
  /// In de, this message translates to:
  /// **'Der zweite Wert'**
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

  /// No description provided for @previewTestHint.
  ///
  /// In de, this message translates to:
  /// **'Probiere die Steuerung aus — Änderungen hier werden nicht gespeichert.'**
  String get previewTestHint;

  /// No description provided for @previewTestReset.
  ///
  /// In de, this message translates to:
  /// **'Zurücksetzen'**
  String get previewTestReset;

  /// No description provided for @newImageBtnLabel.
  ///
  /// In de, this message translates to:
  /// **'Neues Bild'**
  String get newImageBtnLabel;

  /// No description provided for @uploadImageBtnLabel.
  ///
  /// In de, this message translates to:
  /// **'Bild hochladen'**
  String get uploadImageBtnLabel;

  /// No description provided for @invalidImageFileSelected.
  ///
  /// In de, this message translates to:
  /// **'Die gewählte Datei ist kein Bild.'**
  String get invalidImageFileSelected;

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
  /// **'Kampagne beitreten'**
  String get addCharacterToCampagneModalTitle;

  /// No description provided for @assignCharacterToCampagneModalContent.
  ///
  /// In de, this message translates to:
  /// **'Dein Charakter ist noch keiner Kampagne zugeordnet. Gib den Beitrittscode ein, den du von deiner Spielleitung bekommen hast. Sie bestätigt dann deine Anfrage.'**
  String get assignCharacterToCampagneModalContent;

  /// No description provided for @joinCode.
  ///
  /// In de, this message translates to:
  /// **'Beitrittscode'**
  String get joinCode;

  /// No description provided for @genericErrorModalHeader.
  ///
  /// In de, this message translates to:
  /// **'Das hat nicht geklappt'**
  String get genericErrorModalHeader;

  /// No description provided for @genericErrorModalTechnicalDetailsHeader.
  ///
  /// In de, this message translates to:
  /// **'Technische Details'**
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
  /// **'Häufig geändert (z. B. jede Sitzung)'**
  String get propertyEditTypeOneTap;

  /// No description provided for @propertyEditTypeStatic.
  ///
  /// In de, this message translates to:
  /// **'Selten geändert (z. B. beim Levelaufstieg)'**
  String get propertyEditTypeStatic;

  /// No description provided for @propertyEditTypeLabel.
  ///
  /// In de, this message translates to:
  /// **'Änderungshäufigkeit'**
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
  /// **'Zahlenwert'**
  String get integerValue;

  /// No description provided for @listOfIntegersWithIcons.
  ///
  /// In de, this message translates to:
  /// **'Liste von Zahlenwerten mit Icons'**
  String get listOfIntegersWithIcons;

  /// No description provided for @integerValueWithMaxValue.
  ///
  /// In de, this message translates to:
  /// **'Zahlenwert mit Maximalwert'**
  String get integerValueWithMaxValue;

  /// No description provided for @listOfInterValuesWithCalculatedIntegerValues.
  ///
  /// In de, this message translates to:
  /// **'Gruppe von Zahlenwerten mit zusätzlicher Zahl'**
  String get listOfInterValuesWithCalculatedIntegerValues;

  /// No description provided for @integerValueWithCalculatedValue.
  ///
  /// In de, this message translates to:
  /// **'Zahlenwert mit zusätzlicher Zahl'**
  String get integerValueWithCalculatedValue;

  /// No description provided for @characterNameWithLevelAndConfigurableDetails.
  ///
  /// In de, this message translates to:
  /// **'Charakter-Grundwerte (Level, Name und weitere, optionale Angaben)'**
  String get characterNameWithLevelAndConfigurableDetails;

  /// No description provided for @multiselectOption.
  ///
  /// In de, this message translates to:
  /// **'Mehrfachauswahl'**
  String get multiselectOption;

  /// No description provided for @companionOverview.
  ///
  /// In de, this message translates to:
  /// **'Begleiterübersicht'**
  String get companionOverview;

  /// No description provided for @companionSelectorIconHeadline.
  ///
  /// In de, this message translates to:
  /// **'Icon'**
  String get companionSelectorIconHeadline;

  /// No description provided for @companionSelectorIconHint.
  ///
  /// In de, this message translates to:
  /// **'Wird auf dem Charakterbogen über diesen Begleitern angezeigt, z. B. ein Schiff für Fahrzeuge.'**
  String get companionSelectorIconHint;

  /// No description provided for @forCompanionSelector.
  ///
  /// In de, this message translates to:
  /// **'für Begleiter'**
  String get forCompanionSelector;

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
  /// **'Optionen für die Mehrfachauswahl'**
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

  /// No description provided for @multiselectOptionSummary.
  ///
  /// In de, this message translates to:
  /// **'Kurzfassung:'**
  String get multiselectOptionSummary;

  /// No description provided for @multiselectOptionSummaryHelper.
  ///
  /// In de, this message translates to:
  /// **'Optional, ca. 90 Zeichen; erscheint auf dem Charakterbogen. Der volle Text bleibt in der Beschreibung.'**
  String get multiselectOptionSummaryHelper;

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
  /// **'für Zahlenwert'**
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
  /// **'Kampagnenverwaltung'**
  String get campaignManagement;

  /// No description provided for @characterOverview.
  ///
  /// In de, this message translates to:
  /// **'Charakterübersicht'**
  String get characterOverview;

  /// No description provided for @fightingOrdering.
  ///
  /// In de, this message translates to:
  /// **'Kampfreihenfolge'**
  String get fightingOrdering;

  /// No description provided for @grantItems.
  ///
  /// In de, this message translates to:
  /// **'Items verteilen'**
  String get grantItems;

  /// No description provided for @lore.
  ///
  /// In de, this message translates to:
  /// **'Notizen'**
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
  /// **'Beitrittsanfragen'**
  String get openJoinRequests;

  /// No description provided for @joinCodeForNewPlayers.
  ///
  /// In de, this message translates to:
  /// **'Beitrittscode: {code}'**
  String joinCodeForNewPlayers(String code);

  /// No description provided for @noOpenJoinRequests.
  ///
  /// In de, this message translates to:
  /// **'Keine offenen Anfragen'**
  String get noOpenJoinRequests;

  /// No description provided for @user.
  ///
  /// In de, this message translates to:
  /// **'Benutzer:'**
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
  /// **'Noch keine Items verteilt.'**
  String get noItemsGranted;

  /// No description provided for @placeOfFinding.
  ///
  /// In de, this message translates to:
  /// **'Fundort'**
  String get placeOfFinding;

  /// No description provided for @playerRolls.
  ///
  /// In de, this message translates to:
  /// **'Würfe der Spieler'**
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
  /// **'## Items an diesem Fundort'**
  String get itemsToBeFoundInPlaceMarkdown;

  /// No description provided for @noPlaceOfFindingSelected.
  ///
  /// In de, this message translates to:
  /// **'Es wurde noch kein Fundort ausgewählt.'**
  String get noPlaceOfFindingSelected;

  /// No description provided for @followingItemsArePossibleAtPlaceOfFinding.
  ///
  /// In de, this message translates to:
  /// **'Diese Items gibt es hier:'**
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

  /// No description provided for @grantItemsFailedForPlayers.
  ///
  /// In de, this message translates to:
  /// **'Die Items konnten nicht an {characterNames} verteilt werden. Bitte versuche es erneut.'**
  String grantItemsFailedForPlayers(String characterNames);

  /// No description provided for @login.
  ///
  /// In de, this message translates to:
  /// **'Anmelden'**
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
  /// **'Neues Konto anlegen'**
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
  /// **'Item-Details für'**
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
  /// **'{amount, plural, one{Du hast ein neues Item erhalten:} other{Du hast {amount} neue Items erhalten:}}'**
  String receivedXNewItems(int amount);

  /// No description provided for @ok.
  ///
  /// In de, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @rpgConfigurationDmWizardStep2Tutorial.
  ///
  /// In de, this message translates to:
  /// **'Nun kommen wir zu den Charakterbögen.\n\nJedes Rollenspiel hat unterschiedliche Eigenschaften, die die Spieler charakterisieren (z.B. wie viele Lebenspunkte ein Spieler hat).\n\nFür jede Eigenschaft musst du, als Spielleitung, definieren, wie die Spieler mit dieser Eigenschaft interagieren können. Hierbei benötigen wir für jede Eigenschaft drei Informationen von dir:\n\n1. Name der Eigenschaft: Wie soll dieser Wert auf dem Charakterbogen heißen? (z.B. „HP“, „SP“, „Name“, etc.)\n2. Werteart der Eigenschaft: Handelt es sich z.B. um einen Text, den der Spieler anpassen kann (z.B. Hintergrundgeschichte des Charakters) oder um einen Zahlenwert (z.B. die Lebenspunkte)?\n3. Änderungsart: Manche dieser Eigenschaften werden regelmäßig angepasst (z.B. die aktuellen Lebenspunkte), andere hingegen nur selten (z.B. die maximalen Lebenspunkte). Damit dies bei der Erstellung der Charakterbögen berücksichtigt werden kann, musst du uns diese Information mitteilen.\n\nEigenschaften ordnest du in Tabs und Gruppen. Halte eine Eigenschaft gedrückt, um sie zu verschieben.'**
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
  /// **'Initiativewurf'**
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
  /// **'Initiativewurf'**
  String get initiativeRollForCharacterPrefix;

  /// No description provided for @initiativeRollText.
  ///
  /// In de, this message translates to:
  /// **'Ein Kampf beginnt. Würfle deine Initiative!'**
  String get initiativeRollText;

  /// No description provided for @initiativeRollTextFieldLabel.
  ///
  /// In de, this message translates to:
  /// **'Dein Wurf'**
  String get initiativeRollTextFieldLabel;

  /// No description provided for @initiativeBonusHelperSentence.
  ///
  /// In de, this message translates to:
  /// **'Addiere {label} {formattedBonus} zu deinem Wurf'**
  String initiativeBonusHelperSentence(Object formattedBonus, Object label);

  /// No description provided for @fightInitiativeStepTitle.
  ///
  /// In de, this message translates to:
  /// **'Kampf / Initiative'**
  String get fightInitiativeStepTitle;

  /// No description provided for @fightInitiativeStepTutorial.
  ///
  /// In de, this message translates to:
  /// **'Markiere, welcher Wert der Initiative-Bonus ist.\n\nWenn ein Spieler die Initiative würfeln soll, zeigt die App ihm diesen Bonus an. So muss er ihn nicht im Kopf haben, während das Wurffenster den Charakterbogen verdeckt.\n\nWähle **Keine**, falls dein System keinen Bonus verwendet. Sonst wähle unten einen Wert aus. Ist es eine Gruppe von Werten (z. B. Fähigkeiten), wähle zusätzlich den passenden Eintrag. Besteht der Wert aus zwei Zahlen (z. B. Wert und Modifikator oder aktuell und maximal), wähle, welche davon als Bonus zählt.'**
  String get fightInitiativeStepTutorial;

  /// No description provided for @initiativeBonusNoneOption.
  ///
  /// In de, this message translates to:
  /// **'Keine'**
  String get initiativeBonusNoneOption;

  /// No description provided for @initiativeBonusStatPickerLabel.
  ///
  /// In de, this message translates to:
  /// **'Eigenschaft'**
  String get initiativeBonusStatPickerLabel;

  /// No description provided for @initiativeBonusListEntryPickerLabel.
  ///
  /// In de, this message translates to:
  /// **'Listeneintrag'**
  String get initiativeBonusListEntryPickerLabel;

  /// No description provided for @initiativeBonusFieldPickerLabel.
  ///
  /// In de, this message translates to:
  /// **'Feld'**
  String get initiativeBonusFieldPickerLabel;

  /// No description provided for @initiativeBonusIncompleteWarningTitle.
  ///
  /// In de, this message translates to:
  /// **'Unvollständige Auswahl'**
  String get initiativeBonusIncompleteWarningTitle;

  /// No description provided for @initiativeBonusIncompleteWarningBody.
  ///
  /// In de, this message translates to:
  /// **'Deine Auswahl für den Initiative-Bonus ist unvollständig. Wenn du die Seite verlässt, wird sie gelöscht.'**
  String get initiativeBonusIncompleteWarningBody;

  /// No description provided for @initiativeBonusIncompleteStay.
  ///
  /// In de, this message translates to:
  /// **'Bleiben'**
  String get initiativeBonusIncompleteStay;

  /// No description provided for @initiativeBonusIncompleteLeave.
  ///
  /// In de, this message translates to:
  /// **'Trotzdem verlassen'**
  String get initiativeBonusIncompleteLeave;

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
  /// **'Hier änderst du den Titel und die Gruppe deiner Seite.'**
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
  /// **'im Besitz:'**
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
  /// **'Spielleitung'**
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
  /// **'Start-Tab'**
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

  /// No description provided for @itemSortByName.
  ///
  /// In de, this message translates to:
  /// **'Nach Name sortieren (A–Z)'**
  String get itemSortByName;

  /// No description provided for @itemSortByValueAscending.
  ///
  /// In de, this message translates to:
  /// **'Nach Wert sortieren (aufsteigend)'**
  String get itemSortByValueAscending;

  /// No description provided for @itemSortByValueDescending.
  ///
  /// In de, this message translates to:
  /// **'Nach Wert sortieren (absteigend)'**
  String get itemSortByValueDescending;

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

  /// No description provided for @notCraftableRecipeFilter.
  ///
  /// In de, this message translates to:
  /// **'Nicht herstellbar'**
  String get notCraftableRecipeFilter;

  /// No description provided for @noItemsInCategoryCraftable.
  ///
  /// In de, this message translates to:
  /// **'In dieser Kategorie sind keine Items herstellbar'**
  String get noItemsInCategoryCraftable;

  /// No description provided for @noItemsInCategoryNotCraftable.
  ///
  /// In de, this message translates to:
  /// **'In dieser Kategorie sind alle Items herstellbar'**
  String get noItemsInCategoryNotCraftable;

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
  /// **'Notizen'**
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
  /// **'Als Spielleitung'**
  String get startAsDm;

  /// No description provided for @youOwnXCampaigns.
  ///
  /// In de, this message translates to:
  /// **'{count, plural, =0{Du leitest noch keine Kampagne.} one{Du leitest 1 Kampagne.} other{Du leitest {count} Kampagnen.}}'**
  String youOwnXCampaigns(int count);

  /// No description provided for @joinAsPlayer.
  ///
  /// In de, this message translates to:
  /// **'Als Spieler'**
  String get joinAsPlayer;

  /// No description provided for @chooseACharacter.
  ///
  /// In de, this message translates to:
  /// **'Charakter auswählen'**
  String get chooseACharacter;

  /// No description provided for @youOwnXCharacters.
  ///
  /// In de, this message translates to:
  /// **'{count, plural, =0{Du hast noch keinen Charakter.} one{Du hast 1 Charakter.} other{Du hast {count} Charaktere.}}'**
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
  /// **'Gerade ist kein Spieler online'**
  String get noPlayersOnline;

  /// No description provided for @currentFightOrdering.
  ///
  /// In de, this message translates to:
  /// **'Aktuelle Kampfreihenfolge'**
  String get currentFightOrdering;

  /// No description provided for @noFIghtStarted.
  ///
  /// In de, this message translates to:
  /// **'Gerade läuft kein Kampf'**
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
  /// **'Kampagnenname'**
  String get campaignName;

  /// No description provided for @tranformToAlternateForm.
  ///
  /// In de, this message translates to:
  /// **'Verwandeln'**
  String get tranformToAlternateForm;

  /// No description provided for @transformIntoAlternateForm.
  ///
  /// In de, this message translates to:
  /// **'In eine andere Form verwandeln'**
  String get transformIntoAlternateForm;

  /// No description provided for @addNewTransformationComponent.
  ///
  /// In de, this message translates to:
  /// **'Verwandlung hinzufügen'**
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
  /// **'Wähle die Eigenschaften aus, die sich durch diese Verwandlung ändern. Alle anderen bleiben, wie sie sind.'**
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
  /// **'Du bearbeitest gerade eine Verwandlung. Änderungen gelten nur für diese Verwandlung und gehen verloren, wenn du dich zurückverwandelst. Für dauerhafte Änderungen verwandle dich zurück und bearbeite deine Grundform.'**
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
  /// **'Du bearbeitest gerade eine kopierte Eigenschaft. Änderungen gelten nur hier und werden nicht auf den Hauptcharakter übertragen.'**
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
  /// **'Die Verbindung ist unterbrochen. Entweder du oder deine Spielleitung ist offline.'**
  String get yourAreDisconnectedBody;

  /// No description provided for @characterNameStatTitle.
  ///
  /// In de, this message translates to:
  /// **'Charaktername'**
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
  /// **'Bild generieren'**
  String get generateLoreImageTitle;

  /// No description provided for @characterPortraitImagePrompt.
  ///
  /// In de, this message translates to:
  /// **'Porträtbeschreibung'**
  String get characterPortraitImagePrompt;

  /// No description provided for @characterPortraitImagePromptPlaceholder.
  ///
  /// In de, this message translates to:
  /// **'Beschreibe deinen Charakter für die Bildgenerierung'**
  String get characterPortraitImagePromptPlaceholder;

  /// No description provided for @generatedImagesTabTitle.
  ///
  /// In de, this message translates to:
  /// **'Generierte Bilder'**
  String get generatedImagesTabTitle;

  /// No description provided for @noImagesInCampagne.
  ///
  /// In de, this message translates to:
  /// **'Du hast in dieser Kampagne noch keine Bilder generiert.'**
  String get noImagesInCampagne;

  /// No description provided for @enterANameDefaultLabel.
  ///
  /// In de, this message translates to:
  /// **'Gib einen Namen ein'**
  String get enterANameDefaultLabel;

  /// No description provided for @enterSomeDescriptionOnTheLeft.
  ///
  /// In de, this message translates to:
  /// **'Gib links eine Beschreibung ein.'**
  String get enterSomeDescriptionOnTheLeft;

  /// No description provided for @tabIconsConfigurationTitle.
  ///
  /// In de, this message translates to:
  /// **'Tab-Icons'**
  String get tabIconsConfigurationTitle;

  /// No description provided for @realtimeSessionIosHint.
  ///
  /// In de, this message translates to:
  /// **'Auf dem iPad oder iPhone funktionieren Live-Updates am zuverlässigsten, wenn die App im Vordergrund geöffnet ist.'**
  String get realtimeSessionIosHint;

  /// No description provided for @pendingHubSyncBanner.
  ///
  /// In de, this message translates to:
  /// **'Einige Änderungen werden noch mit der Sitzung synchronisiert…'**
  String get pendingHubSyncBanner;

  /// No description provided for @characterConfigSaveFailedTitle.
  ///
  /// In de, this message translates to:
  /// **'Charakter nicht gespeichert'**
  String get characterConfigSaveFailedTitle;

  /// No description provided for @characterConfigSaveFailedBody.
  ///
  /// In de, this message translates to:
  /// **'Deine Änderungen am Charakter konnten nicht gespeichert werden. Prüfe deine Verbindung und versuche es erneut.'**
  String get characterConfigSaveFailedBody;

  /// No description provided for @logout.
  ///
  /// In de, this message translates to:
  /// **'Abmelden'**
  String get logout;

  /// No description provided for @sessionExpiredMessage.
  ///
  /// In de, this message translates to:
  /// **'Deine Sitzung ist abgelaufen. Bitte melde dich erneut an.'**
  String get sessionExpiredMessage;

  /// No description provided for @characterSheetSkinClassicLight.
  ///
  /// In de, this message translates to:
  /// **'Klassisch Hell'**
  String get characterSheetSkinClassicLight;

  /// No description provided for @characterSheetSkinClassicDark.
  ///
  /// In de, this message translates to:
  /// **'Klassisch Dunkel'**
  String get characterSheetSkinClassicDark;

  /// No description provided for @characterSheetSkinArcaneLedger.
  ///
  /// In de, this message translates to:
  /// **'Arkaner Foliant'**
  String get characterSheetSkinArcaneLedger;

  /// No description provided for @characterSheetSkinNightCartographer.
  ///
  /// In de, this message translates to:
  /// **'Nachtkartograph'**
  String get characterSheetSkinNightCartographer;

  /// No description provided for @characterSheetSkinUseCampaignDefault.
  ///
  /// In de, this message translates to:
  /// **'Kampagnen-Standard verwenden'**
  String get characterSheetSkinUseCampaignDefault;

  /// No description provided for @characterSheetSkinCampaignDefaultLabel.
  ///
  /// In de, this message translates to:
  /// **'Kampagnen-Standard'**
  String get characterSheetSkinCampaignDefaultLabel;

  /// No description provided for @characterSheetAppearanceTitle.
  ///
  /// In de, this message translates to:
  /// **'Darstellung'**
  String get characterSheetAppearanceTitle;

  /// No description provided for @apiKeysTitle.
  ///
  /// In de, this message translates to:
  /// **'API-Schlüssel'**
  String get apiKeysTitle;

  /// No description provided for @apiKeysDocsTitle.
  ///
  /// In de, this message translates to:
  /// **'API-Dokumentation'**
  String get apiKeysDocsTitle;

  /// No description provided for @apiKeysDocsDescription.
  ///
  /// In de, this message translates to:
  /// **'Mit API-Schlüsseln kann eine andere App, etwa eine Begleit-App aus deiner Gruppe, für dich als Spieler handeln. Jeder Schlüssel darf nur, was du ihm erlaubst.'**
  String get apiKeysDocsDescription;

  /// No description provided for @apiKeysViewDocs.
  ///
  /// In de, this message translates to:
  /// **'API-Dokumentation öffnen'**
  String get apiKeysViewDocs;

  /// No description provided for @apiKeysGenerate.
  ///
  /// In de, this message translates to:
  /// **'Neuen API-Schlüssel erstellen'**
  String get apiKeysGenerate;

  /// No description provided for @apiKeysEmpty.
  ///
  /// In de, this message translates to:
  /// **'Noch keine API-Schlüssel.'**
  String get apiKeysEmpty;

  /// No description provided for @apiKeysLoadFailed.
  ///
  /// In de, this message translates to:
  /// **'Deine API-Schlüssel konnten nicht geladen werden.'**
  String get apiKeysLoadFailed;

  /// No description provided for @apiKeyUnnamed.
  ///
  /// In de, this message translates to:
  /// **'Unbenannter Schlüssel'**
  String get apiKeyUnnamed;

  /// No description provided for @apiKeyRevoked.
  ///
  /// In de, this message translates to:
  /// **'Widerrufen'**
  String get apiKeyRevoked;

  /// No description provided for @apiKeyExpired.
  ///
  /// In de, this message translates to:
  /// **'Abgelaufen'**
  String get apiKeyExpired;

  /// No description provided for @apiKeyPrefix.
  ///
  /// In de, this message translates to:
  /// **'Präfix: {prefix}'**
  String apiKeyPrefix(String prefix);

  /// No description provided for @apiKeyRevokedAt.
  ///
  /// In de, this message translates to:
  /// **'Widerrufen: {date}'**
  String apiKeyRevokedAt(String date);

  /// No description provided for @apiKeyLastUsedAt.
  ///
  /// In de, this message translates to:
  /// **'Zuletzt benutzt: {date}'**
  String apiKeyLastUsedAt(String date);

  /// No description provided for @apiKeyNeverUsed.
  ///
  /// In de, this message translates to:
  /// **'Noch nie benutzt'**
  String get apiKeyNeverUsed;

  /// No description provided for @apiKeyExpiresAt.
  ///
  /// In de, this message translates to:
  /// **'Läuft ab: {date}'**
  String apiKeyExpiresAt(String date);

  /// No description provided for @apiKeyNeverExpires.
  ///
  /// In de, this message translates to:
  /// **'Läuft nie ab'**
  String get apiKeyNeverExpires;

  /// No description provided for @apiKeyRevokeTitle.
  ///
  /// In de, this message translates to:
  /// **'API-Schlüssel widerrufen?'**
  String get apiKeyRevokeTitle;

  /// No description provided for @apiKeyRevokeBody.
  ///
  /// In de, this message translates to:
  /// **'Das lässt sich nicht rückgängig machen. Jede App, die diesen Schlüssel nutzt, verliert sofort den Zugriff.'**
  String get apiKeyRevokeBody;

  /// No description provided for @apiKeyRevokeConfirm.
  ///
  /// In de, this message translates to:
  /// **'Widerrufen'**
  String get apiKeyRevokeConfirm;

  /// No description provided for @apiKeyRevokeFailed.
  ///
  /// In de, this message translates to:
  /// **'Der API-Schlüssel konnte nicht widerrufen werden.'**
  String get apiKeyRevokeFailed;

  /// No description provided for @apiKeyCreateTitle.
  ///
  /// In de, this message translates to:
  /// **'Neuer API-Schlüssel'**
  String get apiKeyCreateTitle;

  /// No description provided for @apiKeyCreateHint.
  ///
  /// In de, this message translates to:
  /// **'Gib Schlüssel nur an Apps, denen du vertraust. Sie handeln in deinem Namen.'**
  String get apiKeyCreateHint;

  /// No description provided for @apiKeyNameLabel.
  ///
  /// In de, this message translates to:
  /// **'Name, z. B. die App, die ihn nutzt'**
  String get apiKeyNameLabel;

  /// No description provided for @apiKeyPermissionsLabel.
  ///
  /// In de, this message translates to:
  /// **'Rechte'**
  String get apiKeyPermissionsLabel;

  /// No description provided for @apiKeyPresetReadOnly.
  ///
  /// In de, this message translates to:
  /// **'Nur lesen'**
  String get apiKeyPresetReadOnly;

  /// No description provided for @apiKeyPresetCompanion.
  ///
  /// In de, this message translates to:
  /// **'Begleit-App für Spieler'**
  String get apiKeyPresetCompanion;

  /// No description provided for @apiKeyPresetCustom.
  ///
  /// In de, this message translates to:
  /// **'Benutzerdefiniert'**
  String get apiKeyPresetCustom;

  /// No description provided for @apiKeyScopeCampaignsRead.
  ///
  /// In de, this message translates to:
  /// **'Deine Kampagnen und Mitspieler sehen'**
  String get apiKeyScopeCampaignsRead;

  /// No description provided for @apiKeyScopeCharactersRead.
  ///
  /// In de, this message translates to:
  /// **'Deine Charakterbögen lesen'**
  String get apiKeyScopeCharactersRead;

  /// No description provided for @apiKeyScopeCharactersWrite.
  ///
  /// In de, this message translates to:
  /// **'Deine Charakterbögen ändern, z. B. Lebenspunkte'**
  String get apiKeyScopeCharactersWrite;

  /// No description provided for @apiKeyScopeNotesRead.
  ///
  /// In de, this message translates to:
  /// **'Die Notizen lesen, die du sehen darfst'**
  String get apiKeyScopeNotesRead;

  /// No description provided for @apiKeyScopeNotesWrite.
  ///
  /// In de, this message translates to:
  /// **'Eigene Notizen schreiben und festlegen, wer sie sieht'**
  String get apiKeyScopeNotesWrite;

  /// No description provided for @apiKeyScopeFightsPlay.
  ///
  /// In de, this message translates to:
  /// **'Initiative würfeln, wenn die Spielleitung einen Kampf startet'**
  String get apiKeyScopeFightsPlay;

  /// No description provided for @apiKeyScopeEvents.
  ///
  /// In de, this message translates to:
  /// **'Live-Updates empfangen'**
  String get apiKeyScopeEvents;

  /// No description provided for @apiKeyExpiryLabel.
  ///
  /// In de, this message translates to:
  /// **'Gültig für'**
  String get apiKeyExpiryLabel;

  /// No description provided for @apiKeyPermissionsNeedServerUpdate.
  ///
  /// In de, this message translates to:
  /// **'Dieser Server gibt jedem Schlüssel Lesezugriff auf deine Kampagnen, Charaktere und Notizen. Rechte und Laufzeit kannst du wählen, sobald der Server aktualisiert ist.'**
  String get apiKeyPermissionsNeedServerUpdate;

  /// No description provided for @apiKeyExpiryNever.
  ///
  /// In de, this message translates to:
  /// **'Unbegrenzt'**
  String get apiKeyExpiryNever;

  /// No description provided for @apiKeyExpiry30Days.
  ///
  /// In de, this message translates to:
  /// **'30 Tage'**
  String get apiKeyExpiry30Days;

  /// No description provided for @apiKeyExpiry90Days.
  ///
  /// In de, this message translates to:
  /// **'90 Tage'**
  String get apiKeyExpiry90Days;

  /// No description provided for @apiKeyExpiry1Year.
  ///
  /// In de, this message translates to:
  /// **'1 Jahr'**
  String get apiKeyExpiry1Year;

  /// No description provided for @apiKeyCreateConfirm.
  ///
  /// In de, this message translates to:
  /// **'Erstellen'**
  String get apiKeyCreateConfirm;

  /// No description provided for @apiKeyNameRequired.
  ///
  /// In de, this message translates to:
  /// **'Gib einen Namen ein.'**
  String get apiKeyNameRequired;

  /// No description provided for @apiKeyNoScopeSelected.
  ///
  /// In de, this message translates to:
  /// **'Wähle mindestens ein Recht aus.'**
  String get apiKeyNoScopeSelected;

  /// No description provided for @apiKeyCreateFailed.
  ///
  /// In de, this message translates to:
  /// **'Der API-Schlüssel konnte nicht erstellt werden.'**
  String get apiKeyCreateFailed;

  /// No description provided for @apiKeyCreatedTitle.
  ///
  /// In de, this message translates to:
  /// **'API-Schlüssel erstellt'**
  String get apiKeyCreatedTitle;

  /// No description provided for @apiKeyCreatedBody.
  ///
  /// In de, this message translates to:
  /// **'Kopiere den neuen Schlüssel jetzt. Er wird dir nicht noch einmal angezeigt.'**
  String get apiKeyCreatedBody;

  /// No description provided for @apiKeyCopy.
  ///
  /// In de, this message translates to:
  /// **'Kopieren'**
  String get apiKeyCopy;

  /// No description provided for @apiKeyCopied.
  ///
  /// In de, this message translates to:
  /// **'In die Zwischenablage kopiert'**
  String get apiKeyCopied;

  /// No description provided for @apiKeyDone.
  ///
  /// In de, this message translates to:
  /// **'Fertig'**
  String get apiKeyDone;

  /// No description provided for @endFight.
  ///
  /// In de, this message translates to:
  /// **'Kampf beenden'**
  String get endFight;

  /// No description provided for @endFightConfirmation.
  ///
  /// In de, this message translates to:
  /// **'Kampf wirklich beenden? Wer noch nicht gewürfelt hat, wird dann nicht mehr gefragt.'**
  String get endFightConfirmation;

  /// No description provided for @waitingForInitiative.
  ///
  /// In de, this message translates to:
  /// **'Wartet auf Initiative'**
  String get waitingForInitiative;

  /// No description provided for @notAtTheTable.
  ///
  /// In de, this message translates to:
  /// **'nicht am Tisch'**
  String get notAtTheTable;

  /// No description provided for @noCharactersInCampagne.
  ///
  /// In de, this message translates to:
  /// **'Noch keine Charaktere in dieser Kampagne'**
  String get noCharactersInCampagne;

  /// No description provided for @customizeCards.
  ///
  /// In de, this message translates to:
  /// **'Karten anpassen'**
  String get customizeCards;

  /// No description provided for @hiddenCards.
  ///
  /// In de, this message translates to:
  /// **'Ausgeblendet'**
  String get hiddenCards;

  /// No description provided for @allCardsHidden.
  ///
  /// In de, this message translates to:
  /// **'Alle Karten sind ausgeblendet'**
  String get allCardsHidden;

  /// No description provided for @visibleCards.
  ///
  /// In de, this message translates to:
  /// **'Sichtbare Karten'**
  String get visibleCards;

  /// No description provided for @visibleCardsHint.
  ///
  /// In de, this message translates to:
  /// **'Ausgeblendete Karten bleiben auf diesem Gerät ausgeblendet, auch wenn ein Spieler zwischendurch offline war.'**
  String get visibleCardsHint;

  /// No description provided for @cardStatsSection.
  ///
  /// In de, this message translates to:
  /// **'Eigenschaften auf den Karten'**
  String get cardStatsSection;

  /// No description provided for @chooseCardStatsYourself.
  ///
  /// In de, this message translates to:
  /// **'Eigenschaften selbst wählen'**
  String get chooseCardStatsYourself;

  /// No description provided for @automaticCardStatsHint.
  ///
  /// In de, this message translates to:
  /// **'Automatisch: der erste Wert mit Maximum als Balken und die ersten Zahlen aus dem Standard-Tab.'**
  String get automaticCardStatsHint;

  /// No description provided for @cardBar.
  ///
  /// In de, this message translates to:
  /// **'Balken'**
  String get cardBar;

  /// No description provided for @noBar.
  ///
  /// In de, this message translates to:
  /// **'Kein Balken'**
  String get noBar;

  /// No description provided for @cardNumbers.
  ///
  /// In de, this message translates to:
  /// **'Zahlen'**
  String get cardNumbers;

  /// No description provided for @companion.
  ///
  /// In de, this message translates to:
  /// **'Begleiter'**
  String get companion;

  /// No description provided for @calculatedValueShort.
  ///
  /// In de, this message translates to:
  /// **'ber.'**
  String get calculatedValueShort;

  /// No description provided for @noCardStatsAvailable.
  ///
  /// In de, this message translates to:
  /// **'Diese Kampagne hat noch keine Eigenschaften mit Zahlen.'**
  String get noCardStatsAvailable;

  /// No description provided for @maxValueShort.
  ///
  /// In de, this message translates to:
  /// **'Max.'**
  String get maxValueShort;

  /// No description provided for @computedValue.
  ///
  /// In de, this message translates to:
  /// **'Wert berechnen'**
  String get computedValue;

  /// No description provided for @computedValueHint.
  ///
  /// In de, this message translates to:
  /// **'Spieler tragen diesen Wert nicht ein: Er wird aus anderen Eigenschaften berechnet, z. B. passive Wahrnehmung = 10 + Mod(Weisheit) + Übungsbonus (wenn geübt). Modifikatoren werden abgerundet.'**
  String get computedValueHint;

  /// No description provided for @computedBase.
  ///
  /// In de, this message translates to:
  /// **'Startwert'**
  String get computedBase;

  /// No description provided for @computedTerms.
  ///
  /// In de, this message translates to:
  /// **'Bausteine'**
  String get computedTerms;

  /// No description provided for @addComputedTerm.
  ///
  /// In de, this message translates to:
  /// **'Baustein hinzufügen'**
  String get addComputedTerm;

  /// No description provided for @computedSource.
  ///
  /// In de, this message translates to:
  /// **'Wert'**
  String get computedSource;

  /// No description provided for @computedMode.
  ///
  /// In de, this message translates to:
  /// **'Umrechnung'**
  String get computedMode;

  /// No description provided for @computedModeValue.
  ///
  /// In de, this message translates to:
  /// **'wie er ist'**
  String get computedModeValue;

  /// No description provided for @computedModeModifier.
  ///
  /// In de, this message translates to:
  /// **'Modifikator (x−10)/2'**
  String get computedModeModifier;

  /// No description provided for @computedFactor.
  ///
  /// In de, this message translates to:
  /// **'Faktor'**
  String get computedFactor;

  /// No description provided for @computedCondition.
  ///
  /// In de, this message translates to:
  /// **'Zählt nur, wenn gewählt'**
  String get computedCondition;

  /// No description provided for @computedAlways.
  ///
  /// In de, this message translates to:
  /// **'Immer'**
  String get computedAlways;

  /// No description provided for @computedPreview.
  ///
  /// In de, this message translates to:
  /// **'Formel'**
  String get computedPreview;

  /// No description provided for @computedValueNoSources.
  ///
  /// In de, this message translates to:
  /// **'Lege zuerst Eigenschaften mit Zahlen an.'**
  String get computedValueNoSources;

  /// No description provided for @computedModifierOf.
  ///
  /// In de, this message translates to:
  /// **'Mod({label})'**
  String computedModifierOf(String label);

  /// No description provided for @computedIfPicked.
  ///
  /// In de, this message translates to:
  /// **'(wenn {condition})'**
  String computedIfPicked(String condition);

  /// No description provided for @computedValueBadge.
  ///
  /// In de, this message translates to:
  /// **'berechnet'**
  String get computedValueBadge;

  /// No description provided for @computedPreset.
  ///
  /// In de, this message translates to:
  /// **'Vorlage (Fantasy 5E)'**
  String get computedPreset;

  /// No description provided for @computedPresetPassivePerception.
  ///
  /// In de, this message translates to:
  /// **'Passive Wahrnehmung'**
  String get computedPresetPassivePerception;

  /// No description provided for @computedPresetPassiveInsight.
  ///
  /// In de, this message translates to:
  /// **'Passives Motiv erkennen'**
  String get computedPresetPassiveInsight;

  /// No description provided for @computedPresetPassiveInvestigation.
  ///
  /// In de, this message translates to:
  /// **'Passive Nachforschungen'**
  String get computedPresetPassiveInvestigation;

  /// No description provided for @computedPresetPassiveStealth.
  ///
  /// In de, this message translates to:
  /// **'Passive Heimlichkeit'**
  String get computedPresetPassiveStealth;

  /// No description provided for @computedPresetInitiative.
  ///
  /// In de, this message translates to:
  /// **'Initiative'**
  String get computedPresetInitiative;

  /// No description provided for @computedPresetUnarmoredArmorClass.
  ///
  /// In de, this message translates to:
  /// **'RK ohne Rüstung'**
  String get computedPresetUnarmoredArmorClass;

  /// No description provided for @computedPresetIncomplete.
  ///
  /// In de, this message translates to:
  /// **'Nicht alle Werte der Vorlage gibt es in dieser Kampagne. Ergänze die fehlenden Bausteine selbst.'**
  String get computedPresetIncomplete;

  /// No description provided for @attachImageBtnLabel.
  ///
  /// In de, this message translates to:
  /// **'Bild hinzufügen'**
  String get attachImageBtnLabel;

  /// No description provided for @replaceImageBtnLabel.
  ///
  /// In de, this message translates to:
  /// **'Bild ersetzen'**
  String get replaceImageBtnLabel;

  /// No description provided for @removeImageBtnLabel.
  ///
  /// In de, this message translates to:
  /// **'Bild entfernen'**
  String get removeImageBtnLabel;

  /// No description provided for @uploadImageMenuLabel.
  ///
  /// In de, this message translates to:
  /// **'Bild hochladen'**
  String get uploadImageMenuLabel;

  /// No description provided for @insertParagraphMenuLabel.
  ///
  /// In de, this message translates to:
  /// **'Absatz hier einfügen'**
  String get insertParagraphMenuLabel;

  /// No description provided for @connectionLostReconnecting.
  ///
  /// In de, this message translates to:
  /// **'Verbindung unterbrochen – verbinde neu …'**
  String get connectionLostReconnecting;

  /// No description provided for @appName.
  ///
  /// In de, this message translates to:
  /// **'QuestKeeper'**
  String get appName;

  /// No description provided for @welcomeTagline.
  ///
  /// In de, this message translates to:
  /// **'Dein Begleiter für Pen-&-Paper-Runden am Tisch.'**
  String get welcomeTagline;

  /// No description provided for @welcomeDescription.
  ///
  /// In de, this message translates to:
  /// **'Die Spielleitung verwaltet die Kampagne. Die Spieler haben ihren Charakterbogen, ihre Notizen und die Live-Werte auf dem Handy.'**
  String get welcomeDescription;

  /// No description provided for @welcomeLeadButton.
  ///
  /// In de, this message translates to:
  /// **'Ich leite eine Runde'**
  String get welcomeLeadButton;

  /// No description provided for @welcomeLeadHint.
  ///
  /// In de, this message translates to:
  /// **'Du legst eine Kampagne an und lädst deine Gruppe ein.'**
  String get welcomeLeadHint;

  /// No description provided for @welcomeJoinButton.
  ///
  /// In de, this message translates to:
  /// **'Ich trete einer Runde bei'**
  String get welcomeJoinButton;

  /// No description provided for @welcomeJoinHint.
  ///
  /// In de, this message translates to:
  /// **'Nach der Anmeldung gibst du den Code deiner Spielleitung ein.'**
  String get welcomeJoinHint;

  /// No description provided for @loginIntroLead.
  ///
  /// In de, this message translates to:
  /// **'Melde dich an oder lege ein Konto an. Danach legst du deine Kampagne an.'**
  String get loginIntroLead;

  /// No description provided for @loginIntroJoin.
  ///
  /// In de, this message translates to:
  /// **'Melde dich an oder lege ein Konto an. Danach gibst du den Code deiner Spielleitung ein.'**
  String get loginIntroJoin;

  /// No description provided for @loginMissingInput.
  ///
  /// In de, this message translates to:
  /// **'Bitte gib Nutzername und Passwort ein.'**
  String get loginMissingInput;

  /// No description provided for @loginWrongCredentials.
  ///
  /// In de, this message translates to:
  /// **'Nutzername oder Passwort stimmt nicht.'**
  String get loginWrongCredentials;

  /// No description provided for @forgotPasswordLink.
  ///
  /// In de, this message translates to:
  /// **'Passwort vergessen?'**
  String get forgotPasswordLink;

  /// No description provided for @usernameRuleHint.
  ///
  /// In de, this message translates to:
  /// **'3 bis 13 Zeichen, nur Buchstaben und Ziffern'**
  String get usernameRuleHint;

  /// No description provided for @passwordRulesTitle.
  ///
  /// In de, this message translates to:
  /// **'Dein Passwort braucht'**
  String get passwordRulesTitle;

  /// No description provided for @passwordRuleMinLength.
  ///
  /// In de, this message translates to:
  /// **'mindestens {count} Zeichen'**
  String passwordRuleMinLength(int count);

  /// No description provided for @passwordRuleMaxLength.
  ///
  /// In de, this message translates to:
  /// **'höchstens {count} Zeichen'**
  String passwordRuleMaxLength(int count);

  /// No description provided for @passwordRuleMet.
  ///
  /// In de, this message translates to:
  /// **'erfüllt'**
  String get passwordRuleMet;

  /// No description provided for @passwordRuleNotMet.
  ///
  /// In de, this message translates to:
  /// **'noch nicht erfüllt'**
  String get passwordRuleNotMet;

  /// No description provided for @registerUsernameInvalid.
  ///
  /// In de, this message translates to:
  /// **'Der Nutzername braucht 3 bis 13 Zeichen, nur Buchstaben und Ziffern.'**
  String get registerUsernameInvalid;

  /// No description provided for @registerEmailInvalid.
  ///
  /// In de, this message translates to:
  /// **'Bitte gib eine gültige E-Mail-Adresse ein.'**
  String get registerEmailInvalid;

  /// No description provided for @registerPasswordInvalid.
  ///
  /// In de, this message translates to:
  /// **'Das Passwort erfüllt noch nicht alle Regeln.'**
  String get registerPasswordInvalid;

  /// No description provided for @registerUsernameTaken.
  ///
  /// In de, this message translates to:
  /// **'Diesen Nutzernamen gibt es schon. Bitte wähle einen anderen.'**
  String get registerUsernameTaken;

  /// No description provided for @registerPrivacyNotice.
  ///
  /// In de, this message translates to:
  /// **'Wie wir mit deinen Daten umgehen, steht in unserer {privacyPolicyLink}.'**
  String registerPrivacyNotice(String privacyPolicyLink);

  /// No description provided for @privacyPolicyLinkLabel.
  ///
  /// In de, this message translates to:
  /// **'Datenschutzerklärung'**
  String get privacyPolicyLinkLabel;

  /// No description provided for @registerPrivacyNoticeWithoutLink.
  ///
  /// In de, this message translates to:
  /// **'Deine E-Mail-Adresse brauchen wir nur für dein Konto, zum Beispiel zum Zurücksetzen des Passworts.'**
  String get registerPrivacyNoticeWithoutLink;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In de, this message translates to:
  /// **'Passwort zurücksetzen'**
  String get forgotPasswordTitle;

  /// No description provided for @forgotPasswordRequestIntro.
  ///
  /// In de, this message translates to:
  /// **'Gib deinen Nutzernamen und die E-Mail-Adresse deines Kontos ein. Wir schicken dir einen Code.'**
  String get forgotPasswordRequestIntro;

  /// No description provided for @forgotPasswordRequestButton.
  ///
  /// In de, this message translates to:
  /// **'Code anfordern'**
  String get forgotPasswordRequestButton;

  /// No description provided for @forgotPasswordRequestFailed.
  ///
  /// In de, this message translates to:
  /// **'Wir konnten keinen Code schicken. Prüfe Nutzername und E-Mail-Adresse. Wenn du dich mit Apple anmeldest, brauchst du kein Passwort.'**
  String get forgotPasswordRequestFailed;

  /// No description provided for @forgotPasswordCodeSent.
  ///
  /// In de, this message translates to:
  /// **'Wir haben dir einen Code an {email} geschickt. Er gilt zwei Stunden.'**
  String forgotPasswordCodeSent(String email);

  /// No description provided for @resetCodeLabel.
  ///
  /// In de, this message translates to:
  /// **'Code aus der E-Mail'**
  String get resetCodeLabel;

  /// No description provided for @resetCodeHint.
  ///
  /// In de, this message translates to:
  /// **'z. B. 123-456'**
  String get resetCodeHint;

  /// No description provided for @resetCodeInvalid.
  ///
  /// In de, this message translates to:
  /// **'Der Code hat sechs Ziffern, z. B. 123-456.'**
  String get resetCodeInvalid;

  /// No description provided for @newPasswordLabel.
  ///
  /// In de, this message translates to:
  /// **'Neues Passwort'**
  String get newPasswordLabel;

  /// No description provided for @forgotPasswordSaveButton.
  ///
  /// In de, this message translates to:
  /// **'Passwort speichern'**
  String get forgotPasswordSaveButton;

  /// No description provided for @forgotPasswordResetFailed.
  ///
  /// In de, this message translates to:
  /// **'Das hat nicht geklappt: Der Code stimmt nicht oder ist abgelaufen. Fordere bei Bedarf einen neuen an.'**
  String get forgotPasswordResetFailed;

  /// No description provided for @forgotPasswordRequestNewCode.
  ///
  /// In de, this message translates to:
  /// **'Neuen Code anfordern'**
  String get forgotPasswordRequestNewCode;

  /// No description provided for @forgotPasswordSuccess.
  ///
  /// In de, this message translates to:
  /// **'Dein Passwort ist geändert. Melde dich jetzt mit dem neuen Passwort an.'**
  String get forgotPasswordSuccess;

  /// No description provided for @forgotPasswordBackToLogin.
  ///
  /// In de, this message translates to:
  /// **'Zur Anmeldung'**
  String get forgotPasswordBackToLogin;

  /// No description provided for @authNoConnection.
  ///
  /// In de, this message translates to:
  /// **'Der Server ist gerade nicht erreichbar. Versuch es gleich noch einmal.'**
  String get authNoConnection;

  /// No description provided for @wizardFinishBtnLabel.
  ///
  /// In de, this message translates to:
  /// **'Fertig'**
  String get wizardFinishBtnLabel;

  /// No description provided for @wizardSkipBtnLabel.
  ///
  /// In de, this message translates to:
  /// **'Überspringen'**
  String get wizardSkipBtnLabel;

  /// No description provided for @wizardOptionalStepLabel.
  ///
  /// In de, this message translates to:
  /// **'Optionaler Schritt'**
  String get wizardOptionalStepLabel;

  /// No description provided for @wizardShowExplanation.
  ///
  /// In de, this message translates to:
  /// **'Erklärung anzeigen'**
  String get wizardShowExplanation;

  /// No description provided for @wizardHideExplanation.
  ///
  /// In de, this message translates to:
  /// **'Erklärung einklappen'**
  String get wizardHideExplanation;

  /// No description provided for @wizardSavedSnackbar.
  ///
  /// In de, this message translates to:
  /// **'Einrichtung gespeichert'**
  String get wizardSavedSnackbar;

  /// No description provided for @confirmDeleteBtnLabel.
  ///
  /// In de, this message translates to:
  /// **'Löschen'**
  String get confirmDeleteBtnLabel;

  /// No description provided for @wizardUndo.
  ///
  /// In de, this message translates to:
  /// **'Rückgängig'**
  String get wizardUndo;

  /// No description provided for @wizardSkinStepHelper.
  ///
  /// In de, this message translates to:
  /// **'## Willkommen bei QuestKeeper!\n\nIn den nächsten Schritten richtest du deine Kampagne ein: Darstellung, Name, Charakterbogen, Initiative und Währung. Danach folgen optionale Schritte für Items und Crafting, die du überspringen kannst.\n\nAlles wird automatisch gespeichert. Mit dem X oben links schließt du den Assistenten jederzeit; über das Zahnrad oben rechts kommst du später wieder hierher.\n\n## Darstellung\n\nWähle das Standard-Aussehen der Charakterbögen in dieser Kampagne. Spieler können es später für ihre eigenen Charaktere ändern.'**
  String get wizardSkinStepHelper;

  /// No description provided for @wizardCampaignNameStepHelper.
  ///
  /// In de, this message translates to:
  /// **'## Kampagnenname\n\nWir beginnen mit der wohl schwierigsten Frage überhaupt: Wie heißt deine Kampagne?\n\nDer Name braucht mindestens vier Zeichen.'**
  String get wizardCampaignNameStepHelper;

  /// No description provided for @wizardCharacterSheetStepTitle.
  ///
  /// In de, this message translates to:
  /// **'Charakterbogen'**
  String get wizardCharacterSheetStepTitle;

  /// No description provided for @wizardTabNameLabel.
  ///
  /// In de, this message translates to:
  /// **'Name des Tabs'**
  String get wizardTabNameLabel;

  /// No description provided for @wizardUnnamedTab.
  ///
  /// In de, this message translates to:
  /// **'Unbenannter Tab'**
  String get wizardUnnamedTab;

  /// No description provided for @wizardUnnamedProperty.
  ///
  /// In de, this message translates to:
  /// **'Unbenannte Eigenschaft'**
  String get wizardUnnamedProperty;

  /// No description provided for @wizardGroupLabel.
  ///
  /// In de, this message translates to:
  /// **'Gruppe {number}'**
  String wizardGroupLabel(int number);

  /// No description provided for @wizardDeleteTabTitle.
  ///
  /// In de, this message translates to:
  /// **'Tab löschen?'**
  String get wizardDeleteTabTitle;

  /// No description provided for @wizardDeleteTabMessage.
  ///
  /// In de, this message translates to:
  /// **'{count, plural, =0{Den leeren Tab „{tabName}“ löschen?} one{Tab „{tabName}“ mit einer Eigenschaft löschen? Werte der Charaktere gehen verloren.} other{Tab „{tabName}“ mit {count} Eigenschaften löschen? Werte der Charaktere gehen verloren.}}'**
  String wizardDeleteTabMessage(int count, String tabName);

  /// No description provided for @wizardDeletePropertyTitle.
  ///
  /// In de, this message translates to:
  /// **'Eigenschaft löschen?'**
  String get wizardDeletePropertyTitle;

  /// No description provided for @wizardDeletePropertyMessage.
  ///
  /// In de, this message translates to:
  /// **'{count, plural, one{Eigenschaft „{name}“ löschen? Ein Charakter hat dafür schon einen Wert, er geht verloren.} other{Eigenschaft „{name}“ löschen? {count} Charaktere haben dafür schon Werte, sie gehen verloren.}}'**
  String wizardDeletePropertyMessage(int count, String name);

  /// No description provided for @wizardPropertyDeletedSnackbar.
  ///
  /// In de, this message translates to:
  /// **'Eigenschaft „{name}“ gelöscht'**
  String wizardPropertyDeletedSnackbar(String name);

  /// No description provided for @wizardCurrencyStepTitle.
  ///
  /// In de, this message translates to:
  /// **'Währung'**
  String get wizardCurrencyStepTitle;

  /// No description provided for @wizardCurrencyStepHelper.
  ///
  /// In de, this message translates to:
  /// **'## Währung\n\nStelle ein, welche Währungen es in deiner Welt gibt und wie sie umgerechnet werden.\n\nFang mit der kleinsten Einheit an (z. B. Kupfer) und arbeite dich bis zur größten hoch. Gib bei jeder weiteren Währung an, wie viele der vorherigen sie wert ist (in vielen Fantasy-Rollenspielen: 10 Kupfer = 1 Silber).'**
  String get wizardCurrencyStepHelper;

  /// No description provided for @wizardSmallestCurrencyLabel.
  ///
  /// In de, this message translates to:
  /// **'Name der kleinsten Währung:'**
  String get wizardSmallestCurrencyLabel;

  /// No description provided for @wizardNextCurrencyLabel.
  ///
  /// In de, this message translates to:
  /// **'Name der nächstgrößeren Währung:'**
  String get wizardNextCurrencyLabel;

  /// No description provided for @wizardCurrencyMultipleLabel.
  ///
  /// In de, this message translates to:
  /// **'Entspricht wie vielen der vorherigen Währung:'**
  String get wizardCurrencyMultipleLabel;

  /// No description provided for @wizardNewEntryDefaultName.
  ///
  /// In de, this message translates to:
  /// **'Neu'**
  String get wizardNewEntryDefaultName;

  /// No description provided for @wizardLocationsStepTitle.
  ///
  /// In de, this message translates to:
  /// **'Fundorte'**
  String get wizardLocationsStepTitle;

  /// No description provided for @wizardLocationsStepHelper.
  ///
  /// In de, this message translates to:
  /// **'## Fundorte (optional)\n\nAb hier geht es um Items und Crafting. Diesen und die folgenden Schritte (Fundorte, Item-Kategorien, Items, Rezepte) brauchst du nur, wenn ihr damit spielt. Mit **Überspringen** geht es direkt zur Zusammenfassung; schon angelegte Daten bleiben erhalten.\n\nManche Items lassen sich an bestimmten Orten finden: am Strand, in Höhlen, in Grotten und so weiter. Lege hier die Orte an, damit du sie in den nächsten Schritten mit Items verknüpfen kannst.'**
  String get wizardLocationsStepHelper;

  /// No description provided for @wizardLocationLabel.
  ///
  /// In de, this message translates to:
  /// **'Fundort #{number}'**
  String wizardLocationLabel(int number);

  /// No description provided for @wizardLocationItemCount.
  ///
  /// In de, this message translates to:
  /// **'{count, plural, =0{An diesem Fundort gibt es noch keine Items.} one{An diesem Fundort kann ein Item gefunden werden.} other{An diesem Fundort können {count} Items gefunden werden.}}'**
  String wizardLocationItemCount(int count);

  /// No description provided for @wizardItemCategoriesStepTitle.
  ///
  /// In de, this message translates to:
  /// **'Item-Kategorien'**
  String get wizardItemCategoriesStepTitle;

  /// No description provided for @wizardItemCategoriesStepHelper.
  ///
  /// In de, this message translates to:
  /// **'## Item-Kategorien (optional)\n\nDamit die Spieler ihre Items filtern können, sortieren wir sie in Kategorien ein. Dafür haben wir dir eine Reihe von Kategorien und Unterkategorien vorbereitet.\n\nPasse sie gern an, wenn sie nicht zu eurem Rollenspiel passen.'**
  String get wizardItemCategoriesStepHelper;

  /// No description provided for @wizardCategoryNameLabel.
  ///
  /// In de, this message translates to:
  /// **'Name der Kategorie:'**
  String get wizardCategoryNameLabel;

  /// No description provided for @wizardSubCategoryNameLabel.
  ///
  /// In de, this message translates to:
  /// **'Name der Unterkategorie:'**
  String get wizardSubCategoryNameLabel;

  /// No description provided for @wizardCategoryItemCount.
  ///
  /// In de, this message translates to:
  /// **'{count, plural, =0{In dieser Kategorie sind noch keine Items.} one{In dieser Kategorie ist ein Item.} other{In dieser Kategorie sind {count} Items.}}'**
  String wizardCategoryItemCount(int count);

  /// No description provided for @wizardNewSubCategoryBtnLabel.
  ///
  /// In de, this message translates to:
  /// **'Neue Unterkategorie'**
  String get wizardNewSubCategoryBtnLabel;

  /// No description provided for @wizardIconForCategorySuffix.
  ///
  /// In de, this message translates to:
  /// **' (für Kategorie {name})'**
  String wizardIconForCategorySuffix(String name);

  /// No description provided for @wizardItemsStepTitle.
  ///
  /// In de, this message translates to:
  /// **'Items'**
  String get wizardItemsStepTitle;

  /// No description provided for @wizardItemsStepHelper.
  ///
  /// In de, this message translates to:
  /// **'## Items (optional)\n\nHier legst du die Items deiner Welt an: Heiltränke, Waffen, Questgegenstände oder Zutaten für Gifte, also alles, was in den Taschen deiner Spieler landen kann.\n\nAuch die Wirkung eines Tranks kannst du hier hinterlegen.\n\nTipp: Schreib Wirkung, Schaden und Ähnliches an den Anfang der Beschreibung. Dann sehen deine Spieler das Wichtigste auf einen Blick.'**
  String get wizardItemsStepHelper;

  /// No description provided for @wizardEditItemTitle.
  ///
  /// In de, this message translates to:
  /// **'Item bearbeiten'**
  String get wizardEditItemTitle;

  /// No description provided for @wizardItemNameLabel.
  ///
  /// In de, this message translates to:
  /// **'Name des Items:'**
  String get wizardItemNameLabel;

  /// No description provided for @wizardItemCategoryLabel.
  ///
  /// In de, this message translates to:
  /// **'Kategorie'**
  String get wizardItemCategoryLabel;

  /// No description provided for @wizardItemPatchSizeLabel.
  ///
  /// In de, this message translates to:
  /// **'Fundgröße (optional):'**
  String get wizardItemPatchSizeLabel;

  /// No description provided for @wizardItemImageDescriptionLabel.
  ///
  /// In de, this message translates to:
  /// **'Bildbeschreibung:'**
  String get wizardItemImageDescriptionLabel;

  /// No description provided for @wizardItemPlacesOfFindingHeader.
  ///
  /// In de, this message translates to:
  /// **'Fundorte:'**
  String get wizardItemPlacesOfFindingHeader;

  /// No description provided for @wizardNewLocationBtnLabel.
  ///
  /// In de, this message translates to:
  /// **'Neuer Fundort'**
  String get wizardNewLocationBtnLabel;

  /// No description provided for @wizardNewImageBtnLabel.
  ///
  /// In de, this message translates to:
  /// **'Neues Bild'**
  String get wizardNewImageBtnLabel;

  /// No description provided for @wizardPickImageBtnLabel.
  ///
  /// In de, this message translates to:
  /// **'Bild auswählen'**
  String get wizardPickImageBtnLabel;

  /// No description provided for @wizardInvalidImageFile.
  ///
  /// In de, this message translates to:
  /// **'Diese Datei ist kein gültiges Bild.'**
  String get wizardInvalidImageFile;

  /// No description provided for @wizardRecipesStepTitle.
  ///
  /// In de, this message translates to:
  /// **'Rezepte'**
  String get wizardRecipesStepTitle;

  /// No description provided for @wizardRecipesStepHelper.
  ///
  /// In de, this message translates to:
  /// **'## Rezepte (optional)\n\nMit Rezepten können deine Spieler selbst Dinge herstellen, zum Beispiel Heiltränke.\n\nManche Rezepte setzen ein Werkzeug voraus, etwa ein Kräuterkunde-Set. Auch das kannst du im Rezept hinterlegen; die Spieler brauchen das Werkzeug dann, um das Rezept zu nutzen.\n\nTippe auf ein Rezept, um es zu bearbeiten. Halte es gedrückt für weitere Aktionen.'**
  String get wizardRecipesStepHelper;

  /// No description provided for @wizardRecipeOpenDetails.
  ///
  /// In de, this message translates to:
  /// **'Details öffnen'**
  String get wizardRecipeOpenDetails;

  /// No description provided for @wizardRecipeDuplicateAndOpen.
  ///
  /// In de, this message translates to:
  /// **'Duplizieren und öffnen'**
  String get wizardRecipeDuplicateAndOpen;

  /// No description provided for @wizardRecipeDeletePermanently.
  ///
  /// In de, this message translates to:
  /// **'Endgültig löschen'**
  String get wizardRecipeDeletePermanently;

  /// No description provided for @wizardEditRecipeTitle.
  ///
  /// In de, this message translates to:
  /// **'Rezept bearbeiten'**
  String get wizardEditRecipeTitle;

  /// No description provided for @wizardRecipeCreatedItemLabel.
  ///
  /// In de, this message translates to:
  /// **'Herzustellendes Item'**
  String get wizardRecipeCreatedItemLabel;

  /// No description provided for @wizardRecipeRequirementLabel.
  ///
  /// In de, this message translates to:
  /// **'Voraussetzung #{number}'**
  String wizardRecipeRequirementLabel(int number);

  /// No description provided for @wizardRecipeAddRequirement.
  ///
  /// In de, this message translates to:
  /// **'Weitere Voraussetzung'**
  String get wizardRecipeAddRequirement;

  /// No description provided for @wizardRecipeIngredientLabel.
  ///
  /// In de, this message translates to:
  /// **'Zutat #{number}'**
  String wizardRecipeIngredientLabel(int number);

  /// No description provided for @wizardRecipeAddIngredient.
  ///
  /// In de, this message translates to:
  /// **'Weitere Zutat'**
  String get wizardRecipeAddIngredient;

  /// No description provided for @wizardSummaryStepTitle.
  ///
  /// In de, this message translates to:
  /// **'Zusammenfassung'**
  String get wizardSummaryStepTitle;

  /// No description provided for @wizardSummaryStepHelper.
  ///
  /// In de, this message translates to:
  /// **'## Fertig!\n\nDeine Kampagne ist eingerichtet und alles ist gespeichert. Die Übersicht zeigt, was eingerichtet ist.\n\nÄndern kannst du alles später über das Zahnrad oben rechts.\n\nMit **Fertig** schließt du den Assistenten.'**
  String get wizardSummaryStepHelper;

  /// No description provided for @wizardSummaryCampaignLabel.
  ///
  /// In de, this message translates to:
  /// **'Kampagne'**
  String get wizardSummaryCampaignLabel;

  /// No description provided for @wizardSummaryNotSet.
  ///
  /// In de, this message translates to:
  /// **'Noch nicht festgelegt'**
  String get wizardSummaryNotSet;

  /// No description provided for @wizardSummaryTabCount.
  ///
  /// In de, this message translates to:
  /// **'{count, plural, one{1 Tab} other{{count} Tabs}}'**
  String wizardSummaryTabCount(int count);

  /// No description provided for @wizardSummaryPropertyCount.
  ///
  /// In de, this message translates to:
  /// **'{count, plural, one{1 Eigenschaft} other{{count} Eigenschaften}}'**
  String wizardSummaryPropertyCount(int count);

  /// No description provided for @wizardSummaryItemCount.
  ///
  /// In de, this message translates to:
  /// **'{count, plural, =0{Keine Items} one{1 Item} other{{count} Items}}'**
  String wizardSummaryItemCount(int count);

  /// No description provided for @wizardSummaryRecipeCount.
  ///
  /// In de, this message translates to:
  /// **'{count, plural, =0{Keine Rezepte} one{1 Rezept} other{{count} Rezepte}}'**
  String wizardSummaryRecipeCount(int count);

  /// No description provided for @welcomeToQuestKeeper.
  ///
  /// In de, this message translates to:
  /// **'Willkommen bei QuestKeeper'**
  String get welcomeToQuestKeeper;

  /// No description provided for @questKeeperIntro.
  ///
  /// In de, this message translates to:
  /// **'QuestKeeper begleitet eure Pen-&-Paper-Runde am Tisch. Die Spielleitung richtet die Kampagne ein, alle anderen führen ihren Charakterbogen in der App. Trefferpunkte, Gegenstände und geteilte Notizen sind dabei für alle live aktuell.'**
  String get questKeeperIntro;

  /// No description provided for @pathRunAGameTitle.
  ///
  /// In de, this message translates to:
  /// **'Ich leite eine Runde'**
  String get pathRunAGameTitle;

  /// No description provided for @pathRunAGameSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Kampagne anlegen und Spieler einladen'**
  String get pathRunAGameSubtitle;

  /// No description provided for @pathJoinAGameTitle.
  ///
  /// In de, this message translates to:
  /// **'Ich trete einer Runde bei'**
  String get pathJoinAGameTitle;

  /// No description provided for @pathJoinAGameSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Mit dem Code deiner Spielleitung'**
  String get pathJoinAGameSubtitle;

  /// No description provided for @joinCampagneAction.
  ///
  /// In de, this message translates to:
  /// **'Kampagne beitreten'**
  String get joinCampagneAction;

  /// No description provided for @createCampagneAction.
  ///
  /// In de, this message translates to:
  /// **'Kampagne anlegen'**
  String get createCampagneAction;

  /// No description provided for @noCampagnesYetHint.
  ///
  /// In de, this message translates to:
  /// **'Leg eine Kampagne an, richte den Charakterbogen ein und lade deine Gruppe mit einem Code ein.'**
  String get noCampagnesYetHint;

  /// No description provided for @noCharactersYetHint.
  ///
  /// In de, this message translates to:
  /// **'Tritt mit dem Code deiner Spielleitung einer Kampagne bei. Deinen Charakter legst du dabei an.'**
  String get noCharactersYetHint;

  /// No description provided for @campagneSettingsChangedAt.
  ///
  /// In de, this message translates to:
  /// **'Einstellungen geändert: {date}'**
  String campagneSettingsChangedAt(String date);

  /// No description provided for @openJoinRequestsBadge.
  ///
  /// In de, this message translates to:
  /// **'{count, plural, one{1 offene Anfrage} other{{count} offene Anfragen}}'**
  String openJoinRequestsBadge(int count);

  /// No description provided for @characterLastEditedAt.
  ///
  /// In de, this message translates to:
  /// **'Zuletzt bearbeitet: {date}'**
  String characterLastEditedAt(String date);

  /// No description provided for @waitingForDmApproval.
  ///
  /// In de, this message translates to:
  /// **'Warte auf Freigabe durch die Spielleitung'**
  String get waitingForDmApproval;

  /// No description provided for @characterNotInCampagneHint.
  ///
  /// In de, this message translates to:
  /// **'Noch in keiner Kampagne. Tippe, um mit einem Code beizutreten.'**
  String get characterNotInCampagneHint;

  /// No description provided for @joinCampagneNewCharacterIntro.
  ///
  /// In de, this message translates to:
  /// **'Gib den Beitrittscode ein, den du von deiner Spielleitung bekommen hast, und wie dein Charakter heißen soll. Den Rest des Charakterbogens füllst du aus, sobald die Spielleitung dich aufgenommen hat.'**
  String get joinCampagneNewCharacterIntro;

  /// No description provided for @joinCodeEmptyError.
  ///
  /// In de, this message translates to:
  /// **'Bitte gib den Beitrittscode ein.'**
  String get joinCodeEmptyError;

  /// No description provided for @joinCodeIncompleteError.
  ///
  /// In de, this message translates to:
  /// **'Der Code hat sechs Ziffern, zum Beispiel 123-456.'**
  String get joinCodeIncompleteError;

  /// No description provided for @joinCodeUnknownError.
  ///
  /// In de, this message translates to:
  /// **'Diesen Code gibt es nicht. Prüfe ihn mit deiner Spielleitung.'**
  String get joinCodeUnknownError;

  /// No description provided for @characterNameFieldLabel.
  ///
  /// In de, this message translates to:
  /// **'Name deines Charakters'**
  String get characterNameFieldLabel;

  /// No description provided for @nameRequiredError.
  ///
  /// In de, this message translates to:
  /// **'Bitte gib einen Namen ein'**
  String get nameRequiredError;

  /// No description provided for @joinAction.
  ///
  /// In de, this message translates to:
  /// **'Beitreten'**
  String get joinAction;

  /// No description provided for @joinRequestSentConfirmation.
  ///
  /// In de, this message translates to:
  /// **'Anfrage gesendet. Sobald deine Spielleitung zustimmt, kannst du mitspielen.'**
  String get joinRequestSentConfirmation;

  /// No description provided for @joinRequestAcceptedMessage.
  ///
  /// In de, this message translates to:
  /// **'Deine Beitrittsanfrage wurde angenommen. Du kannst jetzt mitspielen.'**
  String get joinRequestAcceptedMessage;

  /// No description provided for @joinRequestDeniedMessage.
  ///
  /// In de, this message translates to:
  /// **'Deine Beitrittsanfrage wurde abgelehnt.'**
  String get joinRequestDeniedMessage;

  /// No description provided for @joinRequestCreatedForDm.
  ///
  /// In de, this message translates to:
  /// **'{playerName} ({username}) möchte deiner Kampagne beitreten.'**
  String joinRequestCreatedForDm(String playerName, String username);

  /// No description provided for @waitingForApprovalTitle.
  ///
  /// In de, this message translates to:
  /// **'Warte auf Freigabe'**
  String get waitingForApprovalTitle;

  /// No description provided for @waitingForApprovalText.
  ///
  /// In de, this message translates to:
  /// **'Deine Anfrage für „{characterName}“ liegt bei deiner Spielleitung. Sobald sie zustimmt, kannst du hier mitspielen.'**
  String waitingForApprovalText(String characterName);

  /// No description provided for @enterCodeAgainAction.
  ///
  /// In de, this message translates to:
  /// **'Code neu eingeben'**
  String get enterCodeAgainAction;

  /// No description provided for @newCampagneIntro.
  ///
  /// In de, this message translates to:
  /// **'Wie soll deine Kampagne heißen? Danach führt dich der Assistent durch Charakterbogen, Währung und Gegenstände.'**
  String get newCampagneIntro;

  /// No description provided for @createAction.
  ///
  /// In de, this message translates to:
  /// **'Anlegen'**
  String get createAction;

  /// No description provided for @invitePlayersAction.
  ///
  /// In de, this message translates to:
  /// **'Spieler einladen'**
  String get invitePlayersAction;

  /// No description provided for @noPlayersYetHint.
  ///
  /// In de, this message translates to:
  /// **'Noch keine Spieler dabei. Lade deine Gruppe über „Spieler einladen“ ein.'**
  String get noPlayersYetHint;

  /// No description provided for @invitePlayersInstruction.
  ///
  /// In de, this message translates to:
  /// **'In QuestKeeper auf „Kampagne beitreten“ tippen und diesen Code eingeben.'**
  String get invitePlayersInstruction;

  /// No description provided for @invitePlayersApprovalHint.
  ///
  /// In de, this message translates to:
  /// **'Die Anfragen erscheinen danach unter „Beitrittsanfragen“. Mit ✓ nimmst du jemanden auf.'**
  String get invitePlayersApprovalHint;

  /// No description provided for @copyCodeAction.
  ///
  /// In de, this message translates to:
  /// **'Code kopieren'**
  String get copyCodeAction;

  /// No description provided for @copiedConfirmation.
  ///
  /// In de, this message translates to:
  /// **'Kopiert'**
  String get copiedConfirmation;

  /// No description provided for @shareInviteAction.
  ///
  /// In de, this message translates to:
  /// **'Einladung teilen'**
  String get shareInviteAction;

  /// No description provided for @inviteShareText.
  ///
  /// In de, this message translates to:
  /// **'Spiel mit in meiner Runde „{campagneName}“! Öffne QuestKeeper, tippe auf „Kampagne beitreten“ und gib diesen Code ein: {code}'**
  String inviteShareText(String campagneName, String code);

  /// No description provided for @inviteShareSubject.
  ///
  /// In de, this message translates to:
  /// **'Einladung zu „{campagneName}“'**
  String inviteShareSubject(String campagneName);

  /// No description provided for @qrCodeHint.
  ///
  /// In de, this message translates to:
  /// **'Der QR-Code enthält nur den Code.'**
  String get qrCodeHint;

  /// No description provided for @closeAction.
  ///
  /// In de, this message translates to:
  /// **'Schließen'**
  String get closeAction;

  /// No description provided for @errorDetailsStatusLabel.
  ///
  /// In de, this message translates to:
  /// **'HTTP-Status:'**
  String get errorDetailsStatusLabel;

  /// No description provided for @errorDetailsServerLabel.
  ///
  /// In de, this message translates to:
  /// **'Server-Antwort:'**
  String get errorDetailsServerLabel;

  /// No description provided for @errorDetailsDescriptionLabel.
  ///
  /// In de, this message translates to:
  /// **'Beschreibung:'**
  String get errorDetailsDescriptionLabel;

  /// No description provided for @errorMessageNoConnection.
  ///
  /// In de, this message translates to:
  /// **'Die Verbindung zum Server hat nicht geklappt. Prüfe deine Internetverbindung und versuche es noch einmal.'**
  String get errorMessageNoConnection;

  /// No description provided for @errorMessageBadRequest.
  ///
  /// In de, this message translates to:
  /// **'Der Server konnte die Eingabe nicht verarbeiten. Prüfe deine Angaben und versuche es noch einmal.'**
  String get errorMessageBadRequest;

  /// No description provided for @errorMessageUnauthorized.
  ///
  /// In de, this message translates to:
  /// **'Dafür fehlt dir die Berechtigung. Melde dich gegebenenfalls neu an.'**
  String get errorMessageUnauthorized;

  /// No description provided for @errorMessageNotFound.
  ///
  /// In de, this message translates to:
  /// **'Das gesuchte Element gibt es nicht (mehr).'**
  String get errorMessageNotFound;

  /// No description provided for @errorMessageConflict.
  ///
  /// In de, this message translates to:
  /// **'Das wurde gerade an anderer Stelle geändert. Lade neu und versuche es noch einmal.'**
  String get errorMessageConflict;

  /// No description provided for @errorMessageServer.
  ///
  /// In de, this message translates to:
  /// **'Auf dem Server ist ein Fehler aufgetreten. Versuche es später noch einmal.'**
  String get errorMessageServer;

  /// No description provided for @errorMessageUnknown.
  ///
  /// In de, this message translates to:
  /// **'Etwas ist schiefgelaufen. Versuche es noch einmal.'**
  String get errorMessageUnknown;

  /// No description provided for @myNotesGroupName.
  ///
  /// In de, this message translates to:
  /// **'Meine Notizen'**
  String get myNotesGroupName;

  /// No description provided for @pageTabShortCampaign.
  ///
  /// In de, this message translates to:
  /// **'Kampagne'**
  String get pageTabShortCampaign;

  /// No description provided for @pageTabShortCharacters.
  ///
  /// In de, this message translates to:
  /// **'Charaktere'**
  String get pageTabShortCharacters;

  /// No description provided for @pageTabShortFight.
  ///
  /// In de, this message translates to:
  /// **'Kampf'**
  String get pageTabShortFight;

  /// No description provided for @pageTabShortItems.
  ///
  /// In de, this message translates to:
  /// **'Items'**
  String get pageTabShortItems;

  /// No description provided for @pageTabShortNotes.
  ///
  /// In de, this message translates to:
  /// **'Notizen'**
  String get pageTabShortNotes;

  /// No description provided for @pageTabShortImages.
  ///
  /// In de, this message translates to:
  /// **'Bilder'**
  String get pageTabShortImages;

  /// No description provided for @ledgerManuscriptDateFormat.
  ///
  /// In de, this message translates to:
  /// **'d. MMMM y, HH:mm'**
  String get ledgerManuscriptDateFormat;

  /// No description provided for @invalidWholeNumberInput.
  ///
  /// In de, this message translates to:
  /// **'Bitte gib eine ganze Zahl ein, z. B. -1 oder 3.'**
  String get invalidWholeNumberInput;

  /// No description provided for @invalidLevelInput.
  ///
  /// In de, this message translates to:
  /// **'Das Level muss eine ganze Zahl ab 0 sein, z. B. 3.'**
  String get invalidLevelInput;

  /// No description provided for @previewAndVariantTileTitle.
  ///
  /// In de, this message translates to:
  /// **'Vorschau und Darstellung'**
  String get previewAndVariantTileTitle;

  /// No description provided for @characterSetupTitle.
  ///
  /// In de, this message translates to:
  /// **'Charakter einrichten'**
  String get characterSetupTitle;

  /// No description provided for @characterSetupProgress.
  ///
  /// In de, this message translates to:
  /// **'Abschnitt {current} von {total}: {tabName}'**
  String characterSetupProgress(int current, int total, String tabName);

  /// No description provided for @characterSetupHint.
  ///
  /// In de, this message translates to:
  /// **'Was du jetzt leer lässt, kannst du später direkt im Charakterbogen ausfüllen.'**
  String get characterSetupHint;

  /// No description provided for @characterSetupFinish.
  ///
  /// In de, this message translates to:
  /// **'Fertig'**
  String get characterSetupFinish;

  /// No description provided for @fillInLater.
  ///
  /// In de, this message translates to:
  /// **'Später ausfüllen'**
  String get fillInLater;

  /// No description provided for @characterNameRequired.
  ///
  /// In de, this message translates to:
  /// **'Bitte gib einen Namen ein.'**
  String get characterNameRequired;

  /// No description provided for @fixMarkedFieldsHint.
  ///
  /// In de, this message translates to:
  /// **'Bitte korrigiere die markierten Felder.'**
  String get fixMarkedFieldsHint;

  /// No description provided for @moneyModeDeposit.
  ///
  /// In de, this message translates to:
  /// **'+ Einzahlen'**
  String get moneyModeDeposit;

  /// No description provided for @moneyModeSpend.
  ///
  /// In de, this message translates to:
  /// **'− Ausgeben'**
  String get moneyModeSpend;

  /// No description provided for @activeAlternateFormBannerTitle.
  ///
  /// In de, this message translates to:
  /// **'Verwandelte Gestalt'**
  String get activeAlternateFormBannerTitle;

  /// No description provided for @missingStatTapToFill.
  ///
  /// In de, this message translates to:
  /// **'Noch leer – tippen zum Ausfüllen'**
  String get missingStatTapToFill;

  /// No description provided for @missingStatUnnamed.
  ///
  /// In de, this message translates to:
  /// **'Unbenannte Eigenschaft'**
  String get missingStatUnnamed;

  /// No description provided for @settingsTitle.
  ///
  /// In de, this message translates to:
  /// **'Einstellungen'**
  String get settingsTitle;

  /// No description provided for @apiKeysSettingsSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Deine persönlichen API-Schlüssel verwalten'**
  String get apiKeysSettingsSubtitle;

  /// No description provided for @noteBlockTextLabel.
  ///
  /// In de, this message translates to:
  /// **'Text'**
  String get noteBlockTextLabel;

  /// No description provided for @generateImageDescriptionHint.
  ///
  /// In de, this message translates to:
  /// **'Beschreibe das Bild, das du generieren möchtest. Je genauer die Beschreibung, desto besser passt das Bild.'**
  String get generateImageDescriptionHint;

  /// No description provided for @generateImagePromptLabel.
  ///
  /// In de, this message translates to:
  /// **'Bildbeschreibung'**
  String get generateImagePromptLabel;

  /// No description provided for @generateImagePromptExample.
  ///
  /// In de, this message translates to:
  /// **'z. B. „Ein mystischer Wald mit Elfen“'**
  String get generateImagePromptExample;

  /// No description provided for @reactivateTransformationTitle.
  ///
  /// In de, this message translates to:
  /// **'Alte Verwandlung reaktivieren'**
  String get reactivateTransformationTitle;

  /// No description provided for @reactivateTransformationQuestion.
  ///
  /// In de, this message translates to:
  /// **'Möchtest du deine letzte Verwandlung wieder aufnehmen oder eine neue Gestalt annehmen?'**
  String get reactivateTransformationQuestion;

  /// No description provided for @newTransformationDeletesOldTitle.
  ///
  /// In de, this message translates to:
  /// **'Alte Verwandlungen werden gelöscht'**
  String get newTransformationDeletesOldTitle;

  /// No description provided for @newTransformationDeletesOldText.
  ///
  /// In de, this message translates to:
  /// **'Wenn du eine neue Verwandlung erstellst, werden alle alten gelöscht.'**
  String get newTransformationDeletesOldText;

  /// No description provided for @selectTransformationTitle.
  ///
  /// In de, this message translates to:
  /// **'Verwandlung auswählen'**
  String get selectTransformationTitle;

  /// No description provided for @selectTransformationComponentsHint.
  ///
  /// In de, this message translates to:
  /// **'Wähle die Verwandlungen aus, aus denen deine neue Gestalt bestehen soll.'**
  String get selectTransformationComponentsHint;

  /// No description provided for @noTransformationComponentsHint.
  ///
  /// In de, this message translates to:
  /// **'Es gibt noch keine Verwandlungen. Lege sie zuerst in den Einstellungen deines Charakters an.'**
  String get noTransformationComponentsHint;

  /// No description provided for @transformationStatSettingsFor.
  ///
  /// In de, this message translates to:
  /// **'Einstellungen für {statName}'**
  String transformationStatSettingsFor(String statName);

  /// No description provided for @invalidWholeNumberShort.
  ///
  /// In de, this message translates to:
  /// **'Ganze Zahl eingeben'**
  String get invalidWholeNumberShort;

  /// No description provided for @invalidNonNegativeNumberShort.
  ///
  /// In de, this message translates to:
  /// **'Zahl ab 0 eingeben'**
  String get invalidNonNegativeNumberShort;

  /// No description provided for @invalidPositiveNumberShort.
  ///
  /// In de, this message translates to:
  /// **'Zahl ab 1 eingeben'**
  String get invalidPositiveNumberShort;

  /// No description provided for @invalidCurrencyMultiple.
  ///
  /// In de, this message translates to:
  /// **'Gib eine ganze Zahl größer als 1 ein, z. B. 10.'**
  String get invalidCurrencyMultiple;

  /// No description provided for @aboutLicensesTitle.
  ///
  /// In de, this message translates to:
  /// **'Info & Lizenzen'**
  String get aboutLicensesTitle;

  /// No description provided for @aboutLicensesSrdTitle.
  ///
  /// In de, this message translates to:
  /// **'Regelmaterial: SRD 5.2.1'**
  String get aboutLicensesSrdTitle;

  /// No description provided for @aboutLicensesSrdIntro.
  ///
  /// In de, this message translates to:
  /// **'Die Vorlage „Fantasy 5E (SRD)“ enthält Material aus dem System Reference Document 5.2.1. Es steht unter der Lizenz Creative Commons Namensnennung 4.0 International (CC BY 4.0).'**
  String get aboutLicensesSrdIntro;

  /// No description provided for @aboutLicensesAttributionEnglish.
  ///
  /// In de, this message translates to:
  /// **'Namensnennung (englisches Original)'**
  String get aboutLicensesAttributionEnglish;

  /// No description provided for @aboutLicensesAttributionGerman.
  ///
  /// In de, this message translates to:
  /// **'Namensnennung (deutsche Fassung)'**
  String get aboutLicensesAttributionGerman;

  /// No description provided for @aboutLicensesAuthoritativeHint.
  ///
  /// In de, this message translates to:
  /// **'Die deutsche Fassung dient nur der Information. Maßgeblich ist die englische Fassung.'**
  String get aboutLicensesAuthoritativeHint;

  /// No description provided for @aboutLicensesChanges.
  ///
  /// In de, this message translates to:
  /// **'Änderungen: Material aus dem SRD 5.2.1 wurde ausgewählt, übersetzt oder aus der deutschen Fassung übernommen, gekürzt und an QuestKeeper angepasst. Kurzbeschreibungen und weitere Texte der Vorlage sind eigene Texte.'**
  String get aboutLicensesChanges;

  /// No description provided for @aboutLicensesOpenLicense.
  ///
  /// In de, this message translates to:
  /// **'Lizenz CC BY 4.0 öffnen'**
  String get aboutLicensesOpenLicense;

  /// No description provided for @aboutLicensesNotAffiliated.
  ///
  /// In de, this message translates to:
  /// **'QuestKeeper ist ein unabhängiges Produkt und wird von keinem Rollenspielverlag herausgegeben oder unterstützt.'**
  String get aboutLicensesNotAffiliated;

  /// No description provided for @aboutLicensesOpenSourceTitle.
  ///
  /// In de, this message translates to:
  /// **'Open-Source-Lizenzen'**
  String get aboutLicensesOpenSourceTitle;

  /// No description provided for @aboutLicensesShowOpenSource.
  ///
  /// In de, this message translates to:
  /// **'Alle Lizenzen anzeigen'**
  String get aboutLicensesShowOpenSource;

  /// No description provided for @aboutLicensesSettingsSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Regelmaterial, Lizenzen und Open-Source-Hinweise'**
  String get aboutLicensesSettingsSubtitle;

  /// No description provided for @statTypeCheckboxTrack.
  ///
  /// In de, this message translates to:
  /// **'Kästchenleiste'**
  String get statTypeCheckboxTrack;

  /// No description provided for @statTypeCheckboxTrackHelp.
  ///
  /// In de, this message translates to:
  /// **'Eine Reihe Kästchen, die Spieler mit einem Tipp auf dem Bogen ankreuzen, z. B. Stress.'**
  String get statTypeCheckboxTrackHelp;

  /// No description provided for @statTypeTextList.
  ///
  /// In de, this message translates to:
  /// **'Textliste'**
  String get statTypeTextList;

  /// No description provided for @statTypeTextListHelp.
  ///
  /// In de, this message translates to:
  /// **'Mehrere Texteinträge, optional mit festen, beschrifteten Plätzen, z. B. Aspekte oder Konsequenzen.'**
  String get statTypeTextListHelp;

  /// No description provided for @statTypeSingleSelect.
  ///
  /// In de, this message translates to:
  /// **'Auswahl (eine)'**
  String get statTypeSingleSelect;

  /// No description provided for @statTypeSingleSelectHelp.
  ///
  /// In de, this message translates to:
  /// **'Spieler wählen genau eine der Optionen, z. B. Herkunft oder Gesinnung.'**
  String get statTypeSingleSelectHelp;

  /// No description provided for @statTypeUnsupported.
  ///
  /// In de, this message translates to:
  /// **'Unbekannter Typ'**
  String get statTypeUnsupported;

  /// No description provided for @statTypeUnsupportedHint.
  ///
  /// In de, this message translates to:
  /// **'Wird von dieser Version nicht unterstützt. Bitte aktualisiere die App.'**
  String get statTypeUnsupportedHint;

  /// No description provided for @checkboxTrackBoxesHeadline.
  ///
  /// In de, this message translates to:
  /// **'Kästchen'**
  String get checkboxTrackBoxesHeadline;

  /// No description provided for @checkboxTrackBoxCountLabel.
  ///
  /// In de, this message translates to:
  /// **'Anzahl'**
  String get checkboxTrackBoxCountLabel;

  /// No description provided for @checkboxTrackLabelsHint.
  ///
  /// In de, this message translates to:
  /// **'Beschriftungen sind optional, z. B. „1“, „2“, „3“ oder „Leicht“.'**
  String get checkboxTrackLabelsHint;

  /// No description provided for @checkboxTrackBoxLabel.
  ///
  /// In de, this message translates to:
  /// **'Kästchen {number}'**
  String checkboxTrackBoxLabel(int number);

  /// No description provided for @checkboxTrackTapHint.
  ///
  /// In de, this message translates to:
  /// **'Tippe ein Kästchen an, um es anzukreuzen oder freizugeben.'**
  String get checkboxTrackTapHint;

  /// No description provided for @textListSlotsHeadline.
  ///
  /// In de, this message translates to:
  /// **'Feste Plätze'**
  String get textListSlotsHeadline;

  /// No description provided for @textListSlotsHint.
  ///
  /// In de, this message translates to:
  /// **'Optional, z. B. „Hauptaspekt“, „Dilemma“ oder „Leicht (2)“.'**
  String get textListSlotsHint;

  /// No description provided for @textListSlotLabel.
  ///
  /// In de, this message translates to:
  /// **'Beschriftung:'**
  String get textListSlotLabel;

  /// No description provided for @textListAllowCustomEntries.
  ///
  /// In de, this message translates to:
  /// **'Spieler dürfen eigene Einträge hinzufügen und löschen'**
  String get textListAllowCustomEntries;

  /// No description provided for @textListAddEntry.
  ///
  /// In de, this message translates to:
  /// **'Eintrag hinzufügen'**
  String get textListAddEntry;

  /// No description provided for @textListOwnEntryLabel.
  ///
  /// In de, this message translates to:
  /// **'Eigener Eintrag'**
  String get textListOwnEntryLabel;

  /// No description provided for @textListEmpty.
  ///
  /// In de, this message translates to:
  /// **'Noch keine Einträge'**
  String get textListEmpty;

  /// No description provided for @textListEditEntryTitle.
  ///
  /// In de, this message translates to:
  /// **'Eintrag bearbeiten'**
  String get textListEditEntryTitle;

  /// No description provided for @textListDeleteEntry.
  ///
  /// In de, this message translates to:
  /// **'Löschen'**
  String get textListDeleteEntry;

  /// No description provided for @singleSelectOptionsHeadline.
  ///
  /// In de, this message translates to:
  /// **'Optionen'**
  String get singleSelectOptionsHeadline;

  /// No description provided for @singleSelectNothingChosen.
  ///
  /// In de, this message translates to:
  /// **'Noch nichts gewählt'**
  String get singleSelectNothingChosen;

  /// No description provided for @showLevelToggle.
  ///
  /// In de, this message translates to:
  /// **'Level anzeigen'**
  String get showLevelToggle;

  /// No description provided for @showLevelHint.
  ///
  /// In de, this message translates to:
  /// **'Aus: Das Charakterformular fragt kein Level ab und der Bogen zeigt keins.'**
  String get showLevelHint;
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
    'that was used.',
  );
}
