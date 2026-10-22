import 'dart:ui' show ImageFilter;

import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart' hide Text;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'localization.dart';
import 'settings_screen.dart';

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
        locale: AppStore.instance.locale,
        supportedLocales: AtlasLocalizations.supportedLocales,
        localizationsDelegates: const [
          AtlasLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        theme: _buildTheme(Brightness.light),
        darkTheme: _buildTheme(Brightness.dark),
        home: const AppShell(),
      ),
    );
  }

  ThemeData _buildTheme(Brightness brightness) {
    const violet = Color(0xFF685AF5);
    final dark = brightness == Brightness.dark;
    final scheme = ColorScheme.fromSeed(
      seedColor: violet,
      brightness: brightness,
      surface: dark ? const Color(0xFF171B2C) : const Color(0xFFFEFEFF),
    ).copyWith(
      primary: dark ? const Color(0xFFA49BFF) : violet,
      secondary: dark ? const Color(0xFF73D8E8) : const Color(0xFF139EB0),
      tertiary: dark ? const Color(0xFFFF9AB5) : const Color(0xFFEF648A),
      surface: dark ? const Color(0xFF171B2C) : const Color(0xFFFEFEFF),
      surfaceContainerLowest: dark ? const Color(0xFF111522) : const Color(0xFFF9F8FF),
      surfaceContainerLow: dark ? const Color(0xFF1B2032) : const Color(0xFFF5F3FF),
      surfaceContainer: dark ? const Color(0xFF22283C) : const Color(0xFFEFEDFF),
      outline: dark ? const Color(0xFF424962) : const Color(0xFFDADCF0),
    );

    final border = dark ? Colors.white.withValues(alpha: 0.10) : const Color(0xFFE2E3F5);
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: dark ? const Color(0xFF101421) : const Color(0xFFF5F5FC),
      visualDensity: VisualDensity.standard,
      splashFactory: InkSparkle.splashFactory,
      pageTransitionsTheme: PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
        },
      ),
      textTheme: ThemeData(brightness: brightness).textTheme.apply(
        bodyColor: scheme.onSurface,
        displayColor: scheme.onSurface,
      ).copyWith(
        headlineLarge: ThemeData(brightness: brightness).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.w900, letterSpacing: -1.2),
        headlineMedium: ThemeData(brightness: brightness).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900, letterSpacing: -0.8),
        titleLarge: ThemeData(brightness: brightness).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -0.4),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: scheme.onSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: scheme.onSurface,
          fontSize: 20,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.6,
        ),
      ),
      cardTheme: CardThemeData(
        color: scheme.surface,
        elevation: 1,
        shadowColor: dark ? Colors.black.withValues(alpha: 0.22) : const Color(0xFF6560A8).withValues(alpha: 0.08),
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(23),
          side: BorderSide(color: border),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: dark ? const Color(0xFF1B2032) : Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        prefixIconColor: scheme.primary,
        hintStyle: TextStyle(color: scheme.onSurfaceVariant.withValues(alpha: 0.82)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: border, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: scheme.primary, width: 1.7),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: scheme.surfaceContainerLow,
        selectedColor: scheme.primaryContainer,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
        side: BorderSide(color: border),
        labelStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
      dividerTheme: DividerThemeData(color: border, space: 1, thickness: 1),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 14),
          textStyle: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          side: BorderSide(color: scheme.outline),
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 72,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        indicatorColor: scheme.primaryContainer,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStateProperty.resolveWith((states) => TextStyle(
          fontSize: 11,
          letterSpacing: 0.1,
          fontWeight: states.contains(WidgetState.selected) ? FontWeight.w800 : FontWeight.w600,
          color: states.contains(WidgetState.selected) ? scheme.primary : scheme.onSurfaceVariant,
        )),
        iconTheme: WidgetStateProperty.resolveWith((states) => IconThemeData(
          color: states.contains(WidgetState.selected) ? scheme.primary : scheme.onSurfaceVariant,
          size: 22,
        )),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: Colors.transparent,
        indicatorColor: scheme.primaryContainer,
        selectedIconTheme: IconThemeData(color: scheme.primary),
        selectedLabelTextStyle: TextStyle(color: scheme.primary, fontWeight: FontWeight.w800),
        unselectedLabelTextStyle: TextStyle(color: scheme.onSurfaceVariant, fontWeight: FontWeight.w600),
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

  List<NavigationDestination> _destinations(BuildContext context) => [
    NavigationDestination(icon: const Icon(Icons.space_dashboard_outlined), selectedIcon: const Icon(Icons.space_dashboard_rounded), label: tr(context, 'Home')),
    NavigationDestination(icon: const Icon(Icons.public_outlined), selectedIcon: const Icon(Icons.public_rounded), label: tr(context, 'Explore')),
    NavigationDestination(icon: const Icon(Icons.wb_cloudy_outlined), selectedIcon: const Icon(Icons.wb_cloudy_rounded), label: tr(context, 'Weather')),
    NavigationDestination(icon: const Icon(Icons.menu_book_outlined), selectedIcon: const Icon(Icons.menu_book_rounded), label: tr(context, 'Books')),
    NavigationDestination(icon: const Icon(Icons.bookmark_border_rounded), selectedIcon: const Icon(Icons.bookmark_rounded), label: tr(context, 'Saved')),
  ];

  @override
  Widget build(BuildContext context) {
    final store = AppStore.instance;
    final width = MediaQuery.sizeOf(context).width;
    final wide = width >= 900;
    final scheme = Theme.of(context).colorScheme;
    final pages = <Widget>[
      HomeScreen(onNavigate: _goTo),
      const CountriesScreen(),
      const WeatherScreen(),
      const BooksScreen(),
      const SavedScreen(),
    ];

    return PopScope<Object?>(
      canPop: _selectedIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _selectedIndex != 0) _goTo(0);
      },
      child: Scaffold(
      extendBody: !wide,
      appBar: AppBar(
        titleSpacing: 18,
        toolbarHeight: 66,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    scheme.surface.withValues(alpha: 0.97),
                    scheme.surface.withValues(alpha: 0.92),
                    scheme.primaryContainer.withValues(alpha: 0.24),
                  ],
                ),
                border: Border(bottom: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.65))),
              ),
            ),
          ),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 39,
              height: 39,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF7468FF), Color(0xFF8B5CF6), Color(0xFF38B6CC)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withValues(alpha: 0.8), width: 1.2),
                boxShadow: [BoxShadow(color: scheme.primary.withValues(alpha: 0.24), blurRadius: 15, offset: const Offset(0, 5))],
              ),
              child: const Icon(Icons.explore_rounded, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 11),
            const Text('AtlasFlow'),
            const SizedBox(width: 9),
            if (width > 520)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: scheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: scheme.secondary.withValues(alpha: 0.25)),
                ),
                child: Text('WORLD EXPLORER', style: TextStyle(color: scheme.onSecondaryContainer, fontSize: 9, letterSpacing: 0.8, fontWeight: FontWeight.w900)),
              ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: tr(context, 'Settings'),
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const SettingsScreen())),
          ),
          Tooltip(
            message: tr(context, 'Appearance'),
            child: PopupMenuButton<ThemeMode>(
              icon: const Icon(Icons.palette_outlined),
              tooltip: tr(context, 'Appearance'),
              onSelected: store.setThemeMode,
              itemBuilder: (context) => [
                PopupMenuItem(value: ThemeMode.system, child: _ThemeMenuLabel(icon: Icons.brightness_auto, label: 'System theme')),
                PopupMenuItem(value: ThemeMode.light, child: _ThemeMenuLabel(icon: Icons.light_mode_outlined, label: 'Light theme')),
                PopupMenuItem(value: ThemeMode.dark, child: _ThemeMenuLabel(icon: Icons.dark_mode_outlined, label: 'Dark theme')),
              ],
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).scaffoldBackgroundColor,
              scheme.primary.withValues(alpha: scheme.brightness == Brightness.dark ? 0.035 : 0.025),
              scheme.secondary.withValues(alpha: scheme.brightness == Brightness.dark ? 0.025 : 0.045),
              Theme.of(context).scaffoldBackgroundColor,
            ],
          ),
        ),
        child: wide
            ? Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 16, 6, 16),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Container(
                        decoration: BoxDecoration(
                          color: scheme.surface.withValues(alpha: 0.90),
                          border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.8)),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: NavigationRail(
                          selectedIndex: _selectedIndex,
                          onDestinationSelected: _goTo,
                          extended: width >= 1200,
                          labelType: width >= 1200 ? NavigationRailLabelType.none : NavigationRailLabelType.all,
                          destinations: _destinations(context).map((item) => NavigationRailDestination(
                            icon: item.icon,
                            selectedIcon: item.selectedIcon,
                            label: Text(item.label),
                          )).toList(),
                        ),
                      ),
                    ),
                  ),
                  Expanded(child: IndexedStack(index: _selectedIndex, children: pages)),
                ],
              )
            : IndexedStack(index: _selectedIndex, children: pages),
      ),
      bottomNavigationBar: wide
          ? null
          : ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        scheme.surface.withValues(alpha: 0.97),
                        scheme.surface.withValues(alpha: 0.94),
                        scheme.primaryContainer.withValues(alpha: 0.30),
                      ],
                    ),
                    border: Border(top: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.85))),
                    boxShadow: [BoxShadow(color: scheme.primary.withValues(alpha: 0.07), blurRadius: 20, offset: const Offset(0, -5))],
                  ),
                  child: NavigationBar(
                    selectedIndex: _selectedIndex,
                    onDestinationSelected: _goTo,
                    destinations: _destinations(context),
                  ),
                ),
              ),
            ),
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
    children: [Icon(icon, size: 20), const SizedBox(width: 12), Text(label)],
  );
}
