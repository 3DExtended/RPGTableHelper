import 'package:flutter/material.dart';
import 'package:quest_keeper/components/app_style_dialog.dart';
import 'package:quest_keeper/components/form_modal_frame.dart';
import 'package:quest_keeper/generated/l10n.dart';
import 'package:quest_keeper/helpers/modal_helpers.dart';

/// "Neue Kampagne": asks for the name of a new campagne.
///
/// Returns the trimmed name, or `null` when cancelled. An empty name is not
/// accepted (inline message), so the server never sees one.
Future<String?> askForNewCampagneName(
  BuildContext context, {
  GlobalKey<NavigatorState>? overrideNavigatorKey,
}) async {
  return await customShowCupertinoModalBottomSheet<String>(
    backgroundColor: const Color.fromARGB(192, 21, 21, 21),
    isDismissible: false,
    expand: false,
    closeProgressThreshold: -50000,
    enableDrag: false,
    context: context,
    overrideNavigatorKey: overrideNavigatorKey,
    builder: (context) => const AskForNewCampagneNameModalContent(),
  );
}

class AskForNewCampagneNameModalContent extends StatefulWidget {
  const AskForNewCampagneNameModalContent({super.key});

  static const nameFieldKey = ValueKey('newCampagneNameField');
  static const submitButtonKey = ValueKey('newCampagneSubmitButton');

  @override
  State<AskForNewCampagneNameModalContent> createState() =>
      _AskForNewCampagneNameModalContentState();
}

class _AskForNewCampagneNameModalContentState
    extends State<AskForNewCampagneNameModalContent> {
  final _nameController = TextEditingController();
  String? _nameError;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _nameError = S.of(context).nameRequiredError);
      return;
    }
    Navigator.of(context).pop(name);
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return FormModalFrame(
      title: s.newCampaign,
      primaryLabel: s.createAction,
      primaryButtonKey: AskForNewCampagneNameModalContent.submitButtonKey,
      onCancel: () => Navigator.of(context).pop(null),
      onPrimary: _submit,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(s.newCampagneIntro, style: appModalBodyStyle(context)),
          const SizedBox(height: 20),
          FormModalTextField(
            key: AskForNewCampagneNameModalContent.nameFieldKey,
            controller: _nameController,
            labelText: s.campaigneName,
            keyboardType: TextInputType.text,
            textCapitalization: TextCapitalization.words,
            autofocus: true,
            errorText: _nameError,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submit(),
            onChanged: (_) {
              if (_nameError != null) setState(() => _nameError = null);
            },
          ),
        ],
      ),
    );
  }
}
