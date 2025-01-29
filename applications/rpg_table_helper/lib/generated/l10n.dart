// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(_current != null,
        'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(instance != null,
        'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?');
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Username`
  String get username {
    return Intl.message(
      'Username',
      name: 'username',
      desc: '',
      args: [],
    );
  }

  /// `Password`
  String get password {
    return Intl.message(
      'Password',
      name: 'password',
      desc: '',
      args: [],
    );
  }

  /// `Player name`
  String get characterNameDefault {
    return Intl.message(
      'Player name',
      name: 'characterNameDefault',
      desc: '',
      args: [],
    );
  }

  /// `Save`
  String get save {
    return Intl.message(
      'Save',
      name: 'save',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get cancel {
    return Intl.message(
      'Cancel',
      name: 'cancel',
      desc: '',
      args: [],
    );
  }

  /// `Configure properties`
  String get configureProperties {
    return Intl.message(
      'Configure properties',
      name: 'configureProperties',
      desc: '',
      args: [],
    );
  }

  /// ` (for {username})`
  String configurePropertiesForCharacterNameSuffix(Object username) {
    return Intl.message(
      ' (for $username)',
      name: 'configurePropertiesForCharacterNameSuffix',
      desc: '',
      args: [username],
    );
  }

  /// `First value`
  String get firstValue {
    return Intl.message(
      'First value',
      name: 'firstValue',
      desc: '',
      args: [],
    );
  }

  /// `Second value`
  String get secondValue {
    return Intl.message(
      'Second value',
      name: 'secondValue',
      desc: '',
      args: [],
    );
  }

  /// `Other value`
  String get otherValue {
    return Intl.message(
      'Other value',
      name: 'otherValue',
      desc: '',
      args: [],
    );
  }

  /// `Calculated value`
  String get calculatedValue {
    return Intl.message(
      'Calculated value',
      name: 'calculatedValue',
      desc: '',
      args: [],
    );
  }

  /// `The value of {property}`
  String valueOfPropertyWithName(Object property) {
    return Intl.message(
      'The value of $property',
      name: 'valueOfPropertyWithName',
      desc: '',
      args: [property],
    );
  }

  /// `The first value`
  String get firstValuePlaceholder {
    return Intl.message(
      'The first value',
      name: 'firstValuePlaceholder',
      desc: '',
      args: [],
    );
  }

  /// `The second value`
  String get secondValuePlaceholder {
    return Intl.message(
      'The second value',
      name: 'secondValuePlaceholder',
      desc: '',
      args: [],
    );
  }

  /// `The other value`
  String get otherValuePlaceholder {
    return Intl.message(
      'The other value',
      name: 'otherValuePlaceholder',
      desc: '',
      args: [],
    );
  }

  /// `The calculated value`
  String get calculatedValuePlaceholder {
    return Intl.message(
      'The calculated value',
      name: 'calculatedValuePlaceholder',
      desc: '',
      args: [],
    );
  }

  /// `Current value`
  String get currentValue {
    return Intl.message(
      'Current value',
      name: 'currentValue',
      desc: '',
      args: [],
    );
  }

  /// `The current value for this property`
  String get currentValuePlaceholder {
    return Intl.message(
      'The current value for this property',
      name: 'currentValuePlaceholder',
      desc: '',
      args: [],
    );
  }

  /// `Max value`
  String get maxValue {
    return Intl.message(
      'Max value',
      name: 'maxValue',
      desc: '',
      args: [],
    );
  }

  /// `The max value for this property`
  String get maxValuePlaceholder {
    return Intl.message(
      'The max value for this property',
      name: 'maxValuePlaceholder',
      desc: '',
      args: [],
    );
  }

  /// `New pet`
  String get newPetBtnLabel {
    return Intl.message(
      'New pet',
      name: 'newPetBtnLabel',
      desc: '',
      args: [],
    );
  }

  /// `Pet`
  String get petDefaultNamePrefix {
    return Intl.message(
      'Pet',
      name: 'petDefaultNamePrefix',
      desc: '',
      args: [],
    );
  }

  /// `Preview`
  String get preview {
    return Intl.message(
      'Preview',
      name: 'preview',
      desc: '',
      args: [],
    );
  }

  /// `New image`
  String get newImageBtnLabel {
    return Intl.message(
      'New image',
      name: 'newImageBtnLabel',
      desc: '',
      args: [],
    );
  }

  /// `Additional settings`
  String get additionalSettings {
    return Intl.message(
      'Additional settings',
      name: 'additionalSettings',
      desc: '',
      args: [],
    );
  }

  /// `Hide property for my character`
  String get hidePropertyForCharacter {
    return Intl.message(
      'Hide property for my character',
      name: 'hidePropertyForCharacter',
      desc: '',
      args: [],
    );
  }

  /// `Hide heading`
  String get hideHeading {
    return Intl.message(
      'Hide heading',
      name: 'hideHeading',
      desc: '',
      args: [],
    );
  }

  /// `Add character to campaign`
  String get addCharacterToCampagneModalTitle {
    return Intl.message(
      'Add character to campaign',
      name: 'addCharacterToCampagneModalTitle',
      desc: '',
      args: [],
    );
  }

  /// `You have created a character, but it is not yet assigned to a season or campaign. Enter the join code you received from your DM here to send a request to your DM.`
  String get assignCharacterToCampagneModalContent {
    return Intl.message(
      'You have created a character, but it is not yet assigned to a season or campaign. Enter the join code you received from your DM here to send a request to your DM.',
      name: 'assignCharacterToCampagneModalContent',
      desc: '',
      args: [],
    );
  }

  /// `Join Code:`
  String get joinCode {
    return Intl.message(
      'Join Code:',
      name: 'joinCode',
      desc: '',
      args: [],
    );
  }

  /// `Error`
  String get genericErrorModalHeader {
    return Intl.message(
      'Error',
      name: 'genericErrorModalHeader',
      desc: '',
      args: [],
    );
  }

  /// `Technical details: `
  String get genericErrorModalTechnicalDetailsHeader {
    return Intl.message(
      'Technical details: ',
      name: 'genericErrorModalTechnicalDetailsHeader',
      desc: '',
      args: [],
    );
  }

  /// `Error code:`
  String get genericErrorModalTechnicalDetailsErrorCodeRowLabel {
    return Intl.message(
      'Error code:',
      name: 'genericErrorModalTechnicalDetailsErrorCodeRowLabel',
      desc: '',
      args: [],
    );
  }

  /// `Error text:`
  String get genericErrorModalTechnicalDetailsExceptionRowLabel {
    return Intl.message(
      'Error text:',
      name: 'genericErrorModalTechnicalDetailsExceptionRowLabel',
      desc: '',
      args: [],
    );
  }

  /// `Name of property`
  String get nameOfPropertyLabel {
    return Intl.message(
      'Name of property',
      name: 'nameOfPropertyLabel',
      desc: '',
      args: [],
    );
  }

  /// `Help text for the property`
  String get descriptionOfProperty {
    return Intl.message(
      'Help text for the property',
      name: 'descriptionOfProperty',
      desc: '',
      args: [],
    );
  }

  /// `Frequently changed (e.g. every session)`
  String get propertyEditTypeOneTap {
    return Intl.message(
      'Frequently changed (e.g. every session)',
      name: 'propertyEditTypeOneTap',
      desc: '',
      args: [],
    );
  }

  /// `Rarely changed (e.g. per level-up)`
  String get propertyEditTypeStatic {
    return Intl.message(
      'Rarely changed (e.g. per level-up)',
      name: 'propertyEditTypeStatic',
      desc: '',
      args: [],
    );
  }

  /// `Change frequency`
  String get propertyEditTypeLabel {
    return Intl.message(
      'Change frequency',
      name: 'propertyEditTypeLabel',
      desc: '',
      args: [],
    );
  }

  /// `Generated image`
  String get generatedImage {
    return Intl.message(
      'Generated image',
      name: 'generatedImage',
      desc: '',
      args: [],
    );
  }

  /// `Multiline text`
  String get multilineText {
    return Intl.message(
      'Multiline text',
      name: 'multilineText',
      desc: '',
      args: [],
    );
  }

  /// `Single line text`
  String get singleLineText {
    return Intl.message(
      'Single line text',
      name: 'singleLineText',
      desc: '',
      args: [],
    );
  }

  /// `Number value`
  String get integerValue {
    return Intl.message(
      'Number value',
      name: 'integerValue',
      desc: '',
      args: [],
    );
  }

  /// `List of number values with icons`
  String get listOfIntegersWithIcons {
    return Intl.message(
      'List of number values with icons',
      name: 'listOfIntegersWithIcons',
      desc: '',
      args: [],
    );
  }

  /// `Number value with max value`
  String get integerValueWithMaxValue {
    return Intl.message(
      'Number value with max value',
      name: 'integerValueWithMaxValue',
      desc: '',
      args: [],
    );
  }

  /// `Group of number values with additional number`
  String get listOfInterValuesWithCalculatedIntegerValues {
    return Intl.message(
      'Group of number values with additional number',
      name: 'listOfInterValuesWithCalculatedIntegerValues',
      desc: '',
      args: [],
    );
  }

  /// `Number value with additional number`
  String get integerValueWithCalculatedValue {
    return Intl.message(
      'Number value with additional number',
      name: 'integerValueWithCalculatedValue',
      desc: '',
      args: [],
    );
  }

  /// `Character name with level and configurable details`
  String get characterNameWithLevelAndConfigurableDetails {
    return Intl.message(
      'Character name with level and configurable details',
      name: 'characterNameWithLevelAndConfigurableDetails',
      desc: '',
      args: [],
    );
  }

  /// `Multiselect`
  String get multiselectOption {
    return Intl.message(
      'Multiselect',
      name: 'multiselectOption',
      desc: '',
      args: [],
    );
  }

  /// `Companion overview`
  String get companionOverview {
    return Intl.message(
      'Companion overview',
      name: 'companionOverview',
      desc: '',
      args: [],
    );
  }

  /// `Kind of property`
  String get kindOfProperty {
    return Intl.message(
      'Kind of property',
      name: 'kindOfProperty',
      desc: '',
      args: [],
    );
  }

  /// `Multiselect options are selectable multiple times`
  String get multiselectOptionsAreSelectableMultipleTimes {
    return Intl.message(
      'Multiselect options are selectable multiple times',
      name: 'multiselectOptionsAreSelectableMultipleTimes',
      desc: '',
      args: [],
    );
  }

  /// `Optional property for companions`
  String get optionalPropertyForCompanions {
    return Intl.message(
      'Optional property for companions',
      name: 'optionalPropertyForCompanions',
      desc: '',
      args: [],
    );
  }

  /// `Optional property for alternate forms`
  String get optionalPropertyForAlternateForms {
    return Intl.message(
      'Optional property for alternate forms',
      name: 'optionalPropertyForAlternateForms',
      desc: '',
      args: [],
    );
  }

  /// `Options for multiselect`
  String get optionsForMultiselect {
    return Intl.message(
      'Options for multiselect',
      name: 'optionsForMultiselect',
      desc: '',
      args: [],
    );
  }

  /// `Name:`
  String get multiselectOptionName {
    return Intl.message(
      'Name:',
      name: 'multiselectOptionName',
      desc: '',
      args: [],
    );
  }

  /// `Description:`
  String get multiselectOptionDescription {
    return Intl.message(
      'Description:',
      name: 'multiselectOptionDescription',
      desc: '',
      args: [],
    );
  }

  /// `Add element`
  String get additionalElement {
    return Intl.message(
      'Add element',
      name: 'additionalElement',
      desc: '',
      args: [],
    );
  }

  /// `More values`
  String get moreValues {
    return Intl.message(
      'More values',
      name: 'moreValues',
      desc: '',
      args: [],
    );
  }

  /// `for number value`
  String get forIntegerValueWithName {
    return Intl.message(
      'for number value',
      name: 'forIntegerValueWithName',
      desc: '',
      args: [],
    );
  }

  /// `Name:`
  String get propertyNameLabel {
    return Intl.message(
      'Name:',
      name: 'propertyNameLabel',
      desc: '',
      args: [],
    );
  }

  /// `Complete registration`
  String get completeRegistration {
    return Intl.message(
      'Complete registration',
      name: 'completeRegistration',
      desc: '',
      args: [],
    );
  }

  /// `Select icon`
  String get selectIconModalTitle {
    return Intl.message(
      'Select icon',
      name: 'selectIconModalTitle',
      desc: '',
      args: [],
    );
  }

  /// `Select a color:`
  String get selectAColor {
    return Intl.message(
      'Select a color:',
      name: 'selectAColor',
      desc: '',
      args: [],
    );
  }

  /// `Select an icon:`
  String get selectAnIcon {
    return Intl.message(
      'Select an icon:',
      name: 'selectAnIcon',
      desc: '',
      args: [],
    );
  }

  /// `Item`
  String get item {
    return Intl.message(
      'Item',
      name: 'item',
      desc: '',
      args: [],
    );
  }

  /// `Some item description`
  String get itemExampleDescription {
    return Intl.message(
      'Some item description',
      name: 'itemExampleDescription',
      desc: '',
      args: [],
    );
  }

  /// `Select`
  String get select {
    return Intl.message(
      'Select',
      name: 'select',
      desc: '',
      args: [],
    );
  }

  /// `Campaign management`
  String get campaignManagement {
    return Intl.message(
      'Campaign management',
      name: 'campaignManagement',
      desc: '',
      args: [],
    );
  }

  /// `Charakter overview`
  String get characterOverview {
    return Intl.message(
      'Charakter overview',
      name: 'characterOverview',
      desc: '',
      args: [],
    );
  }

  /// `Fight order`
  String get fightingOrdering {
    return Intl.message(
      'Fight order',
      name: 'fightingOrdering',
      desc: '',
      args: [],
    );
  }

  /// `Grant items`
  String get grantItems {
    return Intl.message(
      'Grant items',
      name: 'grantItems',
      desc: '',
      args: [],
    );
  }

  /// `Lore`
  String get lore {
    return Intl.message(
      'Lore',
      name: 'lore',
      desc: '',
      args: [],
    );
  }

  /// `Online`
  String get online {
    return Intl.message(
      'Online',
      name: 'online',
      desc: '',
      args: [],
    );
  }

  /// `Offline`
  String get offline {
    return Intl.message(
      'Offline',
      name: 'offline',
      desc: '',
      args: [],
    );
  }

  /// `All players:`
  String get allPlayers {
    return Intl.message(
      'All players:',
      name: 'allPlayers',
      desc: '',
      args: [],
    );
  }

  /// `Join requests:`
  String get openJoinRequests {
    return Intl.message(
      'Join requests:',
      name: 'openJoinRequests',
      desc: '',
      args: [],
    );
  }

  /// `Join code (for new players):`
  String get joinCodeForNewPlayers {
    return Intl.message(
      'Join code (for new players):',
      name: 'joinCodeForNewPlayers',
      desc: '',
      args: [],
    );
  }

  /// `No open requests`
  String get noOpenJoinRequests {
    return Intl.message(
      'No open requests',
      name: 'noOpenJoinRequests',
      desc: '',
      args: [],
    );
  }

  /// `User:`
  String get user {
    return Intl.message(
      'User:',
      name: 'user',
      desc: '',
      args: [],
    );
  }

  /// `Character:`
  String get character {
    return Intl.message(
      'Character:',
      name: 'character',
      desc: '',
      args: [],
    );
  }

  /// `Last granted items`
  String get lastGrantedItems {
    return Intl.message(
      'Last granted items',
      name: 'lastGrantedItems',
      desc: '',
      args: [],
    );
  }

  /// `No items granted yet...`
  String get noItemsGranted {
    return Intl.message(
      'No items granted yet...',
      name: 'noItemsGranted',
      desc: '',
      args: [],
    );
  }

  /// `Place of finding`
  String get placeOfFinding {
    return Intl.message(
      'Place of finding',
      name: 'placeOfFinding',
      desc: '',
      args: [],
    );
  }

  /// `Player rolls`
  String get playerRolls {
    return Intl.message(
      'Player rolls',
      name: 'playerRolls',
      desc: '',
      args: [],
    );
  }

  /// `Dice roll`
  String get diceRoll {
    return Intl.message(
      'Dice roll',
      name: 'diceRoll',
      desc: '',
      args: [],
    );
  }

  /// `Player`
  String get player {
    return Intl.message(
      'Player',
      name: 'player',
      desc: '',
      args: [],
    );
  }

  /// `Send items`
  String get sendItems {
    return Intl.message(
      'Send items',
      name: 'sendItems',
      desc: '',
      args: [],
    );
  }

  /// `## Items to be found in place:`
  String get itemsToBeFoundInPlaceMarkdown {
    return Intl.message(
      '## Items to be found in place:',
      name: 'itemsToBeFoundInPlaceMarkdown',
      desc: '',
      args: [],
    );
  }

  /// `No place of finding selected.`
  String get noPlaceOfFindingSelected {
    return Intl.message(
      'No place of finding selected.',
      name: 'noPlaceOfFindingSelected',
      desc: '',
      args: [],
    );
  }

  /// `The following items are possible at the place of finding:`
  String get followingItemsArePossibleAtPlaceOfFinding {
    return Intl.message(
      'The following items are possible at the place of finding:',
      name: 'followingItemsArePossibleAtPlaceOfFinding',
      desc: '',
      args: [],
    );
  }

  /// `DC`
  String get diceChallengeAbbr {
    return Intl.message(
      'DC',
      name: 'diceChallengeAbbr',
      desc: '',
      args: [],
    );
  }

  /// `Last granted items:`
  String get lastGrantedItemsMarkdownPrefix {
    return Intl.message(
      'Last granted items:',
      name: 'lastGrantedItemsMarkdownPrefix',
      desc: '',
      args: [],
    );
  }

  /// `No items granted this round`
  String get noItemsGrantedToPlayerThisRound {
    return Intl.message(
      'No items granted this round',
      name: 'noItemsGrantedToPlayerThisRound',
      desc: '',
      args: [],
    );
  }

  /// `Login`
  String get login {
    return Intl.message(
      'Login',
      name: 'login',
      desc: '',
      args: [],
    );
  }

  /// `Sign in with Apple`
  String get signInWithApple {
    return Intl.message(
      'Sign in with Apple',
      name: 'signInWithApple',
      desc: '',
      args: [],
    );
  }

  /// `Sign in with Google`
  String get signInWithGoogle {
    return Intl.message(
      'Sign in with Google',
      name: 'signInWithGoogle',
      desc: '',
      args: [],
    );
  }

  /// `Create new account`
  String get createNewAccount {
    return Intl.message(
      'Create new account',
      name: 'createNewAccount',
      desc: '',
      args: [],
    );
  }

  /// `E-Mail`
  String get email {
    return Intl.message(
      'E-Mail',
      name: 'email',
      desc: '',
      args: [],
    );
  }

  /// `Register`
  String get register {
    return Intl.message(
      'Register',
      name: 'register',
      desc: '',
      args: [],
    );
  }

  /// `Item details for`
  String get itemDetailsForPrefix {
    return Intl.message(
      'Item details for',
      name: 'itemDetailsForPrefix',
      desc: '',
      args: [],
    );
  }

  /// `Description:`
  String get itemDetailsDescriptionHeader {
    return Intl.message(
      'Description:',
      name: 'itemDetailsDescriptionHeader',
      desc: '',
      args: [],
    );
  }

  /// `Price:`
  String get itemDetailsPriceHeader {
    return Intl.message(
      'Price:',
      name: 'itemDetailsPriceHeader',
      desc: '',
      args: [],
    );
  }

  /// `Amount`
  String get amount {
    return Intl.message(
      'Amount',
      name: 'amount',
      desc: '',
      args: [],
    );
  }

  /// `Received items`
  String get receivedItemsModalHeader {
    return Intl.message(
      'Received items',
      name: 'receivedItemsModalHeader',
      desc: '',
      args: [],
    );
  }

  /// `# New items`
  String get newItemsMarkdownPlural {
    return Intl.message(
      '# New items',
      name: 'newItemsMarkdownPlural',
      desc: '',
      args: [],
    );
  }

  /// `# New item`
  String get newItemsMarkdownSingular {
    return Intl.message(
      '# New item',
      name: 'newItemsMarkdownSingular',
      desc: '',
      args: [],
    );
  }

  /// `You received one new item:`
  String get receivedOneNewItemText {
    return Intl.message(
      'You received one new item:',
      name: 'receivedOneNewItemText',
      desc: '',
      args: [],
    );
  }

  /// `You received {amount} new items:`
  String receivedXNewItems(Object amount) {
    return Intl.message(
      'You received $amount new items:',
      name: 'receivedXNewItems',
      desc: '',
      args: [amount],
    );
  }

  /// `Ok`
  String get ok {
    return Intl.message(
      'Ok',
      name: 'ok',
      desc: '',
      args: [],
    );
  }

  /// `Now we come to the character sheets.\n\nEvery role-playing game has different attributes that characterize the players (e.g., how many hit points a player has).\n\nFor each attribute, as the game master, you need to define how the players can interact with this attribute. We need three pieces of information from you for each attribute:\n\n1. Name of the attribute: What should this value be called on the character sheet? (e.g., “HP”, “SP”, “Name”, etc.)\n2. Type of the attribute: Is it, for example, a text that the player can modify (e.g., the character's backstory) or a numerical value (e.g., the hit points)?\n3. Change type: Some of these attributes are regularly adjusted (e.g., the current hit points), while others are rarely changed (e.g., the maximum hit points). To consider this when creating the character sheets, you need to provide us with this information.\n\nIf you need more explanations, you can find an example page here with all configurations and the corresponding appearance on the character sheets:`
  String get rpgConfigurationDmWizardStep2Tutorial {
    return Intl.message(
      'Now we come to the character sheets.\n\nEvery role-playing game has different attributes that characterize the players (e.g., how many hit points a player has).\n\nFor each attribute, as the game master, you need to define how the players can interact with this attribute. We need three pieces of information from you for each attribute:\n\n1. Name of the attribute: What should this value be called on the character sheet? (e.g., “HP”, “SP”, “Name”, etc.)\n2. Type of the attribute: Is it, for example, a text that the player can modify (e.g., the character\'s backstory) or a numerical value (e.g., the hit points)?\n3. Change type: Some of these attributes are regularly adjusted (e.g., the current hit points), while others are rarely changed (e.g., the maximum hit points). To consider this when creating the character sheets, you need to provide us with this information.\n\nIf you need more explanations, you can find an example page here with all configurations and the corresponding appearance on the character sheets:',
      name: 'rpgConfigurationDmWizardStep2Tutorial',
      desc: '',
      args: [],
    );
  }

  /// `LVL`
  String get levelAbbr {
    return Intl.message(
      'LVL',
      name: 'levelAbbr',
      desc: '',
      args: [],
    );
  }

  /// `Add additional enemy`
  String get addAdditionalEnemy {
    return Intl.message(
      'Add additional enemy',
      name: 'addAdditionalEnemy',
      desc: '',
      args: [],
    );
  }

  /// `Enemy name`
  String get enemyName {
    return Intl.message(
      'Enemy name',
      name: 'enemyName',
      desc: '',
      args: [],
    );
  }

  /// `Roll of initiative`
  String get rollOfInititive {
    return Intl.message(
      'Roll of initiative',
      name: 'rollOfInititive',
      desc: '',
      args: [],
    );
  }

  /// `Add more`
  String get addAnAdditionalEnemyBtnLabel {
    return Intl.message(
      'Add more',
      name: 'addAnAdditionalEnemyBtnLabel',
      desc: '',
      args: [],
    );
  }

  /// `Enemy`
  String get enemy {
    return Intl.message(
      'Enemy',
      name: 'enemy',
      desc: '',
      args: [],
    );
  }

  /// `Add`
  String get add {
    return Intl.message(
      'Add',
      name: 'add',
      desc: '',
      args: [],
    );
  }

  /// `Initiative roll`
  String get initiativeRollForCharacterPrefix {
    return Intl.message(
      'Initiative roll',
      name: 'initiativeRollForCharacterPrefix',
      desc: '',
      args: [],
    );
  }

  /// `A fight has started. Please roll for initiative.`
  String get initiativeRollText {
    return Intl.message(
      'A fight has started. Please roll for initiative.',
      name: 'initiativeRollText',
      desc: '',
      args: [],
    );
  }

  /// `Initiative roll`
  String get initiativeRollTextFieldLabel {
    return Intl.message(
      'Initiative roll',
      name: 'initiativeRollTextFieldLabel',
      desc: '',
      args: [],
    );
  }

  /// `Absenden`
  String get send {
    return Intl.message(
      'Absenden',
      name: 'send',
      desc: '',
      args: [],
    );
  }

  /// `Edit document`
  String get editPageTitle {
    return Intl.message(
      'Edit document',
      name: 'editPageTitle',
      desc: '',
      args: [],
    );
  }

  /// `You can edit both the title and the grouping of your document here.`
  String get editPageModalText {
    return Intl.message(
      'You can edit both the title and the grouping of your document here.',
      name: 'editPageModalText',
      desc: '',
      args: [],
    );
  }

  /// `Titel`
  String get documentTitleLabel {
    return Intl.message(
      'Titel',
      name: 'documentTitleLabel',
      desc: '',
      args: [],
    );
  }

  /// `Grouping`
  String get documentGroupLabel {
    return Intl.message(
      'Grouping',
      name: 'documentGroupLabel',
      desc: '',
      args: [],
    );
  }

  /// `Recipe for`
  String get recipeForTitlePrefix {
    return Intl.message(
      'Recipe for',
      name: 'recipeForTitlePrefix',
      desc: '',
      args: [],
    );
  }

  /// `Prerequisites:`
  String get recipeRequirements {
    return Intl.message(
      'Prerequisites:',
      name: 'recipeRequirements',
      desc: '',
      args: [],
    );
  }

  /// `Ingredients:`
  String get recipeIngredients {
    return Intl.message(
      'Ingredients:',
      name: 'recipeIngredients',
      desc: '',
      args: [],
    );
  }

  /// `Required:`
  String get requiredIngredientCountPrefix {
    return Intl.message(
      'Required:',
      name: 'requiredIngredientCountPrefix',
      desc: '',
      args: [],
    );
  }

  /// `owned:`
  String get ownedIngredientCountPrefix {
    return Intl.message(
      'owned:',
      name: 'ownedIngredientCountPrefix',
      desc: '',
      args: [],
    );
  }

  /// `Amount`
  String get amountToCraftFieldLabel {
    return Intl.message(
      'Amount',
      name: 'amountToCraftFieldLabel',
      desc: '',
      args: [],
    );
  }

  /// `Craft`
  String get craft {
    return Intl.message(
      'Craft',
      name: 'craft',
      desc: '',
      args: [],
    );
  }

  /// `New`
  String get newItem {
    return Intl.message(
      'New',
      name: 'newItem',
      desc: '',
      args: [],
    );
  }

  /// `Other`
  String get defaultGroupNameForDocuments {
    return Intl.message(
      'Other',
      name: 'defaultGroupNameForDocuments',
      desc: '',
      args: [],
    );
  }

  /// `Document`
  String get documentDefaultNamePrefix {
    return Intl.message(
      'Document',
      name: 'documentDefaultNamePrefix',
      desc: '',
      args: [],
    );
  }

  /// `Author:`
  String get authorLabel {
    return Intl.message(
      'Author:',
      name: 'authorLabel',
      desc: '',
      args: [],
    );
  }

  /// `You`
  String get you {
    return Intl.message(
      'You',
      name: 'you',
      desc: '',
      args: [],
    );
  }

  /// `DM`
  String get dm {
    return Intl.message(
      'DM',
      name: 'dm',
      desc: '',
      args: [],
    );
  }

  /// `%H:%M %m-%d-%Y`
  String get hourMinutesDayMonthYearFormatString {
    return Intl.message(
      '%H:%M %m-%d-%Y',
      name: 'hourMinutesDayMonthYearFormatString',
      desc: '',
      args: [],
    );
  }

  /// `Paragraph`
  String get addParagraphBtnLabel {
    return Intl.message(
      'Paragraph',
      name: 'addParagraphBtnLabel',
      desc: '',
      args: [],
    );
  }

  /// `Image`
  String get addImageBtnLabel {
    return Intl.message(
      'Image',
      name: 'addImageBtnLabel',
      desc: '',
      args: [],
    );
  }

  /// `New grouping:`
  String get newGroup {
    return Intl.message(
      'New grouping:',
      name: 'newGroup',
      desc: '',
      args: [],
    );
  }

  /// `New grouping`
  String get newGroupBtnLabel {
    return Intl.message(
      'New grouping',
      name: 'newGroupBtnLabel',
      desc: '',
      args: [],
    );
  }

  /// `New property`
  String get newPropertyBtnLabel {
    return Intl.message(
      'New property',
      name: 'newPropertyBtnLabel',
      desc: '',
      args: [],
    );
  }

  /// `New tab`
  String get newTabBtnLabel {
    return Intl.message(
      'New tab',
      name: 'newTabBtnLabel',
      desc: '',
      args: [],
    );
  }

  /// `Requires:`
  String get itemCardDescRequires {
    return Intl.message(
      'Requires:',
      name: 'itemCardDescRequires',
      desc: '',
      args: [],
    );
  }

  /// `Default tab`
  String get defaultTab {
    return Intl.message(
      'Default tab',
      name: 'defaultTab',
      desc: '',
      args: [],
    );
  }

  /// `Amount:`
  String get amountHeaderLabel {
    return Intl.message(
      'Amount:',
      name: 'amountHeaderLabel',
      desc: '',
      args: [],
    );
  }

  /// `No items in this category`
  String get noItemsInCategoryErrorText {
    return Intl.message(
      'No items in this category',
      name: 'noItemsInCategoryErrorText',
      desc: '',
      args: [],
    );
  }

  /// `Search`
  String get searchLabel {
    return Intl.message(
      'Search',
      name: 'searchLabel',
      desc: '',
      args: [],
    );
  }

  /// `All`
  String get itemCategoryFilterAll {
    return Intl.message(
      'All',
      name: 'itemCategoryFilterAll',
      desc: '',
      args: [],
    );
  }

  /// `Craftable`
  String get craftableRecipeFilter {
    return Intl.message(
      'Craftable',
      name: 'craftableRecipeFilter',
      desc: '',
      args: [],
    );
  }

  /// `No craftable items in this category`
  String get noItemsInCategoryCraftable {
    return Intl.message(
      'No craftable items in this category',
      name: 'noItemsInCategoryCraftable',
      desc: '',
      args: [],
    );
  }

  /// `No items in this category`
  String get noItemsInCategory {
    return Intl.message(
      'No items in this category',
      name: 'noItemsInCategory',
      desc: '',
      args: [],
    );
  }

  /// `Craftable:`
  String get craftableAmountText {
    return Intl.message(
      'Craftable:',
      name: 'craftableAmountText',
      desc: '',
      args: [],
    );
  }

  /// `Crafting`
  String get navBarHeaderCrafting {
    return Intl.message(
      'Crafting',
      name: 'navBarHeaderCrafting',
      desc: '',
      args: [],
    );
  }

  /// `Lore`
  String get navBarHeaderLore {
    return Intl.message(
      'Lore',
      name: 'navBarHeaderLore',
      desc: '',
      args: [],
    );
  }

  /// `Inventory`
  String get navBarHeaderInventory {
    return Intl.message(
      'Inventory',
      name: 'navBarHeaderInventory',
      desc: '',
      args: [],
    );
  }

  /// `Currency`
  String get navBarHeaderMoney {
    return Intl.message(
      'Currency',
      name: 'navBarHeaderMoney',
      desc: '',
      args: [],
    );
  }

  /// `0 Gold`
  String get noMoneyDefaultText {
    return Intl.message(
      '0 Gold',
      name: 'noMoneyDefaultText',
      desc: '',
      args: [],
    );
  }

  /// `Current balance`
  String get currentBalance {
    return Intl.message(
      'Current balance',
      name: 'currentBalance',
      desc: '',
      args: [],
    );
  }

  /// `Add balance`
  String get addBalance {
    return Intl.message(
      'Add balance',
      name: 'addBalance',
      desc: '',
      args: [],
    );
  }

  /// `Reduce balance`
  String get reduceBalance {
    return Intl.message(
      'Reduce balance',
      name: 'reduceBalance',
      desc: '',
      args: [],
    );
  }

  /// `New balance`
  String get newBalance {
    return Intl.message(
      'New balance',
      name: 'newBalance',
      desc: '',
      args: [],
    );
  }

  /// `Not enough balance for this transaction`
  String get notEnoughBalance {
    return Intl.message(
      'Not enough balance for this transaction',
      name: 'notEnoughBalance',
      desc: '',
      args: [],
    );
  }

  /// `Visible for:`
  String get noteblockVisibleFor {
    return Intl.message(
      'Visible for:',
      name: 'noteblockVisibleFor',
      desc: '',
      args: [],
    );
  }

  /// `- Nothinge selected -`
  String get nothingSelected {
    return Intl.message(
      '- Nothinge selected -',
      name: 'nothingSelected',
      desc: '',
      args: [],
    );
  }

  /// `Name:`
  String get characterNameLabel {
    return Intl.message(
      'Name:',
      name: 'characterNameLabel',
      desc: '',
      args: [],
    );
  }

  /// `Level`
  String get level {
    return Intl.message(
      'Level',
      name: 'level',
      desc: '',
      args: [],
    );
  }

  /// `Count`
  String get count {
    return Intl.message(
      'Count',
      name: 'count',
      desc: '',
      args: [],
    );
  }

  /// `Add items`
  String get addItems {
    return Intl.message(
      'Add items',
      name: 'addItems',
      desc: '',
      args: [],
    );
  }

  /// `Select Game Mode`
  String get selectGameMode {
    return Intl.message(
      'Select Game Mode',
      name: 'selectGameMode',
      desc: '',
      args: [],
    );
  }

  /// `Choose a campaign`
  String get chooseACampagne {
    return Intl.message(
      'Choose a campaign',
      name: 'chooseACampagne',
      desc: '',
      args: [],
    );
  }

  /// `Play as DM`
  String get startAsDm {
    return Intl.message(
      'Play as DM',
      name: 'startAsDm',
      desc: '',
      args: [],
    );
  }

  /// `You own {count} campaigns`
  String youOwnXCampaigns(Object count) {
    return Intl.message(
      'You own $count campaigns',
      name: 'youOwnXCampaigns',
      desc: '',
      args: [count],
    );
  }

  /// `Join as Player`
  String get joinAsPlayer {
    return Intl.message(
      'Join as Player',
      name: 'joinAsPlayer',
      desc: '',
      args: [],
    );
  }

  /// `Choose a character`
  String get chooseACharacter {
    return Intl.message(
      'Choose a character',
      name: 'chooseACharacter',
      desc: '',
      args: [],
    );
  }

  /// `You own {count} characters`
  String youOwnXCharacters(Object count) {
    return Intl.message(
      'You own $count characters',
      name: 'youOwnXCharacters',
      desc: '',
      args: [count],
    );
  }

  /// `Name`
  String get campaigneName {
    return Intl.message(
      'Name',
      name: 'campaigneName',
      desc: '',
      args: [],
    );
  }

  /// `The name of the campaign`
  String get helperTextForNameOfCampaign {
    return Intl.message(
      'The name of the campaign',
      name: 'helperTextForNameOfCampaign',
      desc: '',
      args: [],
    );
  }

  /// `New campaign`
  String get newCampaign {
    return Intl.message(
      'New campaign',
      name: 'newCampaign',
      desc: '',
      args: [],
    );
  }

  /// `Currently no players are online`
  String get noPlayersOnline {
    return Intl.message(
      'Currently no players are online',
      name: 'noPlayersOnline',
      desc: '',
      args: [],
    );
  }

  /// `Current fight ordering`
  String get currentFightOrdering {
    return Intl.message(
      'Current fight ordering',
      name: 'currentFightOrdering',
      desc: '',
      args: [],
    );
  }

  /// `No fight started yet`
  String get noFIghtStarted {
    return Intl.message(
      'No fight started yet',
      name: 'noFIghtStarted',
      desc: '',
      args: [],
    );
  }

  /// `New fight ordering`
  String get newFightOrdering {
    return Intl.message(
      'New fight ordering',
      name: 'newFightOrdering',
      desc: '',
      args: [],
    );
  }

  /// `Additional fight participants`
  String get additionalFightParticipants {
    return Intl.message(
      'Additional fight participants',
      name: 'additionalFightParticipants',
      desc: '',
      args: [],
    );
  }

  /// `Roll for initiative`
  String get rollForInitiative {
    return Intl.message(
      'Roll for initiative',
      name: 'rollForInitiative',
      desc: '',
      args: [],
    );
  }

  /// `Name`
  String get characterName {
    return Intl.message(
      'Name',
      name: 'characterName',
      desc: '',
      args: [],
    );
  }

  /// `The name of the character`
  String get nameOfCharacterHelperText {
    return Intl.message(
      'The name of the character',
      name: 'nameOfCharacterHelperText',
      desc: '',
      args: [],
    );
  }

  /// `Campaign name`
  String get campaignName {
    return Intl.message(
      'Campaign name',
      name: 'campaignName',
      desc: '',
      args: [],
    );
  }

  /// `Roll for initiative`
  String get rollForInitiativeBtnLabel {
    return Intl.message(
      'Roll for initiative',
      name: 'rollForInitiativeBtnLabel',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'de'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
