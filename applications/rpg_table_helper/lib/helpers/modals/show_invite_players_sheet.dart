import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:quest_keeper/components/app_style_dialog.dart';
import 'package:quest_keeper/components/custom_button.dart';
import 'package:quest_keeper/components/custom_fa_icon.dart';
import 'package:quest_keeper/components/form_modal_frame.dart';
import 'package:quest_keeper/generated/l10n.dart';
import 'package:quest_keeper/helpers/character_sheet_skins/character_sheet_skin_chrome.dart';
import 'package:quest_keeper/helpers/modal_helpers.dart';
import 'package:quest_keeper/services/custom_theme_provider.dart';
import 'package:quest_keeper/services/join_link.dart';
import 'package:share_plus/share_plus.dart';

/// Opens the platform share sheet. [origin] anchors the popover on iPad.
typedef InviteShareHandler = Future<void> Function({
  required String text,
  required String subject,
  Rect? origin,
});

Future<void> _shareWithPlatform({
  required String text,
  required String subject,
  Rect? origin,
}) async {
  await SharePlus.instance.share(
    ShareParams(text: text, subject: subject, sharePositionOrigin: origin),
  );
}

/// "Spieler einladen": the join code (large and copyable), a QR code with
/// the code, a share button and a one-line how-to for the players.
///
/// The QR code holds only the code; the app has no deep links.
Future<void> showInvitePlayersSheet(
  BuildContext context, {
  required String joinCode,
  required String campagneName,
  GlobalKey<NavigatorState>? overrideNavigatorKey,
}) async {
  await customShowCupertinoModalBottomSheet<void>(
    backgroundColor: const Color.fromARGB(192, 21, 21, 21),
    isDismissible: true,
    expand: false,
    closeProgressThreshold: -50000,
    enableDrag: true,
    context: context,
    overrideNavigatorKey: overrideNavigatorKey,
    builder: (context) => InvitePlayersSheetContent(
      joinCode: joinCode,
      campagneName: campagneName,
    ),
  );
}

class InvitePlayersSheetContent extends StatefulWidget {
  const InvitePlayersSheetContent({
    super.key,
    required this.joinCode,
    required this.campagneName,
    this.onShare,
  });

  final String joinCode;
  final String campagneName;

  /// Replaces the platform share sheet (tests).
  final InviteShareHandler? onShare;

  static const codeTextKey = ValueKey('inviteJoinCode');
  static const copyButtonKey = ValueKey('inviteCopyCode');
  static const shareButtonKey = ValueKey('inviteShare');

  @override
  State<InvitePlayersSheetContent> createState() =>
      _InvitePlayersSheetContentState();
}

class _InvitePlayersSheetContentState extends State<InvitePlayersSheetContent> {
  final _shareAnchorKey = GlobalKey();
  bool _copied = false;

  Future<void> _copyCode() async {
    await Clipboard.setData(ClipboardData(text: widget.joinCode));
    if (!mounted) return;
    setState(() => _copied = true);
    await Future<void>.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() => _copied = false);
  }

  Future<void> _share() async {
    final s = S.of(context);
    Rect? origin;
    final box =
        _shareAnchorKey.currentContext?.findRenderObject() as RenderBox?;
    if (box != null && box.hasSize) {
      origin = box.localToGlobal(Offset.zero) & box.size;
    }
    final share = widget.onShare ?? _shareWithPlatform;
    await share(
      text: s.inviteShareText(widget.campagneName, widget.joinCode),
      subject: s.inviteShareSubject(widget.campagneName),
      origin: origin,
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = CustomThemeProvider.of(context).theme;

    final codeBlock = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SelectableText(
          widget.joinCode,
          key: InvitePlayersSheetContent.codeTextKey,
          textAlign: TextAlign.center,
          style: appModalBodyStyle(context, fontSize: 44).copyWith(
            fontFamily: 'Ruwudu',
            fontWeight: FontWeight.bold,
            letterSpacing: 6,
          ),
        ),
        const SizedBox(height: 10),
        CustomButton(
          key: InvitePlayersSheetContent.copyButtonKey,
          onPressed: _copyCode,
          icon: CustomFaIcon(
            icon: _copied ? FontAwesomeIcons.check : FontAwesomeIcons.copy,
            size: 16,
            color: theme.darkColor,
          ),
          label: _copied ? s.copiedConfirmation : s.copyCodeAction,
        ),
      ],
    );

    final qrBlock = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            // QR codes need dark modules on a light ground in every skin.
            color: Colors.white,
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: theme.darkColor),
          ),
          child: QrImageView(
            // The key carries the data, which the widget keeps to itself.
            key: ValueKey(joinLinkFor(widget.joinCode)),
            // Scanned with the camera it opens the join dialog of the app.
            data: joinLinkFor(widget.joinCode),
            version: QrVersions.auto,
            size: 170,
            backgroundColor: Colors.white,
            eyeStyle: const QrEyeStyle(
              eyeShape: QrEyeShape.square,
              color: Colors.black,
            ),
            dataModuleStyle: const QrDataModuleStyle(
              dataModuleShape: QrDataModuleShape.square,
              color: Colors.black,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          s.qrCodeHint,
          textAlign: TextAlign.center,
          style: appModalBodyStyle(context, fontSize: 12),
        ),
      ],
    );

    return FormModalFrame(
      title: s.invitePlayersAction,
      primaryLabel: null,
      onPrimary: null,
      cancelLabel: s.closeAction,
      onCancel: () => Navigator.of(context).pop(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.campagneName,
            textAlign: TextAlign.center,
            style: appModalBodyStyle(
              context,
              fontSize: 20,
            ).copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            s.invitePlayersInstruction,
            textAlign: TextAlign.center,
            style: appModalBodyStyle(context),
          ),
          const SizedBox(height: 20),
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 40,
            runSpacing: 20,
            children: [codeBlock, qrBlock],
          ),
          const SizedBox(height: 20),
          Center(
            child: KeyedSubtree(
              key: _shareAnchorKey,
              child: CustomButton(
                key: InvitePlayersSheetContent.shareButtonKey,
                variant: CustomButtonVariant.AccentButton,
                onPressed: _share,
                icon: CustomFaIcon(
                  icon: FontAwesomeIcons.shareFromSquare,
                  size: 16,
                  // same contrast rule as the button label
                  color: isNightCartographerActive(context)
                      ? theme.bgColor
                      : theme.textColor,
                ),
                label: s.shareInviteAction,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            s.invitePlayersApprovalHint,
            textAlign: TextAlign.center,
            style: appModalBodyStyle(context, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
