import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quest_keeper/generated/swaggen/swagger.models.swagger.dart';
import 'package:quest_keeper/services/api_key_service.dart';
import 'package:quest_keeper/services/dependency_provider.dart';

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
        title: const Text('Revoke API Key?'),
        content: const Text(
            'This action cannot be undone. Any application using this key will lose access immediately.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Revoke'),
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
      builder: (context) => AlertDialog(
        title: const Text('Generate New API Key'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(labelText: 'Key Name'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, nameController.text),
            child: const Text('Generate'),
          ),
        ],
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
        title: const Text('API Key Generated'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
                'Please copy your new API key now. You won\'t be able to see it again!'),
            const SizedBox(height: 16),
            SelectableText(
              response.plainKey ?? "",
              style: const TextStyle(
                  fontFamily: 'Courier',
                  fontWeight: FontWeight.bold,
                  fontSize: 16),
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: response.plainKey ?? ""));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Copied to clipboard')),
              );
            },
            icon: const Icon(Icons.copy),
            label: const Text('Copy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('API Keys'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _generateKey,
            tooltip: 'Generate New Key',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _keys.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('No API Keys found.'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _generateKey,
                        child: const Text('Generate API Key'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _keys.length,
                  itemBuilder: (context, index) {
                    var key = _keys[index];
                    var isRevoked = key.revokedAt != null;
                    return ListTile(
                      title: Text(key.name ?? 'Unnamed Key'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Prefix: ${key.prefix}●●●●●●'),
                          Text(
                              'Created: ${key.createdAt!.toLocal().toString().split('.')[0]}'),
                          if (isRevoked)
                            Text(
                              'Revoked: ${key.revokedAt!.toLocal().toString().split('.')[0]}',
                              style: const TextStyle(color: Colors.red),
                            ),
                        ],
                      ),
                      trailing: isRevoked
                          ? const Chip(
                              label: Text('Revoked'),
                              backgroundColor: Colors.red,
                            )
                          : IconButton(
                              icon: const Icon(Icons.delete),
                              color: Colors.red,
                              onPressed: () => _revokeKey(key.id!),
                              tooltip: 'Revoke Key',
                            ),
                    );
                  },
                ),
    );
  }
}
