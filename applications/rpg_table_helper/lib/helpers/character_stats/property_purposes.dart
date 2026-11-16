import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:quest_keeper/generated/l10n.dart';
import 'package:quest_keeper/models/rpg_configuration_model.dart';

/// What a new property is for. The game master picks one of these instead of
/// a field type; each sets the field type and how often the value changes.
enum PropertyPurpose {
  resource,
  counter,
  abilities,
  valueWithBonus,
  keyNumbers,
  tickBoxes,
  checklist,
  pickOne,
  entries,
  shortText,
  longText,
  image,
  companions,
  transformation,
}

class PropertyPurposeInfo {
  const PropertyPurposeInfo({
    required this.purpose,
    required this.icon,
    required this.valueType,
    required this.editType,
  });

  final PropertyPurpose purpose;
  final FaIconData icon;
  final CharacterStatValueType valueType;

  /// [CharacterStatEditType.oneTap] for values that change during play
  /// (players edit them directly on the sheet).
  final CharacterStatEditType editType;

  String title(S s) => switch (purpose) {
    PropertyPurpose.resource => s.propertyPurposeResourceTitle,
    PropertyPurpose.counter => s.propertyPurposeCounterTitle,
    PropertyPurpose.abilities => s.propertyPurposeAbilitiesTitle,
    PropertyPurpose.valueWithBonus => s.propertyPurposeValueWithBonusTitle,
    PropertyPurpose.keyNumbers => s.propertyPurposeKeyNumbersTitle,
    PropertyPurpose.tickBoxes => s.propertyPurposeTickBoxesTitle,
    PropertyPurpose.checklist => s.propertyPurposeChecklistTitle,
    PropertyPurpose.pickOne => s.propertyPurposePickOneTitle,
    PropertyPurpose.entries => s.propertyPurposeEntriesTitle,
    PropertyPurpose.shortText => s.propertyPurposeShortTextTitle,
    PropertyPurpose.longText => s.propertyPurposeLongTextTitle,
    PropertyPurpose.image => s.propertyPurposeImageTitle,
    PropertyPurpose.companions => s.propertyPurposeCompanionsTitle,
    PropertyPurpose.transformation => s.propertyPurposeTransformationTitle,
  };

  String description(S s) => switch (purpose) {
    PropertyPurpose.resource => s.propertyPurposeResourceDescription,
    PropertyPurpose.counter => s.propertyPurposeCounterDescription,
    PropertyPurpose.abilities => s.propertyPurposeAbilitiesDescription,
    PropertyPurpose.valueWithBonus =>
      s.propertyPurposeValueWithBonusDescription,
    PropertyPurpose.keyNumbers => s.propertyPurposeKeyNumbersDescription,
    PropertyPurpose.tickBoxes => s.propertyPurposeTickBoxesDescription,
    PropertyPurpose.checklist => s.propertyPurposeChecklistDescription,
    PropertyPurpose.pickOne => s.propertyPurposePickOneDescription,
    PropertyPurpose.entries => s.propertyPurposeEntriesDescription,
    PropertyPurpose.shortText => s.propertyPurposeShortTextDescription,
    PropertyPurpose.longText => s.propertyPurposeLongTextDescription,
    PropertyPurpose.image => s.propertyPurposeImageDescription,
    PropertyPurpose.companions => s.propertyPurposeCompanionsDescription,
    PropertyPurpose.transformation =>
      s.propertyPurposeTransformationDescription,
  };

  /// The property a new one of this purpose starts with (no name yet).
  CharacterStatDefinition newStat() => CharacterStatDefinition(
    statUuid: '',
    name: '',
    helperText: '',
    groupId: null,
    valueType: valueType,
    editType: editType,
    isOptionalForAlternateForms: false,
    isOptionalForCompanionCharacters: false,
  );

  static PropertyPurposeInfo of(PropertyPurpose purpose) =>
      all.firstWhere((p) => p.purpose == purpose);

  /// In the order the picker shows them: what most sheets need first.
  static const all = <PropertyPurposeInfo>[
    PropertyPurposeInfo(
      purpose: PropertyPurpose.resource,
      icon: FontAwesomeIcons.heart,
      valueType: CharacterStatValueType.intWithMaxValue,
      editType: CharacterStatEditType.oneTap,
    ),
    PropertyPurposeInfo(
      purpose: PropertyPurpose.abilities,
      icon: FontAwesomeIcons.dumbbell,
      valueType: CharacterStatValueType.listOfIntWithCalculatedValues,
      editType: CharacterStatEditType.static,
    ),
    PropertyPurposeInfo(
      purpose: PropertyPurpose.keyNumbers,
      icon: FontAwesomeIcons.shieldHalved,
      valueType: CharacterStatValueType.listOfIntsWithIcons,
      editType: CharacterStatEditType.static,
    ),
    PropertyPurposeInfo(
      purpose: PropertyPurpose.counter,
      icon: FontAwesomeIcons.hashtag,
      valueType: CharacterStatValueType.int,
      editType: CharacterStatEditType.oneTap,
    ),
    PropertyPurposeInfo(
      purpose: PropertyPurpose.valueWithBonus,
      icon: FontAwesomeIcons.diceD20,
      valueType: CharacterStatValueType.intWithCalculatedValue,
      editType: CharacterStatEditType.static,
    ),
    PropertyPurposeInfo(
      purpose: PropertyPurpose.tickBoxes,
      icon: FontAwesomeIcons.squareCheck,
      valueType: CharacterStatValueType.checkboxTrack,
      editType: CharacterStatEditType.oneTap,
    ),
    PropertyPurposeInfo(
      purpose: PropertyPurpose.checklist,
      icon: FontAwesomeIcons.listCheck,
      valueType: CharacterStatValueType.multiselect,
      editType: CharacterStatEditType.static,
    ),
    PropertyPurposeInfo(
      purpose: PropertyPurpose.pickOne,
      icon: FontAwesomeIcons.circleDot,
      valueType: CharacterStatValueType.singleSelect,
      editType: CharacterStatEditType.static,
    ),
    PropertyPurposeInfo(
      purpose: PropertyPurpose.entries,
      icon: FontAwesomeIcons.listUl,
      valueType: CharacterStatValueType.textList,
      editType: CharacterStatEditType.static,
    ),
    PropertyPurposeInfo(
      purpose: PropertyPurpose.shortText,
      icon: FontAwesomeIcons.font,
      valueType: CharacterStatValueType.singleLineText,
      editType: CharacterStatEditType.static,
    ),
    PropertyPurposeInfo(
      purpose: PropertyPurpose.longText,
      icon: FontAwesomeIcons.alignLeft,
      valueType: CharacterStatValueType.multiLineText,
      editType: CharacterStatEditType.static,
    ),
    PropertyPurposeInfo(
      purpose: PropertyPurpose.image,
      icon: FontAwesomeIcons.image,
      valueType: CharacterStatValueType.singleImage,
      editType: CharacterStatEditType.static,
    ),
    PropertyPurposeInfo(
      purpose: PropertyPurpose.companions,
      icon: FontAwesomeIcons.paw,
      valueType: CharacterStatValueType.companionSelector,
      editType: CharacterStatEditType.static,
    ),
    PropertyPurposeInfo(
      purpose: PropertyPurpose.transformation,
      icon: FontAwesomeIcons.wandMagicSparkles,
      valueType: CharacterStatValueType.transformIntoAlternateFormBtn,
      editType: CharacterStatEditType.static,
    ),
  ];
}
