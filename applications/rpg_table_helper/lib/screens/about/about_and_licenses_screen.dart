import 'package:flutter/material.dart';
import 'package:quest_keeper/components/custom_button.dart';
import 'package:quest_keeper/components/navbar.dart';
import 'package:quest_keeper/generated/l10n.dart';
import 'package:quest_keeper/screens/about/srd_attribution.dart';
import 'package:quest_keeper/services/custom_theme_provider.dart';
import 'package:url_launcher/url_launcher.dart';

/// App info and licenses: the CC BY 4.0 attribution of the SRD 5.2.1 the
/// "Fantasy 5E (SRD)" template is built on, plus Flutter's license list.
class AboutAndLicensesScreen extends StatelessWidget {
  static const route = '/about-and-licenses';

  static const appName = 'QuestKeeper';

  const AboutAndLicensesScreen({super.key});

  Future<void> _openLicense() async {
    final url = Uri.parse(ccByLicenseUrl);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = CustomThemeProvider.of(context);
    final theme = themeProvider.theme;
    final textTheme = Theme.of(context).textTheme;
    final s = S.of(context);

    final bodyStyle = textTheme.bodyMedium!.copyWith(
      color: theme.darkTextColor,
    );
    final hintStyle = bodyStyle.copyWith(fontStyle: FontStyle.italic);
    final sectionStyle = textTheme.titleLarge!.copyWith(
      color: theme.darkTextColor,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    );
    final labelStyle = textTheme.titleMedium!.copyWith(
      color: theme.darkTextColor,
      fontWeight: FontWeight.bold,
    );

    Widget gap([double height = 12]) => SizedBox(height: height);

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
                s.aboutLicensesTitle,
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
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 700),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          appName,
                          style: textTheme.headlineMedium!.copyWith(
                            color: theme.darkTextColor,
                          ),
                        ),
                        gap(24),
                        Text(s.aboutLicensesSrdTitle, style: sectionStyle),
                        gap(),
                        Text(s.aboutLicensesSrdIntro, style: bodyStyle),
                        gap(16),
                        Text(
                          s.aboutLicensesAttributionEnglish,
                          style: labelStyle,
                        ),
                        gap(6),
                        SelectableText(
                          srdAttributionEnglish,
                          key: const ValueKey('srdAttributionEnglish'),
                          style: bodyStyle,
                        ),
                        gap(16),
                        Text(
                          s.aboutLicensesAttributionGerman,
                          style: labelStyle,
                        ),
                        gap(6),
                        SelectableText(
                          srdAttributionGerman,
                          key: const ValueKey('srdAttributionGerman'),
                          style: bodyStyle,
                        ),
                        gap(6),
                        Text(
                          s.aboutLicensesAuthoritativeHint,
                          style: hintStyle,
                        ),
                        gap(16),
                        Text(s.aboutLicensesChanges, style: bodyStyle),
                        gap(16),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: CustomButton(
                            key: const ValueKey('openCcByLicense'),
                            onPressed: _openLicense,
                            label: s.aboutLicensesOpenLicense,
                          ),
                        ),
                        gap(6),
                        SelectableText(ccByLicenseUrl, style: hintStyle),
                        gap(16),
                        Text(s.aboutLicensesNotAffiliated, style: bodyStyle),
                        gap(32),
                        Text(
                          s.aboutLicensesOpenSourceTitle,
                          style: sectionStyle,
                        ),
                        gap(),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: CustomButton(
                            key: const ValueKey('showFlutterLicenses'),
                            onPressed: () => showLicensePage(
                              context: context,
                              applicationName: appName,
                            ),
                            label: s.aboutLicensesShowOpenSource,
                          ),
                        ),
                        gap(32),
                      ],
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
