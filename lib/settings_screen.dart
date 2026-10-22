import 'package:flutter/material.dart' hide Text;
import 'app_store.dart';
import 'localization.dart';
import 'widgets.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  @override Widget build(BuildContext context) {
    final store = AppStore.instance;
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(tr(context, 'Settings'))),
      body: ResponsivePage(child: ListView(children: [
        const SizedBox(height: 8),
        GlassSurface(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(width: 46, height: 46, decoration: BoxDecoration(borderRadius: BorderRadius.circular(15), gradient: const LinearGradient(colors: [Color(0xFF7165F5), Color(0xFF21AFC0)])), child: const Icon(Icons.translate_rounded, color: Colors.white)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(tr(context, 'Language'), style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
              const SizedBox(height: 4),
              Text(tr(context, 'Language changes apply across the app.'), style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant)),
            ])),
          ]),
          const SizedBox(height: 12),
          AnimatedBuilder(animation: store, builder: (context, _) => Column(children: AtlasLocalizations.languages.map((language) {
            final selected = store.locale.languageCode == language.code;
            return RadioListTile<Locale>(
              value: Locale(language.code), groupValue: store.locale, contentPadding: EdgeInsets.zero, dense: true,
              activeColor: scheme.primary,
              title: Text(language.name, style: TextStyle(fontWeight: selected ? FontWeight.w800 : FontWeight.w500)),
              subtitle: Text(tr(context, language.englishName), style: Theme.of(context).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
              secondary: selected ? Icon(Icons.check_circle_rounded, color: scheme.primary) : const Icon(Icons.language_rounded),
              onChanged: (locale) { if (locale != null) store.setLocale(locale); },
            );
          }).toList())),
        ])),
        const SizedBox(height: 16),
        GlassSurface(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(tr(context, 'Appearance'), style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          AnimatedBuilder(animation: store, builder: (context, _) => SegmentedButton<ThemeMode>(
            segments: [
              ButtonSegment(value: ThemeMode.system, icon: const Icon(Icons.brightness_auto), label: Text(tr(context, 'System theme'))),
              ButtonSegment(value: ThemeMode.light, icon: const Icon(Icons.light_mode_outlined), label: Text(tr(context, 'Light theme'))),
              ButtonSegment(value: ThemeMode.dark, icon: const Icon(Icons.dark_mode_outlined), label: Text(tr(context, 'Dark theme'))),
            ],
            selected: {store.themeMode}, onSelectionChanged: (values) => store.setThemeMode(values.first), showSelectedIcon: false,
          )),
        ])),
        const SizedBox(height: 16),
        Text('AtlasFlow · Public data explorer', textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
      ])),
    );
  }
}
