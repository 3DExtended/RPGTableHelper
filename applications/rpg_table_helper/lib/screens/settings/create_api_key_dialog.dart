import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:quest_keeper/l10n/app_localizations.dart';
import 'package:quest_keeper/models/api_key_scopes.dart';
import 'package:quest_keeper/services/custom_theme_provider.dart';

/// What the player chose in [CreateApiKeyDialog].
class CreateApiKeyDialogResult {
  final String name;
  final List<String> scopes;
  final ApiKeyLifetime lifetime;

  const CreateApiKeyDialogResult({
    required this.name,
    required this.scopes,
    required this.lifetime,
  });
}

/// Asks for a name, the permissions and the lifetime of a new API key.
/// Pops with a [CreateApiKeyDialogResult], or null when cancelled.
class CreateApiKeyDialog extends StatefulWidget {
  const CreateApiKeyDialog({super.key});

  static Future<CreateApiKeyDialogResult?> show(BuildContext context) =>
      showDialog<CreateApiKeyDialogResult>(
        context: context,
        builder: (context) => const CreateApiKeyDialog(),
      );

  @override
  State<CreateApiKeyDialog> createState() => _CreateApiKeyDialogState();
}

class _CreateApiKeyDialogState extends State<CreateApiKeyDialog> {
  final TextEditingController _nameController = TextEditingController();
  Set<String> _scopes = ApiKeyPreset.readOnly.scopes.toSet();
  ApiKeyLifetime _lifetime = ApiKeyLifetime.unlimited;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _selectPreset(ApiKeyPreset preset) {
    if (preset == ApiKeyPreset.custom) return;
    setState(() {
      _scopes = preset.scopes.toSet();
      _error = null;
    });
  }

  void _toggleScope(String scope, bool selected) {
    setState(() {
      _scopes = {..._scopes};
      if (selected) {
        _scopes.add(scope);
      } else {
        _scopes.remove(scope);
      }
      _error = null;
    });
  }

  void _submit(AppLocalizations l10n) {
    var name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _error = l10n.apiKeyNameRequired);
      return;
    }
    if (_scopes.isEmpty) {
      setState(() => _error = l10n.apiKeyNoScopeSelected);
      return;
    }

    Navigator.pop(
      context,
      CreateApiKeyDialogResult(
        name: name,
        scopes: ApiKeyScopes.normalize(_scopes),
        lifetime: _lifetime,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;
    var theme = CustomThemeProvider.of(context).theme;
    var textStyle = TextStyle(color: theme.darkTextColor);
    var selectedPreset = ApiKeyPreset.forScopes(_scopes);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: AlertDialog(
          backgroundColor: theme.bgColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
            side: BorderSide(color: theme.darkColor, width: 1),
          ),
          title: Text(
            l10n.apiKeyCreateTitle,
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  color: theme.darkTextColor,
                  fontWeight: FontWeight.bold,
                ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.apiKeyCreateHint, style: textStyle),
                const SizedBox(height: 16),
                TextField(
                  key: const ValueKey('apiKeyNameField'),
                  controller: _nameController,
                  autofocus: true,
                  style: textStyle,
                  decoration: InputDecoration(
                    labelText: l10n.apiKeyNameLabel,
                    labelStyle: textStyle,
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: theme.darkColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: theme.darkColor, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  l10n.apiKeyPermissionsLabel,
                  style: textStyle.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: ApiKeyPreset.values
                      .map((preset) => ChoiceChip(
                            key: ValueKey('apiKeyPreset_${preset.name}'),
                            label: Text(preset.label(l10n)),
                            selected: preset == selectedPreset,
                            onSelected: (_) => _selectPreset(preset),
                            labelStyle: TextStyle(
                              color: preset == selectedPreset
                                  ? theme.textColor
                                  : theme.darkTextColor,
                            ),
                            selectedColor: theme.darkColor,
                            backgroundColor: theme.bgColor,
                            showCheckmark: false,
                            side: BorderSide(color: theme.darkColor),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 8),
                ...ApiKeyScopes.all.map((scope) => CheckboxListTile(
                      key: ValueKey('apiKeyScope_$scope'),
                      value: _scopes.contains(scope),
                      onChanged: (value) => _toggleScope(scope, value == true),
                      title: Text(ApiKeyScopes.label(l10n, scope),
                          style: textStyle),
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                      activeColor: theme.darkColor,
                      checkColor: theme.textColor,
                      side: BorderSide(color: theme.darkColor),
                    )),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.apiKeyExpiryLabel,
                        style: textStyle.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DropdownButton<ApiKeyLifetime>(
                      key: const ValueKey('apiKeyLifetime'),
                      value: _lifetime,
                      dropdownColor: theme.bgColor,
                      style: textStyle,
                      underline: Container(height: 1, color: theme.darkColor),
                      onChanged: (value) {
                        if (value != null) setState(() => _lifetime = value);
                      },
                      items: ApiKeyLifetime.values
                          .map((lifetime) => DropdownMenuItem(
                                value: lifetime,
                                child: Text(lifetime.label(l10n)),
                              ))
                          .toList(),
                    ),
                  ],
                ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(_error!, style: const TextStyle(color: Colors.red)),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel, style: textStyle),
            ),
            CupertinoButton(
              key: const ValueKey('apiKeyCreateConfirm'),
              onPressed: () => _submit(l10n),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: theme.darkColor,
              borderRadius: BorderRadius.circular(5),
              minimumSize: Size(0, 0),
              child: Text(
                l10n.apiKeyCreateConfirm,
                style: TextStyle(color: theme.textColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
