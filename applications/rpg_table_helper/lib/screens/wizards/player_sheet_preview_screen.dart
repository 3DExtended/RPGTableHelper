import 'package:flutter/material.dart';
import 'package:quest_keeper/components/custom_button.dart';
import 'package:quest_keeper/components/navbar.dart';
import 'package:quest_keeper/generated/l10n.dart';
import 'package:quest_keeper/main.dart';
import 'package:quest_keeper/models/rpg_character_configuration.dart';
import 'package:quest_keeper/models/rpg_configuration_model.dart';
import 'package:quest_keeper/models/rpg_configuration_templates.dart';
import 'package:quest_keeper/screens/pageviews/player_pageview/player_page_screen.dart';
import 'package:quest_keeper/services/custom_theme_provider.dart';

/// "So sieht es der Spieler": the character sheet as a player will see it,
/// with a sample character, on a phone or a tablet. Lets the game master
/// check the setup before anyone has joined. Nothing here is saved.
class PlayerSheetPreviewScreen extends StatefulWidget {
  const PlayerSheetPreviewScreen({super.key, required this.rpgConfig});

  /// The configuration to show; the sheet itself reads the campaign
  /// configuration from the provider, so persist edits before opening.
  final RpgConfigurationModel rpgConfig;

  /// A typical phone (iPhone 17) and a tablet in landscape (iPad Air 11").
  static const phoneSize = Size(402, 874);
  static const tabletSize = Size(1180, 820);

  static Future<void> open(RpgConfigurationModel rpgConfig) =>
      navigatorKey.currentState!.push(
        MaterialPageRoute(
          builder: (_) => PlayerSheetPreviewScreen(rpgConfig: rpgConfig),
        ),
      );

  /// Types without a generic sample value (nothing to show in a preview).
  static const _typesWithoutSample = {
    CharacterStatValueType.companionSelector,
    CharacterStatValueType.transformIntoAlternateFormBtn,
    CharacterStatValueType.unsupported,
  };

  /// A character with a sample value for every property of every tab and
  /// nothing of the template's sample data (companions, transformations,
  /// items). Properties of the templates get values that fit them
  /// ([RpgConfigurationTemplates.sampleValues]).
  static RpgCharacterConfiguration sampleCharacter(
    RpgConfigurationModel rpgConfig,
    String name,
  ) {
    final base = RpgCharacterConfiguration.getBaseConfiguration(rpgConfig);
    final stats = {for (final s in base.characterStats) s.statUuid: s};

    // The generic samples cover the start tab; the other tabs get the same.
    for (final tab in rpgConfig.characterStatTabsDefinition ??
        const <CharacterStatsTabDefinition>[]) {
      if (tab.isDefaultTab == true) continue;
      final asStartTab = rpgConfig.copyWith(characterStatTabsDefinition: [
        tab.copyWith(
          isDefaultTab: true,
          statsInTab: tab.statsInTab
              .where((s) => !_typesWithoutSample.contains(s.valueType))
              .toList(),
        ),
      ]);
      for (final stat in RpgCharacterConfiguration.getDefaultStats(
          asStartTab, false, null)) {
        stats.putIfAbsent(stat.statUuid, () => stat);
      }
    }

    final fitting = RpgConfigurationTemplates.sampleValues();
    return base.copyWith(
      characterName: name,
      characterStats: [
        for (final stat in stats.values)
          if (fitting[stat.statUuid] case final value?)
            stat.copyWith(serializedValue: value)
          else
            stat,
      ],
      companionCharacters: [],
      transformationComponents: [],
      alternateForms: [],
      alternateForm: null,
      isAlternateFormActive: null,
      inventory: [],
    );
  }

  @override
  State<PlayerSheetPreviewScreen> createState() =>
      _PlayerSheetPreviewScreenState();
}

class _PlayerSheetPreviewScreenState extends State<PlayerSheetPreviewScreen> {
  bool showPhone = true;
  RpgCharacterConfiguration? sample;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    sample ??= PlayerSheetPreviewScreen.sampleCharacter(
      widget.rpgConfig,
      S.of(context).playerPreviewSampleCharacterName,
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = CustomThemeProvider.of(context);
    final theme = themeProvider.theme;
    final textTheme = Theme.of(context).textTheme;
    final s = S.of(context);
    final deviceSize = showPhone
        ? PlayerSheetPreviewScreen.phoneSize
        : PlayerSheetPreviewScreen.tabletSize;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        color: theme.bgColor,
        child: Column(
          children: [
            Navbar(
              backInsteadOfCloseIcon: true,
              closeFunction: () => Navigator.of(context).pop(),
              menuOpen: null,
              useTopSafePadding: true,
              titleWidget: Text(
                s.playerPreviewTitle,
                textAlign: TextAlign.center,
                style: textTheme.titleLarge!.copyWith(
                  color:
                      themeProvider.brightnessNotifier.value == Brightness.light
                      ? theme.textColor
                      : theme.darkTextColor,
                  fontSize: 24,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: [
                  CustomButton(
                    key: const ValueKey('playerPreviewPhone'),
                    isSubbutton: true,
                    variant: showPhone
                        ? CustomButtonVariant.AccentButton
                        : CustomButtonVariant.FlatButton,
                    label: s.playerPreviewPhone,
                    onPressed: () => setState(() => showPhone = true),
                  ),
                  CustomButton(
                    key: const ValueKey('playerPreviewTablet'),
                    isSubbutton: true,
                    variant: showPhone
                        ? CustomButtonVariant.FlatButton
                        : CustomButtonVariant.AccentButton,
                    label: s.playerPreviewTablet,
                    onPressed: () => setState(() => showPhone = false),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                s.playerPreviewHint,
                textAlign: TextAlign.center,
                style: textTheme.bodySmall!.copyWith(
                  color: theme.darkTextColor.withValues(alpha: 0.8),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: _DeviceFrame(
                  // A new key per device rebuilds the sheet with its layout.
                  key: ValueKey(showPhone),
                  size: deviceSize,
                  ink: theme.darkTextColor,
                  child: PlayerPageScreen(
                    routeSettings: PlayerPageScreenRouteSettings(
                      characterConfigurationOverride: sample,
                      disableEdit: true,
                      showInventory: true,
                      showMoney: true,
                      showRecipes: false,
                      showLore: false,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shows [child] as if it ran on a device of [size], scaled to fit.
class _DeviceFrame extends StatelessWidget {
  const _DeviceFrame({
    super.key,
    required this.size,
    required this.ink,
    required this.child,
  });

  final Size size;
  final Color ink;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final radius = size.shortestSide < 600 ? 44.0 : 24.0;
    final mediaQuery = MediaQuery.of(context);

    return FittedBox(
      fit: BoxFit.contain,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius + 10),
          border: Border.all(color: ink.withValues(alpha: 0.5), width: 3),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: SizedBox.fromSize(
            size: size,
            child: MediaQuery(
              data: mediaQuery.copyWith(
                size: size,
                padding: EdgeInsets.zero,
                viewPadding: EdgeInsets.zero,
                viewInsets: EdgeInsets.zero,
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
