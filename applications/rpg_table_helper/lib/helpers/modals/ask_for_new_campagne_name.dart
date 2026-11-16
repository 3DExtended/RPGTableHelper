import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:quest_keeper/components/app_style_dialog.dart';
import 'package:quest_keeper/components/custom_button.dart';
import 'package:quest_keeper/components/custom_fa_icon.dart';
import 'package:quest_keeper/components/form_modal_frame.dart';
import 'package:quest_keeper/generated/l10n.dart';
import 'package:quest_keeper/helpers/modal_helpers.dart';
import 'package:quest_keeper/services/custom_theme_provider.dart';

/// What the game master chose in "Neue Kampagne".
sealed class NewCampagneChoice {
  const NewCampagneChoice();
}

/// A new campagne with this (trimmed, not empty) name.
class NamedNewCampagne extends NewCampagneChoice {
  const NamedNewCampagne(this.name);

  final String name;
}

/// The demo campagne, to try the app alone first.
class DemoCampagne extends NewCampagneChoice {
  const DemoCampagne();
}

/// "Neue Kampagne": asks for the name of a new campagne, or offers the demo
/// campagne instead.
///
/// Returns `null` when cancelled. An empty name is not accepted (inline
/// message), so the server never sees one.
Future<NewCampagneChoice?> askForNewCampagneName(
  BuildContext context, {
  GlobalKey<NavigatorState>? overrideNavigatorKey,
}) async {
  return await customShowCupertinoModalBottomSheet<NewCampagneChoice>(
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
  static const demoButtonKey = ValueKey('newCampagneDemoButton');

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
    Navigator.of(context).pop(NamedNewCampagne(name));
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
          const SizedBox(height: 24),
          _DemoOffer(
            onPressed: () => Navigator.of(context).pop(const DemoCampagne()),
          ),
        ],
      ),
    );
  }
}

/// "Erst mal ausprobieren?": the demo campagne below the name field.
class _DemoOffer extends StatelessWidget {
  const _DemoOffer({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = CustomThemeProvider.of(context).theme;
    final bodyStyle = appModalBodyStyle(context);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(color: theme.accentColor.withValues(alpha: 0.6)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            s.newCampagneDemoTitle,
            style: bodyStyle.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(s.newCampagneDemoText, style: bodyStyle),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: CustomButton(
              key: AskForNewCampagneNameModalContent.demoButtonKey,
              isSubbutton: true,
              icon: CustomFaIcon(
                icon: FontAwesomeIcons.flask,
                size: 14,
                color: theme.darkColor,
              ),
              label: s.newCampagneDemoButton,
              onPressed: onPressed,
            ),
          ),
        ],
      ),
    );
  }
}
