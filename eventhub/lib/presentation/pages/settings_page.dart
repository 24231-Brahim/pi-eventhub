import 'package:flutter/material.dart';
import 'package:eventhub/core/di/injection_container.dart' as di;
import 'package:eventhub/l10n/app_localizations.dart';
import 'package:eventhub/main.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late final ThemeNotifier _themeNotifier;

  @override
  void initState() {
    super.initState();
    _themeNotifier = di.sl<ThemeNotifier>();
    _themeNotifier.addListener(_onChanged);
  }

  void _onChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _themeNotifier.removeListener(_onChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = _themeNotifier.themeMode == ThemeMode.dark;
    final locale = _themeNotifier.locale;
    final languageName = _getLanguageName(locale);

    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.settings)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Appearance',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Card(
            child: SwitchListTile(
              title: Text(AppLocalizations.of(context)!.darkMode),
              subtitle: const Text('Toggle dark theme'),
              secondary:
                  Icon(isDarkMode ? Icons.dark_mode : Icons.light_mode),
              value: isDarkMode,
              onChanged: (value) => _themeNotifier.setThemeMode(
                value ? ThemeMode.dark : ThemeMode.light,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(AppLocalizations.of(context)!.language,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.language),
              title: Text(AppLocalizations.of(context)!.language),
              subtitle: Text(languageName),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showLanguagePicker(),
            ),
          ),
          const SizedBox(height: 24),
          Text('About',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Card(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.info),
                  title: Text('Version'),
                  subtitle: Text('1.0.0'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getLanguageName(Locale locale) {
    if (locale.languageCode == 'fr') return 'Français';
    if (locale.languageCode == 'ar') return 'العربية';
    return 'English';
  }

  void _showLanguagePicker() {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Select Language'),
        children: [
          SimpleDialogOption(
            onPressed: () {
              _themeNotifier.setLocale(const Locale('en'));
              Navigator.pop(context);
            },
            child: const ListTile(
              title: Text('English'),
              trailing: Icon(Icons.check),
            ),
          ),
          SimpleDialogOption(
            onPressed: () {
              _themeNotifier.setLocale(const Locale('fr'));
              Navigator.pop(context);
            },
            child: const ListTile(
              title: Text('Français'),
              trailing: Icon(Icons.check),
            ),
          ),
          SimpleDialogOption(
            onPressed: () {
              _themeNotifier.setLocale(const Locale('ar'));
              Navigator.pop(context);
            },
            child: const ListTile(
              title: Text('العربية'),
              trailing: Icon(Icons.check),
            ),
          ),
        ],
      ),
    );
  }
}
