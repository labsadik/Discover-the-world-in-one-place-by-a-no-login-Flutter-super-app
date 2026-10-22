import 'package:flutter/material.dart';

import 'app_store.dart';
import 'screens.dart';

class AtlasFlowApp extends StatelessWidget {
  const AtlasFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppStore.instance,
      builder: (context, _) => MaterialApp(
        title: 'AtlasFlow — World Explorer',
        debugShowCheckedModeBanner: false,
        themeMode: AppStore.instance.themeMode,
        theme: _buildTheme(Brightness.light),
        darkTheme: _buildTheme(Brightness.dark),
        home: const AppShell(),
      ),
    );
  }

  ThemeData _buildTheme(Brightness brightness) {
    const seed = Color(0xFF5B67F1);
    final dark = brightness == Brightness.dark;
    final scheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: brightness,
      surface: dark ? const Color(0xFF151B2A) : Colors.white,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: dark ? const Color(0xFF0D1220) : const Color(0xFFF6F7FB),
      appBarTheme: AppBarTheme(
        backgroundColor: dark ? const Color(0xFF0D1220) : const Color(0xFFF6F7FB),
        foregroundColor: scheme.onSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: scheme.onSurface,
          fontSize: 20,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        ),
      ),
      cardTheme: CardThemeData(
        color: scheme.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: BorderSide(
            color: dark ? Colors.white.withValues(alpha: 0.06) : const Color(0xFFE7EAF2),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: dark ? const Color(0xFF191F2F) : Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: dark ? Colors.white12 : const Color(0xFFE3E7F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: scheme.primary, width: 1.5),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.6)),
        labelStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
      dividerTheme: DividerThemeData(
        color: dark ? Colors.white12 : const Color(0xFFE8EAF1),
        space: 1,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surface,
        indicatorColor: scheme.primaryContainer,
        labelTextStyle: WidgetStateProperty.resolveWith((states) => TextStyle(
              fontSize: 11,
              fontWeight: states.contains(WidgetState.selected) ? FontWeight.w700 : FontWeight.w500,
            )),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: scheme.surface,
        indicatorColor: scheme.primaryContainer,
        selectedLabelTextStyle: const TextStyle(fontWeight: FontWeight.w700),
      ),
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;

  void _goTo(int index) => setState(() => _selectedIndex = index);

  static const _destinations = <NavigationDestination>[
    NavigationDestination(icon: Icon(Icons.space_dashboard_outlined), selectedIcon: Icon(Icons.space_dashboard), label: 'Home'),
    NavigationDestination(icon: Icon(Icons.public_outlined), selectedIcon: Icon(Icons.public), label: 'Atlas'),
    NavigationDestination(icon: Icon(Icons.wb_cloudy_outlined), selectedIcon: Icon(Icons.wb_cloudy), label: 'Weather'),
    NavigationDestination(icon: Icon(Icons.menu_book_outlined), selectedIcon: Icon(Icons.menu_book), label: 'Books'),
    NavigationDestination(icon: Icon(Icons.bookmark_border), selectedIcon: Icon(Icons.bookmark), label: 'Saved'),
  ];

  @override
  Widget build(BuildContext context) {
    final store = AppStore.instance;
    final wide = MediaQuery.sizeOf(context).width >= 900;
    final pages = <Widget>[
      HomeScreen(onNavigate: _goTo),
      const CountriesScreen(),
      const WeatherScreen(),
      const BooksScreen(),
      const SavedScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 18,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6875F5), Color(0xFF8B5CF6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.explore_rounded, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 10),
            const Text('AtlasFlow'),
          ],
        ),
        actions: [
          Tooltip(
            message: 'Appearance',
            child: PopupMenuButton<ThemeMode>(
              icon: const Icon(Icons.palette_outlined),
              tooltip: 'Appearance',
              onSelected: store.setThemeMode,
              itemBuilder: (context) => const [
                PopupMenuItem(value: ThemeMode.system, child: _ThemeMenuLabel(icon: Icons.brightness_auto, label: 'System theme')),
                PopupMenuItem(value: ThemeMode.light, child: _ThemeMenuLabel(icon: Icons.light_mode_outlined, label: 'Light theme')),
                PopupMenuItem(value: ThemeMode.dark, child: _ThemeMenuLabel(icon: Icons.dark_mode_outlined, label: 'Dark theme')),
              ],
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: wide
          ? Row(
              children: [
                NavigationRail(
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: _goTo,
                  extended: MediaQuery.sizeOf(context).width >= 1200,
                  labelType: MediaQuery.sizeOf(context).width >= 1200
                      ? NavigationRailLabelType.none
                      : NavigationRailLabelType.all,
                  destinations: _destinations.map((item) => NavigationRailDestination(
                        icon: item.icon,
                        selectedIcon: item.selectedIcon,
                        label: Text(item.label),
                      )).toList(),
                ),
                const VerticalDivider(width: 1),
                Expanded(child: IndexedStack(index: _selectedIndex, children: pages)),
              ],
            )
          : IndexedStack(index: _selectedIndex, children: pages),
      bottomNavigationBar: wide
          ? null
          : NavigationBar(
              selectedIndex: _selectedIndex,
              onDestinationSelected: _goTo,
              destinations: _destinations,
            ),
    );
  }
}

class _ThemeMenuLabel extends StatelessWidget {
  const _ThemeMenuLabel({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 12),
          Text(label),
        ],
      );
}
