import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:quest_keeper/components/custom_fa_icon.dart';
import 'package:quest_keeper/generated/l10n.dart';
import 'package:quest_keeper/services/custom_theme_provider.dart';

/// Shortest password a password account accepts.
///
/// The server only ever receives a hash of the password, so the app is the
/// only place these rules are checked. They mirror `passwordValid` in
/// `helpers/validation_helpers.dart`; a test keeps both in step.
const passwordMinLength = 8;

/// Longest password a password account accepts, see [passwordMinLength].
const passwordMaxLength = 41;

/// One rule a new password has to meet.
enum PasswordRule { minLength, maxLength }

/// Whether [password] meets [rule].
bool passwordRuleMet(PasswordRule rule, String password) {
  switch (rule) {
    case PasswordRule.minLength:
      return password.length >= passwordMinLength;
    case PasswordRule.maxLength:
      return password.length <= passwordMaxLength;
  }
}

/// Whether [password] meets every [PasswordRule].
bool allPasswordRulesMet(String password) =>
    PasswordRule.values.every((rule) => passwordRuleMet(rule, password));

/// Text colour for errors that stays readable on light and dark skins.
Color authErrorColor(BuildContext context) {
  final themeProvider = CustomThemeProvider.of(context);
  return themeProvider.brightnessNotifier.value == Brightness.dark
      ? const Color(0xffFF9A8F)
      : themeProvider.theme.darkRed;
}

/// Colour for a met rule's tick, readable on light and dark skins.
Color authSuccessColor(BuildContext context) {
  final themeProvider = CustomThemeProvider.of(context);
  return themeProvider.brightnessNotifier.value == Brightness.dark
      ? themeProvider.theme.lightGreen
      : themeProvider.theme.darkGreen;
}

/// Lists the password rules under a password field and ticks each one off
/// while the user types.
class PasswordRulesChecklist extends StatelessWidget {
  const PasswordRulesChecklist({
    super.key,
    required this.password,
    this.highlightUnmet = false,
  });

  final String password;

  /// Shows rules that are not met yet in the error colour, e.g. after the
  /// user tried to submit.
  final bool highlightUnmet;

  @override
  Widget build(BuildContext context) {
    final theme = CustomThemeProvider.of(context).theme;
    return Padding(
      padding: const EdgeInsets.only(left: 4, top: 2, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            S.of(context).passwordRulesTitle,
            style: Theme.of(context).textTheme.labelMedium!.copyWith(
              fontFamily: 'Ruwudu',
              color: theme.darkTextColor.withValues(alpha: 0.8),
            ),
          ),
          for (final rule in PasswordRule.values)
            PasswordRuleRow(
              key: ValueKey('passwordRule-${rule.name}'),
              label: _labelFor(context, rule),
              met: passwordRuleMet(rule, password),
              highlightUnmet: highlightUnmet,
            ),
        ],
      ),
    );
  }

  String _labelFor(BuildContext context, PasswordRule rule) {
    switch (rule) {
      case PasswordRule.minLength:
        return S.of(context).passwordRuleMinLength(passwordMinLength);
      case PasswordRule.maxLength:
        return S.of(context).passwordRuleMaxLength(passwordMaxLength);
    }
  }
}

/// One line of [PasswordRulesChecklist].
class PasswordRuleRow extends StatelessWidget {
  const PasswordRuleRow({
    super.key,
    required this.label,
    required this.met,
    this.highlightUnmet = false,
  });

  final String label;
  final bool met;
  final bool highlightUnmet;

  @override
  Widget build(BuildContext context) {
    final theme = CustomThemeProvider.of(context).theme;
    final color = met
        ? authSuccessColor(context)
        : (highlightUnmet
              ? authErrorColor(context)
              : theme.darkTextColor.withValues(alpha: 0.7));
    final status = met
        ? S.of(context).passwordRuleMet
        : S.of(context).passwordRuleNotMet;

    return Semantics(
      label: '$label: $status',
      excludeSemantics: true,
      child: Row(
        children: [
          CustomFaIcon(
            icon: met
                ? FontAwesomeIcons.solidCircleCheck
                : FontAwesomeIcons.circle,
            color: color,
            size: 14,
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelMedium!.copyWith(
                fontFamily: 'Ruwudu',
                color: met ? theme.darkTextColor : color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Short error text shown right under a form field.
class AuthFieldError extends StatelessWidget {
  const AuthFieldError({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 6),
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: Text(
          message,
          style: Theme.of(context).textTheme.labelMedium!
              .copyWith(fontFamily: 'Ruwudu', color: authErrorColor(context)),
        ),
      ),
    );
  }
}

/// A framed message on the auth screens, for friendly errors and hints.
class AuthMessageBox extends StatelessWidget {
  const AuthMessageBox({
    super.key,
    required this.message,
    this.isError = false,
  });

  final String message;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final theme = CustomThemeProvider.of(context).theme;
    final accent = isError ? authErrorColor(context) : theme.darkColor;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        border: Border.all(color: accent.withValues(alpha: 0.8)),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomFaIcon(
            icon: isError
                ? FontAwesomeIcons.circleExclamation
                : FontAwesomeIcons.circleInfo,
            color: accent,
            size: 14,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                fontFamily: 'Ruwudu',
                color: isError ? accent : theme.darkTextColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
