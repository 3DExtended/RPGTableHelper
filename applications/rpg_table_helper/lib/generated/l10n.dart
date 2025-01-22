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
