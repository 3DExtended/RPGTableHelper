import 'package:flutter/material.dart';
import 'package:quest_keeper/generated/l10n.dart';
import 'package:quest_keeper/helpers/character_sheet_skins/character_sheet_skin.dart';
import 'package:quest_keeper/services/custom_theme_provider.dart';

String localizedCharacterSheetSkinName(BuildContext context, String skinId) {
  final s = S.of(context);
  switch (skinId) {
    case CharacterSheetSkinIds.classicLight:
      return s.characterSheetSkinClassicLight;
    case CharacterSheetSkinIds.classicDark:
      return s.characterSheetSkinClassicDark;
    case CharacterSheetSkinIds.arcaneLedger:
      return s.characterSheetSkinArcaneLedger;
    case CharacterSheetSkinIds.nightCartographer:
      return s.characterSheetSkinNightCartographer;
    default:
      return skinId;
  }
}

/// Grid of the four v1 skins. [selectedSkinId] null means "use campaign default"
/// only when [showUseCampaignDefault] is true and that option is selected.
class CharacterSheetSkinPicker extends StatelessWidget {
  final String? selectedSkinId;
  final String? campaignDefaultSkinId;
  final bool showUseCampaignDefault;
  final ValueChanged<String?> onSelected;

  const CharacterSheetSkinPicker({
    super.key,
    required this.selectedSkinId,
    required this.onSelected,
    this.campaignDefaultSkinId,
    this.showUseCampaignDefault = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = CustomThemeProvider.of(context).theme;
    final defaultId =
        campaignDefaultSkinId ?? CharacterSheetSkinIds.classicDark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showUseCampaignDefault) ...[
          _SkinOptionTile(
            title: S.of(context).characterSheetSkinUseCampaignDefault,
            subtitle: localizedCharacterSheetSkinName(context, defaultId),
            swatch: CharacterSheetSkin.forRenderId(
              resolveCharacterSheetSkin(
                characterSkinId: null,
                campaignDefaultSkinId: defaultId,
              ).renderSkinId,
            ).theme.bgColor,
            selected: selectedSkinId == null,
            accent: theme.accentColor,
            ink: theme.darkTextColor,
            onTap: () => onSelected(null),
          ),
          const SizedBox(height: 12),
        ],
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: CharacterSheetSkinIds.all.map((id) {
            final skin = CharacterSheetSkin.forRenderId(id);
            final isCampaignDefault = id == defaultId;
            return SizedBox(
              width: 160,
              child: _SkinOptionTile(
                title: localizedCharacterSheetSkinName(context, id),
                subtitle: isCampaignDefault
                    ? S.of(context).characterSheetSkinCampaignDefaultLabel
                    : null,
                swatch: skin.theme.bgColor,
                selected: selectedSkinId == id,
                accent: theme.accentColor,
                ink: theme.darkTextColor,
                onTap: () => onSelected(id),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _SkinOptionTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Color swatch;
  final bool selected;
  final Color accent;
  final Color ink;
  final VoidCallback onTap;

  const _SkinOptionTile({
    required this.title,
    required this.swatch,
    required this.selected,
    required this.accent,
    required this.ink,
    required this.onTap,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: selected ? accent : ink.withValues(alpha: 0.35),
              width: selected ? 2.5 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 48,
                decoration: BoxDecoration(
                  color: swatch,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: ink.withValues(alpha: 0.2)),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: ink,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              if (subtitle != null)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    subtitle!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: ink.withValues(alpha: 0.55),
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                          height: 1.2,
                        ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
