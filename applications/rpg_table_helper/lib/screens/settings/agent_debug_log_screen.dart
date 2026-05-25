import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:quest_keeper/components/custom_fa_icon.dart';
import 'package:quest_keeper/components/navbar.dart';
import 'package:quest_keeper/helpers/agent_debug_log.dart';
import 'package:quest_keeper/services/custom_theme_provider.dart';

/// In-app viewer for campaign-save diagnostic logs (TestFlight / production).
class AgentDebugLogScreen extends StatefulWidget {
  static const route = '/settings/diagnostic-logs';

  const AgentDebugLogScreen({super.key});

  @override
  State<AgentDebugLogScreen> createState() => _AgentDebugLogScreenState();
}

class _AgentDebugLogScreenState extends State<AgentDebugLogScreen> {
  bool _loading = true;
  String _displayText = '';
  AgentDebugLogInfo? _info;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    setState(() => _loading = true);
    final info = await getAgentDebugLogInfo();
    final text = await formatAgentDebugLogForDisplay();
    if (!mounted) return;
    setState(() {
      _info = info;
      _displayText = text;
      _loading = false;
    });
  }

  Future<void> _copyAll() async {
    await Clipboard.setData(ClipboardData(text: _displayText));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Diagnostic log copied to clipboard')),
    );
  }

  Future<void> _confirmClear() async {
    final theme = CustomThemeProvider.of(context).theme;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.bgColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
          side: BorderSide(color: theme.darkColor),
        ),
        title: Text(
          'Clear diagnostic log?',
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
                color: theme.darkTextColor,
                fontWeight: FontWeight.bold,
              ),
        ),
        content: Text(
          'This removes all stored log entries on this device.',
          style: Theme.of(context)
              .textTheme
              .bodyMedium!
              .copyWith(color: theme.darkTextColor),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel',
                style: TextStyle(color: theme.darkTextColor)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Clear', style: TextStyle(color: theme.darkColor)),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await clearAgentDebugLog();
    await _reload();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Diagnostic log cleared')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = CustomThemeProvider.of(context).theme;
    final info = _info;

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
                'Diagnostic logs',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      color: CustomThemeProvider.of(context)
                                  .brightnessNotifier
                                  .value ==
                              Brightness.light
                          ? theme.textColor
                          : theme.darkTextColor,
                      fontSize: 24,
                    ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (info != null) ...[
                    Text(
                      '${info.lineCount} entries · ${info.byteCount} bytes',
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                            color: theme.darkTextColor,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      info.path,
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                            color: theme.darkTextColor.withOpacity(0.7),
                            fontSize: 11,
                          ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _actionChip(
                        context,
                        icon: FontAwesomeIcons.arrowsRotate,
                        label: 'Refresh',
                        onTap: _loading ? null : _reload,
                      ),
                      _actionChip(
                        context,
                        icon: FontAwesomeIcons.copy,
                        label: 'Copy all',
                        onTap: _displayText.isEmpty || _loading ? null : _copyAll,
                      ),
                      _actionChip(
                        context,
                        icon: FontAwesomeIcons.trash,
                        label: 'Clear',
                        onTap: _loading ? null : _confirmClear,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: _loading
                  ? const Center(child: CupertinoActivityIndicator())
                  : Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: theme.darkColor),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        padding: const EdgeInsets.all(12),
                        child: SingleChildScrollView(
                          child: SelectableText(
                            _displayText,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall!
                                .copyWith(
                                  fontFamily: 'monospace',
                                  color: theme.darkTextColor,
                                  height: 1.35,
                                ),
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

  Widget _actionChip(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback? onTap,
  }) {
    final theme = CustomThemeProvider.of(context).theme;
    return CupertinoButton(
      onPressed: onTap,
      minSize: 0,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: theme.darkColor.withValues(alpha: 0.15),
      borderRadius: BorderRadius.circular(5),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomFaIcon(icon: icon, size: 14, color: theme.darkColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium!.copyWith(
                  color: theme.darkTextColor,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}
