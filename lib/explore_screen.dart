import 'package:flutter/material.dart' hide Text;
import 'package:url_launcher/url_launcher.dart';
import 'api_service.dart';
import 'app_store.dart';
import 'localization.dart';
import 'models.dart';
import 'screens.dart';
import 'widgets.dart';

class ExplorerScreen extends StatelessWidget {
  const ExplorerScreen({super.key});
  @override Widget build(BuildContext context) => DefaultTabController(
    length: 5,
    child: ResponsivePage(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SectionHeading(title: tr(context, 'World economy, companies and people'), subtitle: tr(context, 'Explore companies, people, places and economic data from public sources.')),
      const SizedBox(height: 12),
      TabBar(isScrollable: true, tabAlignment: TabAlignment.start, tabs: [
        Tab(icon: const Icon(Icons.public_rounded), text: tr(context, 'Countries')),
        Tab(icon: const Icon(Icons.business_rounded), text: tr(context, 'Companies')),
        Tab(icon: const Icon(Icons.people_alt_rounded), text: tr(context, 'People')),
        Tab(icon: const Icon(Icons.place_rounded), text: tr(context, 'Places')),
        Tab(icon: const Icon(Icons.query_stats_rounded), text: tr(context, 'Economy')),
      ]),
      const SizedBox(height: 8),
      const Expanded(child: TabBarView(children: [
        CountriesScreen(),
        _DirectoryTab(kind: DirectoryKind.companies),
        _DirectoryTab(kind: DirectoryKind.people),
        _PlacesTab(),
        _EconomyTab(),
      ])),
    ])),
  );
}
enum DirectoryKind { companies, people }

class _DirectoryTab extends StatefulWidget {
  const _DirectoryTab({required this.kind});
  final DirectoryKind kind;
  @override State<_DirectoryTab> createState() => _DirectoryTabState();
}
class _DirectoryTabState extends State<_DirectoryTab> {
  final _controller = TextEditingController();
  List<PublicEntity> _items = const [];
  bool _loading = false;
  String? _error;
  int _version = 0;
  @override void dispose() { _controller.dispose(); super.dispose(); }

  Future<void> _search([String? forced]) async {
    final query = (forced ?? _controller.text).trim();
    if (query.isEmpty) return;
    _controller.text = query;
    final version = ++_version;
    setState(() { _loading = true; _error = null; });
    try {
      final language = Localizations.localeOf(context).languageCode;
      final result = await AppStore.instance.api.searchWikidata(query, language: language);
      if (!mounted || version != _version) return;
      setState(() { _items = result; });
    } catch (error) {
      if (!mounted || version != _version) return;
      setState(() { _error = error.toString(); });
    } finally {
      if (mounted && version == _version) setState(() { _loading = false; });
    }
  }

  @override Widget build(BuildContext context) {
    final company = widget.kind == DirectoryKind.companies;
    final samples = company ? ['Microsoft','Toyota','Samsung','OpenAI','Tata Group'] : ['Marie Curie','Rabindranath Tagore','Ada Lovelace','Lionel Messi','Hayao Miyazaki'];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SizedBox(height: 8),
      Text(tr(context, company ? 'Search real companies' : 'Search notable people'), style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
      const SizedBox(height: 10),
      Row(children: [
        Expanded(child: TextField(controller: _controller, textInputAction: TextInputAction.search, onSubmitted: (_) => _search(), decoration: InputDecoration(prefixIcon: const Icon(Icons.search_rounded), hintText: tr(context, company ? 'Search for a company…' : 'Search for a person…')))),
        const SizedBox(width: 8),
        FilledButton(onPressed: _loading ? null : () => _search(), child: Text(tr(context, 'Search'))),
      ]),
      const SizedBox(height: 8),
      Text(tr(context, 'Popular searches'), style: Theme.of(context).textTheme.labelLarge),
      const SizedBox(height: 6),
      Wrap(spacing: 6, runSpacing: 6, children: samples.map((name) => ActionChip(label: Text(name), onPressed: _loading ? null : () => _search(name))).toList()),
      const SizedBox(height: 8),
      if (_loading) const Expanded(child: LoadingPanel(label: 'Loading public data…'))
      else if (_error != null) Expanded(child: ErrorPanel(message: _error!, onRetry: _search))
      else if (_items.isNotEmpty) Expanded(child: ListView.separated(
        itemCount: _items.length, separatorBuilder: (_, _) => const SizedBox(height: 7),
        itemBuilder: (context, index) {
          final item = _items[index];
          return Card(child: ListTile(
            leading: CircleAvatar(child: Icon(company ? Icons.business_rounded : Icons.person_rounded)),
            title: Text(item.label, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800)),
            subtitle: Text(item.description.isEmpty ? tr(context, 'Description unavailable') : item.description, maxLines: 3, overflow: TextOverflow.ellipsis),
            trailing: const Icon(Icons.open_in_new_rounded, size: 18),
            onTap: () => launchUrl(Uri.parse(item.url), mode: LaunchMode.externalApplication),
          ));
        },
      ))
      else Expanded(child: Center(child: Text(tr(context, 'Enter a search and press Search'), textAlign: TextAlign.center))),
      const SizedBox(height: 6),
      Text('Wikidata · public knowledge graph', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
    ]);
  }
}

class _PlacesTab extends StatefulWidget {
  const _PlacesTab();
  @override State<_PlacesTab> createState() => _PlacesTabState();
}
class _PlacesTabState extends State<_PlacesTab> {
  final _controller = TextEditingController();
  List<TravelDestination> _items = const [];
  bool _loading = false;
  String? _error;
  int _version = 0;
  @override void dispose() { _controller.dispose(); super.dispose(); }
  Future<void> _search([String? forced]) async {
    final query = (forced ?? _controller.text).trim();
    if (query.isEmpty) return;
    _controller.text = query;
    final version = ++_version;
    setState(() { _loading = true; _error = null; });
    try {
      final language = Localizations.localeOf(context).languageCode;
      final result = await AppStore.instance.api.searchWikipediaPlaces(query, language: language);
      if (!mounted || version != _version) return;
      setState(() { _items = result; });
    } catch (error) {
      if (!mounted || version != _version) return;
      setState(() { _error = error.toString(); });
    } finally {
      if (mounted && version == _version) setState(() { _loading = false; });
    }
  }
  @override Widget build(BuildContext context) {
    final samples = ['Taj Mahal','Kyoto','Eiffel Tower','Grand Canyon','Sydney Opera House'];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SizedBox(height: 8),
      Text(tr(context, 'Search locations and landmarks…'), style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
      const SizedBox(height: 10),
      Row(children: [
        Expanded(child: TextField(controller: _controller, textInputAction: TextInputAction.search, onSubmitted: (_) => _search(), decoration: InputDecoration(prefixIcon: const Icon(Icons.place_outlined), hintText: tr(context, 'Search locations and landmarks…')))),
        const SizedBox(width: 8),
        FilledButton(onPressed: _loading ? null : () => _search(), child: Text(tr(context, 'Search'))),
      ]),
      const SizedBox(height: 8),
      Wrap(spacing: 6, runSpacing: 6, children: samples.map((name) => ActionChip(label: Text(name), onPressed: _loading ? null : () => _search(name))).toList()),
      const SizedBox(height: 8),
      if (_loading) const Expanded(child: LoadingPanel())
      else if (_error != null) Expanded(child: ErrorPanel(message: _error!, onRetry: _search))
      else if (_items.isEmpty) Expanded(child: Center(child: Text(tr(context, 'Enter a search and press Search'), textAlign: TextAlign.center)))
      else Expanded(child: ListView.separated(
        itemCount: _items.length, separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final item = _items[index];
          return Card(child: ListTile(
            leading: item.imageUrl.isEmpty ? const CircleAvatar(child: Icon(Icons.landscape_rounded)) : ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(item.imageUrl, width: 52, height: 52, fit: BoxFit.cover, errorBuilder: (_, _, _) => const Icon(Icons.landscape_rounded))),
            title: Text(item.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800)),
            subtitle: Text(item.summary, maxLines: 3, overflow: TextOverflow.ellipsis),
            trailing: const Icon(Icons.open_in_new_rounded, size: 18),
            onTap: () => launchUrl(Uri.parse(item.pageUrl), mode: LaunchMode.externalApplication),
          ));
        },
      )),
      const SizedBox(height: 6),
      Text('Wikipedia · Wikimedia Foundation', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
    ]);
  }
}

class _EconomyTab extends StatefulWidget {
  const _EconomyTab();
  @override State<_EconomyTab> createState() => _EconomyTabState();
}
class _EconomyTabState extends State<_EconomyTab> {
  Country? _selected;
  List<WorldBankIndicator> _items = const [];
  bool _loading = false;
  String? _error;
  @override void initState() { super.initState(); AppStore.instance.loadCountries(); }
  Future<void> _load() async {
    final country = _selected;
    if (country == null) return;
    setState(() { _loading = true; _error = null; });
    try {
      final result = await AppStore.instance.api.fetchWorldBankIndicators(country.code);
      if (!mounted || country.code != _selected?.code) return;
      setState(() { _items = result; });
    } catch (error) {
      if (mounted && country.code == _selected?.code) setState(() { _error = error.toString(); });
    } finally {
      if (mounted && country.code == _selected?.code) setState(() { _loading = false; });
    }
  }
  String _label(BuildContext context, String code) => switch (code) {
    'SP.POP.TOTL' => tr(context, 'Population'),
    'NY.GDP.MKTP.CD' => tr(context, 'GDP'),
    'NY.GDP.PCAP.CD' => tr(context, 'GDP per capita'),
    'IT.NET.USER.ZS' => tr(context, 'Internet users'),
    'SP.DYN.LE00.IN' => tr(context, 'Life expectancy'),
    _ => code,
  };
  String _value(WorldBankIndicator item) {
    if (item.code == 'IT.NET.USER.ZS') return '${item.value.toStringAsFixed(1)}%';
    if (item.code == 'SP.DYN.LE00.IN') return '${item.value.toStringAsFixed(1)} years';
    if (item.code == 'NY.GDP.PCAP.CD' || item.code == 'NY.GDP.MKTP.CD') return '$${formatCompactNumber(item.value)}';
    return formatCompactNumber(item.value);
  }
  @override Widget build(BuildContext context) {
    final store = AppStore.instance;
    if (store.countries.isEmpty) return const LoadingPanel();
    final selected = _selected ?? store.countries.firstWhere((c) => c.code == 'US', orElse: () => store.countries.first);
    if (_selected == null) WidgetsBinding.instance.addPostFrameCallback((_) { if (mounted && _selected == null) { setState(() => _selected = selected); _load(); } });
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SizedBox(height: 8),
      Text(tr(context, 'Economic indicators'), style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
      const SizedBox(height: 10),
      DropdownButtonFormField<Country>(
        value: selected, isExpanded: true,
        decoration: InputDecoration(labelText: tr(context, 'Select a country')),
        items: store.countries.map((country) => DropdownMenuItem(value: country, child: Text(country.flagEmoji + ' ' + country.localizedName(Localizations.localeOf(context).languageCode)))).toList(),
        onChanged: (country) { if (country != null) { setState(() { _selected = country; }); _load(); } },
      ),
      const SizedBox(height: 12),
      if (_loading) const Expanded(child: LoadingPanel())
      else if (_error != null) Expanded(child: ErrorPanel(message: _error!, onRetry: _load))
      else if (_items.isEmpty) Expanded(child: Center(child: Text(tr(context, 'No data available'))))
      else Expanded(child: ListView.separated(itemCount: _items.length, separatorBuilder: (_, _) => const SizedBox(height: 8), itemBuilder: (context, index) {
        final item = _items[index];
        return Card(child: ListTile(
          leading: CircleAvatar(child: Icon(item.code == 'SP.POP.TOTL' ? Icons.groups_rounded : Icons.query_stats_rounded)),
          title: Text(_label(context, item.code), style: const TextStyle(fontWeight: FontWeight.w800)),
          subtitle: Text('${tr(context, 'Reporting year')}: ${item.year} · World Bank'),
          trailing: Text(_value(item), style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900)),
        ));
      })),
      const SizedBox(height: 6),
      Text('Source: World Bank · World Development Indicators', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
    ]);
  }
}
