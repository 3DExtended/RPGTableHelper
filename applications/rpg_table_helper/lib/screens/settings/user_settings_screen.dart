import 'dart:io' show Platform;

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:quest_keeper/components/custom_fa_icon.dart';
import 'package:quest_keeper/components/navbar.dart';
import 'package:quest_keeper/l10n/app_localizations.dart';
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
                'Settings',
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
                            AppLocalizations.of(context)!.realtimeSessionIosHint,
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
                        title: 'API Keys',
                        subtitle: 'Manage your personal API keys',
                        onTap: () {
                          Navigator.of(context).pushNamed(ApiKeysScreen.route);
                        },
                      ),
                      // Add more settings cards here
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
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 500),
      child: CupertinoButton(
        onPressed: onTap,
        minSize: 0,
        padding: EdgeInsets.zero,
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
