import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:quest_keeper/components/custom_button.dart';
import 'package:quest_keeper/components/custom_fa_icon.dart';
import 'package:quest_keeper/components/custom_shadow_widget.dart';
import 'package:quest_keeper/components/custom_text_field.dart';
import 'package:quest_keeper/components/horizontal_line.dart';
import 'package:quest_keeper/components/navbar.dart';
import 'package:quest_keeper/generated/l10n.dart';
import 'package:quest_keeper/helpers/character_sheet_skins/character_sheet_skin_chrome.dart';
import 'package:quest_keeper/helpers/character_stats/character_stats_form_pages.dart';
import 'package:quest_keeper/helpers/character_stats/player_stats_configuration_visuals.dart';
import 'package:quest_keeper/helpers/character_stats/show_get_player_configuration_modal.dart';
import 'package:quest_keeper/helpers/modal_helpers.dart';
import 'package:quest_keeper/main.dart';
import 'package:quest_keeper/models/rpg_character_configuration.dart';
import 'package:quest_keeper/services/custom_theme_provider.dart';

/// What the character form is used for.
enum CharacterStatsFormMode {
  /// First setup (or resuming it): one page per tab with missing fields,
  /// progress, "Fill in later".
  setup,

  /// Editing all fields of one tab from the sheet menu: Cancel / Save.
  editTab,

  /// The guided level-up: the level one up, then the properties marked
  /// "Beim Stufenaufstieg abfragen", tab by tab, with progress.
  levelUp,
}

/// How the character form was closed.
enum CharacterStatsFormOutcome {
  /// Last page confirmed (setup) or saved (edit tab).
  completed,

  /// Closed with "Fill in later": everything typed so far was kept.
  filledInLater,

  /// Closed with Cancel / X: confirmed pages are kept, the edits on the open
  /// page are dropped.
  cancelled,
}

/// Persists [stats] (and the [characterName] when it changed) to the
/// character. Called while the form is open, page by page.
typedef CharacterStatsFormPersist = void Function(
  List<RpgCharacterStatValue> stats,
  String? characterName,
);

/// Shows the character form: one page per sheet tab, all fields of the tab
/// below each other (see [buildCharacterStatsFormPages]).
///
/// Values are written through [onPersist] while the form is open:
/// - "Next" / "Done" / "Save" store every field of the page (fields left
///   empty are stored empty and can be edited on the sheet later),
/// - "Back" and "Fill in later" store what was typed,
/// - "Cancel" keeps what was stored before and drops the open page's edits.
Future<CharacterStatsFormOutcome?> showCharacterStatsForm({
  required BuildContext context,
  required List<CharacterStatsFormPage> pages,
  required CharacterStatsFormMode mode,
  required String characterName,
  required Map<String, RpgCharacterStatValue> initialValues,
  required RpgCharacterConfiguration? characterToRenderStatFor,
  required bool isEditingAlternateForm,
  required CharacterStatsFormPersist onPersist,
  GlobalKey<NavigatorState>? overrideNavigatorKey,
  int? previousLevel,
}) {
  return customShowCupertinoModalBottomSheet<CharacterStatsFormOutcome>(
    isDismissible: true,
    expand: true,
    closeProgressThreshold: -50000,
    enableDrag: false,
    context: context,
    backgroundColor: const Color.fromARGB(158, 49, 49, 49),
    overrideNavigatorKey: overrideNavigatorKey,
    builder: (context) => CharacterStatsFormContent(
      pages: pages,
      mode: mode,
      characterName: characterName,
      initialValues: initialValues,
      characterToRenderStatFor: characterToRenderStatFor,
      isEditingAlternateForm: isEditingAlternateForm,
      onPersist: onPersist,
      overrideNavigatorKey: overrideNavigatorKey,
      previousLevel: previousLevel,
    ),
  );
}

class CharacterStatsFormContent extends StatefulWidget {
  const CharacterStatsFormContent({
    super.key,
    required this.pages,
    required this.mode,
    required this.characterName,
    required this.initialValues,
    required this.characterToRenderStatFor,
    required this.isEditingAlternateForm,
    required this.onPersist,
    this.overrideNavigatorKey,
    this.previousLevel,
  });

  final List<CharacterStatsFormPage> pages;
  final CharacterStatsFormMode mode;
  final String characterName;
  final Map<String, RpgCharacterStatValue> initialValues;
  final RpgCharacterConfiguration? characterToRenderStatFor;
  final bool isEditingAlternateForm;
  final CharacterStatsFormPersist onPersist;
  final GlobalKey<NavigatorState>? overrideNavigatorKey;

  /// The level before the level-up ([CharacterStatsFormMode.levelUp]).
  final int? previousLevel;

  /// "Schnell starten" on the first page of the setup.
  static const quickStartKey = ValueKey('character-stats-form-quick-start');

  /// Back from the quick start to every section.
  static const allSectionsKey = ValueKey('character-stats-form-all-sections');

  @override
  State<CharacterStatsFormContent> createState() =>
      _CharacterStatsFormContentState();
}

class _CharacterStatsFormContentState extends State<CharacterStatsFormContent> {
  int _pageIndex = 0;

  /// Latest value of every field shown so far (also of earlier pages).
  final Map<String, RpgCharacterStatValue> _current = {};

  /// Value of each field when it was first shown or last stored; a field
  /// whose current value differs from it has unsaved edits.
  final Map<String, RpgCharacterStatValue> _baseline = {};

  /// Fields whose input is invalid right now (e.g. text in the level).
  final Set<String> _invalid = {};

  /// The name as typed (only editable on a page with the name field).
  late String _name;
  late String _storedName;

  /// "Schnell starten" was chosen: only [_quickPage] is shown.
  bool _quick = false;

  /// The page of the quick start, null when it is not offered.
  late final CharacterStatsFormPage? _quickPage =
      _isSetup ? quickStartPageOf(widget.pages) : null;

  CharacterStatsFormPage get _page =>
      _quick ? _quickPage! : widget.pages[_pageIndex];
  bool get _isLastPage => _quick || _pageIndex >= widget.pages.length - 1;
  bool get _isSetup => widget.mode == CharacterStatsFormMode.setup;
  bool get _isLevelUp => widget.mode == CharacterStatsFormMode.levelUp;

  /// Page by page with progress: the setup and the level-up.
  bool get _isGuided => widget.mode != CharacterStatsFormMode.editTab;

  /// The quick start is the first choice on the first page.
  bool get _offersQuickStart =>
      _quickPage != null && !_quick && _pageIndex == 0;

  @override
  void initState() {
    super.initState();
    _storedName = widget.characterName;
    _name = widget.characterName;
  }

  void _onNameChanged(String name) {
    if (!mounted || name == _name) return;
    setState(() {
      _name = name;
    });
  }

  bool get _isNameValid => !_page.showNameField || _name.trim().isNotEmpty;

  bool get _isPageValid =>
      _isNameValid && _page.stats.every((s) => !_invalid.contains(s.statUuid));

  static bool _sameValue(RpgCharacterStatValue a, RpgCharacterStatValue b) =>
      a.serializedValue == b.serializedValue &&
      a.variant == b.variant &&
      (a.hideFromCharacterScreen ?? false) ==
          (b.hideFromCharacterScreen ?? false) &&
      (a.hideLabelOfStat ?? false) == (b.hideLabelOfStat ?? false);

  bool _isDirty(String statUuid) {
    final current = _current[statUuid];
    final baseline = _baseline[statUuid];
    if (current == null || baseline == null) return false;
    return !_sameValue(current, baseline);
  }

  void _onNewStatValue(String statUuid, RpgCharacterStatValue value) {
    // The first report of a field is its untouched state (the field seeds its
    // value right after it is built), so it becomes the baseline.
    _baseline.putIfAbsent(statUuid, () => value);
    _current[statUuid] = value;
  }

  void _onValidityChanged(String statUuid, bool isValid) {
    if (!mounted) return;
    setState(() {
      if (isValid) {
        _invalid.remove(statUuid);
      } else {
        _invalid.add(statUuid);
      }
    });
  }

  String? get _nameToStore {
    final name = _name.trim();
    if (name.isEmpty || name == _storedName.trim()) return null;
    return name;
  }

  void _persist(List<String> statUuids) {
    final stats = statUuids
        .map((uuid) => _current[uuid])
        .whereType<RpgCharacterStatValue>()
        .toList();
    final name = _nameToStore;
    if (stats.isEmpty && name == null) return;

    widget.onPersist(stats, name);

    for (final stat in stats) {
      _baseline[stat.statUuid] = stat;
    }
    if (name != null) _storedName = name;
  }

  /// Stores every field of the open page, also the ones left untouched.
  void _persistPage() {
    _persist(
      _page.stats
          .map((s) => s.statUuid)
          .where((uuid) => !_invalid.contains(uuid))
          .toList(),
    );
  }

  /// Stores only what the player typed (on any page), never invalid input.
  void _persistEdits() {
    _persist(
      _current.keys
          .where((uuid) => _isDirty(uuid) && !_invalid.contains(uuid))
          .toList(),
    );
  }

  void _close(CharacterStatsFormOutcome outcome) {
    (widget.overrideNavigatorKey ?? navigatorKey).currentState!.pop(outcome);
  }

  void _onNext() {
    if (!_isPageValid) return;
    if (_quick) {
      // The quick fields, and whatever was typed on the first page before.
      _persist({
        for (final stat in _page.stats)
          if (!_invalid.contains(stat.statUuid)) stat.statUuid,
        ..._current.keys.where(
          (uuid) => _isDirty(uuid) && !_invalid.contains(uuid),
        ),
      }.toList());
      _close(CharacterStatsFormOutcome.filledInLater);
      return;
    }
    _persistPage();
    if (_isLastPage) {
      _close(CharacterStatsFormOutcome.completed);
      return;
    }
    setState(() {
      _pageIndex++;
    });
  }

  void _onBack() {
    if (_pageIndex == 0) return;
    _persistEdits();
    setState(() {
      _pageIndex--;
    });
  }

  void _onQuickStart() {
    setState(() {
      _quick = true;
    });
  }

  void _onAllSections() {
    setState(() {
      _quick = false;
      _pageIndex = 0;
    });
  }

  /// "Name, Porträt und Charakter-Zusammenfassung".
  String _quickStartFields(BuildContext context) {
    final s = S.of(context);
    final page = _quickPage!;
    final names = [
      if (page.showNameField) s.characterName,
      for (final stat in page.stats) stat.name.trim(),
    ].where((name) => name.isNotEmpty).toList();
    if (names.length <= 1) return names.join();
    return '${names.take(names.length - 1).join(', ')} '
        '${s.quickStartAnd} ${names.last}';
  }

  /// On the first page of the level-up: from which level to which, and,
  /// when it asks for nothing but the level, where that is set.
  String? _levelUpHint(BuildContext context) {
    if (!_isLevelUp || _pageIndex > 0) return null;
    final s = S.of(context);
    final from = widget.previousLevel ?? 1;
    final onlyLevel = widget.pages.length == 1 && _page.stats.length == 1;
    return [
      s.levelUpIntro(from, from + 1),
      if (onlyLevel) s.levelUpOnlyLevelHint,
    ].join('\n\n');
  }

  void _onFillInLater() {
    if (!_isPageValid) return;
    _persistEdits();
    _close(CharacterStatsFormOutcome.filledInLater);
  }

  void _onCancel() {
    _close(CharacterStatsFormOutcome.cancelled);
  }

  String get _title {
    if (_isSetup) return S.of(context).characterSetupTitle;
    if (_isLevelUp) return S.of(context).levelUpTitle;
    return S.of(context).configureProperties +
        (widget.characterName.isEmpty
            ? ""
            : S
                  .of(context)
                  .configurePropertiesForCharacterNameSuffix(
                    widget.characterName,
                  ));
  }

  @override
  Widget build(BuildContext context) {
    final theme = CustomThemeProvider.of(context).theme;
    final modalPadding = MediaQuery.of(context).size.width < 800 ? 20.0 : 80.0;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: EdgeInsets.only(
          bottom: 20,
          top: 20,
          left: modalPadding,
          right: modalPadding,
        ),
        child: Center(
          child: CustomShadowWidget(
            child: SkinnedModalPanel(
              child: Column(
                children: [
                  Navbar(
                    backInsteadOfCloseIcon: false,
                    closeFunction: _onCancel,
                    menuOpen: null,
                    useTopSafePadding: false,
                    titleWidget: Text(
                      _title,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        color:
                            CustomThemeProvider.of(context)
                                    .brightnessNotifier
                                    .value ==
                                Brightness.light
                            ? theme.textColor
                            : theme.darkTextColor,
                        fontSize: 24,
                      ),
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      // A fresh scroll position (top) for every page.
                      key: ValueKey(
                        'character-stats-form-page-${_quick ? 'quick' : _pageIndex}',
                      ),
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      padding: const EdgeInsets.all(20),
                      child: _buildPageBody(context),
                    ),
                  ),
                  _buildFooter(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPageBody(BuildContext context) {
    final theme = CustomThemeProvider.of(context).theme;
    final textStyle = Theme.of(context).textTheme.labelMedium!
        .copyWith(color: theme.darkTextColor, fontSize: 16);
    final page = _page;
    final tabName = page.tab?.tabName ?? S.of(context).characterName;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_isGuided) ...[
          if (_offersQuickStart) ...[
            _QuickStartCard(
              fields: _quickStartFields(context),
              onStart: _onQuickStart,
            ),
            const SizedBox(height: 16),
          ],
          Text(
            _quick
                ? S.of(context).quickStartTitle
                : widget.pages.length > 1
                ? S
                      .of(context)
                      .characterSetupProgress(
                        _pageIndex + 1,
                        widget.pages.length,
                        tabName,
                      )
                : tabName,
            key: const ValueKey('character-stats-form-progress'),
            style: textStyle.copyWith(fontSize: 20),
          ),
          if (!_quick && widget.pages.length > 1) ...[
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: (_pageIndex + 1) / widget.pages.length,
                minHeight: 6,
                color: theme.accentColor,
                backgroundColor: theme.middleBgColor,
              ),
            ),
          ],
          const SizedBox(height: 10),
          if (_levelUpHint(context) case final hint?)
            Text(
              hint,
              key: const ValueKey('character-stats-form-level-up-hint'),
              style: textStyle.copyWith(fontSize: 14),
            )
          else if (_isSetup)
            Text(
              _quick
                  ? S.of(context).quickStartPageHint
                  : S.of(context).characterSetupHint,
              style: textStyle.copyWith(fontSize: 14),
            ),
          const SizedBox(height: 10),
        ] else ...[
          Text(tabName, style: textStyle.copyWith(fontSize: 20)),
          const SizedBox(height: 10),
        ],
        if (widget.isEditingAlternateForm) ...[
          WarningBox(
            warningTitle: S.of(context).transformationIsEditedWarningTitle,
            warningText: S.of(context).youAreEditingAnAlternateFormWarningText,
          ),
          const SizedBox(height: 20),
        ],
        if (page.showNameField) ...[
          _CharacterNameField(
            key: ValueKey(
              'character-stats-form-name-${_quick ? 'quick' : _pageIndex}',
            ),
            initialName: _name,
            onChanged: _onNameChanged,
          ),
          const SizedBox(height: 10),
        ],
        for (final (index, stat) in page.stats.indexed) ...[
          if (index > 0 || page.showNameField) ...[
            const SizedBox(height: 10),
            const HorizontalLine(useDarkColor: true),
            const SizedBox(height: 20),
          ],
          if (widget.initialValues[stat.statUuid]?.isCopy == true) ...[
            WarningBox(
              warningTitle: S.of(context).propertyIsCopied,
              warningText: S
                  .of(context)
                  .youAreEditingACopiedPropertyChangesWillNotAffect,
            ),
            const SizedBox(height: 10),
          ],
          PlayerStatsConfigurationVisuals(
            key: ValueKey('character-stats-form-field-${stat.statUuid}'),
            statConfiguration: stat,
            characterValue:
                _current[stat.statUuid] ?? widget.initialValues[stat.statUuid],
            characterName: widget.characterName,
            characterToRenderStatFor: widget.characterToRenderStatFor,
            collapsiblePreview: true,
            onNewStatValue: (value) => _onNewStatValue(stat.statUuid, value),
            onValidityChanged: (isValid) =>
                _onValidityChanged(stat.statUuid, isValid),
          ),
        ],
      ],
    );
  }

  Widget _buildFooter(BuildContext context) {
    final theme = CustomThemeProvider.of(context).theme;
    final pageValid = _isPageValid;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        10,
        20,
        modalFooterBottomPadding(context, classic: 20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!pageValid)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                S.of(context).fixMarkedFieldsHint,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelMedium!
                    .copyWith(color: theme.darkTextColor, fontSize: 14),
              ),
            ),
          if (_isSetup && _quick) ...[
            _ButtonRow(
              leading: CustomButton(
                key: CharacterStatsFormContent.allSectionsKey,
                label: S.of(context).quickStartAllSections,
                onPressed: _onAllSections,
              ),
              trailing: CustomButton(
                label: S.of(context).characterSetupFinish,
                variant: CustomButtonVariant.AccentButton,
                onPressed: pageValid ? _onNext : null,
              ),
            ),
            const SizedBox(height: 8),
            _ButtonRow(
              leading: CustomButton(
                label: S.of(context).cancel,
                variant: CustomButtonVariant.FlatButton,
                onPressed: _onCancel,
              ),
              trailing: const SizedBox.shrink(),
            ),
          ] else if (_isGuided) ...[
            _ButtonRow(
              leading: _pageIndex > 0
                  ? CustomButton(label: S.of(context).back, onPressed: _onBack)
                  : null,
              trailing: CustomButton(
                label: _isLastPage
                    ? S.of(context).characterSetupFinish
                    : S.of(context).next,
                variant: CustomButtonVariant.AccentButton,
                onPressed: pageValid ? _onNext : null,
              ),
            ),
            const SizedBox(height: 8),
            _ButtonRow(
              leading: CustomButton(
                label: S.of(context).cancel,
                variant: CustomButtonVariant.FlatButton,
                onPressed: _onCancel,
              ),
              trailing: _isSetup
                  ? CustomButton(
                      label: S.of(context).fillInLater,
                      variant: CustomButtonVariant.FlatButton,
                      onPressed: pageValid ? _onFillInLater : null,
                    )
                  : const SizedBox.shrink(),
            ),
          ] else
            _ButtonRow(
              leading: CustomButton(
                label: S.of(context).cancel,
                onPressed: _onCancel,
              ),
              trailing: CustomButton(
                label: S.of(context).save,
                onPressed: pageValid ? _onNext : null,
              ),
            ),
        ],
      ),
    );
  }
}

/// "Schnell starten": the first choice of the setup, above the first page.
class _QuickStartCard extends StatelessWidget {
  const _QuickStartCard({required this.fields, required this.onStart});

  /// What the quick start asks for, e.g. "Name, Porträt und Grundwerte".
  final String fields;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = CustomThemeProvider.of(context).theme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
      decoration: BoxDecoration(
        color: theme.accentColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.accentColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: CustomFaIcon(
                  icon: FontAwesomeIcons.bolt,
                  size: 18,
                  color: theme.accentColor,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s.quickStartTitle,
                      style: textTheme.titleSmall!.copyWith(
                        color: theme.darkTextColor,
                        fontSize: 17,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      s.quickStartText(fields),
                      style: textTheme.bodySmall!.copyWith(
                        color: theme.darkTextColor.withValues(alpha: 0.85),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerRight,
            child: CustomButton(
              key: CharacterStatsFormContent.quickStartKey,
              isSubbutton: true,
              variant: CustomButtonVariant.AccentButton,
              label: s.quickStartTitle,
              onPressed: onStart,
            ),
          ),
        ],
      ),
    );
  }
}

/// Two footer buttons at the row's ends; on narrow phones (or with long
/// translations) they shrink instead of overflowing.
class _ButtonRow extends StatelessWidget {
  const _ButtonRow({required this.leading, required this.trailing});

  final Widget? leading;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (leading != null)
          Flexible(
            child: FittedBox(fit: BoxFit.scaleDown, child: leading),
          ),
        const Spacer(),
        Flexible(
          child: FittedBox(fit: BoxFit.scaleDown, child: trailing),
        ),
      ],
    );
  }
}

/// The character name input. Owns its controller: the modal's shadow draws
/// the page a second time, and two text fields must not share a controller.
class _CharacterNameField extends StatefulWidget {
  const _CharacterNameField({
    super.key,
    required this.initialName,
    required this.onChanged,
  });

  final String initialName;
  final ValueChanged<String> onChanged;

  @override
  State<_CharacterNameField> createState() => _CharacterNameFieldState();
}

class _CharacterNameFieldState extends State<_CharacterNameField> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initialName,
  );

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onChanged);
  }

  void _onChanged() => widget.onChanged(_controller.text);

  @override
  void dispose() {
    _controller.removeListener(_onChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      labelText: S.of(context).characterName,
      placeholderText: S.of(context).nameOfCharacterHelperText,
      textEditingController: _controller,
      keyboardType: TextInputType.text,
      errorText: _controller.text.trim().isEmpty
          ? S.of(context).characterNameRequired
          : null,
    );
  }
}
