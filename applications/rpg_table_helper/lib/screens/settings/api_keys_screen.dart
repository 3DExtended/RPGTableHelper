import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:quest_keeper/components/custom_fa_icon.dart';
import 'package:quest_keeper/components/navbar.dart';
import 'package:quest_keeper/constants.dart';
import 'package:quest_keeper/generated/swaggen/swagger.models.swagger.dart';
import 'package:quest_keeper/services/api_key_service.dart';
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
    setState(() => _isLoading = true);
    try {
      var service = DependencyProvider.of(context).getService<IApiKeyService>();
      var keys = await service.getApiKeys();

      if (!context.mounted) return;
      await keys.possiblyHandleError(context);
      if (!context.mounted) return;

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
          SnackBar(content: Text('Failed to load keys: $e')),
        );
      }
    }
  }

  Future<void> _revokeKey(String id) async {
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
          'Revoke API Key?',
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
                color: CustomThemeProvider.of(context).theme.darkTextColor,
                fontWeight: FontWeight.bold,
              ),
        ),
        content: Text(
          'This action cannot be undone. Any application using this key will lose access immediately.',
          style: TextStyle(
            color: CustomThemeProvider.of(context).theme.darkTextColor,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: CustomThemeProvider.of(context).theme.darkTextColor,
              ),
            ),
          ),
          CupertinoButton(
            onPressed: () => Navigator.pop(context, true),
            minSize: 0,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.red,
            borderRadius: BorderRadius.circular(5),
            child: const Text(
              'Revoke',
              style: TextStyle(
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
            SnackBar(content: Text('Failed to revoke key: $e')),
          );
        }
      }
    }
  }

  Future<void> _generateKey() async {
    TextEditingController nameController = TextEditingController();

    var name = await showDialog<String>(
      context: context,
      builder: (context) => Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: AlertDialog(
            backgroundColor: CustomThemeProvider.of(context).theme.bgColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
              side: BorderSide(
                color: CustomThemeProvider.of(context).theme.darkColor,
                width: 1,
              ),
            ),
            title: Text(
              'Generate New API Key',
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    color: CustomThemeProvider.of(context).theme.darkTextColor,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            content: TextField(
              controller: nameController,
              autofocus: true,
              style: TextStyle(
                color: CustomThemeProvider.of(context).theme.darkTextColor,
              ),
              decoration: InputDecoration(
                labelText: 'Key Name',
                labelStyle: TextStyle(
                  color: CustomThemeProvider.of(context).theme.darkTextColor,
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: CustomThemeProvider.of(context).theme.darkColor,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: CustomThemeProvider.of(context).theme.darkColor,
                    width: 2,
                  ),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: CustomThemeProvider.of(context).theme.darkTextColor,
                  ),
                ),
              ),
              CupertinoButton(
                onPressed: () => Navigator.pop(context, nameController.text),
                minSize: 0,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                color: CustomThemeProvider.of(context).theme.darkColor,
                borderRadius: BorderRadius.circular(5),
                child: Text(
                  'Generate',
                  style: TextStyle(
                    color: CustomThemeProvider.of(context).theme.textColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (name != null && name.isNotEmpty) {
      if (!mounted) return;
      try {
        var service =
            DependencyProvider.of(context).getService<IApiKeyService>();
        var response = await service.createApiKey(name);

        if (!context.mounted) return;
        await response.possiblyHandleError(context);
        if (!context.mounted) return;

        if (mounted) {
          _showKeyDialog(response.result!);
          _loadKeys();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to create key: $e')),
          );
        }
      }
    }
  }

  void _showKeyDialog(CreateApiKeyResponse response) {
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
          'API Key Generated',
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
              'Please copy your new API key now. You won\'t be able to see it again!',
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
                    'Copied to clipboard',
                    style: TextStyle(
                      color: CustomThemeProvider.of(context).theme.textColor,
                    ),
                  ),
                  backgroundColor: CustomThemeProvider.of(context).theme.darkColor,
                ),
              );
            },
            icon: Icon(
              Icons.copy,
              color: CustomThemeProvider.of(context).theme.darkTextColor,
            ),
            label: Text(
              'Copy',
              style: TextStyle(
                color: CustomThemeProvider.of(context).theme.darkTextColor,
              ),
            ),
          ),
          CupertinoButton(
            onPressed: () => Navigator.pop(context),
            minSize: 0,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: CustomThemeProvider.of(context).theme.darkColor,
            borderRadius: BorderRadius.circular(5),
            child: Text(
              'Done',
              style: TextStyle(
                color: CustomThemeProvider.of(context).theme.textColor,
              ),
            ),
          ),
        ],
      ),
    );
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
                'API Keys',
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
                                            'API Documentation',
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
                                        'Use your API keys to access the External API programmatically.',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium!
                                            .copyWith(
                                              color:
                                                  CustomThemeProvider.of(context)
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
                                        minSize: 0,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 12),
                                        color: CustomThemeProvider.of(context)
                                            .theme
                                            .darkColor,
                                        borderRadius: BorderRadius.circular(5),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            CustomFaIcon(
                                              icon: FontAwesomeIcons
                                                  .arrowUpRightFromSquare,
                                              size: 14,
                                              color:
                                                  CustomThemeProvider.of(context)
                                                      .theme
                                                      .textColor,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              'View API Documentation',
                                              style: TextStyle(
                                                color:
                                                    CustomThemeProvider.of(
                                                            context)
                                                        .theme
                                                        .textColor,
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
                                minSize: 0,
                                padding: EdgeInsets.zero,
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
                                        Text(
                                          'Generate New API Key',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium!
                                              .copyWith(
                                                fontWeight: FontWeight.bold,
                                                color:
                                                    CustomThemeProvider.of(
                                                            context)
                                                        .theme
                                                        .darkTextColor,
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
                                  'No API Keys found.',
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
                                                    key.name ?? 'Unnamed Key',
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
                                                  Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 12,
                                                        vertical: 6),
                                                    decoration: BoxDecoration(
                                                      color: Colors.red,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12),
                                                    ),
                                                    child: const Text(
                                                      'Revoked',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  )
                                                else
                                                  CupertinoButton(
                                                    onPressed: () =>
                                                        _revokeKey(key.id!),
                                                    minSize: 0,
                                                    padding:
                                                        const EdgeInsets.all(8),
                                                    child: CustomFaIcon(
                                                      icon:
                                                          FontAwesomeIcons.trash,
                                                      size: 16,
                                                      color: Colors.red,
                                                    ),
                                                  ),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              'Prefix: ${key.prefix}●●●●●●',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium!
                                                  .copyWith(
                                                    color: CustomThemeProvider
                                                            .of(context)
                                                        .theme
                                                        .darkTextColor,
                                                    fontFamily: 'Courier',
                                                  ),
                                            ),
                                            const SizedBox(height: 4),
                                            if (isRevoked) ...[
                                              const SizedBox(height: 4),
                                              Text(
                                                'Revoked: ${key.revokedAt!.toLocal().toString().split('.')[0]}',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall!
                                                    .copyWith(
                                                      color: Colors.red,
                                                    ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
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
