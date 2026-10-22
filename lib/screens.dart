import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

import 'api_service.dart';
import 'app_store.dart';
import 'extras.dart';
import 'models.dart';
import 'widgets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.onNavigate});
  final ValueChanged<int> onNavigate;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _search = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => AppStore.instance.loadCountries());
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = AppStore.instance;
    final colors = Theme.of(context).colorScheme;
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) => ResponsivePage(
        child: ListView(
          children: [
            Container(
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF5965EC), Color(0xFF7C56D9), Color(0xFF3D8EDB)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(28),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) => Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.18), borderRadius: BorderRadius.circular(30)),
                            child: const Text('YOUR WORLD, CONNECTED',
                                style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.3)),
                          ),
                          const SizedBox(height: 18),
                          Text('Discover more.\nExplore everything.',
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: Colors.white, fontWeight: FontWeight.w900, height: 1.05, letterSpacing: -1,
                              )),
                          const SizedBox(height: 12),
                          Text('Countries, forecasts, places, books and little things worth learning — together in one place.',
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white.withValues(alpha: 0.88), height: 1.45)),
                          const SizedBox(height: 20),
                          Wrap(spacing: 10, runSpacing: 10, children: [
                            FilledButton.icon(
                              style: FilledButton.styleFrom(backgroundColor: Colors.white, foregroundColor: const Color(0xFF4D59D5)),
                              onPressed: () => widget.onNavigate(1),
                              icon: const Icon(Icons.public_rounded),
                              label: const Text('Explore atlas'),
                            ),
                            OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(foregroundColor: Colors.white, side: BorderSide(color: Colors.white.withValues(alpha: 0.6))),
                              onPressed: () => widget.onNavigate(2),
                              icon: const Icon(Icons.cloud_outlined),
                              label: const Text('Check weather'),
                            ),
                          ]),
                        ],
                      ),
                    ),
                    if (constraints.maxWidth > 500) ...[
                      const SizedBox(width: 18),
                      Container(
                        width: 128,
                        height: 128,
                        decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.13), border: Border.all(color: Colors.white24)),
                        child: const Icon(Icons.public_rounded, size: 88, color: Colors.white),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 22),
            TextField(
              controller: _search,
              onChanged: (value) => setState(() => _query = value.trim().toLowerCase()),
              decoration: InputDecoration(
                hintText: 'Search countries by name, capital or language…',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _query.isEmpty ? const Icon(Icons.travel_explore_rounded) : IconButton(
                  onPressed: () { _search.clear(); setState(() => _query = ''); },
                  icon: const Icon(Icons.close_rounded),
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (_query.isEmpty) ...[
              const SectionHeading(title: 'Explore your world', subtitle: 'One app, many ways to discover'),
              const SizedBox(height: 14),
              LayoutBuilder(builder: (context, constraints) {
                final count = constraints.maxWidth > 850 ? 4 : 2;
                final features = <_Feature>[
                  _Feature(Icons.public_rounded, 'World atlas', 'Countries & cultures', const Color(0xFF6374F5), () => widget.onNavigate(1)),
                  _Feature(Icons.cloud_sun_rounded, 'Weather', 'Forecast & air quality', const Color(0xFF0E9D88), () => widget.onNavigate(2)),
                  _Feature(Icons.menu_book_rounded, 'Open library', 'Books & reading lists', const Color(0xFF8B5CF6), () => widget.onNavigate(3)),
                  _Feature(Icons.photo_library_rounded, 'Photo explorer', 'Real images & credits', const Color(0xFFEF8B44), () => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => const PhotosScreen()))),
                  _Feature(Icons.currency_exchange_rounded, 'Currency', 'Reference rates', const Color(0xFF2389C8), () => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => const CurrencyScreen()))),
                  _Feature(Icons.quiz_rounded, 'Country quiz', 'Learn as you play', const Color(0xFFE45F80), () => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => const QuizScreen()))),
                  _Feature(Icons.bookmark_rounded, 'Saved', 'Your collection', const Color(0xFF64748B), () => widget.onNavigate(4)),
                  _Feature(Icons.auto_awesome_rounded, 'Daily discovery', 'Find something new', const Color(0xFFD2A12E), () {
                    final list = store.countries;
                    if (list.isNotEmpty) showCountryDetails(context, list[DateTime.now().day % list.length]);
                    else widget.onNavigate(1);
                  }),
                ];
                return GridView.count(
                  crossAxisCount: count,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: constraints.maxWidth < 400 ? 1.6 : 2.0,
                  children: features.map((item) => _FeatureCard(feature: item)).toList(),
                );
              }),
            ],
            const SizedBox(height: 24),
            SectionHeading(
              title: _query.isEmpty ? 'Countries to explore' : 'Search results',
              subtitle: store.countries.isEmpty ? 'Loading the public country dataset' : store.countries.length.toString() + ' countries and territories',
              trailing: _query.isEmpty ? TextButton(onPressed: () => widget.onNavigate(1), child: const Text('View all')) : null,
            ),
            const SizedBox(height: 12),
            if (store.countriesLoading && store.countries.isEmpty)
              const LoadingPanel()
            else if (store.countriesError != null && store.countries.isEmpty)
              ErrorPanel(message: store.countriesError!, onRetry: () => store.loadCountries(forceRefresh: true))
            else
              _CountryGrid(
                countries: store.countries.where((country) {
                  final query = _query;
                  final matches = country.name.toLowerCase().contains(query) ||
                      country.capitals.any((capital) => capital.toLowerCase().contains(query)) ||
                      country.region.toLowerCase().contains(query) ||
                      country.languages.any((language) => language.toLowerCase().contains(query));
                  if (query.isNotEmpty) return matches;
                  return ['Japan', 'India', 'Brazil', 'France', 'Canada', 'New Zealand'].contains(country.name);
                }).take(_query.isEmpty ? 6 : 16).toList(),
                onTap: (country) => showCountryDetails(context, country),
              ),
            const SizedBox(height: 22),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(color: colors.primaryContainer.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(22)),
              child: Row(children: [
                Icon(Icons.shield_outlined, size: 30, color: colors.primary),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Private by design', style: TextStyle(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Text('No account or API key. Favourites and reading lists stay on this device.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant)),
                ])),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}

class _Feature {
  const _Feature(this.icon, this.title, this.caption, this.color, this.onTap);
  final IconData icon;
  final String title;
  final String caption;
  final Color color;
  final VoidCallback onTap;
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({required this.feature});
  final _Feature feature;

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    tween: Tween(begin: 0.97, end: 1),
    duration: const Duration(milliseconds: 300),
    curve: Curves.easeOutCubic,
    builder: (context, scale, child) => Transform.scale(scale: scale, child: child),
    child: Material(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: feature.onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(13),
          child: Row(children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(color: feature.color.withValues(alpha: 0.13), borderRadius: BorderRadius.circular(13)),
              child: Icon(feature.icon, color: feature.color, size: 22),
            ),
            const SizedBox(width: 10),
            Expanded(child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(feature.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text(feature.caption, maxLines: 2, overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
              ],
            )),
          ]),
        ),
      ),
    ),
  );
}

class CountriesScreen extends StatefulWidget {
  const CountriesScreen({super.key});

  @override
  State<CountriesScreen> createState() => _CountriesScreenState();
}

class _CountriesScreenState extends State<CountriesScreen> {
  final _controller = TextEditingController();
  String _query = '';
  String _region = 'All';

  @override
  void initState() {
    super.initState();
    AppStore.instance.loadCountries();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = AppStore.instance;
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        final regionSet = store.countries.map((country) => country.region).where((value) => value.isNotEmpty).toSet().toList()..sort();
        final regions = ['All', ...regionSet];
        final filtered = store.countries.where((country) {
          final matches = _query.isEmpty || country.name.toLowerCase().contains(_query) ||
              country.capitals.any((capital) => capital.toLowerCase().contains(_query)) ||
              country.region.toLowerCase().contains(_query) ||
              country.languages.any((language) => language.toLowerCase().contains(_query));
          return matches && (_region == 'All' || country.region == _region);
        }).toList();

        return ResponsivePage(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SectionHeading(title: 'World Atlas', subtitle: 'Country facts from a public dataset'),
            const SizedBox(height: 18),
            TextField(
              controller: _controller,
              onChanged: (value) => setState(() => _query = value.trim().toLowerCase()),
              decoration: InputDecoration(
                hintText: 'Country, capital, language…',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _query.isEmpty ? null : IconButton(onPressed: () {
                  _controller.clear(); setState(() => _query = '');
                }, icon: const Icon(Icons.close_rounded)),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 42,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: regions.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, index) => ChoiceChip(
                  label: Text(regions[index]),
                  selected: _region == regions[index],
                  onSelected: (_) => setState(() => _region = regions[index]),
                ),
              ),
            ),
            const SizedBox(height: 14),
            if (store.countriesLoading && store.countries.isEmpty)
              const Expanded(child: LoadingPanel())
            else if (store.countriesError != null && store.countries.isEmpty)
              Expanded(child: ErrorPanel(message: store.countriesError!, onRetry: () => store.loadCountries(forceRefresh: true)))
            else if (filtered.isEmpty)
              const Expanded(child: EmptyPanel(icon: Icons.travel_explore_rounded, title: 'No countries found', message: 'Try a different name, capital or region.'))
            else
              Expanded(child: LayoutBuilder(builder: (context, constraints) {
                final columns = constraints.maxWidth > 900 ? 3 : (constraints.maxWidth > 540 ? 2 : 1);
                return GridView.builder(
                  itemCount: filtered.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    mainAxisExtent: 104,
                  ),
                  itemBuilder: (context, index) => _CountryTile(
                    country: filtered[index],
                    onTap: () => showCountryDetails(context, filtered[index]),
                  ),
                );
              })),
          ]),
        );
      },
    );
  }
}

class _CountryGrid extends StatelessWidget {
  const _CountryGrid({required this.countries, required this.onTap});
  final List<Country> countries;
  final ValueChanged<Country> onTap;

  @override
  Widget build(BuildContext context) {
    if (countries.isEmpty) {
      return const EmptyPanel(icon: Icons.search_off_rounded, title: 'No matching countries', message: 'Try another search, or open the full atlas.');
    }
    return LayoutBuilder(builder: (context, constraints) {
      final columns = constraints.maxWidth > 850 ? 3 : (constraints.maxWidth > 520 ? 2 : 1);
      return GridView.builder(
        itemCount: countries.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: columns, mainAxisSpacing: 10, crossAxisSpacing: 10, mainAxisExtent: 104),
        itemBuilder: (context, index) => _CountryTile(country: countries[index], onTap: () => onTap(countries[index])),
      );
    });
  }
}

class _CountryTile extends StatelessWidget {
  const _CountryTile({required this.country, required this.onTap});
  final Country country;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
        child: Row(children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(15)),
            alignment: Alignment.center,
            child: Text(country.flagEmoji, style: const TextStyle(fontSize: 30)),
          ),
          const SizedBox(width: 11),
          Expanded(child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(country.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text(country.capital, maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
              const SizedBox(height: 4),
              Text(country.region + ' · ' + formatCompactNumber(country.population) + ' people',
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).colorScheme.primary)),
            ],
          )),
          const Icon(Icons.chevron_right_rounded),
        ]),
      ),
    ),
  );
}

void showCountryDetails(BuildContext context, Country country) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => CountryDetailsSheet(country: country),
  );
}

class CountryDetailsSheet extends StatelessWidget {
  const CountryDetailsSheet({super.key, required this.country});
  final Country country;

  @override
  Widget build(BuildContext context) {
    final store = AppStore.instance;
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 8, 22, 26),
          child: SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text(country.flagEmoji, style: const TextStyle(fontSize: 46)),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(country.name, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)),
                Text(country.officialName, style: Theme.of(context).textTheme.bodySmall),
              ])),
              IconButton.filledTonal(
                onPressed: () => store.toggleCountryFavorite(country),
                tooltip: store.favoriteCountryCodes.contains(country.code) ? 'Remove from saved' : 'Save country',
                icon: Icon(store.favoriteCountryCodes.contains(country.code) ? Icons.bookmark : Icons.bookmark_border),
              ),
            ]),
            const SizedBox(height: 20),
            Wrap(spacing: 8, runSpacing: 8, children: [
              _InfoChip(icon: Icons.location_city, label: 'Capital', value: country.capital),
              _InfoChip(icon: Icons.public, label: 'Region', value: country.region),
              _InfoChip(icon: Icons.people_alt_outlined, label: 'Population', value: formatCompactNumber(country.population)),
              _InfoChip(icon: Icons.square_foot_outlined, label: 'Area', value: formatCompactNumber(country.area.round()) + ' km²'),
              _InfoChip(icon: Icons.currency_exchange, label: 'Currency', value: country.currencyLabel),
              _InfoChip(icon: Icons.translate_rounded, label: 'Languages', value: country.languages.isEmpty ? 'Not listed' : country.languages.join(', ')),
              _InfoChip(icon: Icons.schedule_rounded, label: 'Time zones', value: country.timezones.take(4).join(', ')),
              _InfoChip(icon: Icons.flag_outlined, label: 'Borders', value: country.borders.isEmpty ? 'None listed' : country.borders.join(', ')),
            ]),
            if (country.flagUrl.isNotEmpty) ...[
              const SizedBox(height: 18),
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(country.flagUrl, height: 110, width: double.infinity, fit: BoxFit.contain,
                    errorBuilder: (_, _, _) => const SizedBox.shrink()),
              ),
            ],
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: () => showCountryCompareDialog(context, country),
              icon: const Icon(Icons.compare_arrows_rounded),
              label: const Text('Compare with another country'),
            ),
          ])),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Container(
    constraints: const BoxConstraints(maxWidth: 340),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(14),
      color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
    ),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 17, color: Theme.of(context).colorScheme.primary),
      const SizedBox(width: 8),
      Flexible(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
        Text(value, maxLines: 3, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700)),
      ])),
    ]),
  );
}

void showCountryCompareDialog(BuildContext context, Country first) {
  final countries = AppStore.instance.countries.where((country) => country.code != first.code).toList();
  if (countries.isEmpty) return;
  showDialog<void>(context: context, builder: (context) {
    Country second = countries.first;
    return StatefulBuilder(builder: (context, setState) => AlertDialog(
      title: const Text('Country comparison'),
      content: SizedBox(
        width: 480,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          DropdownButtonFormField<Country>(
            value: second,
            isExpanded: true,
            decoration: const InputDecoration(labelText: 'Compare with'),
            items: countries.map((country) => DropdownMenuItem(value: country, child: Text(country.flagEmoji + '  ' + country.name, overflow: TextOverflow.ellipsis))).toList(),
            onChanged: (value) { if (value != null) setState(() => second = value); },
          ),
          const SizedBox(height: 18),
          _CompareRow(label: 'Capital', left: first.capital, right: second.capital),
          _CompareRow(label: 'Population', left: formatCompactNumber(first.population), right: formatCompactNumber(second.population)),
          _CompareRow(label: 'Area km²', left: formatCompactNumber(first.area.round()), right: formatCompactNumber(second.area.round())),
          _CompareRow(label: 'Currency', left: first.currencyLabel, right: second.currencyLabel),
          _CompareRow(label: 'Languages', left: first.languages.take(2).join(', '), right: second.languages.take(2).join(', ')),
        ]),
      ),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Done'))],
    ));
  });
}

class _CompareRow extends StatelessWidget {
  const _CompareRow({required this.label, required this.left, required this.right});
  final String label;
  final String left;
  final String right;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Expanded(child: Text(left, style: const TextStyle(fontWeight: FontWeight.w700))),
      SizedBox(width: 84, child: Text(label, textAlign: TextAlign.center, style: Theme.of(context).textTheme.labelSmall)),
      Expanded(child: Text(right, textAlign: TextAlign.end, style: const TextStyle(fontWeight: FontWeight.w700))),
    ]),
  );
}

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});
  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final _city = TextEditingController();
  WeatherSnapshot? _weather;
  String _place = '';
  bool _loading = false;
  String? _error;

  @override
  void dispose() { _city.dispose(); super.dispose(); }

  Future<void> _loadCity() async {
    final value = _city.text.trim();
    if (value.isEmpty) { setState(() => _error = 'Enter a city name, for example Tokyo or Kolkata.'); return; }
    setState(() { _loading = true; _error = null; });
    try {
      final place = await AppStore.instance.api.geocodeCity(value);
      final weather = await AppStore.instance.api.fetchWeather(place.latitude, place.longitude);
      if (!mounted) return;
      setState(() { _weather = weather; _place = place.country.isEmpty ? place.name : place.name + ', ' + place.country; });
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally { if (mounted) setState(() => _loading = false); }
  }

  Future<void> _loadLocation() async {
    setState(() { _loading = true; _error = null; });
    try {
      if (!await Geolocator.isLocationServiceEnabled()) throw const ApiException('Location services are off. Search a city instead.');
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        throw const ApiException('Location permission was not granted. Search a city instead.');
      }
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.medium, timeLimit: Duration(seconds: 14)),
      );
      final weather = await AppStore.instance.api.fetchWeather(position.latitude, position.longitude);
      if (!mounted) return;
      setState(() { _weather = weather; _place = 'Current location'; });
    } catch (error) {
      if (mounted) setState(() => _error = error.toString().replaceFirst('Exception: ', ''));
    } finally { if (mounted) setState(() => _loading = false); }
  }

  @override
  Widget build(BuildContext context) => ResponsivePage(
    child: ListView(children: [
      const SectionHeading(title: 'Weather Center', subtitle: 'Current conditions, forecast and air quality'),
      const SizedBox(height: 18),
      Row(children: [
        Expanded(child: TextField(
          controller: _city,
          textInputAction: TextInputAction.search,
          onSubmitted: (_) => _loadCity(),
          decoration: const InputDecoration(prefixIcon: Icon(Icons.search_rounded), hintText: 'Search any city…'),
        )),
        const SizedBox(width: 8),
        FilledButton(
          onPressed: _loading ? null : _loadCity,
          style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18)),
          child: const Icon(Icons.arrow_forward_rounded),
        ),
      ]),
      const SizedBox(height: 10),
      Align(alignment: Alignment.centerLeft, child: OutlinedButton.icon(
        onPressed: _loading ? null : _loadLocation,
        icon: const Icon(Icons.my_location_rounded, size: 18),
        label: const Text('Use my current location'),
      )),
      if (_loading) const LoadingPanel(label: 'Fetching live weather…'),
      if (_error != null) ...[const SizedBox(height: 8), ErrorPanel(message: _error!, onRetry: _loadCity)],
      if (_weather == null && !_loading && _error == null) ...[
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(26),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF1E6CB5), Color(0xFF61B6D8)], begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(26),
          ),
          child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(Icons.cloud_queue_rounded, color: Colors.white, size: 42),
            SizedBox(height: 15),
            Text('Weather, wherever you are.', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
            SizedBox(height: 8),
            Text('Search any city for real current conditions, hourly changes and a 7-day forecast. Location access is optional.',
              style: TextStyle(color: Colors.white, height: 1.45)),
          ]),
        ),
      ],
      if (_weather != null) ...[
        const SizedBox(height: 16),
        _WeatherHero(weather: _weather!, place: _place),
        const SizedBox(height: 20),
        const SectionHeading(title: 'Next hours', subtitle: 'Temperature and chance of precipitation'),
        const SizedBox(height: 12),
        SizedBox(height: 116, child: Builder(builder: (context) {
          final weather = _weather!;
          final count = weather.hourlyTimes.length < 12 ? weather.hourlyTimes.length : 12;
          final found = weather.hourlyTimes.indexWhere((time) => time.compareTo(weather.updatedAt) >= 0);
          final start = found < 0 ? 0 : found;
          return ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: count,
            separatorBuilder: (_, _) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final i = start + index;
              if (i >= weather.hourlyTimes.length || i >= weather.hourlyTemps.length) return const SizedBox.shrink();
              final rain = i < weather.hourlyRain.length ? weather.hourlyRain[i] : 0;
              return Container(
                width: 88,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.55)),
                ),
                child: Column(children: [
                  Text(timeLabel(weather.hourlyTimes[i]), style: Theme.of(context).textTheme.labelSmall),
                  const Spacer(),
                  const Icon(Icons.thermostat_rounded, size: 20),
                  Text(weather.hourlyTemps[i].round().toString() + '°', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                  Text(rain.toString() + '% rain', style: Theme.of(context).textTheme.labelSmall),
                ]),
              );
            },
          );
        })),
        const SizedBox(height: 22),
        const SectionHeading(title: '7-day forecast', subtitle: 'Daily high and low temperatures'),
        const SizedBox(height: 12),
        Card(child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(children: _weather!.days.map((day) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(children: [
              SizedBox(width: 48, child: Text(weekdayLabel(day.date), style: const TextStyle(fontWeight: FontWeight.w700))),
              Icon(weatherIcon(day.weatherCode), size: 22, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 10),
              Expanded(child: Text(weatherDescription(day.weatherCode), style: Theme.of(context).textTheme.bodySmall)),
              Text(day.minTemp.round().toString() + '°', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
              const SizedBox(width: 14),
              SizedBox(width: 34, child: Text(day.maxTemp.round().toString() + '°', textAlign: TextAlign.end, style: const TextStyle(fontWeight: FontWeight.w800))),
            ]),
          )).toList()),
        )),
        const SizedBox(height: 20),
        const SectionHeading(title: 'Weather details'),
        const SizedBox(height: 12),
        LayoutBuilder(builder: (context, constraints) {
          final weather = _weather!;
          final columns = constraints.maxWidth > 600 ? 3 : 2;
          return GridView.count(
            crossAxisCount: columns,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.65,
            children: [
              _WeatherMetric(icon: Icons.thermostat, label: 'Feels like', value: weather.apparentTemperature.round().toString() + '°C'),
              _WeatherMetric(icon: Icons.water_drop_outlined, label: 'Humidity', value: weather.humidity.toString() + '%'),
              _WeatherMetric(icon: Icons.air_rounded, label: 'Wind speed', value: weather.windSpeed.round().toString() + ' km/h'),
              _WeatherMetric(icon: Icons.wb_twilight_rounded, label: 'Sunrise', value: weather.days.isEmpty ? '—' : timeLabel(weather.days.first.sunrise)),
              _WeatherMetric(icon: Icons.nights_stay_outlined, label: 'Sunset', value: weather.days.isEmpty ? '—' : timeLabel(weather.days.first.sunset)),
              _WeatherMetric(icon: Icons.airline_stops_rounded, label: 'US AQI', value: weather.usAqi == null ? 'Unavailable' : weather.usAqi!.round().toString()),
              _WeatherMetric(icon: Icons.grain_rounded, label: 'PM2.5', value: weather.pm25 == null ? 'Unavailable' : weather.pm25!.toStringAsFixed(1) + ' μg/m³'),
            ],
          );
        }),
        const SizedBox(height: 14),
        Text('Weather and air-quality data: Open-Meteo. Values may change and are not an emergency alert service.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
      ],
    ]),
  );
}

class _WeatherHero extends StatelessWidget {
  const _WeatherHero({required this.weather, required this.place});
  final WeatherSnapshot weather;
  final String place;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      gradient: const LinearGradient(colors: [Color(0xFF233C82), Color(0xFF476FDA), Color(0xFF3D9CC8)], begin: Alignment.topLeft, end: Alignment.bottomRight),
      borderRadius: BorderRadius.circular(26),
    ),
    child: Row(children: [
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(place, style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800)),
        const SizedBox(height: 6),
        Text(weatherDescription(weather.weatherCode), style: TextStyle(color: Colors.white.withValues(alpha: 0.84))),
        const SizedBox(height: 12),
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: weather.temperature),
          duration: const Duration(milliseconds: 800),
          builder: (context, value, _) => Text(value.round().toString() + '°',
            style: const TextStyle(color: Colors.white, fontSize: 64, height: 1, fontWeight: FontWeight.w900, letterSpacing: -3)),
        ),
        const SizedBox(height: 8),
        Text('Updated ' + weather.updatedAt, style: TextStyle(color: Colors.white.withValues(alpha: 0.72), fontSize: 11)),
      ])),
      Icon(weatherIcon(weather.weatherCode, isDay: weather.isDay), size: 86, color: Colors.white.withValues(alpha: 0.94)),
    ]),
  );
}

class _WeatherMetric extends StatelessWidget {
  const _WeatherMetric({required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5)),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, color: Theme.of(context).colorScheme.primary),
      const Spacer(),
      Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
      Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
    ]),
  );
}

class BooksScreen extends StatefulWidget {
  const BooksScreen({super.key});
  @override
  State<BooksScreen> createState() => _BooksScreenState();
}

class _BooksScreenState extends State<BooksScreen> {
  final _controller = TextEditingController(text: 'world');
  Timer? _debounce;
  Future<List<Book>>? _future;
  String _query = 'world';

  @override
  void initState() { super.initState(); _future = AppStore.instance.api.searchBooks(_query); }

  @override
  void dispose() { _debounce?.cancel(); _controller.dispose(); super.dispose(); }

  void _search(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 450), () {
      if (!mounted) return;
      setState(() {
        _query = value.trim().isEmpty ? 'world' : value.trim();
        _future = AppStore.instance.api.searchBooks(_query);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final store = AppStore.instance;
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) => ResponsivePage(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SectionHeading(title: 'Open Library', subtitle: 'Books from a public catalogue'),
          const SizedBox(height: 18),
          TextField(
            controller: _controller,
            onChanged: _search,
            textInputAction: TextInputAction.search,
            decoration: const InputDecoration(prefixIcon: Icon(Icons.search_rounded), hintText: 'Title, author or topic…'),
          ),
          const SizedBox(height: 12),
          Row(children: [
            const Icon(Icons.bookmark_added_outlined, size: 18),
            const SizedBox(width: 8),
            Expanded(child: Text(store.readingStatuses.length.toString() + ' books in your reading list',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant))),
          ]),
          const SizedBox(height: 16),
          Expanded(child: FutureBuilder<List<Book>>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) return const LoadingPanel(label: 'Searching Open Library…');
              if (snapshot.hasError) return ErrorPanel(message: snapshot.error.toString(), onRetry: () => setState(() => _future = store.api.searchBooks(_query)));
              final books = snapshot.data ?? const <Book>[];
              if (books.isEmpty) return const EmptyPanel(icon: Icons.menu_book_outlined, title: 'No books found', message: 'Try a broader title, author or topic.');
              return LayoutBuilder(builder: (context, constraints) {
                final columns = constraints.maxWidth > 1000 ? 5 : (constraints.maxWidth > 740 ? 4 : (constraints.maxWidth > 500 ? 3 : 2));
                return GridView.builder(
                  itemCount: books.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: columns, crossAxisSpacing: 12, mainAxisSpacing: 14, childAspectRatio: 0.59),
                  itemBuilder: (context, index) => _BookCard(book: books[index], onTap: () => showBookDetails(context, books[index])),
                );
              });
            },
          )),
        ]),
      ),
    );
  }
}

class _BookCard extends StatelessWidget {
  const _BookCard({required this.book, required this.onTap});
  final Book book;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final store = AppStore.instance;
    final saved = store.readingStatuses.containsKey(book.key);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: Stack(fit: StackFit.expand, children: [
            Container(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: book.coverUrl.isEmpty
                  ? const ImagePlaceholder(icon: Icons.menu_book_rounded)
                  : Image.network(book.coverUrl, fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const ImagePlaceholder(icon: Icons.menu_book_rounded),
                      loadingBuilder: (context, child, progress) => progress == null ? child : const ImagePlaceholder(icon: Icons.menu_book_rounded)),
            ),
            Positioned(top: 6, right: 6, child: Material(
              color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.93),
              shape: const CircleBorder(),
              child: IconButton(
                visualDensity: VisualDensity.compact,
                tooltip: saved ? 'Remove from reading list' : 'Add to reading list',
                onPressed: () => store.setBookStatus(book, saved ? null : 'Want to read'),
                icon: Icon(saved ? Icons.bookmark : Icons.bookmark_border, size: 19),
              ),
            )),
          ])),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(book.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800, height: 1.2)),
              const SizedBox(height: 5),
              Text(book.authorLabel, maxLines: 2, overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
              const SizedBox(height: 6),
              Text(book.firstPublishYear?.toString() ?? 'Year not listed',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w700)),
            ]),
          ),
        ]),
      ),
    );
  }
}

void showBookDetails(BuildContext context, Book book) {
  showModalBottomSheet<void>(context: context, isScrollControlled: true, showDragHandle: true, builder: (_) => BookDetailsSheet(book: book));
}

class BookDetailsSheet extends StatelessWidget {
  const BookDetailsSheet({super.key, required this.book});
  final Book book;

  @override
  Widget build(BuildContext context) {
    final store = AppStore.instance;
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) => SafeArea(child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 8, 22, 28),
        child: SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            ClipRRect(borderRadius: BorderRadius.circular(14), child: SizedBox(
              width: 104, height: 148,
              child: book.coverUrl.isEmpty ? const ImagePlaceholder(icon: Icons.menu_book_rounded)
                  : Image.network(book.coverUrl, fit: BoxFit.cover, errorBuilder: (_, _, _) => const ImagePlaceholder(icon: Icons.menu_book_rounded)),
            )),
            const SizedBox(width: 16),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(book.title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              Text(book.authorLabel),
              const SizedBox(height: 6),
              Text(book.firstPublishYear?.toString() ?? 'Publication year not listed',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
              const SizedBox(height: 10),
              Text(book.editionCount.toString() + ' listed editions', style: Theme.of(context).textTheme.labelMedium),
            ])),
          ]),
          if (book.subjects.isNotEmpty) ...[
            const SizedBox(height: 18),
            const Text('Subjects', style: TextStyle(fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Wrap(spacing: 8, runSpacing: 8, children: book.subjects.take(8).map((subject) => Chip(label: Text(subject, overflow: TextOverflow.ellipsis))).toList()),
          ],
          const SizedBox(height: 20),
          DropdownButtonFormField<String>(
            value: store.readingStatuses[book.key] ?? 'Not saved',
            decoration: const InputDecoration(labelText: 'Reading list'),
            items: const [
              DropdownMenuItem(value: 'Not saved', child: Text('Not saved')),
              DropdownMenuItem(value: 'Want to read', child: Text('Want to read')),
              DropdownMenuItem(value: 'Reading', child: Text('Reading')),
              DropdownMenuItem(value: 'Finished', child: Text('Finished')),
            ],
            onChanged: (value) => store.setBookStatus(book, value == 'Not saved' ? null : value),
          ),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: () {
              final key = book.key.startsWith('/') ? book.key : '/' + book.key;
              launchUrl(Uri.https('openlibrary.org', key), mode: LaunchMode.externalApplication);
            },
            icon: const Icon(Icons.open_in_new_rounded),
            label: const Text('Open Open Library record'),
          ),
          const SizedBox(height: 8),
          Text('Book data and covers come from Open Library. Reading and download access depends on each title’s rights and availability.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
        ])),
      )),
    );
  }
}

class SavedScreen extends StatefulWidget {
  const SavedScreen({super.key});
  @override
  State<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends State<SavedScreen> {
  String _category = 'Countries';

  @override
  void initState() { super.initState(); AppStore.instance.loadCountries(); }

  @override
  Widget build(BuildContext context) {
    final store = AppStore.instance;
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        final countries = store.countries.where((country) => store.favoriteCountryCodes.contains(country.code)).toList();
        return ResponsivePage(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SectionHeading(title: 'Your saved space', subtitle: 'Collections stored on this device'),
          const SizedBox(height: 18),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'Countries', label: Text('Countries'), icon: Icon(Icons.public_rounded)),
              ButtonSegment(value: 'Books', label: Text('Books'), icon: Icon(Icons.menu_book_rounded)),
              ButtonSegment(value: 'Photos', label: Text('Photos'), icon: Icon(Icons.photo_library_outlined)),
            ],
            selected: {_category},
            onSelectionChanged: (selection) => setState(() => _category = selection.first),
          ),
          const SizedBox(height: 16),
          Expanded(child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            child: switch (_category) {
              'Countries' => countries.isEmpty
                  ? const EmptyPanel(key: ValueKey('no-countries'), icon: Icons.bookmark_border, title: 'No saved countries yet', message: 'Open World Atlas and tap the bookmark to keep a country here.')
                  : ListView.separated(
                      key: const ValueKey('countries'),
                      itemCount: countries.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (context, index) => _CountryTile(country: countries[index], onTap: () => showCountryDetails(context, countries[index])),
                    ),
              'Books' => store.savedBooks.isEmpty
                  ? const EmptyPanel(key: ValueKey('no-books'), icon: Icons.menu_book_outlined, title: 'Your reading list is empty', message: 'Search Open Library and save books to track what you want to read.')
                  : ListView.separated(
                      key: const ValueKey('books'),
                      itemCount: store.savedBooks.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final book = store.savedBooks.values.toList()[index];
                        return Card(child: ListTile(
                          leading: SizedBox(width: 44, child: book.coverUrl.isEmpty ? const ImagePlaceholder(icon: Icons.menu_book)
                            : Image.network(book.coverUrl, fit: BoxFit.cover, errorBuilder: (_, _, _) => const ImagePlaceholder(icon: Icons.menu_book))),
                          title: Text(book.title, maxLines: 2, overflow: TextOverflow.ellipsis),
                          subtitle: Text((store.readingStatuses[book.key] ?? 'Saved') + ' · ' + book.authorLabel, maxLines: 2, overflow: TextOverflow.ellipsis),
                          onTap: () => showBookDetails(context, book),
                        ));
                      },
                    ),
              _ => store.savedPhotos.isEmpty
                  ? const EmptyPanel(key: ValueKey('no-photos'), icon: Icons.photo_library_outlined, title: 'No saved images yet', message: 'Discover public images and bookmark ones you want to revisit.')
                  : GridView.builder(
                      key: const ValueKey('photos'),
                      itemCount: store.savedPhotos.length,
                      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 270, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 0.85),
                      itemBuilder: (context, index) {
                        final photo = store.savedPhotos.values.toList()[index];
                        return Card(clipBehavior: Clip.antiAlias, child: InkWell(
                          onTap: () => showPhotoDetails(context, photo),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Expanded(child: Image.network(photo.imageUrl, width: double.infinity, fit: BoxFit.cover, errorBuilder: (_, _, _) => const ImagePlaceholder())),
                            Padding(padding: const EdgeInsets.all(10), child: Text(photo.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700))),
                          ]),
                        ));
                      },
                    ),
            },
          )),
        ]));
      },
    );
  }
}

void showPhotoDetails(BuildContext context, PhotoItem photo) {
  showModalBottomSheet<void>(context: context, isScrollControlled: true, showDragHandle: true, builder: (_) => PhotoDetailsSheet(photo: photo));
}

class PhotoDetailsSheet extends StatelessWidget {
  const PhotoDetailsSheet({super.key, required this.photo});
  final PhotoItem photo;

  @override
  Widget build(BuildContext context) {
    final store = AppStore.instance;
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) => SafeArea(child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 22),
        child: SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          ClipRRect(borderRadius: BorderRadius.circular(18), child: Image.network(photo.imageUrl, width: double.infinity, height: 250, fit: BoxFit.cover,
            errorBuilder: (_, _, _) => const SizedBox(height: 140, child: ImagePlaceholder()))),
          const SizedBox(height: 16),
          Text(photo.title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          Text('Creator: ' + photo.artist),
          const SizedBox(height: 4),
          Text('Licence: ' + photo.license),
          if (photo.licenseUrl.isNotEmpty) ...[const SizedBox(height: 8), SelectableText(photo.licenseUrl)],
          const SizedBox(height: 18),
          Wrap(spacing: 10, runSpacing: 10, children: [
            FilledButton.icon(
              onPressed: () => store.togglePhotoSaved(photo),
              icon: Icon(store.savedPhotos.containsKey(photo.id) ? Icons.bookmark_remove : Icons.bookmark_add_outlined),
              label: Text(store.savedPhotos.containsKey(photo.id) ? 'Remove saved image' : 'Save image'),
            ),
            if (photo.pageUrl.isNotEmpty) OutlinedButton.icon(
              onPressed: () => launchUrl(Uri.parse(photo.pageUrl), mode: LaunchMode.externalApplication),
              icon: const Icon(Icons.open_in_new_rounded),
              label: const Text('Source page'),
            ),
          ]),
          const SizedBox(height: 8),
          Text('Image and licence metadata are provided by Wikimedia Commons. Check the linked file page for full terms.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
        ])),
      )),
    );
  }
}
