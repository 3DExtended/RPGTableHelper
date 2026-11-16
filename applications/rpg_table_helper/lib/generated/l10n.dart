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
    assert(
      _current != null,
      'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.',
    );
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
    assert(
      instance != null,
      'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?',
    );
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Username`
  String get username {
    return Intl.message('Username', name: 'username', desc: '', args: []);
  }

  /// `Password`
  String get password {
    return Intl.message('Password', name: 'password', desc: '', args: []);
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
    return Intl.message('Save', name: 'save', desc: '', args: []);
  }

  /// `Cancel`
  String get cancel {
    return Intl.message('Cancel', name: 'cancel', desc: '', args: []);
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
    return Intl.message('First value', name: 'firstValue', desc: '', args: []);
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
    return Intl.message('Other value', name: 'otherValue', desc: '', args: []);
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
    return Intl.message('Max value', name: 'maxValue', desc: '', args: []);
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
    return Intl.message('New pet', name: 'newPetBtnLabel', desc: '', args: []);
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
    return Intl.message('Preview', name: 'preview', desc: '', args: []);
  }

  /// `Try the controls — changes here aren't saved.`
  String get previewTestHint {
    return Intl.message(
      'Try the controls — changes here aren\'t saved.',
      name: 'previewTestHint',
      desc: '',
      args: [],
    );
  }

  /// `Reset`
  String get previewTestReset {
    return Intl.message('Reset', name: 'previewTestReset', desc: '', args: []);
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

  /// `Upload image`
  String get uploadImageBtnLabel {
    return Intl.message(
      'Upload image',
      name: 'uploadImageBtnLabel',
      desc: '',
      args: [],
    );
  }

  /// `The selected file is not an image.`
  String get invalidImageFileSelected {
    return Intl.message(
      'The selected file is not an image.',
      name: 'invalidImageFileSelected',
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

  /// `Join a campaign`
  String get addCharacterToCampagneModalTitle {
    return Intl.message(
      'Join a campaign',
      name: 'addCharacterToCampagneModalTitle',
      desc: '',
      args: [],
    );
  }

  /// `Your character is not part of a campaign yet. Enter the join code you got from your game master. They will then confirm your request.`
  String get assignCharacterToCampagneModalContent {
    return Intl.message(
      'Your character is not part of a campaign yet. Enter the join code you got from your game master. They will then confirm your request.',
      name: 'assignCharacterToCampagneModalContent',
      desc: '',
      args: [],
    );
  }

  /// `Join code`
  String get joinCode {
    return Intl.message('Join code', name: 'joinCode', desc: '', args: []);
  }

  /// `That didn't work`
  String get genericErrorModalHeader {
    return Intl.message(
      'That didn\'t work',
      name: 'genericErrorModalHeader',
      desc: '',
      args: [],
    );
  }

  /// `Technical details`
  String get genericErrorModalTechnicalDetailsHeader {
    return Intl.message(
      'Technical details',
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

  /// `Icon`
  String get companionSelectorIconHeadline {
    return Intl.message(
      'Icon',
      name: 'companionSelectorIconHeadline',
      desc: '',
      args: [],
    );
  }

  /// `Shown above these companions on the character sheet, e.g. a ship for vehicles.`
  String get companionSelectorIconHint {
    return Intl.message(
      'Shown above these companions on the character sheet, e.g. a ship for vehicles.',
      name: 'companionSelectorIconHint',
      desc: '',
      args: [],
    );
  }

  /// `for companions`
  String get forCompanionSelector {
    return Intl.message(
      'for companions',
      name: 'forCompanionSelector',
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

  /// `Summary:`
  String get multiselectOptionSummary {
    return Intl.message(
      'Summary:',
      name: 'multiselectOptionSummary',
      desc: '',
      args: [],
    );
  }

  /// `Optional, ~90 characters; shown on the sheet. Full text stays in Description.`
  String get multiselectOptionSummaryHelper {
    return Intl.message(
      'Optional, ~90 characters; shown on the sheet. Full text stays in Description.',
      name: 'multiselectOptionSummaryHelper',
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
    return Intl.message('More values', name: 'moreValues', desc: '', args: []);
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
    return Intl.message('Name:', name: 'propertyNameLabel', desc: '', args: []);
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
    return Intl.message('Item', name: 'item', desc: '', args: []);
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
    return Intl.message('Select', name: 'select', desc: '', args: []);
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

  /// `Character overview`
  String get characterOverview {
    return Intl.message(
      'Character overview',
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
    return Intl.message('Grant items', name: 'grantItems', desc: '', args: []);
  }

  /// `Notes`
  String get lore {
    return Intl.message('Notes', name: 'lore', desc: '', args: []);
  }

  /// `Online`
  String get online {
    return Intl.message('Online', name: 'online', desc: '', args: []);
  }

  /// `Offline`
  String get offline {
    return Intl.message('Offline', name: 'offline', desc: '', args: []);
  }

  /// `All players:`
  String get allPlayers {
    return Intl.message('All players:', name: 'allPlayers', desc: '', args: []);
  }

  /// `Join requests`
  String get openJoinRequests {
    return Intl.message(
      'Join requests',
      name: 'openJoinRequests',
      desc: '',
      args: [],
    );
  }

  /// `Join code: {code}`
  String joinCodeForNewPlayers(String code) {
    return Intl.message(
      'Join code: $code',
      name: 'joinCodeForNewPlayers',
      desc: '',
      args: [code],
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
    return Intl.message('User:', name: 'user', desc: '', args: []);
  }

  /// `Character:`
  String get character {
    return Intl.message('Character:', name: 'character', desc: '', args: []);
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
    return Intl.message('Dice roll', name: 'diceRoll', desc: '', args: []);
  }

  /// `Player`
  String get player {
    return Intl.message('Player', name: 'player', desc: '', args: []);
  }

  /// `Send items`
  String get sendItems {
    return Intl.message('Send items', name: 'sendItems', desc: '', args: []);
  }

  /// `## Items at this place`
  String get itemsToBeFoundInPlaceMarkdown {
    return Intl.message(
      '## Items at this place',
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

  /// `These items can be found here:`
  String get followingItemsArePossibleAtPlaceOfFinding {
    return Intl.message(
      'These items can be found here:',
      name: 'followingItemsArePossibleAtPlaceOfFinding',
      desc: '',
      args: [],
    );
  }

  /// `DC`
  String get diceChallengeAbbr {
    return Intl.message('DC', name: 'diceChallengeAbbr', desc: '', args: []);
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

  /// `Could not grant the items to {characterNames}. Please try again.`
  String grantItemsFailedForPlayers(String characterNames) {
    return Intl.message(
      'Could not grant the items to $characterNames. Please try again.',
      name: 'grantItemsFailedForPlayers',
      desc: '',
      args: [characterNames],
    );
  }

  /// `Sign in`
  String get login {
    return Intl.message('Sign in', name: 'login', desc: '', args: []);
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

  /// `Email`
  String get email {
    return Intl.message('Email', name: 'email', desc: '', args: []);
  }

  /// `Register`
  String get register {
    return Intl.message('Register', name: 'register', desc: '', args: []);
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
    return Intl.message('Amount', name: 'amount', desc: '', args: []);
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

  /// `{amount, plural, one{You received one new item:} other{You received {amount} new items:}}`
  String receivedXNewItems(num amount) {
    return Intl.plural(
      amount,
      one: 'You received one new item:',
      other: 'You received $amount new items:',
      name: 'receivedXNewItems',
      desc: '',
      args: [amount],
    );
  }

  /// `OK`
  String get ok {
    return Intl.message('OK', name: 'ok', desc: '', args: []);
  }

  /// `Now we come to the character sheets.\n\nEvery role-playing game has different attributes that characterize the players (e.g., how many hit points a player has).\n\nFor each attribute, as the game master, you need to define how the players can interact with this attribute. We need three pieces of information from you for each attribute:\n\n1. Name of the attribute: What should this value be called on the character sheet? (e.g., “HP”, “SP”, “Name”, etc.)\n2. Type of the attribute: Is it, for example, a text that the player can modify (e.g., the backstory of the character) or a numerical value (e.g., the hit points)?\n3. Change type: Some of these attributes are regularly adjusted (e.g., the current hit points), while others are rarely changed (e.g., the maximum hit points). To consider this when creating the character sheets, you need to provide us with this information.\n\nYou arrange attributes in tabs and groups. Press and hold an attribute to move it.`
  String get rpgConfigurationDmWizardStep2Tutorial {
    return Intl.message(
      'Now we come to the character sheets.\n\nEvery role-playing game has different attributes that characterize the players (e.g., how many hit points a player has).\n\nFor each attribute, as the game master, you need to define how the players can interact with this attribute. We need three pieces of information from you for each attribute:\n\n1. Name of the attribute: What should this value be called on the character sheet? (e.g., “HP”, “SP”, “Name”, etc.)\n2. Type of the attribute: Is it, for example, a text that the player can modify (e.g., the backstory of the character) or a numerical value (e.g., the hit points)?\n3. Change type: Some of these attributes are regularly adjusted (e.g., the current hit points), while others are rarely changed (e.g., the maximum hit points). To consider this when creating the character sheets, you need to provide us with this information.\n\nYou arrange attributes in tabs and groups. Press and hold an attribute to move it.',
      name: 'rpgConfigurationDmWizardStep2Tutorial',
      desc: '',
      args: [],
    );
  }

  /// `LVL`
  String get levelAbbr {
    return Intl.message('LVL', name: 'levelAbbr', desc: '', args: []);
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
    return Intl.message('Enemy name', name: 'enemyName', desc: '', args: []);
  }

  /// `Initiative roll`
  String get rollOfInititive {
    return Intl.message(
      'Initiative roll',
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
    return Intl.message('Enemy', name: 'enemy', desc: '', args: []);
  }

  /// `Add`
  String get add {
    return Intl.message('Add', name: 'add', desc: '', args: []);
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

  /// `A fight is starting. Roll for initiative!`
  String get initiativeRollText {
    return Intl.message(
      'A fight is starting. Roll for initiative!',
      name: 'initiativeRollText',
      desc: '',
      args: [],
    );
  }

  /// `Your roll`
  String get initiativeRollTextFieldLabel {
    return Intl.message(
      'Your roll',
      name: 'initiativeRollTextFieldLabel',
      desc: '',
      args: [],
    );
  }

  /// `Add {label} {formattedBonus} to your roll`
  String initiativeBonusHelperSentence(Object label, Object formattedBonus) {
    return Intl.message(
      'Add $label $formattedBonus to your roll',
      name: 'initiativeBonusHelperSentence',
      desc: '',
      args: [label, formattedBonus],
    );
  }

  /// `Fight / Initiative`
  String get fightInitiativeStepTitle {
    return Intl.message(
      'Fight / Initiative',
      name: 'fightInitiativeStepTitle',
      desc: '',
      args: [],
    );
  }

  /// `Mark which stat counts as the initiative bonus.\n\nWhen a player is asked to roll for initiative, they will see a hint with this bonus so they don't have to remember it while the roll popup covers their character sheet.\n\nChoose **None** if your system doesn't use a bonus. Otherwise pick a stat below. If it is a group of values (e.g. abilities), also pick the entry that applies. If the value has two numbers (e.g. score and modifier, or current and max), pick which one counts as the bonus.`
  String get fightInitiativeStepTutorial {
    return Intl.message(
      'Mark which stat counts as the initiative bonus.\n\nWhen a player is asked to roll for initiative, they will see a hint with this bonus so they don\'t have to remember it while the roll popup covers their character sheet.\n\nChoose **None** if your system doesn\'t use a bonus. Otherwise pick a stat below. If it is a group of values (e.g. abilities), also pick the entry that applies. If the value has two numbers (e.g. score and modifier, or current and max), pick which one counts as the bonus.',
      name: 'fightInitiativeStepTutorial',
      desc: '',
      args: [],
    );
  }

  /// `None`
  String get initiativeBonusNoneOption {
    return Intl.message(
      'None',
      name: 'initiativeBonusNoneOption',
      desc: '',
      args: [],
    );
  }

  /// `Stat`
  String get initiativeBonusStatPickerLabel {
    return Intl.message(
      'Stat',
      name: 'initiativeBonusStatPickerLabel',
      desc: '',
      args: [],
    );
  }

  /// `List entry`
  String get initiativeBonusListEntryPickerLabel {
    return Intl.message(
      'List entry',
      name: 'initiativeBonusListEntryPickerLabel',
      desc: '',
      args: [],
    );
  }

  /// `Field`
  String get initiativeBonusFieldPickerLabel {
    return Intl.message(
      'Field',
      name: 'initiativeBonusFieldPickerLabel',
      desc: '',
      args: [],
    );
  }

  /// `Incomplete selection`
  String get initiativeBonusIncompleteWarningTitle {
    return Intl.message(
      'Incomplete selection',
      name: 'initiativeBonusIncompleteWarningTitle',
      desc: '',
      args: [],
    );
  }

  /// `Your initiative bonus selection is incomplete and will be cleared if you leave.`
  String get initiativeBonusIncompleteWarningBody {
    return Intl.message(
      'Your initiative bonus selection is incomplete and will be cleared if you leave.',
      name: 'initiativeBonusIncompleteWarningBody',
      desc: '',
      args: [],
    );
  }

  /// `Stay`
  String get initiativeBonusIncompleteStay {
    return Intl.message(
      'Stay',
      name: 'initiativeBonusIncompleteStay',
      desc: '',
      args: [],
    );
  }

  /// `Leave anyway`
  String get initiativeBonusIncompleteLeave {
    return Intl.message(
      'Leave anyway',
      name: 'initiativeBonusIncompleteLeave',
      desc: '',
      args: [],
    );
  }

  /// `Send`
  String get send {
    return Intl.message('Send', name: 'send', desc: '', args: []);
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

  /// `Title`
  String get documentTitleLabel {
    return Intl.message(
      'Title',
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
    return Intl.message('Craft', name: 'craft', desc: '', args: []);
  }

  /// `New`
  String get newItem {
    return Intl.message('New', name: 'newItem', desc: '', args: []);
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
    return Intl.message('Author:', name: 'authorLabel', desc: '', args: []);
  }

  /// `You`
  String get you {
    return Intl.message('You', name: 'you', desc: '', args: []);
  }

  /// `Game master`
  String get dm {
    return Intl.message('Game master', name: 'dm', desc: '', args: []);
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
    return Intl.message('Image', name: 'addImageBtnLabel', desc: '', args: []);
  }

  /// `New grouping:`
  String get newGroup {
    return Intl.message('New grouping:', name: 'newGroup', desc: '', args: []);
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
    return Intl.message('New tab', name: 'newTabBtnLabel', desc: '', args: []);
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
    return Intl.message('Default tab', name: 'defaultTab', desc: '', args: []);
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
    return Intl.message('Search', name: 'searchLabel', desc: '', args: []);
  }

  /// `Sort by name (A–Z)`
  String get itemSortByName {
    return Intl.message(
      'Sort by name (A–Z)',
      name: 'itemSortByName',
      desc: '',
      args: [],
    );
  }

  /// `Sort by value (low to high)`
  String get itemSortByValueAscending {
    return Intl.message(
      'Sort by value (low to high)',
      name: 'itemSortByValueAscending',
      desc: '',
      args: [],
    );
  }

  /// `Sort by value (high to low)`
  String get itemSortByValueDescending {
    return Intl.message(
      'Sort by value (high to low)',
      name: 'itemSortByValueDescending',
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

  /// `Not craftable`
  String get notCraftableRecipeFilter {
    return Intl.message(
      'Not craftable',
      name: 'notCraftableRecipeFilter',
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

  /// `All items in this category are craftable`
  String get noItemsInCategoryNotCraftable {
    return Intl.message(
      'All items in this category are craftable',
      name: 'noItemsInCategoryNotCraftable',
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

  /// `Notes`
  String get navBarHeaderLore {
    return Intl.message('Notes', name: 'navBarHeaderLore', desc: '', args: []);
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
    return Intl.message('Add balance', name: 'addBalance', desc: '', args: []);
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
    return Intl.message('New balance', name: 'newBalance', desc: '', args: []);
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

  /// `- Nothing selected -`
  String get nothingSelected {
    return Intl.message(
      '- Nothing selected -',
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
    return Intl.message('Level', name: 'level', desc: '', args: []);
  }

  /// `Count`
  String get count {
    return Intl.message('Count', name: 'count', desc: '', args: []);
  }

  /// `Add items`
  String get addItems {
    return Intl.message('Add items', name: 'addItems', desc: '', args: []);
  }

  /// `Choose your role`
  String get selectGameMode {
    return Intl.message(
      'Choose your role',
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

  /// `As game master`
  String get startAsDm {
    return Intl.message(
      'As game master',
      name: 'startAsDm',
      desc: '',
      args: [],
    );
  }

  /// `{count, plural, =0{You don't run a campaign yet.} one{You run 1 campaign.} other{You run {count} campaigns.}}`
  String youOwnXCampaigns(int count) {
    return Intl.plural(
      count,
      zero: 'You don\'t run a campaign yet.',
      one: 'You run 1 campaign.',
      other: 'You run $count campaigns.',
      name: 'youOwnXCampaigns',
      desc: '',
      args: [count],
    );
  }

  /// `As player`
  String get joinAsPlayer {
    return Intl.message('As player', name: 'joinAsPlayer', desc: '', args: []);
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

  /// `{count, plural, =0{You don't have a character yet.} one{You have 1 character.} other{You have {count} characters.}}`
  String youOwnXCharacters(int count) {
    return Intl.plural(
      count,
      zero: 'You don\'t have a character yet.',
      one: 'You have 1 character.',
      other: 'You have $count characters.',
      name: 'youOwnXCharacters',
      desc: '',
      args: [count],
    );
  }

  /// `Name`
  String get campaigneName {
    return Intl.message('Name', name: 'campaigneName', desc: '', args: []);
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

  /// `No fight is running`
  String get noFIghtStarted {
    return Intl.message(
      'No fight is running',
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
    return Intl.message('Name', name: 'characterName', desc: '', args: []);
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

  /// `Transform`
  String get tranformToAlternateForm {
    return Intl.message(
      'Transform',
      name: 'tranformToAlternateForm',
      desc: '',
      args: [],
    );
  }

  /// `Transform into alternate form`
  String get transformIntoAlternateForm {
    return Intl.message(
      'Transform into alternate form',
      name: 'transformIntoAlternateForm',
      desc: '',
      args: [],
    );
  }

  /// `Add transformation`
  String get addNewTransformationComponent {
    return Intl.message(
      'Add transformation',
      name: 'addNewTransformationComponent',
      desc: '',
      args: [],
    );
  }

  /// `Create new transformation`
  String get createNewTransformationTitle {
    return Intl.message(
      'Create new transformation',
      name: 'createNewTransformationTitle',
      desc: '',
      args: [],
    );
  }

  /// `Transformation name`
  String get transformationName {
    return Intl.message(
      'Transformation name',
      name: 'transformationName',
      desc: '',
      args: [],
    );
  }

  /// `Transformation description`
  String get transformationDescription {
    return Intl.message(
      'Transformation description',
      name: 'transformationDescription',
      desc: '',
      args: [],
    );
  }

  /// `Choose the properties this transformation changes. All others stay as they are.`
  String get createTransformationHelperText {
    return Intl.message(
      'Choose the properties this transformation changes. All others stay as they are.',
      name: 'createTransformationHelperText',
      desc: '',
      args: [],
    );
  }

  /// `Back`
  String get back {
    return Intl.message('Back', name: 'back', desc: '', args: []);
  }

  /// `Next`
  String get next {
    return Intl.message('Next', name: 'next', desc: '', args: []);
  }

  /// `Warning`
  String get warning {
    return Intl.message('Warning', name: 'warning', desc: '', args: []);
  }

  /// `You are editing a transformation. Changes only apply to this transformation and are lost when you change back. For lasting changes, change back and edit your base form.`
  String get youAreEditingAnAlternateFormWarningText {
    return Intl.message(
      'You are editing a transformation. Changes only apply to this transformation and are lost when you change back. For lasting changes, change back and edit your base form.',
      name: 'youAreEditingAnAlternateFormWarningText',
      desc: '',
      args: [],
    );
  }

  /// `Transformation is edited`
  String get transformationIsEditedWarningTitle {
    return Intl.message(
      'Transformation is edited',
      name: 'transformationIsEditedWarningTitle',
      desc: '',
      args: [],
    );
  }

  /// `Property is copied`
  String get propertyIsCopied {
    return Intl.message(
      'Property is copied',
      name: 'propertyIsCopied',
      desc: '',
      args: [],
    );
  }

  /// `You are editing a copied property. Changes will not affect the original property.`
  String get youAreEditingACopiedPropertyChangesWillNotAffect {
    return Intl.message(
      'You are editing a copied property. Changes will not affect the original property.',
      name: 'youAreEditingACopiedPropertyChangesWillNotAffect',
      desc: '',
      args: [],
    );
  }

  /// `Previous transformation`
  String get previousTransformationSelectionBtn {
    return Intl.message(
      'Previous transformation',
      name: 'previousTransformationSelectionBtn',
      desc: '',
      args: [],
    );
  }

  /// `New transformation`
  String get newTransformationSelectionBtn {
    return Intl.message(
      'New transformation',
      name: 'newTransformationSelectionBtn',
      desc: '',
      args: [],
    );
  }

  /// `Yes`
  String get yes {
    return Intl.message('Yes', name: 'yes', desc: '', args: []);
  }

  /// `No`
  String get no {
    return Intl.message('No', name: 'no', desc: '', args: []);
  }

  /// `You are disconnected. Either you or your game master is offline.`
  String get yourAreDisconnectedBody {
    return Intl.message(
      'You are disconnected. Either you or your game master is offline.',
      name: 'yourAreDisconnectedBody',
      desc: '',
      args: [],
    );
  }

  /// `Character name`
  String get characterNameStatTitle {
    return Intl.message(
      'Character name',
      name: 'characterNameStatTitle',
      desc: '',
      args: [],
    );
  }

  /// `What is the name of your character?`
  String get characterNameStatHelperText {
    return Intl.message(
      'What is the name of your character?',
      name: 'characterNameStatHelperText',
      desc: '',
      args: [],
    );
  }

  /// `Generate image`
  String get generateImageBtnLabel {
    return Intl.message(
      'Generate image',
      name: 'generateImageBtnLabel',
      desc: '',
      args: [],
    );
  }

  /// `Generate an image`
  String get generateLoreImageTitle {
    return Intl.message(
      'Generate an image',
      name: 'generateLoreImageTitle',
      desc: '',
      args: [],
    );
  }

  /// `Portrait description`
  String get characterPortraitImagePrompt {
    return Intl.message(
      'Portrait description',
      name: 'characterPortraitImagePrompt',
      desc: '',
      args: [],
    );
  }

  /// `Describe your character for image generation`
  String get characterPortraitImagePromptPlaceholder {
    return Intl.message(
      'Describe your character for image generation',
      name: 'characterPortraitImagePromptPlaceholder',
      desc: '',
      args: [],
    );
  }

  /// `Generated images`
  String get generatedImagesTabTitle {
    return Intl.message(
      'Generated images',
      name: 'generatedImagesTabTitle',
      desc: '',
      args: [],
    );
  }

  /// `You haven't generated any images in this campaign yet.`
  String get noImagesInCampagne {
    return Intl.message(
      'You haven\'t generated any images in this campaign yet.',
      name: 'noImagesInCampagne',
      desc: '',
      args: [],
    );
  }

  /// `Enter a name`
  String get enterANameDefaultLabel {
    return Intl.message(
      'Enter a name',
      name: 'enterANameDefaultLabel',
      desc: '',
      args: [],
    );
  }

  /// `Enter a description on the left.`
  String get enterSomeDescriptionOnTheLeft {
    return Intl.message(
      'Enter a description on the left.',
      name: 'enterSomeDescriptionOnTheLeft',
      desc: '',
      args: [],
    );
  }

  /// `Tab icons`
  String get tabIconsConfigurationTitle {
    return Intl.message(
      'Tab icons',
      name: 'tabIconsConfigurationTitle',
      desc: '',
      args: [],
    );
  }

  /// `On iPad or iPhone, live updates work best while this app is open in the foreground.`
  String get realtimeSessionIosHint {
    return Intl.message(
      'On iPad or iPhone, live updates work best while this app is open in the foreground.',
      name: 'realtimeSessionIosHint',
      desc: '',
      args: [],
    );
  }

  /// `Some changes are still syncing to the session…`
  String get pendingHubSyncBanner {
    return Intl.message(
      'Some changes are still syncing to the session…',
      name: 'pendingHubSyncBanner',
      desc: '',
      args: [],
    );
  }

  /// `Character not saved`
  String get characterConfigSaveFailedTitle {
    return Intl.message(
      'Character not saved',
      name: 'characterConfigSaveFailedTitle',
      desc: '',
      args: [],
    );
  }

  /// `Your character changes could not be saved. Check your connection and try again.`
  String get characterConfigSaveFailedBody {
    return Intl.message(
      'Your character changes could not be saved. Check your connection and try again.',
      name: 'characterConfigSaveFailedBody',
      desc: '',
      args: [],
    );
  }

  /// `Sign out`
  String get logout {
    return Intl.message('Sign out', name: 'logout', desc: '', args: []);
  }

  /// `Your session has expired. Please sign in again.`
  String get sessionExpiredMessage {
    return Intl.message(
      'Your session has expired. Please sign in again.',
      name: 'sessionExpiredMessage',
      desc: '',
      args: [],
    );
  }

  /// `Classic Light`
  String get characterSheetSkinClassicLight {
    return Intl.message(
      'Classic Light',
      name: 'characterSheetSkinClassicLight',
      desc: '',
      args: [],
    );
  }

  /// `Classic Dark`
  String get characterSheetSkinClassicDark {
    return Intl.message(
      'Classic Dark',
      name: 'characterSheetSkinClassicDark',
      desc: '',
      args: [],
    );
  }

  /// `Arcane Ledger`
  String get characterSheetSkinArcaneLedger {
    return Intl.message(
      'Arcane Ledger',
      name: 'characterSheetSkinArcaneLedger',
      desc: '',
      args: [],
    );
  }

  /// `Night Cartographer`
  String get characterSheetSkinNightCartographer {
    return Intl.message(
      'Night Cartographer',
      name: 'characterSheetSkinNightCartographer',
      desc: '',
      args: [],
    );
  }

  /// `Use campaign default`
  String get characterSheetSkinUseCampaignDefault {
    return Intl.message(
      'Use campaign default',
      name: 'characterSheetSkinUseCampaignDefault',
      desc: '',
      args: [],
    );
  }

  /// `Campaign default`
  String get characterSheetSkinCampaignDefaultLabel {
    return Intl.message(
      'Campaign default',
      name: 'characterSheetSkinCampaignDefaultLabel',
      desc: '',
      args: [],
    );
  }

  /// `Appearance`
  String get characterSheetAppearanceTitle {
    return Intl.message(
      'Appearance',
      name: 'characterSheetAppearanceTitle',
      desc: '',
      args: [],
    );
  }

  /// `API Keys`
  String get apiKeysTitle {
    return Intl.message('API Keys', name: 'apiKeysTitle', desc: '', args: []);
  }

  /// `API documentation`
  String get apiKeysDocsTitle {
    return Intl.message(
      'API documentation',
      name: 'apiKeysDocsTitle',
      desc: '',
      args: [],
    );
  }

  /// `API keys let another app, such as a companion app someone in your group built, act for you as a player. Each key can only do what you allow it.`
  String get apiKeysDocsDescription {
    return Intl.message(
      'API keys let another app, such as a companion app someone in your group built, act for you as a player. Each key can only do what you allow it.',
      name: 'apiKeysDocsDescription',
      desc: '',
      args: [],
    );
  }

  /// `View API documentation`
  String get apiKeysViewDocs {
    return Intl.message(
      'View API documentation',
      name: 'apiKeysViewDocs',
      desc: '',
      args: [],
    );
  }

  /// `Generate new API key`
  String get apiKeysGenerate {
    return Intl.message(
      'Generate new API key',
      name: 'apiKeysGenerate',
      desc: '',
      args: [],
    );
  }

  /// `No API keys yet.`
  String get apiKeysEmpty {
    return Intl.message(
      'No API keys yet.',
      name: 'apiKeysEmpty',
      desc: '',
      args: [],
    );
  }

  /// `Could not load your API keys.`
  String get apiKeysLoadFailed {
    return Intl.message(
      'Could not load your API keys.',
      name: 'apiKeysLoadFailed',
      desc: '',
      args: [],
    );
  }

  /// `Unnamed key`
  String get apiKeyUnnamed {
    return Intl.message(
      'Unnamed key',
      name: 'apiKeyUnnamed',
      desc: '',
      args: [],
    );
  }

  /// `Revoked`
  String get apiKeyRevoked {
    return Intl.message('Revoked', name: 'apiKeyRevoked', desc: '', args: []);
  }

  /// `Expired`
  String get apiKeyExpired {
    return Intl.message('Expired', name: 'apiKeyExpired', desc: '', args: []);
  }

  /// `Prefix: {prefix}`
  String apiKeyPrefix(String prefix) {
    return Intl.message(
      'Prefix: $prefix',
      name: 'apiKeyPrefix',
      desc: '',
      args: [prefix],
    );
  }

  /// `Revoked: {date}`
  String apiKeyRevokedAt(String date) {
    return Intl.message(
      'Revoked: $date',
      name: 'apiKeyRevokedAt',
      desc: '',
      args: [date],
    );
  }

  /// `Last used: {date}`
  String apiKeyLastUsedAt(String date) {
    return Intl.message(
      'Last used: $date',
      name: 'apiKeyLastUsedAt',
      desc: '',
      args: [date],
    );
  }

  /// `Never used`
  String get apiKeyNeverUsed {
    return Intl.message(
      'Never used',
      name: 'apiKeyNeverUsed',
      desc: '',
      args: [],
    );
  }

  /// `Expires: {date}`
  String apiKeyExpiresAt(String date) {
    return Intl.message(
      'Expires: $date',
      name: 'apiKeyExpiresAt',
      desc: '',
      args: [date],
    );
  }

  /// `Never expires`
  String get apiKeyNeverExpires {
    return Intl.message(
      'Never expires',
      name: 'apiKeyNeverExpires',
      desc: '',
      args: [],
    );
  }

  /// `Revoke API key?`
  String get apiKeyRevokeTitle {
    return Intl.message(
      'Revoke API key?',
      name: 'apiKeyRevokeTitle',
      desc: '',
      args: [],
    );
  }

  /// `This cannot be undone. Any app using this key loses access immediately.`
  String get apiKeyRevokeBody {
    return Intl.message(
      'This cannot be undone. Any app using this key loses access immediately.',
      name: 'apiKeyRevokeBody',
      desc: '',
      args: [],
    );
  }

  /// `Revoke`
  String get apiKeyRevokeConfirm {
    return Intl.message(
      'Revoke',
      name: 'apiKeyRevokeConfirm',
      desc: '',
      args: [],
    );
  }

  /// `Could not revoke the API key.`
  String get apiKeyRevokeFailed {
    return Intl.message(
      'Could not revoke the API key.',
      name: 'apiKeyRevokeFailed',
      desc: '',
      args: [],
    );
  }

  /// `New API key`
  String get apiKeyCreateTitle {
    return Intl.message(
      'New API key',
      name: 'apiKeyCreateTitle',
      desc: '',
      args: [],
    );
  }

  /// `Only give a key to apps you trust. They act as you.`
  String get apiKeyCreateHint {
    return Intl.message(
      'Only give a key to apps you trust. They act as you.',
      name: 'apiKeyCreateHint',
      desc: '',
      args: [],
    );
  }

  /// `Name, e.g. the app that uses it`
  String get apiKeyNameLabel {
    return Intl.message(
      'Name, e.g. the app that uses it',
      name: 'apiKeyNameLabel',
      desc: '',
      args: [],
    );
  }

  /// `Permissions`
  String get apiKeyPermissionsLabel {
    return Intl.message(
      'Permissions',
      name: 'apiKeyPermissionsLabel',
      desc: '',
      args: [],
    );
  }

  /// `Read only`
  String get apiKeyPresetReadOnly {
    return Intl.message(
      'Read only',
      name: 'apiKeyPresetReadOnly',
      desc: '',
      args: [],
    );
  }

  /// `Player companion app`
  String get apiKeyPresetCompanion {
    return Intl.message(
      'Player companion app',
      name: 'apiKeyPresetCompanion',
      desc: '',
      args: [],
    );
  }

  /// `Custom`
  String get apiKeyPresetCustom {
    return Intl.message(
      'Custom',
      name: 'apiKeyPresetCustom',
      desc: '',
      args: [],
    );
  }

  /// `See your campaigns and fellow players`
  String get apiKeyScopeCampaignsRead {
    return Intl.message(
      'See your campaigns and fellow players',
      name: 'apiKeyScopeCampaignsRead',
      desc: '',
      args: [],
    );
  }

  /// `Read your character sheets`
  String get apiKeyScopeCharactersRead {
    return Intl.message(
      'Read your character sheets',
      name: 'apiKeyScopeCharactersRead',
      desc: '',
      args: [],
    );
  }

  /// `Change your character sheets, e.g. hit points`
  String get apiKeyScopeCharactersWrite {
    return Intl.message(
      'Change your character sheets, e.g. hit points',
      name: 'apiKeyScopeCharactersWrite',
      desc: '',
      args: [],
    );
  }

  /// `Read the notes you can see`
  String get apiKeyScopeNotesRead {
    return Intl.message(
      'Read the notes you can see',
      name: 'apiKeyScopeNotesRead',
      desc: '',
      args: [],
    );
  }

  /// `Write your own notes and choose who sees them`
  String get apiKeyScopeNotesWrite {
    return Intl.message(
      'Write your own notes and choose who sees them',
      name: 'apiKeyScopeNotesWrite',
      desc: '',
      args: [],
    );
  }

  /// `Roll initiative when the game master starts a fight`
  String get apiKeyScopeFightsPlay {
    return Intl.message(
      'Roll initiative when the game master starts a fight',
      name: 'apiKeyScopeFightsPlay',
      desc: '',
      args: [],
    );
  }

  /// `Receive live updates`
  String get apiKeyScopeEvents {
    return Intl.message(
      'Receive live updates',
      name: 'apiKeyScopeEvents',
      desc: '',
      args: [],
    );
  }

  /// `Valid for`
  String get apiKeyExpiryLabel {
    return Intl.message(
      'Valid for',
      name: 'apiKeyExpiryLabel',
      desc: '',
      args: [],
    );
  }

  /// `This server gives every key read access to your campaigns, characters and notes. You can choose permissions and a lifetime once the server is updated.`
  String get apiKeyPermissionsNeedServerUpdate {
    return Intl.message(
      'This server gives every key read access to your campaigns, characters and notes. You can choose permissions and a lifetime once the server is updated.',
      name: 'apiKeyPermissionsNeedServerUpdate',
      desc: '',
      args: [],
    );
  }

  /// `Unlimited`
  String get apiKeyExpiryNever {
    return Intl.message(
      'Unlimited',
      name: 'apiKeyExpiryNever',
      desc: '',
      args: [],
    );
  }

  /// `30 days`
  String get apiKeyExpiry30Days {
    return Intl.message(
      '30 days',
      name: 'apiKeyExpiry30Days',
      desc: '',
      args: [],
    );
  }

  /// `90 days`
  String get apiKeyExpiry90Days {
    return Intl.message(
      '90 days',
      name: 'apiKeyExpiry90Days',
      desc: '',
      args: [],
    );
  }

  /// `1 year`
  String get apiKeyExpiry1Year {
    return Intl.message(
      '1 year',
      name: 'apiKeyExpiry1Year',
      desc: '',
      args: [],
    );
  }

  /// `Generate`
  String get apiKeyCreateConfirm {
    return Intl.message(
      'Generate',
      name: 'apiKeyCreateConfirm',
      desc: '',
      args: [],
    );
  }

  /// `Enter a name.`
  String get apiKeyNameRequired {
    return Intl.message(
      'Enter a name.',
      name: 'apiKeyNameRequired',
      desc: '',
      args: [],
    );
  }

  /// `Choose at least one permission.`
  String get apiKeyNoScopeSelected {
    return Intl.message(
      'Choose at least one permission.',
      name: 'apiKeyNoScopeSelected',
      desc: '',
      args: [],
    );
  }

  /// `Could not create the API key.`
  String get apiKeyCreateFailed {
    return Intl.message(
      'Could not create the API key.',
      name: 'apiKeyCreateFailed',
      desc: '',
      args: [],
    );
  }

  /// `API key created`
  String get apiKeyCreatedTitle {
    return Intl.message(
      'API key created',
      name: 'apiKeyCreatedTitle',
      desc: '',
      args: [],
    );
  }

  /// `Copy your new key now. You won't see it again.`
  String get apiKeyCreatedBody {
    return Intl.message(
      'Copy your new key now. You won\'t see it again.',
      name: 'apiKeyCreatedBody',
      desc: '',
      args: [],
    );
  }

  /// `Copy`
  String get apiKeyCopy {
    return Intl.message('Copy', name: 'apiKeyCopy', desc: '', args: []);
  }

  /// `Copied to clipboard`
  String get apiKeyCopied {
    return Intl.message(
      'Copied to clipboard',
      name: 'apiKeyCopied',
      desc: '',
      args: [],
    );
  }

  /// `Done`
  String get apiKeyDone {
    return Intl.message('Done', name: 'apiKeyDone', desc: '', args: []);
  }

  /// `End fight`
  String get endFight {
    return Intl.message('End fight', name: 'endFight', desc: '', args: []);
  }

  /// `End the fight? Whoever has not rolled yet will not be asked any more.`
  String get endFightConfirmation {
    return Intl.message(
      'End the fight? Whoever has not rolled yet will not be asked any more.',
      name: 'endFightConfirmation',
      desc: '',
      args: [],
    );
  }

  /// `Waiting for initiative`
  String get waitingForInitiative {
    return Intl.message(
      'Waiting for initiative',
      name: 'waitingForInitiative',
      desc: '',
      args: [],
    );
  }

  /// `not at the table`
  String get notAtTheTable {
    return Intl.message(
      'not at the table',
      name: 'notAtTheTable',
      desc: '',
      args: [],
    );
  }

  /// `No characters in this campaign yet`
  String get noCharactersInCampagne {
    return Intl.message(
      'No characters in this campaign yet',
      name: 'noCharactersInCampagne',
      desc: '',
      args: [],
    );
  }

  /// `Customize cards`
  String get customizeCards {
    return Intl.message(
      'Customize cards',
      name: 'customizeCards',
      desc: '',
      args: [],
    );
  }

  /// `Hidden`
  String get hiddenCards {
    return Intl.message('Hidden', name: 'hiddenCards', desc: '', args: []);
  }

  /// `All cards are hidden`
  String get allCardsHidden {
    return Intl.message(
      'All cards are hidden',
      name: 'allCardsHidden',
      desc: '',
      args: [],
    );
  }

  /// `Visible cards`
  String get visibleCards {
    return Intl.message(
      'Visible cards',
      name: 'visibleCards',
      desc: '',
      args: [],
    );
  }

  /// `Hidden cards stay hidden on this device, even if a player was offline in between.`
  String get visibleCardsHint {
    return Intl.message(
      'Hidden cards stay hidden on this device, even if a player was offline in between.',
      name: 'visibleCardsHint',
      desc: '',
      args: [],
    );
  }

  /// `Properties on the cards`
  String get cardStatsSection {
    return Intl.message(
      'Properties on the cards',
      name: 'cardStatsSection',
      desc: '',
      args: [],
    );
  }

  /// `Choose properties yourself`
  String get chooseCardStatsYourself {
    return Intl.message(
      'Choose properties yourself',
      name: 'chooseCardStatsYourself',
      desc: '',
      args: [],
    );
  }

  /// `Automatic: the first value with a maximum as bar and the first numbers of the default tab.`
  String get automaticCardStatsHint {
    return Intl.message(
      'Automatic: the first value with a maximum as bar and the first numbers of the default tab.',
      name: 'automaticCardStatsHint',
      desc: '',
      args: [],
    );
  }

  /// `Bar`
  String get cardBar {
    return Intl.message('Bar', name: 'cardBar', desc: '', args: []);
  }

  /// `No bar`
  String get noBar {
    return Intl.message('No bar', name: 'noBar', desc: '', args: []);
  }

  /// `Numbers`
  String get cardNumbers {
    return Intl.message('Numbers', name: 'cardNumbers', desc: '', args: []);
  }

  /// `Companion`
  String get companion {
    return Intl.message('Companion', name: 'companion', desc: '', args: []);
  }

  /// `calc.`
  String get calculatedValueShort {
    return Intl.message(
      'calc.',
      name: 'calculatedValueShort',
      desc: '',
      args: [],
    );
  }

  /// `This campaign has no properties with numbers yet.`
  String get noCardStatsAvailable {
    return Intl.message(
      'This campaign has no properties with numbers yet.',
      name: 'noCardStatsAvailable',
      desc: '',
      args: [],
    );
  }

  /// `max.`
  String get maxValueShort {
    return Intl.message('max.', name: 'maxValueShort', desc: '', args: []);
  }

  /// `Compute the value`
  String get computedValue {
    return Intl.message(
      'Compute the value',
      name: 'computedValue',
      desc: '',
      args: [],
    );
  }

  /// `Players don't enter this value: it is computed from other properties, e.g. passive Perception = 10 + Mod(Wisdom) + proficiency bonus (if proficient). Modifiers round down.`
  String get computedValueHint {
    return Intl.message(
      'Players don\'t enter this value: it is computed from other properties, e.g. passive Perception = 10 + Mod(Wisdom) + proficiency bonus (if proficient). Modifiers round down.',
      name: 'computedValueHint',
      desc: '',
      args: [],
    );
  }

  /// `Start value`
  String get computedBase {
    return Intl.message(
      'Start value',
      name: 'computedBase',
      desc: '',
      args: [],
    );
  }

  /// `Building blocks`
  String get computedTerms {
    return Intl.message(
      'Building blocks',
      name: 'computedTerms',
      desc: '',
      args: [],
    );
  }

  /// `Add building block`
  String get addComputedTerm {
    return Intl.message(
      'Add building block',
      name: 'addComputedTerm',
      desc: '',
      args: [],
    );
  }

  /// `Value`
  String get computedSource {
    return Intl.message('Value', name: 'computedSource', desc: '', args: []);
  }

  /// `Conversion`
  String get computedMode {
    return Intl.message('Conversion', name: 'computedMode', desc: '', args: []);
  }

  /// `as is`
  String get computedModeValue {
    return Intl.message('as is', name: 'computedModeValue', desc: '', args: []);
  }

  /// `Modifier (x−10)/2`
  String get computedModeModifier {
    return Intl.message(
      'Modifier (x−10)/2',
      name: 'computedModeModifier',
      desc: '',
      args: [],
    );
  }

  /// `Factor`
  String get computedFactor {
    return Intl.message('Factor', name: 'computedFactor', desc: '', args: []);
  }

  /// `Counts only if picked`
  String get computedCondition {
    return Intl.message(
      'Counts only if picked',
      name: 'computedCondition',
      desc: '',
      args: [],
    );
  }

  /// `Always`
  String get computedAlways {
    return Intl.message('Always', name: 'computedAlways', desc: '', args: []);
  }

  /// `Formula`
  String get computedPreview {
    return Intl.message('Formula', name: 'computedPreview', desc: '', args: []);
  }

  /// `Add properties with numbers first.`
  String get computedValueNoSources {
    return Intl.message(
      'Add properties with numbers first.',
      name: 'computedValueNoSources',
      desc: '',
      args: [],
    );
  }

  /// `Mod({label})`
  String computedModifierOf(String label) {
    return Intl.message(
      'Mod($label)',
      name: 'computedModifierOf',
      desc: '',
      args: [label],
    );
  }

  /// `(if {condition})`
  String computedIfPicked(String condition) {
    return Intl.message(
      '(if $condition)',
      name: 'computedIfPicked',
      desc: '',
      args: [condition],
    );
  }

  /// `computed`
  String get computedValueBadge {
    return Intl.message(
      'computed',
      name: 'computedValueBadge',
      desc: '',
      args: [],
    );
  }

  /// `Template (Fantasy 5E)`
  String get computedPreset {
    return Intl.message(
      'Template (Fantasy 5E)',
      name: 'computedPreset',
      desc: '',
      args: [],
    );
  }

  /// `Passive Perception`
  String get computedPresetPassivePerception {
    return Intl.message(
      'Passive Perception',
      name: 'computedPresetPassivePerception',
      desc: '',
      args: [],
    );
  }

  /// `Passive Insight`
  String get computedPresetPassiveInsight {
    return Intl.message(
      'Passive Insight',
      name: 'computedPresetPassiveInsight',
      desc: '',
      args: [],
    );
  }

  /// `Passive Investigation`
  String get computedPresetPassiveInvestigation {
    return Intl.message(
      'Passive Investigation',
      name: 'computedPresetPassiveInvestigation',
      desc: '',
      args: [],
    );
  }

  /// `Passive Stealth`
  String get computedPresetPassiveStealth {
    return Intl.message(
      'Passive Stealth',
      name: 'computedPresetPassiveStealth',
      desc: '',
      args: [],
    );
  }

  /// `Initiative`
  String get computedPresetInitiative {
    return Intl.message(
      'Initiative',
      name: 'computedPresetInitiative',
      desc: '',
      args: [],
    );
  }

  /// `AC without armor`
  String get computedPresetUnarmoredArmorClass {
    return Intl.message(
      'AC without armor',
      name: 'computedPresetUnarmoredArmorClass',
      desc: '',
      args: [],
    );
  }

  /// `Not every value of the template exists in this campaign. Add the missing building blocks yourself.`
  String get computedPresetIncomplete {
    return Intl.message(
      'Not every value of the template exists in this campaign. Add the missing building blocks yourself.',
      name: 'computedPresetIncomplete',
      desc: '',
      args: [],
    );
  }

  /// `Add image`
  String get attachImageBtnLabel {
    return Intl.message(
      'Add image',
      name: 'attachImageBtnLabel',
      desc: '',
      args: [],
    );
  }

  /// `Replace image`
  String get replaceImageBtnLabel {
    return Intl.message(
      'Replace image',
      name: 'replaceImageBtnLabel',
      desc: '',
      args: [],
    );
  }

  /// `Remove image`
  String get removeImageBtnLabel {
    return Intl.message(
      'Remove image',
      name: 'removeImageBtnLabel',
      desc: '',
      args: [],
    );
  }

  /// `Upload image`
  String get uploadImageMenuLabel {
    return Intl.message(
      'Upload image',
      name: 'uploadImageMenuLabel',
      desc: '',
      args: [],
    );
  }

  /// `Insert paragraph here`
  String get insertParagraphMenuLabel {
    return Intl.message(
      'Insert paragraph here',
      name: 'insertParagraphMenuLabel',
      desc: '',
      args: [],
    );
  }

  /// `Connection lost – reconnecting…`
  String get connectionLostReconnecting {
    return Intl.message(
      'Connection lost – reconnecting…',
      name: 'connectionLostReconnecting',
      desc: '',
      args: [],
    );
  }

  /// `QuestKeeper`
  String get appName {
    return Intl.message('QuestKeeper', name: 'appName', desc: '', args: []);
  }

  /// `Your companion for pen & paper sessions at the table.`
  String get welcomeTagline {
    return Intl.message(
      'Your companion for pen & paper sessions at the table.',
      name: 'welcomeTagline',
      desc: '',
      args: [],
    );
  }

  /// `The game master runs the campaign. Players keep their character sheet, their notes and the live stats on their phone.`
  String get welcomeDescription {
    return Intl.message(
      'The game master runs the campaign. Players keep their character sheet, their notes and the live stats on their phone.',
      name: 'welcomeDescription',
      desc: '',
      args: [],
    );
  }

  /// `I run a game`
  String get welcomeLeadButton {
    return Intl.message(
      'I run a game',
      name: 'welcomeLeadButton',
      desc: '',
      args: [],
    );
  }

  /// `You create a campaign and invite your group.`
  String get welcomeLeadHint {
    return Intl.message(
      'You create a campaign and invite your group.',
      name: 'welcomeLeadHint',
      desc: '',
      args: [],
    );
  }

  /// `I'm joining a game`
  String get welcomeJoinButton {
    return Intl.message(
      'I\'m joining a game',
      name: 'welcomeJoinButton',
      desc: '',
      args: [],
    );
  }

  /// `After signing in, you enter the code from your game master.`
  String get welcomeJoinHint {
    return Intl.message(
      'After signing in, you enter the code from your game master.',
      name: 'welcomeJoinHint',
      desc: '',
      args: [],
    );
  }

  /// `Sign in or create an account. Then you set up your campaign.`
  String get loginIntroLead {
    return Intl.message(
      'Sign in or create an account. Then you set up your campaign.',
      name: 'loginIntroLead',
      desc: '',
      args: [],
    );
  }

  /// `Sign in or create an account. Then you enter the code from your game master.`
  String get loginIntroJoin {
    return Intl.message(
      'Sign in or create an account. Then you enter the code from your game master.',
      name: 'loginIntroJoin',
      desc: '',
      args: [],
    );
  }

  /// `Please enter your username and password.`
  String get loginMissingInput {
    return Intl.message(
      'Please enter your username and password.',
      name: 'loginMissingInput',
      desc: '',
      args: [],
    );
  }

  /// `Username or password is incorrect.`
  String get loginWrongCredentials {
    return Intl.message(
      'Username or password is incorrect.',
      name: 'loginWrongCredentials',
      desc: '',
      args: [],
    );
  }

  /// `Forgot password?`
  String get forgotPasswordLink {
    return Intl.message(
      'Forgot password?',
      name: 'forgotPasswordLink',
      desc: '',
      args: [],
    );
  }

  /// `3 to 13 characters, letters and digits only`
  String get usernameRuleHint {
    return Intl.message(
      '3 to 13 characters, letters and digits only',
      name: 'usernameRuleHint',
      desc: '',
      args: [],
    );
  }

  /// `Your password needs`
  String get passwordRulesTitle {
    return Intl.message(
      'Your password needs',
      name: 'passwordRulesTitle',
      desc: '',
      args: [],
    );
  }

  /// `at least {count} characters`
  String passwordRuleMinLength(int count) {
    return Intl.message(
      'at least $count characters',
      name: 'passwordRuleMinLength',
      desc: '',
      args: [count],
    );
  }

  /// `at most {count} characters`
  String passwordRuleMaxLength(int count) {
    return Intl.message(
      'at most $count characters',
      name: 'passwordRuleMaxLength',
      desc: '',
      args: [count],
    );
  }

  /// `met`
  String get passwordRuleMet {
    return Intl.message('met', name: 'passwordRuleMet', desc: '', args: []);
  }

  /// `not met yet`
  String get passwordRuleNotMet {
    return Intl.message(
      'not met yet',
      name: 'passwordRuleNotMet',
      desc: '',
      args: [],
    );
  }

  /// `The username needs 3 to 13 characters, letters and digits only.`
  String get registerUsernameInvalid {
    return Intl.message(
      'The username needs 3 to 13 characters, letters and digits only.',
      name: 'registerUsernameInvalid',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a valid email address.`
  String get registerEmailInvalid {
    return Intl.message(
      'Please enter a valid email address.',
      name: 'registerEmailInvalid',
      desc: '',
      args: [],
    );
  }

  /// `The password doesn't meet all the rules yet.`
  String get registerPasswordInvalid {
    return Intl.message(
      'The password doesn\'t meet all the rules yet.',
      name: 'registerPasswordInvalid',
      desc: '',
      args: [],
    );
  }

  /// `This username is already taken. Please pick another one.`
  String get registerUsernameTaken {
    return Intl.message(
      'This username is already taken. Please pick another one.',
      name: 'registerUsernameTaken',
      desc: '',
      args: [],
    );
  }

  /// `You can read how we handle your data in our {privacyPolicyLink}.`
  String registerPrivacyNotice(String privacyPolicyLink) {
    return Intl.message(
      'You can read how we handle your data in our $privacyPolicyLink.',
      name: 'registerPrivacyNotice',
      desc: '',
      args: [privacyPolicyLink],
    );
  }

  /// `privacy policy`
  String get privacyPolicyLinkLabel {
    return Intl.message(
      'privacy policy',
      name: 'privacyPolicyLinkLabel',
      desc: '',
      args: [],
    );
  }

  /// `We only use your email address for your account, for example to reset your password.`
  String get registerPrivacyNoticeWithoutLink {
    return Intl.message(
      'We only use your email address for your account, for example to reset your password.',
      name: 'registerPrivacyNoticeWithoutLink',
      desc: '',
      args: [],
    );
  }

  /// `Reset password`
  String get forgotPasswordTitle {
    return Intl.message(
      'Reset password',
      name: 'forgotPasswordTitle',
      desc: '',
      args: [],
    );
  }

  /// `Enter your username and the email address of your account. We'll send you a code.`
  String get forgotPasswordRequestIntro {
    return Intl.message(
      'Enter your username and the email address of your account. We\'ll send you a code.',
      name: 'forgotPasswordRequestIntro',
      desc: '',
      args: [],
    );
  }

  /// `Send code`
  String get forgotPasswordRequestButton {
    return Intl.message(
      'Send code',
      name: 'forgotPasswordRequestButton',
      desc: '',
      args: [],
    );
  }

  /// `We couldn't send a code. Check your username and email address. If you sign in with Apple, you don't need a password.`
  String get forgotPasswordRequestFailed {
    return Intl.message(
      'We couldn\'t send a code. Check your username and email address. If you sign in with Apple, you don\'t need a password.',
      name: 'forgotPasswordRequestFailed',
      desc: '',
      args: [],
    );
  }

  /// `We sent a code to {email}. It's valid for two hours.`
  String forgotPasswordCodeSent(String email) {
    return Intl.message(
      'We sent a code to $email. It\'s valid for two hours.',
      name: 'forgotPasswordCodeSent',
      desc: '',
      args: [email],
    );
  }

  /// `Code from the email`
  String get resetCodeLabel {
    return Intl.message(
      'Code from the email',
      name: 'resetCodeLabel',
      desc: '',
      args: [],
    );
  }

  /// `e.g. 123-456`
  String get resetCodeHint {
    return Intl.message(
      'e.g. 123-456',
      name: 'resetCodeHint',
      desc: '',
      args: [],
    );
  }

  /// `The code has six digits, e.g. 123-456.`
  String get resetCodeInvalid {
    return Intl.message(
      'The code has six digits, e.g. 123-456.',
      name: 'resetCodeInvalid',
      desc: '',
      args: [],
    );
  }

  /// `New password`
  String get newPasswordLabel {
    return Intl.message(
      'New password',
      name: 'newPasswordLabel',
      desc: '',
      args: [],
    );
  }

  /// `Save password`
  String get forgotPasswordSaveButton {
    return Intl.message(
      'Save password',
      name: 'forgotPasswordSaveButton',
      desc: '',
      args: [],
    );
  }

  /// `That didn't work: the code is wrong or has expired. Request a new one if needed.`
  String get forgotPasswordResetFailed {
    return Intl.message(
      'That didn\'t work: the code is wrong or has expired. Request a new one if needed.',
      name: 'forgotPasswordResetFailed',
      desc: '',
      args: [],
    );
  }

  /// `Request a new code`
  String get forgotPasswordRequestNewCode {
    return Intl.message(
      'Request a new code',
      name: 'forgotPasswordRequestNewCode',
      desc: '',
      args: [],
    );
  }

  /// `Your password has been changed. Sign in with your new password now.`
  String get forgotPasswordSuccess {
    return Intl.message(
      'Your password has been changed. Sign in with your new password now.',
      name: 'forgotPasswordSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Back to sign in`
  String get forgotPasswordBackToLogin {
    return Intl.message(
      'Back to sign in',
      name: 'forgotPasswordBackToLogin',
      desc: '',
      args: [],
    );
  }

  /// `The server can't be reached right now. Please try again in a moment.`
  String get authNoConnection {
    return Intl.message(
      'The server can\'t be reached right now. Please try again in a moment.',
      name: 'authNoConnection',
      desc: '',
      args: [],
    );
  }

  /// `Done`
  String get wizardFinishBtnLabel {
    return Intl.message(
      'Done',
      name: 'wizardFinishBtnLabel',
      desc: '',
      args: [],
    );
  }

  /// `Skip`
  String get wizardSkipBtnLabel {
    return Intl.message('Skip', name: 'wizardSkipBtnLabel', desc: '', args: []);
  }

  /// `Optional step`
  String get wizardOptionalStepLabel {
    return Intl.message(
      'Optional step',
      name: 'wizardOptionalStepLabel',
      desc: '',
      args: [],
    );
  }

  /// `Show explanation`
  String get wizardShowExplanation {
    return Intl.message(
      'Show explanation',
      name: 'wizardShowExplanation',
      desc: '',
      args: [],
    );
  }

  /// `Hide explanation`
  String get wizardHideExplanation {
    return Intl.message(
      'Hide explanation',
      name: 'wizardHideExplanation',
      desc: '',
      args: [],
    );
  }

  /// `Setup saved`
  String get wizardSavedSnackbar {
    return Intl.message(
      'Setup saved',
      name: 'wizardSavedSnackbar',
      desc: '',
      args: [],
    );
  }

  /// `Delete`
  String get confirmDeleteBtnLabel {
    return Intl.message(
      'Delete',
      name: 'confirmDeleteBtnLabel',
      desc: '',
      args: [],
    );
  }

  /// `Undo`
  String get wizardUndo {
    return Intl.message('Undo', name: 'wizardUndo', desc: '', args: []);
  }

  /// `## Welcome to QuestKeeper!\n\nIn the next steps you set up your campaign: appearance, name, character sheet, initiative and currency. Optional steps for items and crafting follow, which you can skip.\n\nEverything is saved automatically. Close the wizard at any time with the X in the top left; the gear icon in the top right brings you back here later.\n\n## Appearance\n\nPick the default look for character sheets in this campaign. Players can change it later for their own characters.`
  String get wizardSkinStepHelper {
    return Intl.message(
      '## Welcome to QuestKeeper!\n\nIn the next steps you set up your campaign: appearance, name, character sheet, initiative and currency. Optional steps for items and crafting follow, which you can skip.\n\nEverything is saved automatically. Close the wizard at any time with the X in the top left; the gear icon in the top right brings you back here later.\n\n## Appearance\n\nPick the default look for character sheets in this campaign. Players can change it later for their own characters.',
      name: 'wizardSkinStepHelper',
      desc: '',
      args: [],
    );
  }

  /// `## Campaign name\n\nWhat is your campaign called? You can change the name any time later.\n\nThe name needs at least four characters.`
  String get wizardCampaignNameStepHelper {
    return Intl.message(
      '## Campaign name\n\nWhat is your campaign called? You can change the name any time later.\n\nThe name needs at least four characters.',
      name: 'wizardCampaignNameStepHelper',
      desc: '',
      args: [],
    );
  }

  /// `Character sheet`
  String get wizardCharacterSheetStepTitle {
    return Intl.message(
      'Character sheet',
      name: 'wizardCharacterSheetStepTitle',
      desc: '',
      args: [],
    );
  }

  /// `Tab name`
  String get wizardTabNameLabel {
    return Intl.message(
      'Tab name',
      name: 'wizardTabNameLabel',
      desc: '',
      args: [],
    );
  }

  /// `Unnamed tab`
  String get wizardUnnamedTab {
    return Intl.message(
      'Unnamed tab',
      name: 'wizardUnnamedTab',
      desc: '',
      args: [],
    );
  }

  /// `Unnamed property`
  String get wizardUnnamedProperty {
    return Intl.message(
      'Unnamed property',
      name: 'wizardUnnamedProperty',
      desc: '',
      args: [],
    );
  }

  /// `Group {number}`
  String wizardGroupLabel(int number) {
    return Intl.message(
      'Group $number',
      name: 'wizardGroupLabel',
      desc: '',
      args: [number],
    );
  }

  /// `Delete tab?`
  String get wizardDeleteTabTitle {
    return Intl.message(
      'Delete tab?',
      name: 'wizardDeleteTabTitle',
      desc: '',
      args: [],
    );
  }

  /// `{count, plural, =0{Delete the empty tab “{tabName}”?} one{Delete tab “{tabName}” with one property? Character values will be lost.} other{Delete tab “{tabName}” with {count} properties? Character values will be lost.}}`
  String wizardDeleteTabMessage(int count, String tabName) {
    return Intl.plural(
      count,
      zero: 'Delete the empty tab “$tabName”?',
      one:
          'Delete tab “$tabName” with one property? Character values will be lost.',
      other:
          'Delete tab “$tabName” with $count properties? Character values will be lost.',
      name: 'wizardDeleteTabMessage',
      desc: '',
      args: [count, tabName],
    );
  }

  /// `Delete property?`
  String get wizardDeletePropertyTitle {
    return Intl.message(
      'Delete property?',
      name: 'wizardDeletePropertyTitle',
      desc: '',
      args: [],
    );
  }

  /// `{count, plural, one{Delete property “{name}”? One character already has a value for it, which will be lost.} other{Delete property “{name}”? {count} characters already have values for it, which will be lost.}}`
  String wizardDeletePropertyMessage(int count, String name) {
    return Intl.plural(
      count,
      one:
          'Delete property “$name”? One character already has a value for it, which will be lost.',
      other:
          'Delete property “$name”? $count characters already have values for it, which will be lost.',
      name: 'wizardDeletePropertyMessage',
      desc: '',
      args: [count, name],
    );
  }

  /// `Property “{name}” deleted`
  String wizardPropertyDeletedSnackbar(String name) {
    return Intl.message(
      'Property “$name” deleted',
      name: 'wizardPropertyDeletedSnackbar',
      desc: '',
      args: [name],
    );
  }

  /// `Currency`
  String get wizardCurrencyStepTitle {
    return Intl.message(
      'Currency',
      name: 'wizardCurrencyStepTitle',
      desc: '',
      args: [],
    );
  }

  /// `## Currency\n\nSet up which currencies exist in your world and how they convert.\n\nStart with the smallest unit (e.g. copper) and work your way up to the largest. For each further currency, enter how many of the previous one it is worth (in many fantasy RPGs: 10 copper = 1 silver).`
  String get wizardCurrencyStepHelper {
    return Intl.message(
      '## Currency\n\nSet up which currencies exist in your world and how they convert.\n\nStart with the smallest unit (e.g. copper) and work your way up to the largest. For each further currency, enter how many of the previous one it is worth (in many fantasy RPGs: 10 copper = 1 silver).',
      name: 'wizardCurrencyStepHelper',
      desc: '',
      args: [],
    );
  }

  /// `Name of the smallest currency:`
  String get wizardSmallestCurrencyLabel {
    return Intl.message(
      'Name of the smallest currency:',
      name: 'wizardSmallestCurrencyLabel',
      desc: '',
      args: [],
    );
  }

  /// `Name of the next larger currency:`
  String get wizardNextCurrencyLabel {
    return Intl.message(
      'Name of the next larger currency:',
      name: 'wizardNextCurrencyLabel',
      desc: '',
      args: [],
    );
  }

  /// `Worth how many of the previous currency:`
  String get wizardCurrencyMultipleLabel {
    return Intl.message(
      'Worth how many of the previous currency:',
      name: 'wizardCurrencyMultipleLabel',
      desc: '',
      args: [],
    );
  }

  /// `New`
  String get wizardNewEntryDefaultName {
    return Intl.message(
      'New',
      name: 'wizardNewEntryDefaultName',
      desc: '',
      args: [],
    );
  }

  /// `Places of finding`
  String get wizardLocationsStepTitle {
    return Intl.message(
      'Places of finding',
      name: 'wizardLocationsStepTitle',
      desc: '',
      args: [],
    );
  }

  /// `## Places of finding (optional)\n\nFrom here on it is about items and crafting. You only need this and the following steps (places of finding, item categories, items, recipes) if you play with them. **Skip** takes you straight to the summary; data you already entered stays.\n\nSome items can be found in certain places: on the beach, in caves, in grottos and so on. Add those places here so you can link them to items in the next steps.`
  String get wizardLocationsStepHelper {
    return Intl.message(
      '## Places of finding (optional)\n\nFrom here on it is about items and crafting. You only need this and the following steps (places of finding, item categories, items, recipes) if you play with them. **Skip** takes you straight to the summary; data you already entered stays.\n\nSome items can be found in certain places: on the beach, in caves, in grottos and so on. Add those places here so you can link them to items in the next steps.',
      name: 'wizardLocationsStepHelper',
      desc: '',
      args: [],
    );
  }

  /// `Place #{number}`
  String wizardLocationLabel(int number) {
    return Intl.message(
      'Place #$number',
      name: 'wizardLocationLabel',
      desc: '',
      args: [number],
    );
  }

  /// `{count, plural, =0{No items can be found here yet.} one{One item can be found here.} other{{count} items can be found here.}}`
  String wizardLocationItemCount(int count) {
    return Intl.plural(
      count,
      zero: 'No items can be found here yet.',
      one: 'One item can be found here.',
      other: '$count items can be found here.',
      name: 'wizardLocationItemCount',
      desc: '',
      args: [count],
    );
  }

  /// `Item categories`
  String get wizardItemCategoriesStepTitle {
    return Intl.message(
      'Item categories',
      name: 'wizardItemCategoriesStepTitle',
      desc: '',
      args: [],
    );
  }

  /// `## Item categories (optional)\n\nSo players can filter their items, we sort them into categories. We have prepared a set of categories and subcategories for you.\n\nFeel free to adjust them if they do not fit your game.`
  String get wizardItemCategoriesStepHelper {
    return Intl.message(
      '## Item categories (optional)\n\nSo players can filter their items, we sort them into categories. We have prepared a set of categories and subcategories for you.\n\nFeel free to adjust them if they do not fit your game.',
      name: 'wizardItemCategoriesStepHelper',
      desc: '',
      args: [],
    );
  }

  /// `Category name:`
  String get wizardCategoryNameLabel {
    return Intl.message(
      'Category name:',
      name: 'wizardCategoryNameLabel',
      desc: '',
      args: [],
    );
  }

  /// `Subcategory name:`
  String get wizardSubCategoryNameLabel {
    return Intl.message(
      'Subcategory name:',
      name: 'wizardSubCategoryNameLabel',
      desc: '',
      args: [],
    );
  }

  /// `{count, plural, =0{No items in this category yet.} one{One item in this category.} other{{count} items in this category.}}`
  String wizardCategoryItemCount(int count) {
    return Intl.plural(
      count,
      zero: 'No items in this category yet.',
      one: 'One item in this category.',
      other: '$count items in this category.',
      name: 'wizardCategoryItemCount',
      desc: '',
      args: [count],
    );
  }

  /// `New subcategory`
  String get wizardNewSubCategoryBtnLabel {
    return Intl.message(
      'New subcategory',
      name: 'wizardNewSubCategoryBtnLabel',
      desc: '',
      args: [],
    );
  }

  /// ` (for category {name})`
  String wizardIconForCategorySuffix(String name) {
    return Intl.message(
      ' (for category $name)',
      name: 'wizardIconForCategorySuffix',
      desc: '',
      args: [name],
    );
  }

  /// `Items`
  String get wizardItemsStepTitle {
    return Intl.message(
      'Items',
      name: 'wizardItemsStepTitle',
      desc: '',
      args: [],
    );
  }

  /// `## Items (optional)\n\nAdd the items of your world here: healing potions, weapons, quest items or ingredients for poisons, anything that can end up in the bags of your players.\n\nYou can also note what a potion does.\n\nTip: put effects, damage and the like at the start of the description. Then your players see the most important facts at a glance.`
  String get wizardItemsStepHelper {
    return Intl.message(
      '## Items (optional)\n\nAdd the items of your world here: healing potions, weapons, quest items or ingredients for poisons, anything that can end up in the bags of your players.\n\nYou can also note what a potion does.\n\nTip: put effects, damage and the like at the start of the description. Then your players see the most important facts at a glance.',
      name: 'wizardItemsStepHelper',
      desc: '',
      args: [],
    );
  }

  /// `Edit item`
  String get wizardEditItemTitle {
    return Intl.message(
      'Edit item',
      name: 'wizardEditItemTitle',
      desc: '',
      args: [],
    );
  }

  /// `Item name:`
  String get wizardItemNameLabel {
    return Intl.message(
      'Item name:',
      name: 'wizardItemNameLabel',
      desc: '',
      args: [],
    );
  }

  /// `Category`
  String get wizardItemCategoryLabel {
    return Intl.message(
      'Category',
      name: 'wizardItemCategoryLabel',
      desc: '',
      args: [],
    );
  }

  /// `Patch size (optional):`
  String get wizardItemPatchSizeLabel {
    return Intl.message(
      'Patch size (optional):',
      name: 'wizardItemPatchSizeLabel',
      desc: '',
      args: [],
    );
  }

  /// `Image description:`
  String get wizardItemImageDescriptionLabel {
    return Intl.message(
      'Image description:',
      name: 'wizardItemImageDescriptionLabel',
      desc: '',
      args: [],
    );
  }

  /// `Places of finding:`
  String get wizardItemPlacesOfFindingHeader {
    return Intl.message(
      'Places of finding:',
      name: 'wizardItemPlacesOfFindingHeader',
      desc: '',
      args: [],
    );
  }

  /// `New place`
  String get wizardNewLocationBtnLabel {
    return Intl.message(
      'New place',
      name: 'wizardNewLocationBtnLabel',
      desc: '',
      args: [],
    );
  }

  /// `New image`
  String get wizardNewImageBtnLabel {
    return Intl.message(
      'New image',
      name: 'wizardNewImageBtnLabel',
      desc: '',
      args: [],
    );
  }

  /// `Choose image`
  String get wizardPickImageBtnLabel {
    return Intl.message(
      'Choose image',
      name: 'wizardPickImageBtnLabel',
      desc: '',
      args: [],
    );
  }

  /// `This file is not a valid image.`
  String get wizardInvalidImageFile {
    return Intl.message(
      'This file is not a valid image.',
      name: 'wizardInvalidImageFile',
      desc: '',
      args: [],
    );
  }

  /// `Recipes`
  String get wizardRecipesStepTitle {
    return Intl.message(
      'Recipes',
      name: 'wizardRecipesStepTitle',
      desc: '',
      args: [],
    );
  }

  /// `## Recipes (optional)\n\nRecipes let your players craft things themselves, for example healing potions.\n\nSome recipes require a tool, such as a herbalism kit. You can note that in the recipe too; players then need the tool to use the recipe.\n\nTap a recipe to edit it. Press and hold it for more actions.`
  String get wizardRecipesStepHelper {
    return Intl.message(
      '## Recipes (optional)\n\nRecipes let your players craft things themselves, for example healing potions.\n\nSome recipes require a tool, such as a herbalism kit. You can note that in the recipe too; players then need the tool to use the recipe.\n\nTap a recipe to edit it. Press and hold it for more actions.',
      name: 'wizardRecipesStepHelper',
      desc: '',
      args: [],
    );
  }

  /// `Open details`
  String get wizardRecipeOpenDetails {
    return Intl.message(
      'Open details',
      name: 'wizardRecipeOpenDetails',
      desc: '',
      args: [],
    );
  }

  /// `Duplicate and open`
  String get wizardRecipeDuplicateAndOpen {
    return Intl.message(
      'Duplicate and open',
      name: 'wizardRecipeDuplicateAndOpen',
      desc: '',
      args: [],
    );
  }

  /// `Delete permanently`
  String get wizardRecipeDeletePermanently {
    return Intl.message(
      'Delete permanently',
      name: 'wizardRecipeDeletePermanently',
      desc: '',
      args: [],
    );
  }

  /// `Edit recipe`
  String get wizardEditRecipeTitle {
    return Intl.message(
      'Edit recipe',
      name: 'wizardEditRecipeTitle',
      desc: '',
      args: [],
    );
  }

  /// `Item to craft`
  String get wizardRecipeCreatedItemLabel {
    return Intl.message(
      'Item to craft',
      name: 'wizardRecipeCreatedItemLabel',
      desc: '',
      args: [],
    );
  }

  /// `Prerequisite #{number}`
  String wizardRecipeRequirementLabel(int number) {
    return Intl.message(
      'Prerequisite #$number',
      name: 'wizardRecipeRequirementLabel',
      desc: '',
      args: [number],
    );
  }

  /// `Add prerequisite`
  String get wizardRecipeAddRequirement {
    return Intl.message(
      'Add prerequisite',
      name: 'wizardRecipeAddRequirement',
      desc: '',
      args: [],
    );
  }

  /// `Ingredient #{number}`
  String wizardRecipeIngredientLabel(int number) {
    return Intl.message(
      'Ingredient #$number',
      name: 'wizardRecipeIngredientLabel',
      desc: '',
      args: [number],
    );
  }

  /// `Add ingredient`
  String get wizardRecipeAddIngredient {
    return Intl.message(
      'Add ingredient',
      name: 'wizardRecipeAddIngredient',
      desc: '',
      args: [],
    );
  }

  /// `Summary`
  String get wizardSummaryStepTitle {
    return Intl.message(
      'Summary',
      name: 'wizardSummaryStepTitle',
      desc: '',
      args: [],
    );
  }

  /// `## All set!\n\nYour campaign is set up and everything is saved. The overview shows what is set up.\n\nYou can change everything later via the gear icon in the top right.\n\n**Done** closes the wizard.`
  String get wizardSummaryStepHelper {
    return Intl.message(
      '## All set!\n\nYour campaign is set up and everything is saved. The overview shows what is set up.\n\nYou can change everything later via the gear icon in the top right.\n\n**Done** closes the wizard.',
      name: 'wizardSummaryStepHelper',
      desc: '',
      args: [],
    );
  }

  /// `Campaign`
  String get wizardSummaryCampaignLabel {
    return Intl.message(
      'Campaign',
      name: 'wizardSummaryCampaignLabel',
      desc: '',
      args: [],
    );
  }

  /// `Not set yet`
  String get wizardSummaryNotSet {
    return Intl.message(
      'Not set yet',
      name: 'wizardSummaryNotSet',
      desc: '',
      args: [],
    );
  }

  /// `{count, plural, one{1 tab} other{{count} tabs}}`
  String wizardSummaryTabCount(int count) {
    return Intl.plural(
      count,
      one: '1 tab',
      other: '$count tabs',
      name: 'wizardSummaryTabCount',
      desc: '',
      args: [count],
    );
  }

  /// `{count, plural, one{1 property} other{{count} properties}}`
  String wizardSummaryPropertyCount(int count) {
    return Intl.plural(
      count,
      one: '1 property',
      other: '$count properties',
      name: 'wizardSummaryPropertyCount',
      desc: '',
      args: [count],
    );
  }

  /// `{count, plural, =0{No items} one{1 item} other{{count} items}}`
  String wizardSummaryItemCount(int count) {
    return Intl.plural(
      count,
      zero: 'No items',
      one: '1 item',
      other: '$count items',
      name: 'wizardSummaryItemCount',
      desc: '',
      args: [count],
    );
  }

  /// `{count, plural, =0{No recipes} one{1 recipe} other{{count} recipes}}`
  String wizardSummaryRecipeCount(int count) {
    return Intl.plural(
      count,
      zero: 'No recipes',
      one: '1 recipe',
      other: '$count recipes',
      name: 'wizardSummaryRecipeCount',
      desc: '',
      args: [count],
    );
  }

  /// `Welcome to QuestKeeper`
  String get welcomeToQuestKeeper {
    return Intl.message(
      'Welcome to QuestKeeper',
      name: 'welcomeToQuestKeeper',
      desc: '',
      args: [],
    );
  }

  /// `QuestKeeper supports your tabletop group at the table. The game master sets up the campaign, everyone else keeps their character sheet in the app. Hit points, items and shared notes stay up to date for everyone, live.`
  String get questKeeperIntro {
    return Intl.message(
      'QuestKeeper supports your tabletop group at the table. The game master sets up the campaign, everyone else keeps their character sheet in the app. Hit points, items and shared notes stay up to date for everyone, live.',
      name: 'questKeeperIntro',
      desc: '',
      args: [],
    );
  }

  /// `I run a game`
  String get pathRunAGameTitle {
    return Intl.message(
      'I run a game',
      name: 'pathRunAGameTitle',
      desc: '',
      args: [],
    );
  }

  /// `Create a campaign and invite players`
  String get pathRunAGameSubtitle {
    return Intl.message(
      'Create a campaign and invite players',
      name: 'pathRunAGameSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `I join a game`
  String get pathJoinAGameTitle {
    return Intl.message(
      'I join a game',
      name: 'pathJoinAGameTitle',
      desc: '',
      args: [],
    );
  }

  /// `With the code from your game master`
  String get pathJoinAGameSubtitle {
    return Intl.message(
      'With the code from your game master',
      name: 'pathJoinAGameSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Join a campaign`
  String get joinCampagneAction {
    return Intl.message(
      'Join a campaign',
      name: 'joinCampagneAction',
      desc: '',
      args: [],
    );
  }

  /// `Create campaign`
  String get createCampagneAction {
    return Intl.message(
      'Create campaign',
      name: 'createCampagneAction',
      desc: '',
      args: [],
    );
  }

  /// `Create a campaign, set up the character sheet and invite your group with a code.`
  String get noCampagnesYetHint {
    return Intl.message(
      'Create a campaign, set up the character sheet and invite your group with a code.',
      name: 'noCampagnesYetHint',
      desc: '',
      args: [],
    );
  }

  /// `Join a campaign with the code from your game master. You create your character along the way.`
  String get noCharactersYetHint {
    return Intl.message(
      'Join a campaign with the code from your game master. You create your character along the way.',
      name: 'noCharactersYetHint',
      desc: '',
      args: [],
    );
  }

  /// `Settings changed: {date}`
  String campagneSettingsChangedAt(String date) {
    return Intl.message(
      'Settings changed: $date',
      name: 'campagneSettingsChangedAt',
      desc: '',
      args: [date],
    );
  }

  /// `{count, plural, one{1 open request} other{{count} open requests}}`
  String openJoinRequestsBadge(int count) {
    return Intl.plural(
      count,
      one: '1 open request',
      other: '$count open requests',
      name: 'openJoinRequestsBadge',
      desc: '',
      args: [count],
    );
  }

  /// `Last edited: {date}`
  String characterLastEditedAt(String date) {
    return Intl.message(
      'Last edited: $date',
      name: 'characterLastEditedAt',
      desc: '',
      args: [date],
    );
  }

  /// `Waiting for the game master to approve`
  String get waitingForDmApproval {
    return Intl.message(
      'Waiting for the game master to approve',
      name: 'waitingForDmApproval',
      desc: '',
      args: [],
    );
  }

  /// `Not in a campaign yet. Tap to join with a code.`
  String get characterNotInCampagneHint {
    return Intl.message(
      'Not in a campaign yet. Tap to join with a code.',
      name: 'characterNotInCampagneHint',
      desc: '',
      args: [],
    );
  }

  /// `Enter the join code you got from your game master and the name of your character. You fill in the rest of the character sheet once the game master has let you in.`
  String get joinCampagneNewCharacterIntro {
    return Intl.message(
      'Enter the join code you got from your game master and the name of your character. You fill in the rest of the character sheet once the game master has let you in.',
      name: 'joinCampagneNewCharacterIntro',
      desc: '',
      args: [],
    );
  }

  /// `Please enter the join code.`
  String get joinCodeEmptyError {
    return Intl.message(
      'Please enter the join code.',
      name: 'joinCodeEmptyError',
      desc: '',
      args: [],
    );
  }

  /// `The code has six digits, for example 123-456.`
  String get joinCodeIncompleteError {
    return Intl.message(
      'The code has six digits, for example 123-456.',
      name: 'joinCodeIncompleteError',
      desc: '',
      args: [],
    );
  }

  /// `This code does not exist. Check it with your game master.`
  String get joinCodeUnknownError {
    return Intl.message(
      'This code does not exist. Check it with your game master.',
      name: 'joinCodeUnknownError',
      desc: '',
      args: [],
    );
  }

  /// `Name of your character`
  String get characterNameFieldLabel {
    return Intl.message(
      'Name of your character',
      name: 'characterNameFieldLabel',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a name`
  String get nameRequiredError {
    return Intl.message(
      'Please enter a name',
      name: 'nameRequiredError',
      desc: '',
      args: [],
    );
  }

  /// `Join`
  String get joinAction {
    return Intl.message('Join', name: 'joinAction', desc: '', args: []);
  }

  /// `Request sent. As soon as your game master approves, you can play.`
  String get joinRequestSentConfirmation {
    return Intl.message(
      'Request sent. As soon as your game master approves, you can play.',
      name: 'joinRequestSentConfirmation',
      desc: '',
      args: [],
    );
  }

  /// `Your join request was accepted. You can play now.`
  String get joinRequestAcceptedMessage {
    return Intl.message(
      'Your join request was accepted. You can play now.',
      name: 'joinRequestAcceptedMessage',
      desc: '',
      args: [],
    );
  }

  /// `Your join request was declined.`
  String get joinRequestDeniedMessage {
    return Intl.message(
      'Your join request was declined.',
      name: 'joinRequestDeniedMessage',
      desc: '',
      args: [],
    );
  }

  /// `{playerName} ({username}) wants to join your campaign.`
  String joinRequestCreatedForDm(String playerName, String username) {
    return Intl.message(
      '$playerName ($username) wants to join your campaign.',
      name: 'joinRequestCreatedForDm',
      desc: '',
      args: [playerName, username],
    );
  }

  /// `Waiting for approval`
  String get waitingForApprovalTitle {
    return Intl.message(
      'Waiting for approval',
      name: 'waitingForApprovalTitle',
      desc: '',
      args: [],
    );
  }

  /// `Your request for “{characterName}” is with your game master. As soon as they approve, you can play here.`
  String waitingForApprovalText(String characterName) {
    return Intl.message(
      'Your request for “$characterName” is with your game master. As soon as they approve, you can play here.',
      name: 'waitingForApprovalText',
      desc: '',
      args: [characterName],
    );
  }

  /// `Enter code again`
  String get enterCodeAgainAction {
    return Intl.message(
      'Enter code again',
      name: 'enterCodeAgainAction',
      desc: '',
      args: [],
    );
  }

  /// `What should your campaign be called? Next you pick a template, and the assistant guides you through character sheet, currency and items.`
  String get newCampagneIntro {
    return Intl.message(
      'What should your campaign be called? Next you pick a template, and the assistant guides you through character sheet, currency and items.',
      name: 'newCampagneIntro',
      desc: '',
      args: [],
    );
  }

  /// `Create`
  String get createAction {
    return Intl.message('Create', name: 'createAction', desc: '', args: []);
  }

  /// `Invite players`
  String get invitePlayersAction {
    return Intl.message(
      'Invite players',
      name: 'invitePlayersAction',
      desc: '',
      args: [],
    );
  }

  /// `No players yet. Invite your group with “Invite players”.`
  String get noPlayersYetHint {
    return Intl.message(
      'No players yet. Invite your group with “Invite players”.',
      name: 'noPlayersYetHint',
      desc: '',
      args: [],
    );
  }

  /// `In QuestKeeper, tap “Join a campaign” and enter this code.`
  String get invitePlayersInstruction {
    return Intl.message(
      'In QuestKeeper, tap “Join a campaign” and enter this code.',
      name: 'invitePlayersInstruction',
      desc: '',
      args: [],
    );
  }

  /// `Requests then show up under “Join requests”. Tap ✓ to let someone in.`
  String get invitePlayersApprovalHint {
    return Intl.message(
      'Requests then show up under “Join requests”. Tap ✓ to let someone in.',
      name: 'invitePlayersApprovalHint',
      desc: '',
      args: [],
    );
  }

  /// `Copy code`
  String get copyCodeAction {
    return Intl.message(
      'Copy code',
      name: 'copyCodeAction',
      desc: '',
      args: [],
    );
  }

  /// `Copied`
  String get copiedConfirmation {
    return Intl.message(
      'Copied',
      name: 'copiedConfirmation',
      desc: '',
      args: [],
    );
  }

  /// `Share invitation`
  String get shareInviteAction {
    return Intl.message(
      'Share invitation',
      name: 'shareInviteAction',
      desc: '',
      args: [],
    );
  }

  /// `Play in my campaign “{campagneName}”! Open QuestKeeper, tap “Join a campaign” and enter this code: {code}`
  String inviteShareText(String campagneName, String code) {
    return Intl.message(
      'Play in my campaign “$campagneName”! Open QuestKeeper, tap “Join a campaign” and enter this code: $code',
      name: 'inviteShareText',
      desc: '',
      args: [campagneName, code],
    );
  }

  /// `Invitation to “{campagneName}”`
  String inviteShareSubject(String campagneName) {
    return Intl.message(
      'Invitation to “$campagneName”',
      name: 'inviteShareSubject',
      desc: '',
      args: [campagneName],
    );
  }

  /// `The QR code only contains the code.`
  String get qrCodeHint {
    return Intl.message(
      'The QR code only contains the code.',
      name: 'qrCodeHint',
      desc: '',
      args: [],
    );
  }

  /// `Close`
  String get closeAction {
    return Intl.message('Close', name: 'closeAction', desc: '', args: []);
  }

  /// `HTTP status:`
  String get errorDetailsStatusLabel {
    return Intl.message(
      'HTTP status:',
      name: 'errorDetailsStatusLabel',
      desc: '',
      args: [],
    );
  }

  /// `Server response:`
  String get errorDetailsServerLabel {
    return Intl.message(
      'Server response:',
      name: 'errorDetailsServerLabel',
      desc: '',
      args: [],
    );
  }

  /// `Description:`
  String get errorDetailsDescriptionLabel {
    return Intl.message(
      'Description:',
      name: 'errorDetailsDescriptionLabel',
      desc: '',
      args: [],
    );
  }

  /// `Could not reach the server. Check your internet connection and try again.`
  String get errorMessageNoConnection {
    return Intl.message(
      'Could not reach the server. Check your internet connection and try again.',
      name: 'errorMessageNoConnection',
      desc: '',
      args: [],
    );
  }

  /// `The server could not process the input. Check your entries and try again.`
  String get errorMessageBadRequest {
    return Intl.message(
      'The server could not process the input. Check your entries and try again.',
      name: 'errorMessageBadRequest',
      desc: '',
      args: [],
    );
  }

  /// `You are not allowed to do this. Sign in again if needed.`
  String get errorMessageUnauthorized {
    return Intl.message(
      'You are not allowed to do this. Sign in again if needed.',
      name: 'errorMessageUnauthorized',
      desc: '',
      args: [],
    );
  }

  /// `This item does not exist (anymore).`
  String get errorMessageNotFound {
    return Intl.message(
      'This item does not exist (anymore).',
      name: 'errorMessageNotFound',
      desc: '',
      args: [],
    );
  }

  /// `This was just changed somewhere else. Reload and try again.`
  String get errorMessageConflict {
    return Intl.message(
      'This was just changed somewhere else. Reload and try again.',
      name: 'errorMessageConflict',
      desc: '',
      args: [],
    );
  }

  /// `Something went wrong on the server. Please try again later.`
  String get errorMessageServer {
    return Intl.message(
      'Something went wrong on the server. Please try again later.',
      name: 'errorMessageServer',
      desc: '',
      args: [],
    );
  }

  /// `Something went wrong. Please try again.`
  String get errorMessageUnknown {
    return Intl.message(
      'Something went wrong. Please try again.',
      name: 'errorMessageUnknown',
      desc: '',
      args: [],
    );
  }

  /// `My notes`
  String get myNotesGroupName {
    return Intl.message(
      'My notes',
      name: 'myNotesGroupName',
      desc: '',
      args: [],
    );
  }

  /// `Campaign`
  String get pageTabShortCampaign {
    return Intl.message(
      'Campaign',
      name: 'pageTabShortCampaign',
      desc: '',
      args: [],
    );
  }

  /// `Characters`
  String get pageTabShortCharacters {
    return Intl.message(
      'Characters',
      name: 'pageTabShortCharacters',
      desc: '',
      args: [],
    );
  }

  /// `Combat`
  String get pageTabShortFight {
    return Intl.message(
      'Combat',
      name: 'pageTabShortFight',
      desc: '',
      args: [],
    );
  }

  /// `Items`
  String get pageTabShortItems {
    return Intl.message('Items', name: 'pageTabShortItems', desc: '', args: []);
  }

  /// `Notes`
  String get pageTabShortNotes {
    return Intl.message('Notes', name: 'pageTabShortNotes', desc: '', args: []);
  }

  /// `Images`
  String get pageTabShortImages {
    return Intl.message(
      'Images',
      name: 'pageTabShortImages',
      desc: '',
      args: [],
    );
  }

  /// `MMMM d, y, h:mm a`
  String get ledgerManuscriptDateFormat {
    return Intl.message(
      'MMMM d, y, h:mm a',
      name: 'ledgerManuscriptDateFormat',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a whole number, e.g. -1 or 3.`
  String get invalidWholeNumberInput {
    return Intl.message(
      'Please enter a whole number, e.g. -1 or 3.',
      name: 'invalidWholeNumberInput',
      desc: '',
      args: [],
    );
  }

  /// `The level must be a whole number of 0 or more, e.g. 3.`
  String get invalidLevelInput {
    return Intl.message(
      'The level must be a whole number of 0 or more, e.g. 3.',
      name: 'invalidLevelInput',
      desc: '',
      args: [],
    );
  }

  /// `Preview and layout`
  String get previewAndVariantTileTitle {
    return Intl.message(
      'Preview and layout',
      name: 'previewAndVariantTileTitle',
      desc: '',
      args: [],
    );
  }

  /// `Set up character`
  String get characterSetupTitle {
    return Intl.message(
      'Set up character',
      name: 'characterSetupTitle',
      desc: '',
      args: [],
    );
  }

  /// `Section {current} of {total}: {tabName}`
  String characterSetupProgress(Object current, Object total, Object tabName) {
    return Intl.message(
      'Section $current of $total: $tabName',
      name: 'characterSetupProgress',
      desc: '',
      args: [current, total, tabName],
    );
  }

  /// `Anything you leave empty now can be filled in later right on the character sheet.`
  String get characterSetupHint {
    return Intl.message(
      'Anything you leave empty now can be filled in later right on the character sheet.',
      name: 'characterSetupHint',
      desc: '',
      args: [],
    );
  }

  /// `Done`
  String get characterSetupFinish {
    return Intl.message(
      'Done',
      name: 'characterSetupFinish',
      desc: '',
      args: [],
    );
  }

  /// `Fill in later`
  String get fillInLater {
    return Intl.message(
      'Fill in later',
      name: 'fillInLater',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a name.`
  String get characterNameRequired {
    return Intl.message(
      'Please enter a name.',
      name: 'characterNameRequired',
      desc: '',
      args: [],
    );
  }

  /// `Please fix the marked fields.`
  String get fixMarkedFieldsHint {
    return Intl.message(
      'Please fix the marked fields.',
      name: 'fixMarkedFieldsHint',
      desc: '',
      args: [],
    );
  }

  /// `+ Add`
  String get moneyModeDeposit {
    return Intl.message('+ Add', name: 'moneyModeDeposit', desc: '', args: []);
  }

  /// `− Spend`
  String get moneyModeSpend {
    return Intl.message('− Spend', name: 'moneyModeSpend', desc: '', args: []);
  }

  /// `Alternate form`
  String get activeAlternateFormBannerTitle {
    return Intl.message(
      'Alternate form',
      name: 'activeAlternateFormBannerTitle',
      desc: '',
      args: [],
    );
  }

  /// `Still empty – tap to fill in`
  String get missingStatTapToFill {
    return Intl.message(
      'Still empty – tap to fill in',
      name: 'missingStatTapToFill',
      desc: '',
      args: [],
    );
  }

  /// `Unnamed property`
  String get missingStatUnnamed {
    return Intl.message(
      'Unnamed property',
      name: 'missingStatUnnamed',
      desc: '',
      args: [],
    );
  }

  /// `Settings`
  String get settingsTitle {
    return Intl.message('Settings', name: 'settingsTitle', desc: '', args: []);
  }

  /// `Manage your personal API keys`
  String get apiKeysSettingsSubtitle {
    return Intl.message(
      'Manage your personal API keys',
      name: 'apiKeysSettingsSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Text`
  String get noteBlockTextLabel {
    return Intl.message('Text', name: 'noteBlockTextLabel', desc: '', args: []);
  }

  /// `Describe the image you want to generate. The more detail you give, the better the image fits.`
  String get generateImageDescriptionHint {
    return Intl.message(
      'Describe the image you want to generate. The more detail you give, the better the image fits.',
      name: 'generateImageDescriptionHint',
      desc: '',
      args: [],
    );
  }

  /// `Image description`
  String get generateImagePromptLabel {
    return Intl.message(
      'Image description',
      name: 'generateImagePromptLabel',
      desc: '',
      args: [],
    );
  }

  /// `e.g. “A mystical forest with elves”`
  String get generateImagePromptExample {
    return Intl.message(
      'e.g. “A mystical forest with elves”',
      name: 'generateImagePromptExample',
      desc: '',
      args: [],
    );
  }

  /// `Reactivate previous transformation`
  String get reactivateTransformationTitle {
    return Intl.message(
      'Reactivate previous transformation',
      name: 'reactivateTransformationTitle',
      desc: '',
      args: [],
    );
  }

  /// `Do you want to resume your last transformation or take on a new form?`
  String get reactivateTransformationQuestion {
    return Intl.message(
      'Do you want to resume your last transformation or take on a new form?',
      name: 'reactivateTransformationQuestion',
      desc: '',
      args: [],
    );
  }

  /// `Old transformations will be deleted`
  String get newTransformationDeletesOldTitle {
    return Intl.message(
      'Old transformations will be deleted',
      name: 'newTransformationDeletesOldTitle',
      desc: '',
      args: [],
    );
  }

  /// `Creating a new transformation deletes all old ones.`
  String get newTransformationDeletesOldText {
    return Intl.message(
      'Creating a new transformation deletes all old ones.',
      name: 'newTransformationDeletesOldText',
      desc: '',
      args: [],
    );
  }

  /// `Choose transformation`
  String get selectTransformationTitle {
    return Intl.message(
      'Choose transformation',
      name: 'selectTransformationTitle',
      desc: '',
      args: [],
    );
  }

  /// `Choose the transformations your new form should be made of.`
  String get selectTransformationComponentsHint {
    return Intl.message(
      'Choose the transformations your new form should be made of.',
      name: 'selectTransformationComponentsHint',
      desc: '',
      args: [],
    );
  }

  /// `There are no transformations yet. Set them up in your character settings first.`
  String get noTransformationComponentsHint {
    return Intl.message(
      'There are no transformations yet. Set them up in your character settings first.',
      name: 'noTransformationComponentsHint',
      desc: '',
      args: [],
    );
  }

  /// `Settings for {statName}`
  String transformationStatSettingsFor(String statName) {
    return Intl.message(
      'Settings for $statName',
      name: 'transformationStatSettingsFor',
      desc: '',
      args: [statName],
    );
  }

  /// `Enter a whole number`
  String get invalidWholeNumberShort {
    return Intl.message(
      'Enter a whole number',
      name: 'invalidWholeNumberShort',
      desc: '',
      args: [],
    );
  }

  /// `Enter 0 or more`
  String get invalidNonNegativeNumberShort {
    return Intl.message(
      'Enter 0 or more',
      name: 'invalidNonNegativeNumberShort',
      desc: '',
      args: [],
    );
  }

  /// `Enter 1 or more`
  String get invalidPositiveNumberShort {
    return Intl.message(
      'Enter 1 or more',
      name: 'invalidPositiveNumberShort',
      desc: '',
      args: [],
    );
  }

  /// `Enter a whole number greater than 1, e.g. 10.`
  String get invalidCurrencyMultiple {
    return Intl.message(
      'Enter a whole number greater than 1, e.g. 10.',
      name: 'invalidCurrencyMultiple',
      desc: '',
      args: [],
    );
  }

  /// `About & licenses`
  String get aboutLicensesTitle {
    return Intl.message(
      'About & licenses',
      name: 'aboutLicensesTitle',
      desc: '',
      args: [],
    );
  }

  /// `Rules material: SRD 5.2.1`
  String get aboutLicensesSrdTitle {
    return Intl.message(
      'Rules material: SRD 5.2.1',
      name: 'aboutLicensesSrdTitle',
      desc: '',
      args: [],
    );
  }

  /// `The “Fantasy 5E (SRD)” template contains material from the System Reference Document 5.2.1. It is licensed under the Creative Commons Attribution 4.0 International License (CC BY 4.0).`
  String get aboutLicensesSrdIntro {
    return Intl.message(
      'The “Fantasy 5E (SRD)” template contains material from the System Reference Document 5.2.1. It is licensed under the Creative Commons Attribution 4.0 International License (CC BY 4.0).',
      name: 'aboutLicensesSrdIntro',
      desc: '',
      args: [],
    );
  }

  /// `Attribution (English original)`
  String get aboutLicensesAttributionEnglish {
    return Intl.message(
      'Attribution (English original)',
      name: 'aboutLicensesAttributionEnglish',
      desc: '',
      args: [],
    );
  }

  /// `Attribution (German edition)`
  String get aboutLicensesAttributionGerman {
    return Intl.message(
      'Attribution (German edition)',
      name: 'aboutLicensesAttributionGerman',
      desc: '',
      args: [],
    );
  }

  /// `The German text is for information only. The English version is authoritative.`
  String get aboutLicensesAuthoritativeHint {
    return Intl.message(
      'The German text is for information only. The English version is authoritative.',
      name: 'aboutLicensesAuthoritativeHint',
      desc: '',
      args: [],
    );
  }

  /// `Changes: material from the SRD 5.2.1 was selected, translated or taken from the German edition, abridged and adapted for QuestKeeper. Summaries and other template texts are our own.`
  String get aboutLicensesChanges {
    return Intl.message(
      'Changes: material from the SRD 5.2.1 was selected, translated or taken from the German edition, abridged and adapted for QuestKeeper. Summaries and other template texts are our own.',
      name: 'aboutLicensesChanges',
      desc: '',
      args: [],
    );
  }

  /// `Open license CC BY 4.0`
  String get aboutLicensesOpenLicense {
    return Intl.message(
      'Open license CC BY 4.0',
      name: 'aboutLicensesOpenLicense',
      desc: '',
      args: [],
    );
  }

  /// `QuestKeeper is an independent product. It is not published or endorsed by any roleplaying game publisher.`
  String get aboutLicensesNotAffiliated {
    return Intl.message(
      'QuestKeeper is an independent product. It is not published or endorsed by any roleplaying game publisher.',
      name: 'aboutLicensesNotAffiliated',
      desc: '',
      args: [],
    );
  }

  /// `Open source licenses`
  String get aboutLicensesOpenSourceTitle {
    return Intl.message(
      'Open source licenses',
      name: 'aboutLicensesOpenSourceTitle',
      desc: '',
      args: [],
    );
  }

  /// `Show all licenses`
  String get aboutLicensesShowOpenSource {
    return Intl.message(
      'Show all licenses',
      name: 'aboutLicensesShowOpenSource',
      desc: '',
      args: [],
    );
  }

  /// `Rules material, licenses and open source notices`
  String get aboutLicensesSettingsSubtitle {
    return Intl.message(
      'Rules material, licenses and open source notices',
      name: 'aboutLicensesSettingsSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Checkbox track`
  String get statTypeCheckboxTrack {
    return Intl.message(
      'Checkbox track',
      name: 'statTypeCheckboxTrack',
      desc: '',
      args: [],
    );
  }

  /// `A row of boxes players tick with one tap on the sheet, e.g. stress.`
  String get statTypeCheckboxTrackHelp {
    return Intl.message(
      'A row of boxes players tick with one tap on the sheet, e.g. stress.',
      name: 'statTypeCheckboxTrackHelp',
      desc: '',
      args: [],
    );
  }

  /// `Text list`
  String get statTypeTextList {
    return Intl.message(
      'Text list',
      name: 'statTypeTextList',
      desc: '',
      args: [],
    );
  }

  /// `Several text entries, optionally with fixed, labelled slots, e.g. aspects or consequences.`
  String get statTypeTextListHelp {
    return Intl.message(
      'Several text entries, optionally with fixed, labelled slots, e.g. aspects or consequences.',
      name: 'statTypeTextListHelp',
      desc: '',
      args: [],
    );
  }

  /// `Choice (one)`
  String get statTypeSingleSelect {
    return Intl.message(
      'Choice (one)',
      name: 'statTypeSingleSelect',
      desc: '',
      args: [],
    );
  }

  /// `Players pick exactly one of the options, e.g. background or alignment.`
  String get statTypeSingleSelectHelp {
    return Intl.message(
      'Players pick exactly one of the options, e.g. background or alignment.',
      name: 'statTypeSingleSelectHelp',
      desc: '',
      args: [],
    );
  }

  /// `Unknown type`
  String get statTypeUnsupported {
    return Intl.message(
      'Unknown type',
      name: 'statTypeUnsupported',
      desc: '',
      args: [],
    );
  }

  /// `Not supported by this version. Please update the app.`
  String get statTypeUnsupportedHint {
    return Intl.message(
      'Not supported by this version. Please update the app.',
      name: 'statTypeUnsupportedHint',
      desc: '',
      args: [],
    );
  }

  /// `Boxes`
  String get checkboxTrackBoxesHeadline {
    return Intl.message(
      'Boxes',
      name: 'checkboxTrackBoxesHeadline',
      desc: '',
      args: [],
    );
  }

  /// `Count`
  String get checkboxTrackBoxCountLabel {
    return Intl.message(
      'Count',
      name: 'checkboxTrackBoxCountLabel',
      desc: '',
      args: [],
    );
  }

  /// `Labels are optional, e.g. “1”, “2”, “3” or “Mild”.`
  String get checkboxTrackLabelsHint {
    return Intl.message(
      'Labels are optional, e.g. “1”, “2”, “3” or “Mild”.',
      name: 'checkboxTrackLabelsHint',
      desc: '',
      args: [],
    );
  }

  /// `Box {number}`
  String checkboxTrackBoxLabel(Object number) {
    return Intl.message(
      'Box $number',
      name: 'checkboxTrackBoxLabel',
      desc: '',
      args: [number],
    );
  }

  /// `Tap a box to tick or clear it.`
  String get checkboxTrackTapHint {
    return Intl.message(
      'Tap a box to tick or clear it.',
      name: 'checkboxTrackTapHint',
      desc: '',
      args: [],
    );
  }

  /// `Fixed slots`
  String get textListSlotsHeadline {
    return Intl.message(
      'Fixed slots',
      name: 'textListSlotsHeadline',
      desc: '',
      args: [],
    );
  }

  /// `Optional, e.g. “High concept”, “Trouble” or “Mild (2)”.`
  String get textListSlotsHint {
    return Intl.message(
      'Optional, e.g. “High concept”, “Trouble” or “Mild (2)”.',
      name: 'textListSlotsHint',
      desc: '',
      args: [],
    );
  }

  /// `Label:`
  String get textListSlotLabel {
    return Intl.message(
      'Label:',
      name: 'textListSlotLabel',
      desc: '',
      args: [],
    );
  }

  /// `Players may add and delete their own entries`
  String get textListAllowCustomEntries {
    return Intl.message(
      'Players may add and delete their own entries',
      name: 'textListAllowCustomEntries',
      desc: '',
      args: [],
    );
  }

  /// `Add entry`
  String get textListAddEntry {
    return Intl.message(
      'Add entry',
      name: 'textListAddEntry',
      desc: '',
      args: [],
    );
  }

  /// `Own entry`
  String get textListOwnEntryLabel {
    return Intl.message(
      'Own entry',
      name: 'textListOwnEntryLabel',
      desc: '',
      args: [],
    );
  }

  /// `No entries yet`
  String get textListEmpty {
    return Intl.message(
      'No entries yet',
      name: 'textListEmpty',
      desc: '',
      args: [],
    );
  }

  /// `Edit entry`
  String get textListEditEntryTitle {
    return Intl.message(
      'Edit entry',
      name: 'textListEditEntryTitle',
      desc: '',
      args: [],
    );
  }

  /// `Delete`
  String get textListDeleteEntry {
    return Intl.message(
      'Delete',
      name: 'textListDeleteEntry',
      desc: '',
      args: [],
    );
  }

  /// `Options`
  String get singleSelectOptionsHeadline {
    return Intl.message(
      'Options',
      name: 'singleSelectOptionsHeadline',
      desc: '',
      args: [],
    );
  }

  /// `Nothing chosen yet`
  String get singleSelectNothingChosen {
    return Intl.message(
      'Nothing chosen yet',
      name: 'singleSelectNothingChosen',
      desc: '',
      args: [],
    );
  }

  /// `Show level`
  String get showLevelToggle {
    return Intl.message(
      'Show level',
      name: 'showLevelToggle',
      desc: '',
      args: [],
    );
  }

  /// `Off: the character form does not ask for a level and the sheet shows none.`
  String get showLevelHint {
    return Intl.message(
      'Off: the character form does not ask for a level and the sheet shows none.',
      name: 'showLevelHint',
      desc: '',
      args: [],
    );
  }

  /// `Player's view`
  String get playerPreviewButton {
    return Intl.message(
      'Player\'s view',
      name: 'playerPreviewButton',
      desc: '',
      args: [],
    );
  }

  /// `Player's view`
  String get playerPreviewTitle {
    return Intl.message(
      'Player\'s view',
      name: 'playerPreviewTitle',
      desc: '',
      args: [],
    );
  }

  /// `Phone`
  String get playerPreviewPhone {
    return Intl.message(
      'Phone',
      name: 'playerPreviewPhone',
      desc: '',
      args: [],
    );
  }

  /// `Tablet`
  String get playerPreviewTablet {
    return Intl.message(
      'Tablet',
      name: 'playerPreviewTablet',
      desc: '',
      args: [],
    );
  }

  /// `A sample character with default values. Nothing here is saved.`
  String get playerPreviewHint {
    return Intl.message(
      'A sample character with default values. Nothing here is saved.',
      name: 'playerPreviewHint',
      desc: '',
      args: [],
    );
  }

  /// `Sample character`
  String get playerPreviewSampleCharacterName {
    return Intl.message(
      'Sample character',
      name: 'playerPreviewSampleCharacterName',
      desc: '',
      args: [],
    );
  }

  /// `Players' notes`
  String get othersNotesGroupName {
    return Intl.message(
      'Players\' notes',
      name: 'othersNotesGroupName',
      desc: '',
      args: [],
    );
  }

  /// `Template`
  String get wizardTemplateStepTitle {
    return Intl.message(
      'Template',
      name: 'wizardTemplateStepTitle',
      desc: '',
      args: [],
    );
  }

  /// `## Welcome to QuestKeeper!\n\nIn the next steps you set up your campaign: template, appearance, name, character sheet, initiative and currency. Optional steps for items and crafting follow, which you can skip.\n\nEverything is saved automatically. Close the wizard at any time with the X in the top left; the gear icon in the top right brings you back here later.\n\n## Template\n\nPick what you start with. The template fills in the character sheet and the currency. You can change everything in the next steps.\n\nYou only pick a template when you create the campaign. Later, the gear icon lets you change each part on its own.`
  String get wizardTemplateStepHelper {
    return Intl.message(
      '## Welcome to QuestKeeper!\n\nIn the next steps you set up your campaign: template, appearance, name, character sheet, initiative and currency. Optional steps for items and crafting follow, which you can skip.\n\nEverything is saved automatically. Close the wizard at any time with the X in the top left; the gear icon in the top right brings you back here later.\n\n## Template\n\nPick what you start with. The template fills in the character sheet and the currency. You can change everything in the next steps.\n\nYou only pick a template when you create the campaign. Later, the gear icon lets you change each part on its own.',
      name: 'wizardTemplateStepHelper',
      desc: '',
      args: [],
    );
  }

  /// `Includes`
  String get wizardTemplateContentsLabel {
    return Intl.message(
      'Includes',
      name: 'wizardTemplateContentsLabel',
      desc: '',
      args: [],
    );
  }

  /// `Blank`
  String get wizardTemplateEmptyName {
    return Intl.message(
      'Blank',
      name: 'wizardTemplateEmptyName',
      desc: '',
      args: [],
    );
  }

  /// `A plain sheet with name, level and a description. You add everything else yourself.`
  String get wizardTemplateEmptyDescription {
    return Intl.message(
      'A plain sheet with name, level and a description. You add everything else yourself.',
      name: 'wizardTemplateEmptyDescription',
      desc: '',
      args: [],
    );
  }

  /// `Name, level, one currency`
  String get wizardTemplateEmptyContents {
    return Intl.message(
      'Name, level, one currency',
      name: 'wizardTemplateEmptyContents',
      desc: '',
      args: [],
    );
  }

  /// `Fantasy 5E (SRD)`
  String get wizardTemplateFantasyName {
    return Intl.message(
      'Fantasy 5E (SRD)',
      name: 'wizardTemplateFantasyName',
      desc: '',
      args: [],
    );
  }

  /// `Classic fantasy with abilities, hit points and spells.`
  String get wizardTemplateFantasyDescription {
    return Intl.message(
      'Classic fantasy with abilities, hit points and spells.',
      name: 'wizardTemplateFantasyDescription',
      desc: '',
      args: [],
    );
  }

  /// `Abilities, skills, spells, copper to platinum`
  String get wizardTemplateFantasyContents {
    return Intl.message(
      'Abilities, skills, spells, copper to platinum',
      name: 'wizardTemplateFantasyContents',
      desc: '',
      args: [],
    );
  }

  /// `Narrative (aspects & stress)`
  String get wizardTemplateNarrativeName {
    return Intl.message(
      'Narrative (aspects & stress)',
      name: 'wizardTemplateNarrativeName',
      desc: '',
      args: [],
    );
  }

  /// `For tables where the story comes first: aspects describe the characters, stress takes the hits.`
  String get wizardTemplateNarrativeDescription {
    return Intl.message(
      'For tables where the story comes first: aspects describe the characters, stress takes the hits.',
      name: 'wizardTemplateNarrativeDescription',
      desc: '',
      args: [],
    );
  }

  /// `Aspects, skills, stunts, stress, consequences, story points`
  String get wizardTemplateNarrativeContents {
    return Intl.message(
      'Aspects, skills, stunts, stress, consequences, story points',
      name: 'wizardTemplateNarrativeContents',
      desc: '',
      args: [],
    );
  }

  /// `Switch template?`
  String get wizardTemplateReplaceTitle {
    return Intl.message(
      'Switch template?',
      name: 'wizardTemplateReplaceTitle',
      desc: '',
      args: [],
    );
  }

  /// `You changed things since picking the template. These changes will be lost. The campaign name and appearance stay.`
  String get wizardTemplateReplaceMessage {
    return Intl.message(
      'You changed things since picking the template. These changes will be lost. The campaign name and appearance stay.',
      name: 'wizardTemplateReplaceMessage',
      desc: '',
      args: [],
    );
  }

  /// `Switch template`
  String get wizardTemplateReplaceConfirm {
    return Intl.message(
      'Switch template',
      name: 'wizardTemplateReplaceConfirm',
      desc: '',
      args: [],
    );
  }

  /// `## Appearance\n\nPick the default look for character sheets in this campaign. Players can change it later for their own characters.`
  String get wizardSkinStepHelperAfterTemplate {
    return Intl.message(
      '## Appearance\n\nPick the default look for character sheets in this campaign. Players can change it later for their own characters.',
      name: 'wizardSkinStepHelperAfterTemplate',
      desc: '',
      args: [],
    );
  }

  /// `Number and maximum`
  String get statStyleNumberAndMax {
    return Intl.message(
      'Number and maximum',
      name: 'statStyleNumberAndMax',
      desc: '',
      args: [],
    );
  }

  /// `Ring`
  String get statStyleRing {
    return Intl.message('Ring', name: 'statStyleRing', desc: '', args: []);
  }

  /// `Pentagon`
  String get statStylePentagon {
    return Intl.message(
      'Pentagon',
      name: 'statStylePentagon',
      desc: '',
      args: [],
    );
  }

  /// `Ring in health colours`
  String get statStyleRingHealthColors {
    return Intl.message(
      'Ring in health colours',
      name: 'statStyleRingHealthColors',
      desc: '',
      args: [],
    );
  }

  /// `Pips`
  String get statStylePips {
    return Intl.message('Pips', name: 'statStylePips', desc: '', args: []);
  }

  /// `Hearts`
  String get statStyleHearts {
    return Intl.message('Hearts', name: 'statStyleHearts', desc: '', args: []);
  }

  /// `Crystals`
  String get statStyleCrystals {
    return Intl.message(
      'Crystals',
      name: 'statStyleCrystals',
      desc: '',
      args: [],
    );
  }

  /// `Segmented bar`
  String get statStyleSegmentedBar {
    return Intl.message(
      'Segmented bar',
      name: 'statStyleSegmentedBar',
      desc: '',
      args: [],
    );
  }

  /// `Compact`
  String get statStyleCombatChip {
    return Intl.message(
      'Compact',
      name: 'statStyleCombatChip',
      desc: '',
      args: [],
    );
  }

  /// `Stacked`
  String get statStyleStacked {
    return Intl.message(
      'Stacked',
      name: 'statStyleStacked',
      desc: '',
      args: [],
    );
  }

  /// `Modifier first`
  String get statStyleModifierFirst {
    return Intl.message(
      'Modifier first',
      name: 'statStyleModifierFirst',
      desc: '',
      args: [],
    );
  }

  /// `Classic block`
  String get statStyleClassicBlock {
    return Intl.message(
      'Classic block',
      name: 'statStyleClassicBlock',
      desc: '',
      args: [],
    );
  }

  /// `Pentagons`
  String get statStylePentagons {
    return Intl.message(
      'Pentagons',
      name: 'statStylePentagons',
      desc: '',
      args: [],
    );
  }

  /// `Tiles, modifier first`
  String get statStyleModifierTiles {
    return Intl.message(
      'Tiles, modifier first',
      name: 'statStyleModifierTiles',
      desc: '',
      args: [],
    );
  }

  /// `Shields`
  String get statStyleShields {
    return Intl.message(
      'Shields',
      name: 'statStyleShields',
      desc: '',
      args: [],
    );
  }

  /// `Classic blocks`
  String get statStyleClassicBlocks {
    return Intl.message(
      'Classic blocks',
      name: 'statStyleClassicBlocks',
      desc: '',
      args: [],
    );
  }

  /// `Icon and value`
  String get statStyleIconAndValue {
    return Intl.message(
      'Icon and value',
      name: 'statStyleIconAndValue',
      desc: '',
      args: [],
    );
  }

  /// `Value over name`
  String get statStyleValueOverLabel {
    return Intl.message(
      'Value over name',
      name: 'statStyleValueOverLabel',
      desc: '',
      args: [],
    );
  }

  /// `Medallions`
  String get statStyleMedallions {
    return Intl.message(
      'Medallions',
      name: 'statStyleMedallions',
      desc: '',
      args: [],
    );
  }

  /// `Ribbon`
  String get statStyleRibbon {
    return Intl.message('Ribbon', name: 'statStyleRibbon', desc: '', args: []);
  }

  /// `First value large`
  String get statStyleMainValueLarge {
    return Intl.message(
      'First value large',
      name: 'statStyleMainValueLarge',
      desc: '',
      args: [],
    );
  }

  /// `Selected only`
  String get statStyleSelectedOnly {
    return Intl.message(
      'Selected only',
      name: 'statStyleSelectedOnly',
      desc: '',
      args: [],
    );
  }

  /// `All options`
  String get statStyleAllOptions {
    return Intl.message(
      'All options',
      name: 'statStyleAllOptions',
      desc: '',
      args: [],
    );
  }

  /// `Chips`
  String get statStyleChips {
    return Intl.message('Chips', name: 'statStyleChips', desc: '', args: []);
  }

  /// `Tiles`
  String get statStyleTiles {
    return Intl.message('Tiles', name: 'statStyleTiles', desc: '', args: []);
  }

  /// `Summary`
  String get statStyleSummary {
    return Intl.message(
      'Summary',
      name: 'statStyleSummary',
      desc: '',
      args: [],
    );
  }

  /// `Level circle`
  String get statStyleLevelCircle {
    return Intl.message(
      'Level circle',
      name: 'statStyleLevelCircle',
      desc: '',
      args: [],
    );
  }

  /// `Banner`
  String get statStyleBanner {
    return Intl.message('Banner', name: 'statStyleBanner', desc: '', args: []);
  }

  /// `Portrait card`
  String get statStylePortraitCard {
    return Intl.message(
      'Portrait card',
      name: 'statStylePortraitCard',
      desc: '',
      args: [],
    );
  }

  /// `Single line`
  String get statStyleSingleLine {
    return Intl.message(
      'Single line',
      name: 'statStyleSingleLine',
      desc: '',
      args: [],
    );
  }

  /// `Text`
  String get statStyleText {
    return Intl.message('Text', name: 'statStyleText', desc: '', args: []);
  }

  /// `Collapsible`
  String get statStyleCollapsible {
    return Intl.message(
      'Collapsible',
      name: 'statStyleCollapsible',
      desc: '',
      args: [],
    );
  }

  /// `Parchment`
  String get statStyleParchment {
    return Intl.message(
      'Parchment',
      name: 'statStyleParchment',
      desc: '',
      args: [],
    );
  }

  /// `Image`
  String get statStyleImage {
    return Intl.message('Image', name: 'statStyleImage', desc: '', args: []);
  }

  /// `Paw and buttons`
  String get statStylePawAndButtons {
    return Intl.message(
      'Paw and buttons',
      name: 'statStylePawAndButtons',
      desc: '',
      args: [],
    );
  }

  /// `Small cards`
  String get statStyleSmallCards {
    return Intl.message(
      'Small cards',
      name: 'statStyleSmallCards',
      desc: '',
      args: [],
    );
  }

  /// `Wand`
  String get statStyleWand {
    return Intl.message('Wand', name: 'statStyleWand', desc: '', args: []);
  }

  /// `Active form banner`
  String get statStyleActiveFormBanner {
    return Intl.message(
      'Active form banner',
      name: 'statStyleActiveFormBanner',
      desc: '',
      args: [],
    );
  }

  /// `Number over name`
  String get statStyleNumberOverName {
    return Intl.message(
      'Number over name',
      name: 'statStyleNumberOverName',
      desc: '',
      args: [],
    );
  }

  /// `Large number`
  String get statStyleLargeNumber {
    return Intl.message(
      'Large number',
      name: 'statStyleLargeNumber',
      desc: '',
      args: [],
    );
  }

  /// `Boxes`
  String get statStyleBoxes {
    return Intl.message('Boxes', name: 'statStyleBoxes', desc: '', args: []);
  }

  /// `List`
  String get statStyleList {
    return Intl.message('List', name: 'statStyleList', desc: '', args: []);
  }

  /// `Chosen option`
  String get statStyleChosenOption {
    return Intl.message(
      'Chosen option',
      name: 'statStyleChosenOption',
      desc: '',
      args: [],
    );
  }

  /// `{index} of {count}`
  String statStylePosition(int index, int count) {
    return Intl.message(
      '$index of $count',
      name: 'statStylePosition',
      desc: '',
      args: [index, count],
    );
  }

  /// `Previous style`
  String get statStylePrevious {
    return Intl.message(
      'Previous style',
      name: 'statStylePrevious',
      desc: '',
      args: [],
    );
  }

  /// `Next style`
  String get statStyleNext {
    return Intl.message(
      'Next style',
      name: 'statStyleNext',
      desc: '',
      args: [],
    );
  }

  /// `What do you want to track?`
  String get propertyPurposePickerQuestion {
    return Intl.message(
      'What do you want to track?',
      name: 'propertyPurposePickerQuestion',
      desc: '',
      args: [],
    );
  }

  /// `Pick what the property is for. You can still change its field type and look afterwards.`
  String get propertyPurposePickerHint {
    return Intl.message(
      'Pick what the property is for. You can still change its field type and look afterwards.',
      name: 'propertyPurposePickerHint',
      desc: '',
      args: [],
    );
  }

  /// `All field types`
  String get propertyPurposeAdvancedTitle {
    return Intl.message(
      'All field types',
      name: 'propertyPurposeAdvancedTitle',
      desc: '',
      args: [],
    );
  }

  /// `Choose the field type yourself from the full list.`
  String get propertyPurposeAdvancedDescription {
    return Intl.message(
      'Choose the field type yourself from the full list.',
      name: 'propertyPurposeAdvancedDescription',
      desc: '',
      args: [],
    );
  }

  /// `Field type and how often it changes`
  String get propertyPurposeChangeType {
    return Intl.message(
      'Field type and how often it changes',
      name: 'propertyPurposeChangeType',
      desc: '',
      args: [],
    );
  }

  /// `This is how the property looks on the sheet, with sample values.`
  String get propertyPreviewHint {
    return Intl.message(
      'This is how the property looks on the sheet, with sample values.',
      name: 'propertyPreviewHint',
      desc: '',
      args: [],
    );
  }

  /// `Add entries above to see the preview here.`
  String get propertyPreviewNeedsEntries {
    return Intl.message(
      'Add entries above to see the preview here.',
      name: 'propertyPreviewNeedsEntries',
      desc: '',
      args: [],
    );
  }

  /// `Health & resources`
  String get propertyPurposeResourceTitle {
    return Intl.message(
      'Health & resources',
      name: 'propertyPurposeResourceTitle',
      desc: '',
      args: [],
    );
  }

  /// `A value with a maximum that players change with + and − during play. E.g. hit points, mana, ammunition.`
  String get propertyPurposeResourceDescription {
    return Intl.message(
      'A value with a maximum that players change with + and − during play. E.g. hit points, mana, ammunition.',
      name: 'propertyPurposeResourceDescription',
      desc: '',
      args: [],
    );
  }

  /// `Abilities`
  String get propertyPurposeAbilitiesTitle {
    return Intl.message(
      'Abilities',
      name: 'propertyPurposeAbilitiesTitle',
      desc: '',
      args: [],
    );
  }

  /// `Several values with a bonus that rarely change. E.g. strength, dexterity, wisdom.`
  String get propertyPurposeAbilitiesDescription {
    return Intl.message(
      'Several values with a bonus that rarely change. E.g. strength, dexterity, wisdom.',
      name: 'propertyPurposeAbilitiesDescription',
      desc: '',
      args: [],
    );
  }

  /// `Key numbers`
  String get propertyPurposeKeyNumbersTitle {
    return Intl.message(
      'Key numbers',
      name: 'propertyPurposeKeyNumbersTitle',
      desc: '',
      args: [],
    );
  }

  /// `Several numbers with an icon. E.g. armour class, speed, initiative.`
  String get propertyPurposeKeyNumbersDescription {
    return Intl.message(
      'Several numbers with an icon. E.g. armour class, speed, initiative.',
      name: 'propertyPurposeKeyNumbersDescription',
      desc: '',
      args: [],
    );
  }

  /// `Counter`
  String get propertyPurposeCounterTitle {
    return Intl.message(
      'Counter',
      name: 'propertyPurposeCounterTitle',
      desc: '',
      args: [],
    );
  }

  /// `A single number that changes during play. E.g. story points, inspiration, luck.`
  String get propertyPurposeCounterDescription {
    return Intl.message(
      'A single number that changes during play. E.g. story points, inspiration, luck.',
      name: 'propertyPurposeCounterDescription',
      desc: '',
      args: [],
    );
  }

  /// `Value with bonus`
  String get propertyPurposeValueWithBonusTitle {
    return Intl.message(
      'Value with bonus',
      name: 'propertyPurposeValueWithBonusTitle',
      desc: '',
      args: [],
    );
  }

  /// `A number with a second number next to it. E.g. an ability with its modifier.`
  String get propertyPurposeValueWithBonusDescription {
    return Intl.message(
      'A number with a second number next to it. E.g. an ability with its modifier.',
      name: 'propertyPurposeValueWithBonusDescription',
      desc: '',
      args: [],
    );
  }

  /// `Tick boxes`
  String get propertyPurposeTickBoxesTitle {
    return Intl.message(
      'Tick boxes',
      name: 'propertyPurposeTickBoxesTitle',
      desc: '',
      args: [],
    );
  }

  /// `Boxes players tick with one tap. E.g. stress, exhaustion, death saves.`
  String get propertyPurposeTickBoxesDescription {
    return Intl.message(
      'Boxes players tick with one tap. E.g. stress, exhaustion, death saves.',
      name: 'propertyPurposeTickBoxesDescription',
      desc: '',
      args: [],
    );
  }

  /// `Checklist`
  String get propertyPurposeChecklistTitle {
    return Intl.message(
      'Checklist',
      name: 'propertyPurposeChecklistTitle',
      desc: '',
      args: [],
    );
  }

  /// `Tick several options from a list. E.g. skills, saving throws, languages.`
  String get propertyPurposeChecklistDescription {
    return Intl.message(
      'Tick several options from a list. E.g. skills, saving throws, languages.',
      name: 'propertyPurposeChecklistDescription',
      desc: '',
      args: [],
    );
  }

  /// `Pick one`
  String get propertyPurposePickOneTitle {
    return Intl.message(
      'Pick one',
      name: 'propertyPurposePickOneTitle',
      desc: '',
      args: [],
    );
  }

  /// `Exactly one option from a list. E.g. class, alignment, origin.`
  String get propertyPurposePickOneDescription {
    return Intl.message(
      'Exactly one option from a list. E.g. class, alignment, origin.',
      name: 'propertyPurposePickOneDescription',
      desc: '',
      args: [],
    );
  }

  /// `List of entries`
  String get propertyPurposeEntriesTitle {
    return Intl.message(
      'List of entries',
      name: 'propertyPurposeEntriesTitle',
      desc: '',
      args: [],
    );
  }

  /// `Short entries, fixed or added by players. E.g. aspects, goals, contacts.`
  String get propertyPurposeEntriesDescription {
    return Intl.message(
      'Short entries, fixed or added by players. E.g. aspects, goals, contacts.',
      name: 'propertyPurposeEntriesDescription',
      desc: '',
      args: [],
    );
  }

  /// `Short text`
  String get propertyPurposeShortTextTitle {
    return Intl.message(
      'Short text',
      name: 'propertyPurposeShortTextTitle',
      desc: '',
      args: [],
    );
  }

  /// `One line. E.g. deity, title, home town.`
  String get propertyPurposeShortTextDescription {
    return Intl.message(
      'One line. E.g. deity, title, home town.',
      name: 'propertyPurposeShortTextDescription',
      desc: '',
      args: [],
    );
  }

  /// `Long text`
  String get propertyPurposeLongTextTitle {
    return Intl.message(
      'Long text',
      name: 'propertyPurposeLongTextTitle',
      desc: '',
      args: [],
    );
  }

  /// `Several paragraphs. E.g. background, personality, equipment.`
  String get propertyPurposeLongTextDescription {
    return Intl.message(
      'Several paragraphs. E.g. background, personality, equipment.',
      name: 'propertyPurposeLongTextDescription',
      desc: '',
      args: [],
    );
  }

  /// `Image`
  String get propertyPurposeImageTitle {
    return Intl.message(
      'Image',
      name: 'propertyPurposeImageTitle',
      desc: '',
      args: [],
    );
  }

  /// `An image with a description. E.g. portrait, crest.`
  String get propertyPurposeImageDescription {
    return Intl.message(
      'An image with a description. E.g. portrait, crest.',
      name: 'propertyPurposeImageDescription',
      desc: '',
      args: [],
    );
  }

  /// `Companions`
  String get propertyPurposeCompanionsTitle {
    return Intl.message(
      'Companions',
      name: 'propertyPurposeCompanionsTitle',
      desc: '',
      args: [],
    );
  }

  /// `Companions with their own sheet. E.g. pet, familiar, mount.`
  String get propertyPurposeCompanionsDescription {
    return Intl.message(
      'Companions with their own sheet. E.g. pet, familiar, mount.',
      name: 'propertyPurposeCompanionsDescription',
      desc: '',
      args: [],
    );
  }

  /// `Transformation`
  String get propertyPurposeTransformationTitle {
    return Intl.message(
      'Transformation',
      name: 'propertyPurposeTransformationTitle',
      desc: '',
      args: [],
    );
  }

  /// `A button that turns the character into another form. E.g. an animal shape.`
  String get propertyPurposeTransformationDescription {
    return Intl.message(
      'A button that turns the character into another form. E.g. an animal shape.',
      name: 'propertyPurposeTransformationDescription',
      desc: '',
      args: [],
    );
  }

  /// `Ready-made blocks`
  String get buildingBlocksTitle {
    return Intl.message(
      'Ready-made blocks',
      name: 'buildingBlocksTitle',
      desc: '',
      args: [],
    );
  }

  /// `Take properties from the templates, e.g. ability scores, saving throws, spell slots, aspects or stress.`
  String get buildingBlocksCardDescription {
    return Intl.message(
      'Take properties from the templates, e.g. ability scores, saving throws, spell slots, aspects or stress.',
      name: 'buildingBlocksCardDescription',
      desc: '',
      args: [],
    );
  }

  /// `Tick what you want to take over. The properties go into this tab, and you can change them afterwards.`
  String get buildingBlocksHint {
    return Intl.message(
      'Tick what you want to take over. The properties go into this tab, and you can change them afterwards.',
      name: 'buildingBlocksHint',
      desc: '',
      args: [],
    );
  }

  /// `Tab “{tabName}”`
  String buildingBlocksTabLabel(String tabName) {
    return Intl.message(
      'Tab “$tabName”',
      name: 'buildingBlocksTabLabel',
      desc: '',
      args: [tabName],
    );
  }

  /// `Already on the sheet`
  String get buildingBlocksAlreadyOnSheet {
    return Intl.message(
      'Already on the sheet',
      name: 'buildingBlocksAlreadyOnSheet',
      desc: '',
      args: [],
    );
  }

  /// `Add`
  String get buildingBlocksAdd {
    return Intl.message('Add', name: 'buildingBlocksAdd', desc: '', args: []);
  }

  /// `Add {count}`
  String buildingBlocksAddCount(int count) {
    return Intl.message(
      'Add $count',
      name: 'buildingBlocksAddCount',
      desc: '',
      args: [count],
    );
  }

  /// `From one of your campaigns`
  String get wizardTemplateFromCampagneHeader {
    return Intl.message(
      'From one of your campaigns',
      name: 'wizardTemplateFromCampagneHeader',
      desc: '',
      args: [],
    );
  }

  /// `Takes over the character sheet, currency, items and recipes. Characters, notes and players stay in the other campaign.`
  String get wizardTemplateFromCampagneHint {
    return Intl.message(
      'Takes over the character sheet, currency, items and recipes. Characters, notes and players stay in the other campaign.',
      name: 'wizardTemplateFromCampagneHint',
      desc: '',
      args: [],
    );
  }

  /// `{count, plural, one{1 property} other{{count} properties}}`
  String wizardTemplateFromCampagneProperties(int count) {
    return Intl.plural(
      count,
      one: '1 property',
      other: '$count properties',
      name: 'wizardTemplateFromCampagneProperties',
      desc: '',
      args: [count],
    );
  }

  /// `{count, plural, one{1 item} other{{count} items}}`
  String wizardTemplateFromCampagneItems(int count) {
    return Intl.plural(
      count,
      one: '1 item',
      other: '$count items',
      name: 'wizardTemplateFromCampagneItems',
      desc: '',
      args: [count],
    );
  }

  /// `{count, plural, one{1 recipe} other{{count} recipes}}`
  String wizardTemplateFromCampagneRecipes(int count) {
    return Intl.plural(
      count,
      one: '1 recipe',
      other: '$count recipes',
      name: 'wizardTemplateFromCampagneRecipes',
      desc: '',
      args: [count],
    );
  }

  /// `Sheet with the tabs {tabs}`
  String wizardTemplateFromCampagneDescription(String tabs) {
    return Intl.message(
      'Sheet with the tabs $tabs',
      name: 'wizardTemplateFromCampagneDescription',
      desc: '',
      args: [tabs],
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
