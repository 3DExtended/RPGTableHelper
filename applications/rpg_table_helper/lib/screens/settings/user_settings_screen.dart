import 'package:flutter/material.dart';
import 'package:quest_keeper/screens/settings/api_keys_screen.dart';

class UserSettingsScreen extends StatelessWidget {
  static const route = '/settings';

  const UserSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.vpn_key),
            title: const Text('API Keys'),
            subtitle: const Text('Manage your personal API keys'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).pushNamed(ApiKeysScreen.route);
            },
          ),
          // Add more settings here
        ],
      ),
    );
  }
}
