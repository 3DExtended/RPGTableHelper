import 'dart:io' show Platform;

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:quest_keeper/components/custom_fa_icon.dart';
import 'package:quest_keeper/components/navbar.dart';
import 'package:quest_keeper/l10n/app_localizations.dart';
import 'package:quest_keeper/screens/about/about_and_licenses_screen.dart';
import 'package:quest_keeper/screens/settings/agent_debug_log_screen.dart';
import 'package:quest_keeper/screens/settings/api_keys_screen.dart';
import 'package:quest_keeper/services/custom_theme_provider.dart';

class UserSettingsScreen extends StatelessWidget {
  static const route = '/settings';

  /// When null, the iOS realtime hint uses [Platform.isIOS]. Set in tests/goldens.
  final bool? showRealtimeSessionHint;

  const UserSettingsScreen({super.key, this.showRealtimeSessionHint});

  bool get _showIosRealtimeSessionHint {
    if (showRealtimeSessionHint != null) {
      return showRealtimeSessionHint!;
    }
    return !kIsWeb && Platform.isIOS;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        color: CustomThemeProvider.of(context).theme.bgColor,
        child: Column(
          children: [
            Navbar(
              backInsteadOfCloseIcon: true,
              closeFunction: () => Navigator.of(context).pop(),
              menuOpen: null,
              useTopSafePadding: true,
              titleWidget: Text(
                AppLocalizations.of(context)!.settingsTitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    color: CustomThemeProvider.of(context)
                                .brightnessNotifier
                                .value ==
                            Brightness.light
                        ? CustomThemeProvider.of(context).theme.textColor
                        : CustomThemeProvider.of(context).theme.darkTextColor,
                    fontSize: 24),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (_showIosRealtimeSessionHint)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 20.0),
                          child: Text(
                            AppLocalizations.of(context)!
                                .realtimeSessionIosHint,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                  color: CustomThemeProvider.of(context)
                                      .theme
                                      .darkTextColor,
                                ),
                          ),
                        ),
                      _buildSettingsCard(
                        context,
                        icon: FontAwesomeIcons.key,
                        title: AppLocalizations.of(context)!.apiKeysTitle,
                        subtitle: AppLocalizations.of(context)!
                            .apiKeysSettingsSubtitle,
                        onTap: () {
                          Navigator.of(context).pushNamed(ApiKeysScreen.route);
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildSettingsCard(
                        context,
                        icon: FontAwesomeIcons.scaleBalanced,
                        title:
                            AppLocalizations.of(context)!.aboutLicensesTitle,
                        subtitle: AppLocalizations.of(context)!
                            .aboutLicensesSettingsSubtitle,
                        onTap: () {
                          Navigator.of(context)
                              .pushNamed(AboutAndLicensesScreen.route);
                        },
                      ),
                      // Developer tool: nothing in the app writes this log
                      // any more, so release builds do not show it.
                      if (kDebugMode) ...[
                        const SizedBox(height: 16),
                        _buildSettingsCard(
                          context,
                          icon: FontAwesomeIcons.bug,
                          title: 'Diagnostic logs',
                          subtitle:
                              'Campaign save debug log (for TestFlight troubleshooting)',
                          onTap: () {
                            Navigator.of(context)
                                .pushNamed(AgentDebugLogScreen.route);
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsCard(
    BuildContext context, {
    required FaIconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 500),
      child: CupertinoButton(
        onPressed: onTap,
        padding: EdgeInsets.zero,
        minimumSize: Size(0, 0),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
                color: CustomThemeProvider.of(context).theme.darkColor),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 20.0),
                  child: CustomFaIcon(
                    icon: icon,
                    size: 32,
                    color: CustomThemeProvider.of(context).theme.darkColor,
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(
                              color: CustomThemeProvider.of(context)
                                  .theme
                                  .darkTextColor,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                              color: CustomThemeProvider.of(context)
                                  .theme
                                  .darkTextColor,
                            ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: CustomFaIcon(
                    icon: FontAwesomeIcons.chevronRight,
                    size: 20,
                    color: CustomThemeProvider.of(context).theme.darkColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
