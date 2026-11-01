import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:quest_keeper/components/custom_fa_icon.dart';
import 'package:quest_keeper/components/navbar.dart';
import 'package:quest_keeper/constants.dart';
import 'package:quest_keeper/generated/swaggen/swagger.models.swagger.dart';
import 'package:quest_keeper/l10n/app_localizations.dart';
import 'package:quest_keeper/models/api_key_scopes.dart';
import 'package:quest_keeper/screens/settings/create_api_key_dialog.dart';
import 'package:quest_keeper/services/api_key_service.dart';
import 'package:quest_keeper/services/backend_capabilities_service.dart';
import 'package:quest_keeper/services/custom_theme_provider.dart';
import 'package:quest_keeper/services/dependency_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class ApiKeysScreen extends StatefulWidget {
  static const route = '/settings/apikeys';

  const ApiKeysScreen({super.key});

  @override
  State<ApiKeysScreen> createState() => _ApiKeysScreenState();
}

class _ApiKeysScreenState extends State<ApiKeysScreen> {
  List<ApiKeyDto> _keys = [];
  bool _isLoading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadKeys();
  }

  Future<void> _loadKeys() async {
    var l10n = AppLocalizations.of(context)!;
    setState(() => _isLoading = true);
    try {
      var service = DependencyProvider.of(context).getService<IApiKeyService>();
      var keys = await service.getApiKeys();

      if (!mounted) return;
      await keys.possiblyHandleError(context);
      if (!mounted) return;

      if (mounted) {
        if (!keys.isSuccessful) {
          setState(() => _isLoading = false);
          return;
        }

        setState(() {
          _keys = keys.result!;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.apiKeysLoadFailed)),
        );
      }
    }
  }

  Future<void> _revokeKey(String id) async {
    var l10n = AppLocalizations.of(context)!;
    var confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: CustomThemeProvider.of(context).theme.bgColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
          side: BorderSide(
            color: CustomThemeProvider.of(context).theme.darkColor,
            width: 1,
          ),
        ),
        title: Text(
          l10n.apiKeyRevokeTitle,
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
                color: CustomThemeProvider.of(context).theme.darkTextColor,
                fontWeight: FontWeight.bold,
              ),
        ),
        content: Text(
          l10n.apiKeyRevokeBody,
          style: TextStyle(
            color: CustomThemeProvider.of(context).theme.darkTextColor,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              l10n.cancel,
              style: TextStyle(
                color: CustomThemeProvider.of(context).theme.darkTextColor,
              ),
            ),
          ),
          CupertinoButton(
            onPressed: () => Navigator.pop(context, true),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.red,
            borderRadius: BorderRadius.circular(5),
            minimumSize: Size(0, 0),
            child: Text(
              l10n.apiKeyRevokeConfirm,
              style: const TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      if (!mounted) return;
      try {
        var service =
            DependencyProvider.of(context).getService<IApiKeyService>();
        await service.revokeApiKey(id);
        _loadKeys();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.apiKeyRevokeFailed)),
          );
        }
      }
    }
  }

  Future<void> _generateKey() async {
    var l10n = AppLocalizations.of(context)!;
    var capabilities = await DependencyProvider.of(context)
        .getService<IBackendCapabilitiesService>()
        .ensureCapabilitiesLoaded();
    if (!mounted) return;
    var choice = await CreateApiKeyDialog.show(
      context,
      canChoosePermissions:
          capabilities.contains(BackendCapability.scopedApiKeys),
    );
    if (choice == null || !mounted) return;

    try {
      var service = DependencyProvider.of(context).getService<IApiKeyService>();
      var response = await service.createApiKey(
        choice.name,
        scopes: choice.scopes,
        expiresAt: choice.lifetime.expiresAtFrom(DateTime.now()),
      );

      if (!mounted) return;
      await response.possiblyHandleError(context);
      if (!mounted || !response.isSuccessful) return;

      _showKeyDialog(response.result!);
      _loadKeys();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.apiKeyCreateFailed)),
        );
      }
    }
  }

  void _showKeyDialog(CreateApiKeyResponse response) {
    var l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: CustomThemeProvider.of(context).theme.bgColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
          side: BorderSide(
            color: CustomThemeProvider.of(context).theme.darkColor,
            width: 1,
          ),
        ),
        title: Text(
          l10n.apiKeyCreatedTitle,
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
                color: CustomThemeProvider.of(context).theme.darkTextColor,
                fontWeight: FontWeight.bold,
              ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.apiKeyCreatedBody,
              style: TextStyle(
                color: CustomThemeProvider.of(context).theme.darkTextColor,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(
                  color: CustomThemeProvider.of(context).theme.darkColor,
                ),
                borderRadius: BorderRadius.circular(5),
              ),
              child: SelectableText(
                response.plainKey ?? "",
                style: TextStyle(
                  fontFamily: 'Courier',
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: CustomThemeProvider.of(context).theme.darkTextColor,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: response.plainKey ?? ""));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    l10n.apiKeyCopied,
                    style: TextStyle(
                      color: CustomThemeProvider.of(context).theme.textColor,
                    ),
                  ),
                  backgroundColor:
                      CustomThemeProvider.of(context).theme.darkColor,
                ),
              );
            },
            icon: Icon(
              Icons.copy,
              color: CustomThemeProvider.of(context).theme.darkTextColor,
            ),
            label: Text(
              l10n.apiKeyCopy,
              style: TextStyle(
                color: CustomThemeProvider.of(context).theme.darkTextColor,
              ),
            ),
          ),
          CupertinoButton(
            onPressed: () => Navigator.pop(context),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: CustomThemeProvider.of(context).theme.darkColor,
            borderRadius: BorderRadius.circular(5),
            minimumSize: Size(0, 0),
            child: Text(
              l10n.apiKeyDone,
              style: TextStyle(
                color: CustomThemeProvider.of(context).theme.textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(BuildContext context, DateTime date) =>
      DateFormat.yMd(Localizations.localeOf(context).toString())
          .add_Hm()
          .format(date.toLocal());

  Widget _statusBadge(String label, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      );

  /// Prefix, permissions, last use and expiry of [key].
  List<Widget> _buildKeyDetails(BuildContext context, ApiKeyDto key) {
    var l10n = AppLocalizations.of(context)!;
    var textColor = CustomThemeProvider.of(context).theme.darkTextColor;
    var bodyStyle =
        Theme.of(context).textTheme.bodyMedium!.copyWith(color: textColor);
    var smallStyle =
        Theme.of(context).textTheme.bodySmall!.copyWith(color: textColor);
    // A server without scoped keys does not send scopes; its keys can read.
    var scopes = ApiKeyScopes.normalize(key.scopes ?? ApiKeyScopes.readOnly);
    var preset = ApiKeyPreset.forScopes(scopes);

    return [
      const SizedBox(height: 8),
      Text(
        l10n.apiKeyPrefix('${key.prefix}●●●●●●'),
        style: bodyStyle.copyWith(fontFamily: 'Courier'),
      ),
      const SizedBox(height: 8),
      Text(
        '${l10n.apiKeyPermissionsLabel}: ${preset == ApiKeyPreset.custom ? '' : preset.label(l10n)}',
        style: bodyStyle.copyWith(fontWeight: FontWeight.bold),
      ),
      if (preset == ApiKeyPreset.custom)
        ...scopes.map((scope) =>
            Text('• ${ApiKeyScopes.label(l10n, scope)}', style: smallStyle)),
      const SizedBox(height: 8),
      Text(
        key.lastUsedAt == null
            ? l10n.apiKeyNeverUsed
            : l10n.apiKeyLastUsedAt(_formatDate(context, key.lastUsedAt!)),
        style: smallStyle,
      ),
      Text(
        key.expiresAt == null
            ? l10n.apiKeyNeverExpires
            : l10n.apiKeyExpiresAt(_formatDate(context, key.expiresAt!)),
        style: smallStyle,
      ),
      if (key.revokedAt != null) ...[
        const SizedBox(height: 4),
        Text(
          l10n.apiKeyRevokedAt(_formatDate(context, key.revokedAt!)),
          style: smallStyle.copyWith(color: Colors.red),
        ),
      ],
    ];
  }

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;
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
                l10n.apiKeysTitle,
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
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        color: CustomThemeProvider.of(context).theme.darkColor,
                      ),
                    )
                  : SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            // API Documentation Card
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 500),
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: CustomThemeProvider.of(context)
                                          .theme
                                          .darkColor),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          CustomFaIcon(
                                            icon: FontAwesomeIcons.circleInfo,
                                            size: 20,
                                            color:
                                                CustomThemeProvider.of(context)
                                                    .theme
                                                    .darkColor,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            l10n.apiKeysDocsTitle,
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium!
                                                .copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  color: CustomThemeProvider.of(
                                                          context)
                                                      .theme
                                                      .darkTextColor,
                                                ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        l10n.apiKeysDocsDescription,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium!
                                            .copyWith(
                                              color: CustomThemeProvider.of(
                                                      context)
                                                  .theme
                                                  .darkTextColor,
                                            ),
                                      ),
                                      const SizedBox(height: 16),
                                      CupertinoButton(
                                        onPressed: () async {
                                          final url = Uri.parse(
                                              '${apiBaseUrl}swagger/index.html');
                                          if (await canLaunchUrl(url)) {
                                            await launchUrl(url,
                                                mode: LaunchMode
                                                    .externalApplication);
                                          }
                                        },
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 12),
                                        color: CustomThemeProvider.of(context)
                                            .theme
                                            .darkColor,
                                        borderRadius: BorderRadius.circular(5),
                                        minimumSize: Size(0, 0),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            CustomFaIcon(
                                              icon: FontAwesomeIcons
                                                  .arrowUpRightFromSquare,
                                              size: 14,
                                              color: CustomThemeProvider.of(
                                                      context)
                                                  .theme
                                                  .textColor,
                                            ),
                                            const SizedBox(width: 8),
                                            Flexible(
                                              child: Text(
                                                l10n.apiKeysViewDocs,
                                                style: TextStyle(
                                                  color: CustomThemeProvider.of(
                                                          context)
                                                      .theme
                                                      .textColor,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            // Generate New Key Button
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 500),
                              child: CupertinoButton(
                                onPressed: _generateKey,
                                padding: EdgeInsets.zero,
                                minimumSize: Size(0, 0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: CustomThemeProvider.of(context)
                                            .theme
                                            .darkColor),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(20.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        CustomFaIcon(
                                          icon: FontAwesomeIcons.plus,
                                          size: 20,
                                          color: CustomThemeProvider.of(context)
                                              .theme
                                              .darkColor,
                                        ),
                                        const SizedBox(width: 12),
                                        Flexible(
                                          child: Text(
                                            l10n.apiKeysGenerate,
                                            textAlign: TextAlign.center,
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium!
                                                .copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  color: CustomThemeProvider.of(
                                                          context)
                                                      .theme
                                                      .darkTextColor,
                                                ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            // API Keys List
                            if (_keys.isEmpty)
                              Padding(
                                padding: const EdgeInsets.all(40.0),
                                child: Text(
                                  l10n.apiKeysEmpty,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge!
                                      .copyWith(
                                        color: CustomThemeProvider.of(context)
                                            .theme
                                            .darkTextColor,
                                      ),
                                ),
                              )
                            else
                              ..._keys.map((key) {
                                var isRevoked = key.revokedAt != null;
                                var isExpired = key.expiresAt != null &&
                                    key.expiresAt!.isBefore(DateTime.now());
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 10.0),
                                  child: ConstrainedBox(
                                    constraints:
                                        const BoxConstraints(maxWidth: 500),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            color:
                                                CustomThemeProvider.of(context)
                                                    .theme
                                                    .darkColor),
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(20.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    key.name ??
                                                        l10n.apiKeyUnnamed,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .titleMedium!
                                                        .copyWith(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: CustomThemeProvider
                                                                  .of(context)
                                                              .theme
                                                              .darkTextColor,
                                                        ),
                                                  ),
                                                ),
                                                if (isRevoked)
                                                  _statusBadge(
                                                      l10n.apiKeyRevoked,
                                                      Colors.red)
                                                else if (isExpired)
                                                  _statusBadge(
                                                      l10n.apiKeyExpired,
                                                      Colors.grey.shade700)
                                                else
                                                  CupertinoButton(
                                                    onPressed: () =>
                                                        _revokeKey(key.id!),
                                                    padding:
                                                        const EdgeInsets.all(8),
                                                    minimumSize: Size(0, 0),
                                                    child: CustomFaIcon(
                                                      icon: FontAwesomeIcons
                                                          .trash,
                                                      size: 16,
                                                      color: Colors.red,
                                                    ),
                                                  ),
                                              ],
                                            ),
                                            ..._buildKeyDetails(context, key),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }),
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
}
