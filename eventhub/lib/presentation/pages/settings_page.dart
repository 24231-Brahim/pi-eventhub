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
    final l10n = AppLocalizations.of(context)!;
    final isDarkMode = _themeNotifier.themeMode == ThemeMode.dark;
    final locale = _themeNotifier.locale;
    final languageName = _getLanguageName(locale);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(l10n.appearance,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Card(
            child: SwitchListTile(
              title: Text(l10n.darkMode),
              subtitle: Text(l10n.toggleDarkTheme),
              secondary:
                  Icon(isDarkMode ? Icons.dark_mode : Icons.light_mode),
              value: isDarkMode,
              onChanged: (value) => _themeNotifier.setThemeMode(
                value ? ThemeMode.dark : ThemeMode.light,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(l10n.language,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.language),
              title: Text(l10n.language),
              subtitle: Text(languageName),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showLanguagePicker(),
            ),
          ),
          const SizedBox(height: 24),
          Text(l10n.about,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.info),
                  title: Text(l10n.version),
                  subtitle: const Text('1.0.0'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getLanguageName(Locale locale) {
    final l10n = AppLocalizations.of(context);
    if (locale.languageCode == 'fr') return l10n?.french ?? 'Français';
    if (locale.languageCode == 'ar') return l10n?.arabic ?? 'العربية';
    return l10n?.english ?? 'English';
  }

  void _showLanguagePicker() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(l10n.selectLanguage),
        children: [
          SimpleDialogOption(
            onPressed: () {
              _themeNotifier.setLocale(const Locale('en'));
              Navigator.pop(context);
            },
            child: ListTile(
              leading: Text(l10n.english),
              trailing: const Icon(Icons.check),
            ),
          ),
          SimpleDialogOption(
            onPressed: () {
              _themeNotifier.setLocale(const Locale('fr'));
              Navigator.pop(context);
            },
            child: ListTile(
              leading: Text(l10n.french),
              trailing: const Icon(Icons.check),
            ),
          ),
          SimpleDialogOption(
            onPressed: () {
              _themeNotifier.setLocale(const Locale('ar'));
              Navigator.pop(context);
            },
            child: ListTile(
              leading: Text(l10n.arabic),
              trailing: const Icon(Icons.check),
            ),
          ),
        ],
      ),
    );
  }
}
