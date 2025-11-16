import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/design_tokens.dart';
import '../providers/settings_provider.dart';
import '../services/hive_service.dart';
import '../services/import_export_service.dart';
import '../services/notification_service.dart';
import '../services/storage_service.dart';
import '../widgets/app_bar.dart';
import '../widgets/toast.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _busy = false;

  ImportExportService _service(BuildContext context) {
    final storage = context.read<StorageService>();
    final hive = context.read<HiveService>();
    return ImportExportService(storage, hive);
  }

  Future<void> _exportData(BuildContext context) async {
    setState(() => _busy = true);
    try {
      final data = await _service(context).exportData();
      if (!mounted) return;
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Export JSON'),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: SelectableText(data),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _importData(BuildContext context) async {
    final controller = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Import JSON'),
        content: TextField(
          controller: controller,
          minLines: 5,
          maxLines: 10,
          decoration: const InputDecoration(hintText: 'Paste JSON payload'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Import'),
          ),
        ],
      ),
    );
    if (confirmed != true || controller.text.isEmpty) return;
    setState(() => _busy = true);
    try {
      await _service(context).importData(controller.text);
      if (mounted) {
        showToast(context, 'Import complete.');
      }
    } catch (error) {
      showToast(context, 'Import failed: $error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final spacing = DesignTokens.spacing;
    return Scaffold(
      appBar: const PomodoRxAppBar(title: 'Settings', showBack: true),
      body: Padding(
        padding: EdgeInsets.all(spacing.s4),
        child: Consumer<SettingsProvider>(
          builder: (context, settings, _) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Theme', style: Theme.of(context).textTheme.titleLarge),
                DropdownButton<ThemeMode>(
                  value: settings.themeMode,
                  items: const [
                    DropdownMenuItem(value: ThemeMode.light, child: Text('Light')),
                    DropdownMenuItem(value: ThemeMode.dark, child: Text('Dark')),
                    DropdownMenuItem(value: ThemeMode.system, child: Text('System')),
                  ],
                  onChanged: (mode) {
                    if (mode != null) settings.updateTheme(mode);
                  },
                ),
                SwitchListTile(
                  title: const Text('Enable Text-to-Speech'),
                  value: settings.ttsEnabled,
                  onChanged: settings.setTtsEnabled,
                ),
                SwitchListTile(
                  title: const Text('Enable Notifications'),
                  subtitle: const Text('Show local notifications when timer ends'),
                  value: settings.notificationsEnabled,
                  onChanged: (val) async {
                    if (val) {
                      await NotificationService().ensurePermissionsRequested();
                    }
                    settings.setNotificationsEnabled(val);
                  },
                ),
                const Divider(),
                Text('Backup', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: _busy ? null : () => _exportData(context),
                  icon: const Icon(Icons.download),
                  label: const Text('Export JSON'),
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: _busy ? null : () => _importData(context),
                  icon: const Icon(Icons.upload),
                  label: const Text('Import JSON'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
