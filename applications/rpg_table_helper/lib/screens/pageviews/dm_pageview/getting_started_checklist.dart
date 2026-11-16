import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:quest_keeper/components/custom_button.dart';
import 'package:quest_keeper/components/custom_fa_icon.dart';
import 'package:quest_keeper/generated/l10n.dart';
import 'package:quest_keeper/models/rpg_configuration_model.dart';
import 'package:quest_keeper/services/custom_theme_provider.dart';

/// What the game master has done of the first steps of a campagne.
class GettingStartedProgress {
  const GettingStartedProgress({
    required this.sheetReady,
    required this.playersJoined,
    required this.hasNote,
  });

  /// The configuration [config] of a campagne with [playerCount] players and
  /// [noteCount] note documents.
  factory GettingStartedProgress.of({
    required RpgConfigurationModel? config,
    required int playerCount,
    required int noteCount,
  }) => GettingStartedProgress(
    sheetReady: (config?.characterStatTabsDefinition ?? const [])
        .any((tab) => tab.statsInTab.isNotEmpty),
    playersJoined: playerCount > 0,
    hasNote: noteCount > 0,
  );

  final bool sheetReady;
  final bool playersJoined;
  final bool hasNote;

  bool get isComplete => sheetReady && playersJoined && hasNote;
}

/// "Erste Schritte" on the game master's campagne page: sheet, players,
/// first note. Shown until all three are done or it is hidden.
class GettingStartedChecklist extends StatelessWidget {
  const GettingStartedChecklist({
    super.key,
    required this.progress,
    required this.onSetUpSheet,
    required this.onInvite,
    required this.onOpenNotes,
    required this.onDismiss,
  });

  final GettingStartedProgress progress;
  final VoidCallback onSetUpSheet;
  final VoidCallback? onInvite;
  final VoidCallback? onOpenNotes;
  final VoidCallback onDismiss;

  static const dismissKey = ValueKey('gettingStartedDismiss');
  static const sheetKey = ValueKey('gettingStartedSheet');
  static const playersKey = ValueKey('gettingStartedPlayers');
  static const noteKey = ValueKey('gettingStartedNote');

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = CustomThemeProvider.of(context).theme;
    final textTheme = Theme.of(context).textTheme;
    final done = [
      progress.sheetReady,
      progress.playersJoined,
      progress.hasNote,
    ].where((d) => d).length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 10, 6, 10),
      decoration: BoxDecoration(
        color: theme.accentColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.accentColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  s.gettingStartedTitle(done, 3),
                  style: textTheme.titleSmall!.copyWith(
                    color: theme.darkTextColor,
                    fontSize: 18,
                  ),
                ),
              ),
              Semantics(
                label: s.gettingStartedDismiss,
                button: true,
                child: CustomButton(
                  key: dismissKey,
                  isSubbutton: true,
                  variant: CustomButtonVariant.FlatButton,
                  icon: CustomFaIcon(
                    icon: FontAwesomeIcons.xmark,
                    size: 16,
                    color: theme.darkTextColor,
                  ),
                  onPressed: onDismiss,
                ),
              ),
            ],
          ),
          _Step(
            key: sheetKey,
            done: progress.sheetReady,
            label: s.gettingStartedSheet,
            actionLabel: s.gettingStartedSheetAction,
            onAction: onSetUpSheet,
          ),
          _Step(
            key: playersKey,
            done: progress.playersJoined,
            label: s.gettingStartedPlayers,
            actionLabel: s.gettingStartedPlayersAction,
            onAction: onInvite,
          ),
          _Step(
            key: noteKey,
            done: progress.hasNote,
            label: s.gettingStartedNote,
            actionLabel: s.gettingStartedNoteAction,
            onAction: onOpenNotes,
          ),
        ],
      ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({
    super.key,
    required this.done,
    required this.label,
    required this.actionLabel,
    required this.onAction,
  });

  final bool done;
  final String label;
  final String actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = CustomThemeProvider.of(context).theme;
    final style = Theme.of(context).textTheme.bodyMedium!.copyWith(
      color: theme.darkTextColor.withValues(alpha: done ? 0.6 : 1),
      fontSize: 16,
      decoration: done ? TextDecoration.lineThrough : null,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Semantics(
            label: done ? S.of(context).gettingStartedDone : null,
            child: CustomFaIcon(
              icon: done
                  ? FontAwesomeIcons.solidCircleCheck
                  : FontAwesomeIcons.circle,
              size: 18,
              color: done ? theme.accentColor : theme.darkTextColor,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(label, style: style)),
          if (!done && onAction != null)
            CustomButton(
              isSubbutton: true,
              variant: CustomButtonVariant.FlatButton,
              label: actionLabel,
              onPressed: onAction,
            )
          else
            // Keeps the rows as high as those with a button.
            const SizedBox(height: 40),
        ],
      ),
    );
  }
}
