import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:quest_keeper/components/custom_fa_icon.dart';
import 'package:quest_keeper/generated/l10n.dart';
import 'package:quest_keeper/services/custom_theme_provider.dart';

/// Where the image for a note block comes from.
enum NoteImageSource { upload, generate }

/// What can be inserted between two note blocks.
enum NoteBlockInsertKind { paragraph, uploadImage, generateImage }

class NoteBlockMenuItem<T> {
  const NoteBlockMenuItem(this.value, this.icon, this.label);

  final T value;
  final FaIconData icon;
  final String label;
}

/// Shows a small menu right below the widget of [anchorContext] and returns
/// the chosen value, or null if the menu was dismissed.
Future<T?> showNoteBlockMenu<T>(
  BuildContext anchorContext,
  List<NoteBlockMenuItem<T>> items,
) {
  final theme = CustomThemeProvider.of(anchorContext).theme;
  final anchor = anchorContext.findRenderObject() as RenderBox;
  final overlay =
      Overlay.of(anchorContext).context.findRenderObject() as RenderBox;
  final topLeft = anchor.localToGlobal(
    Offset(0, anchor.size.height),
    ancestor: overlay,
  );
  final bottomRight = anchor.localToGlobal(
    anchor.size.bottomRight(Offset.zero),
    ancestor: overlay,
  );

  return showMenu<T>(
    context: anchorContext,
    color: theme.bgColor,
    position: RelativeRect.fromRect(
      Rect.fromPoints(topLeft, bottomRight),
      Offset.zero & overlay.size,
    ),
    items: [
      for (final item in items)
        PopupMenuItem<T>(
          value: item.value,
          child: Row(
            children: [
              CustomFaIcon(icon: item.icon, size: 16, color: theme.darkColor),
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  item.label,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(anchorContext).textTheme.bodyMedium!
                      .copyWith(color: theme.darkTextColor, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
    ],
  );
}

/// The two ways to get an image: upload one or generate one.
Future<NoteImageSource?> showNoteImageSourceMenu(BuildContext anchorContext) {
  return showNoteBlockMenu(anchorContext, [
    NoteBlockMenuItem(
      NoteImageSource.upload,
      FontAwesomeIcons.image,
      S.of(anchorContext).uploadImageMenuLabel,
    ),
    NoteBlockMenuItem(
      NoteImageSource.generate,
      FontAwesomeIcons.wandMagicSparkles,
      S.of(anchorContext).generateImageBtnLabel,
    ),
  ]);
}
