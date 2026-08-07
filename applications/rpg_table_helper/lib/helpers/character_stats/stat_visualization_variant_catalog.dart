/// Stable indices for player visualization variants.
///
/// Use these IDs when giving feedback (e.g. "keep V-HP-5, drop V-HP-7").
/// Existing variants keep historical indices where possible; removals renumber
/// only the trailing new variants that shifted.
library;

/// Human-readable catalog for the throwaway review gallery.
class StatVisualizationVariantCatalog {
  static const entries = <StatVisualizationVariantEntry>[
    // --- intWithMaxValue ---
    StatVisualizationVariantEntry(
      id: 'V-HP-0',
      valueType: 'intWithMaxValue',
      variant: 0,
      title: 'Text value / max',
      isNew: false,
    ),
    StatVisualizationVariantEntry(
      id: 'V-HP-1',
      valueType: 'intWithMaxValue',
      variant: 1,
      title: 'Circular progress (accent)',
      isNew: false,
    ),
    StatVisualizationVariantEntry(
      id: 'V-HP-2',
      valueType: 'intWithMaxValue',
      variant: 2,
      title: 'Pentagon',
      isNew: false,
    ),
    StatVisualizationVariantEntry(
      id: 'V-HP-3',
      valueType: 'intWithMaxValue',
      variant: 3,
      title: 'Circular progress (health colors)',
      isNew: false,
    ),
    StatVisualizationVariantEntry(
      id: 'V-HP-4',
      valueType: 'intWithMaxValue',
      variant: 4,
      title: 'Dot pips',
      isNew: false,
    ),
    StatVisualizationVariantEntry(
      id: 'V-HP-5',
      valueType: 'intWithMaxValue',
      variant: 5,
      title: 'Heart reservoir',
      isNew: true,
    ),
    StatVisualizationVariantEntry(
      id: 'V-HP-6',
      valueType: 'intWithMaxValue',
      variant: 6,
      title: 'Gem / crystal reservoir',
      isNew: true,
    ),
    StatVisualizationVariantEntry(
      id: 'V-HP-7',
      valueType: 'intWithMaxValue',
      variant: 7,
      title: 'Segmented track',
      isNew: true,
    ),
    StatVisualizationVariantEntry(
      id: 'V-HP-8',
      valueType: 'intWithMaxValue',
      variant: 8,
      title: 'Compact combat chip (was V-HP-9; wound rings removed)',
      isNew: true,
    ),

    // --- intWithCalculatedValue ---
    StatVisualizationVariantEntry(
      id: 'V-CALC-0',
      valueType: 'intWithCalculatedValue',
      variant: 0,
      title: 'Stacked text',
      isNew: false,
    ),
    StatVisualizationVariantEntry(
      id: 'V-CALC-1',
      valueType: 'intWithCalculatedValue',
      variant: 1,
      title: 'Pentagon',
      isNew: false,
    ),
    StatVisualizationVariantEntry(
      id: 'V-CALC-2',
      valueType: 'intWithCalculatedValue',
      variant: 2,
      title: 'Modifier-first',
      isNew: true,
    ),
    StatVisualizationVariantEntry(
      id: 'V-CALC-3',
      valueType: 'intWithCalculatedValue',
      variant: 3,
      title: 'Classic ability block',
      isNew: true,
    ),

    // --- listOfIntWithCalculatedValues ---
    StatVisualizationVariantEntry(
      id: 'V-ABILITY-0',
      valueType: 'listOfIntWithCalculatedValues',
      variant: 0,
      title: 'Pentagon grid',
      isNew: false,
    ),
    StatVisualizationVariantEntry(
      id: 'V-ABILITY-1',
      valueType: 'listOfIntWithCalculatedValues',
      variant: 1,
      title: 'Modifier-first tiles',
      isNew: true,
    ),
    StatVisualizationVariantEntry(
      id: 'V-ABILITY-2',
      valueType: 'listOfIntWithCalculatedValues',
      variant: 2,
      title: 'Hex / shield tiles',
      isNew: true,
    ),
    StatVisualizationVariantEntry(
      id: 'V-ABILITY-3',
      valueType: 'listOfIntWithCalculatedValues',
      variant: 3,
      title: 'Classic ability blocks',
      isNew: true,
    ),

    // --- listOfIntsWithIcons ---
    StatVisualizationVariantEntry(
      id: 'V-ICON-0',
      valueType: 'listOfIntsWithIcons',
      variant: 0,
      title: 'Icon + Label: value',
      isNew: false,
    ),
    StatVisualizationVariantEntry(
      id: 'V-ICON-1',
      valueType: 'listOfIntsWithIcons',
      variant: 1,
      title: 'Icon + value over label',
      isNew: false,
    ),
    StatVisualizationVariantEntry(
      id: 'V-ICON-2',
      valueType: 'listOfIntsWithIcons',
      variant: 2,
      title: 'Medallion / badge cluster',
      isNew: true,
    ),
    StatVisualizationVariantEntry(
      id: 'V-ICON-3',
      valueType: 'listOfIntsWithIcons',
      variant: 3,
      title: 'Horizontal ribbon',
      isNew: true,
    ),
    StatVisualizationVariantEntry(
      id: 'V-ICON-4',
      valueType: 'listOfIntsWithIcons',
      variant: 4,
      title: 'Primary hero + secondaries',
      isNew: true,
    ),

    // --- multiselect ---
    StatVisualizationVariantEntry(
      id: 'V-MULTI-0',
      valueType: 'multiselect',
      variant: 0,
      title: 'Selected-only list',
      isNew: false,
    ),
    StatVisualizationVariantEntry(
      id: 'V-MULTI-1',
      valueType: 'multiselect',
      variant: 1,
      title: 'All options list',
      isNew: false,
    ),
    StatVisualizationVariantEntry(
      id: 'V-MULTI-2',
      valueType: 'multiselect',
      variant: 2,
      title: 'Proficiency chips',
      isNew: true,
    ),
    StatVisualizationVariantEntry(
      id: 'V-MULTI-3',
      valueType: 'multiselect',
      variant: 3,
      title: 'Icon / tile grid (was V-MULTI-4; checklist+grouped removed)',
      isNew: true,
    ),
    StatVisualizationVariantEntry(
      id: 'V-MULTI-4',
      valueType: 'multiselect',
      variant: 4,
      title: 'Summary list (tap for details)',
      isNew: true,
    ),

    // --- characterNameWithLevelAndAdditionalDetails ---
    StatVisualizationVariantEntry(
      id: 'V-ID-0',
      valueType: 'characterNameWithLevelAndAdditionalDetails',
      variant: 0,
      title: 'Level circle + detail grid',
      isNew: false,
    ),
    StatVisualizationVariantEntry(
      id: 'V-ID-1',
      valueType: 'characterNameWithLevelAndAdditionalDetails',
      variant: 1,
      title: 'Banner + level seal',
      isNew: true,
    ),
    StatVisualizationVariantEntry(
      id: 'V-ID-2',
      valueType: 'characterNameWithLevelAndAdditionalDetails',
      variant: 2,
      title: 'Portrait-led card (generate/save image)',
      isNew: true,
    ),
    StatVisualizationVariantEntry(
      id: 'V-ID-3',
      valueType: 'characterNameWithLevelAndAdditionalDetails',
      variant: 3,
      title: 'Minimal identity line',
      isNew: true,
    ),

    // --- multiLineText only (singleLineText stays at baseline) ---
    StatVisualizationVariantEntry(
      id: 'V-TEXT-0',
      valueType: 'multiLineText',
      variant: 0,
      title: 'Labeled markdown',
      isNew: false,
    ),
    StatVisualizationVariantEntry(
      id: 'V-TEXT-1',
      valueType: 'multiLineText',
      variant: 1,
      title: 'Collapsible lore panel (expanded)',
      isNew: true,
    ),
    StatVisualizationVariantEntry(
      id: 'V-TEXT-2',
      valueType: 'multiLineText',
      variant: 2,
      title: 'Parchment frame (left accent)',
      isNew: true,
    ),

    // --- singleImage / singleLineText baselines only ---
    StatVisualizationVariantEntry(
      id: 'V-IMG-0',
      valueType: 'singleImage',
      variant: 0,
      title: 'Bordered image',
      isNew: false,
    ),
    StatVisualizationVariantEntry(
      id: 'V-SLTEXT-0',
      valueType: 'singleLineText',
      variant: 0,
      title: 'Labeled markdown',
      isNew: false,
    ),

    // --- companion / transform / int ---
    StatVisualizationVariantEntry(
      id: 'V-COMP-0',
      valueType: 'companionSelector',
      variant: 0,
      title: 'Paw + buttons',
      isNew: false,
    ),
    StatVisualizationVariantEntry(
      id: 'V-COMP-1',
      valueType: 'companionSelector',
      variant: 1,
      title: 'Mini character cards',
      isNew: true,
    ),
    StatVisualizationVariantEntry(
      id: 'V-FORM-0',
      valueType: 'transformIntoAlternateFormBtn',
      variant: 0,
      title: 'Wand + transform button',
      isNew: false,
    ),
    StatVisualizationVariantEntry(
      id: 'V-FORM-1',
      valueType: 'transformIntoAlternateFormBtn',
      variant: 1,
      title: 'Active-form banner',
      isNew: true,
    ),
    StatVisualizationVariantEntry(
      id: 'V-INT-0',
      valueType: 'int',
      variant: 0,
      title: 'Number over label',
      isNew: false,
    ),
    StatVisualizationVariantEntry(
      id: 'V-INT-1',
      valueType: 'int',
      variant: 1,
      title: 'Large numeral tile',
      isNew: true,
    ),
  ];

  static List<StatVisualizationVariantEntry> get newOnly =>
      entries.where((e) => e.isNew).toList();
}

class StatVisualizationVariantEntry {
  const StatVisualizationVariantEntry({
    required this.id,
    required this.valueType,
    required this.variant,
    required this.title,
    required this.isNew,
  });

  final String id;
  final String valueType;
  final int variant;
  final String title;
  final bool isNew;
}
