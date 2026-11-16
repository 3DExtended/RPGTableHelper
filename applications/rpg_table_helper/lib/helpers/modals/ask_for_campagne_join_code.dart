import 'package:flutter/material.dart';
import 'package:quest_keeper/components/app_style_dialog.dart';
import 'package:quest_keeper/components/form_modal_frame.dart';
import 'package:quest_keeper/generated/l10n.dart';
import 'package:quest_keeper/generated/swaggen/swagger.models.swagger.dart';
import 'package:quest_keeper/helpers/join_code_input_formatter.dart';
import 'package:quest_keeper/helpers/modal_helpers.dart';
import 'package:quest_keeper/services/dependency_provider.dart';
import 'package:quest_keeper/services/join_requests/join_campagne_flow.dart';
import 'package:quest_keeper/services/rpg_entity_service.dart';

/// A join request that reached the server.
class JoinCampagneResult {
  const JoinCampagneResult({
    required this.playerCharacterId,
    required this.campagneJoinRequestId,
    required this.joinCode,
  });

  final PlayerCharacterIdentifier playerCharacterId;
  final String? campagneJoinRequestId;
  final String joinCode;
}

/// "Kampagne beitreten": asks for the join code and sends the join request.
///
/// With [existingCharacterId] the request is sent for that character.
/// Without it the dialog also asks for a character name and creates the
/// character first; the rest of the sheet is filled in after the DM accepts.
///
/// Returns `null` when the player cancels. A wrong code shows an inline
/// message and keeps the dialog open.
Future<JoinCampagneResult?> askForCampagneJoinCode(
  BuildContext context, {
  GlobalKey<NavigatorState>? overrideNavigatorKey,
  PlayerCharacterIdentifier? existingCharacterId,
  String? initialCode,
}) async {
  return await customShowCupertinoModalBottomSheet<JoinCampagneResult>(
    backgroundColor: const Color.fromARGB(192, 21, 21, 21),
    isDismissible: false,
    expand: false,
    closeProgressThreshold: -50000,
    enableDrag: false,
    context: context,
    overrideNavigatorKey: overrideNavigatorKey,
    builder: (context) => AskForCampagneJoinCodeModalContent(
      existingCharacterId: existingCharacterId,
      initialCode: initialCode,
    ),
  );
}

class AskForCampagneJoinCodeModalContent extends StatefulWidget {
  const AskForCampagneJoinCodeModalContent({
    super.key,
    this.existingCharacterId,
    this.initialCode,
  });

  final PlayerCharacterIdentifier? existingCharacterId;

  /// The code of a join link (QR code of "Spieler einladen"): filled in, so
  /// only the name is left to type.
  final String? initialCode;

  static const codeFieldKey = ValueKey('joinCodeField');
  static const nameFieldKey = ValueKey('joinCharacterNameField');
  static const submitButtonKey = ValueKey('joinSubmitButton');

  @override
  State<AskForCampagneJoinCodeModalContent> createState() =>
      _AskForCampagneJoinCodeModalContentState();
}

class _AskForCampagneJoinCodeModalContentState
    extends State<AskForCampagneJoinCodeModalContent> {
  final _codeController = TextEditingController();
  final _nameController = TextEditingController();

  String? _codeError;
  String? _nameError;
  bool _isBusy = false;

  /// The existing character, or the one created by an earlier attempt in
  /// this dialog (e.g. before a typo in the code), so a retry reuses it.
  PlayerCharacterIdentifier? _characterId;

  bool get _asksForName => widget.existingCharacterId == null;
  bool get _characterAlreadyCreated =>
      _asksForName && _characterId?.value != null;

  @override
  void initState() {
    super.initState();
    _characterId = widget.existingCharacterId;
    if (widget.initialCode case final code?) {
      _codeController.text = formatJoinCode(code);
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final s = S.of(context);
    final name = _nameController.text.trim();
    final codeProblem = validateJoinCode(_codeController.text);

    setState(() {
      _codeError = switch (codeProblem) {
        JoinCodeProblem.empty => s.joinCodeEmptyError,
        JoinCodeProblem.incomplete => s.joinCodeIncompleteError,
        null => null,
      };
      _nameError = _asksForName && !_characterAlreadyCreated && name.isEmpty
          ? s.nameRequiredError
          : null;
    });
    if (_codeError != null || _nameError != null) return;

    setState(() => _isBusy = true);
    final joinCode = formatJoinCode(_codeController.text);
    final outcome = await requestToJoinCampagne(
      service: DependencyProvider.of(context).getService<IRpgEntityService>(),
      joinCode: joinCode,
      playerCharacterId: _characterId,
      newCharacterName: name,
    );
    if (!mounted) return;

    setState(() {
      _isBusy = false;
      _characterId = outcome.playerCharacterId ?? _characterId;
    });

    switch (outcome) {
      case JoinCampagneRequested():
        Navigator.of(context).pop(JoinCampagneResult(
          playerCharacterId: outcome.playerCharacterId!,
          campagneJoinRequestId: outcome.campagneJoinRequestId,
          joinCode: joinCode,
        ));
      case JoinCampagneUnknownCode():
        setState(() => _codeError = s.joinCodeUnknownError);
      case JoinCampagneFailed():
        await outcome.response.possiblyHandleError(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return FormModalFrame(
      title: s.joinCampagneAction,
      primaryLabel: s.joinAction,
      primaryButtonKey: AskForCampagneJoinCodeModalContent.submitButtonKey,
      isBusy: _isBusy,
      onCancel: () => Navigator.of(context).pop(null),
      onPrimary: _submit,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            _asksForName
                ? s.joinCampagneNewCharacterIntro
                : s.assignCharacterToCampagneModalContent,
            style: appModalBodyStyle(context),
          ),
          const SizedBox(height: 20),
          FormModalTextField(
            key: AskForCampagneJoinCodeModalContent.codeFieldKey,
            controller: _codeController,
            labelText: s.joinCode,
            hintText: '123-456',
            keyboardType: TextInputType.number,
            inputFormatters: const [JoinCodeInputFormatter()],
            autofocus: widget.initialCode == null || !_asksForName,
            errorText: _codeError,
            textCapitalization: TextCapitalization.none,
            onChanged: (_) {
              if (_codeError != null) setState(() => _codeError = null);
            },
            style: appModalBodyStyle(context, fontSize: 28).copyWith(
              fontFamily: 'Ruwudu',
              letterSpacing: 4,
            ),
          ),
          if (_asksForName) ...[
            const SizedBox(height: 10),
            FormModalTextField(
              key: AskForCampagneJoinCodeModalContent.nameFieldKey,
              controller: _nameController,
              labelText: s.characterNameFieldLabel,
              keyboardType: TextInputType.text,
              textCapitalization: TextCapitalization.words,
              autofocus: widget.initialCode != null,
              enabled: !_characterAlreadyCreated && !_isBusy,
              errorText: _nameError,
              onChanged: (_) {
                if (_nameError != null) setState(() => _nameError = null);
              },
            ),
          ],
        ],
      ),
    );
  }
}
