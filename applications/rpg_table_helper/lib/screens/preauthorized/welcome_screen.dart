import 'package:flutter/material.dart';
import 'package:quest_keeper/components/colored_rotated_square.dart';
import 'package:quest_keeper/components/custom_button.dart';
import 'package:quest_keeper/components/horizontal_line.dart';
import 'package:quest_keeper/generated/l10n.dart';
import 'package:quest_keeper/screens/preauthorized/login_screen.dart';
import 'package:quest_keeper/services/custom_theme_provider.dart';
import 'package:quest_keeper/services/onboarding_intent_store.dart';

/// First screen for people who are not signed in: says what the app is for
/// and offers the two ways in, leading a game or joining one.
///
/// Both ways lead to [LoginScreen] (which also offers registration). The
/// chosen [OnboardingIntent] is stored for the role selection after sign-in
/// and passed to [LoginScreen] as route argument.
class WelcomeScreen extends StatelessWidget {
  static const route = 'welcome';

  const WelcomeScreen({super.key});

  Future<void> _choose(BuildContext context, OnboardingIntent intent) async {
    await saveOnboardingIntent(intent);
    if (!context.mounted) return;
    await Navigator.of(context).pushNamed(LoginScreen.route, arguments: intent);
  }

  @override
  Widget build(BuildContext context) {
    final theme = CustomThemeProvider.of(context).theme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: theme.bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.18,
                      ),
                      child: Image.asset(
                        "assets/icons/icon_flat.png",
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Semantics(
                      header: true,
                      child: Text(
                        S.of(context).appName,
                        textAlign: TextAlign.center,
                        style: textTheme.headlineLarge!.copyWith(
                          fontFamily: 'Ruwudu',
                          fontSize: 40,
                          color: theme.darkTextColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _OrnamentDivider(color: theme.darkColor),
                    const SizedBox(height: 16),
                    Text(
                      S.of(context).welcomeTagline,
                      textAlign: TextAlign.center,
                      style: textTheme.titleMedium!.copyWith(
                        fontFamily: 'Ruwudu',
                        fontSize: 20,
                        color: theme.darkTextColor,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      S.of(context).welcomeDescription,
                      textAlign: TextAlign.center,
                      style: textTheme.bodyLarge!.copyWith(
                        fontFamily: 'Ruwudu',
                        color: theme.darkTextColor.withValues(alpha: 0.85),
                      ),
                    ),
                    const SizedBox(height: 36),
                    _WelcomePath(
                      buttonKey: const ValueKey('welcome-lead'),
                      label: S.of(context).welcomeLeadButton,
                      hint: S.of(context).welcomeLeadHint,
                      variant: CustomButtonVariant.AccentButton,
                      onPressed: () => _choose(context, OnboardingIntent.lead),
                    ),
                    const SizedBox(height: 24),
                    _WelcomePath(
                      buttonKey: const ValueKey('welcome-join'),
                      label: S.of(context).welcomeJoinButton,
                      hint: S.of(context).welcomeJoinHint,
                      variant: CustomButtonVariant.DarkButton,
                      onPressed: () => _choose(context, OnboardingIntent.join),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Thin line with a diamond in the middle, as used in the app's chrome.
class _OrnamentDivider extends StatelessWidget {
  const _OrnamentDivider({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: SizedBox(
        width: 220,
        child: Row(
          children: [
            const Expanded(child: HorizontalLine(useDarkColor: true)),
            ColoredRotatedSquare(isSolidSquare: true, color: color),
            const Expanded(child: HorizontalLine(useDarkColor: true)),
          ],
        ),
      ),
    );
  }
}

/// One way into the app: a large button with a short line about what
/// happens next.
class _WelcomePath extends StatelessWidget {
  const _WelcomePath({
    required this.buttonKey,
    required this.label,
    required this.hint,
    required this.variant,
    required this.onPressed,
  });

  final Key buttonKey;
  final String label;
  final String hint;
  final CustomButtonVariant variant;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = CustomThemeProvider.of(context).theme;

    return Column(
      children: [
        CustomButton(
          key: buttonKey,
          width: 298,
          height: 55,
          boderRadiusOverride: 7,
          label: label,
          variant: variant,
          onPressed: onPressed,
        ),
        const SizedBox(height: 8),
        Text(
          hint,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
            fontFamily: 'Ruwudu',
            color: theme.darkTextColor.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }
}
