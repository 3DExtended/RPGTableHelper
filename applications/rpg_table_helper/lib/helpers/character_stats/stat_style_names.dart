import 'package:quest_keeper/generated/l10n.dart';
import 'package:quest_keeper/models/rpg_configuration_model.dart';

/// The names of the visual styles of [type], in the order of their variant
/// numbers (see numberOfVariantsForValueTypes), as the style picker shows
/// them.
List<String> statStyleNames(S s, CharacterStatValueType type) =>
    switch (type) {
      CharacterStatValueType.intWithMaxValue => [
          s.statStyleNumberAndMax,
          s.statStyleRing,
          s.statStylePentagon,
          s.statStyleRingHealthColors,
          s.statStylePips,
          s.statStyleHearts,
          s.statStyleCrystals,
          s.statStyleSegmentedBar,
          s.statStyleCombatChip,
        ],
      CharacterStatValueType.intWithCalculatedValue => [
          s.statStyleStacked,
          s.statStylePentagon,
          s.statStyleModifierFirst,
          s.statStyleClassicBlock,
        ],
      CharacterStatValueType.listOfIntWithCalculatedValues => [
          s.statStylePentagons,
          s.statStyleModifierTiles,
          s.statStyleShields,
          s.statStyleClassicBlocks,
        ],
      CharacterStatValueType.listOfIntsWithIcons => [
          s.statStyleIconAndValue,
          s.statStyleValueOverLabel,
          s.statStyleMedallions,
          s.statStyleRibbon,
          s.statStyleMainValueLarge,
        ],
      CharacterStatValueType.multiselect => [
          s.statStyleSelectedOnly,
          s.statStyleAllOptions,
          s.statStyleChips,
          s.statStyleTiles,
          s.statStyleSummary,
        ],
      CharacterStatValueType.characterNameWithLevelAndAdditionalDetails => [
          s.statStyleLevelCircle,
          s.statStyleBanner,
          s.statStylePortraitCard,
          s.statStyleSingleLine,
        ],
      CharacterStatValueType.multiLineText => [
          s.statStyleText,
          s.statStyleCollapsible,
          s.statStyleParchment,
        ],
      CharacterStatValueType.singleLineText => [s.statStyleText],
      CharacterStatValueType.singleImage => [s.statStyleImage],
      CharacterStatValueType.companionSelector => [
          s.statStylePawAndButtons,
          s.statStyleSmallCards,
        ],
      CharacterStatValueType.transformIntoAlternateFormBtn => [
          s.statStyleWand,
          s.statStyleActiveFormBanner,
        ],
      CharacterStatValueType.int => [
          s.statStyleNumberOverName,
          s.statStyleLargeNumber,
        ],
      CharacterStatValueType.checkboxTrack => [s.statStyleBoxes],
      CharacterStatValueType.textList => [s.statStyleList],
      CharacterStatValueType.singleSelect => [
          s.statStyleChosenOption,
          s.statStyleAllOptions,
        ],
      CharacterStatValueType.unsupported => [s.statStyleText],
    };
