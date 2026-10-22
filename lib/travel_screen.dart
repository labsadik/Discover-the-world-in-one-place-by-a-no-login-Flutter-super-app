import 'dart:async';

import 'package:flutter/material.dart' hide Text;
import 'localization.dart';
import 'package:url_launcher/url_launcher.dart';

import 'app_store.dart';
import 'models.dart';
import 'widgets.dart';

class TravelGuideScreen extends StatefulWidget {
  const TravelGuideScreen({super.key});

  @override
  State<TravelGuideScreen> createState() => _TravelGuideScreenState();
}

class _TravelGuideScreenState extends State<TravelGuideScreen> {
  final _controller = TextEditingController(text: 'popular destinations');
  Timer? _debounce;
  Future<List<TravelDestination>>? _future;
  String _query = 'popular destinations';
  final List<TravelDestination> _moreDestinations = [];
  bool _loadingMore = false;
  bool _hasMore = true;
  int _queryVersion = 0;

  @override
  void initState() {
    super.initState();
    _future = AppStore.instance.api.searchDestinations(_query);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _search(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 450), () {
      if (!mounted) return;
      final query = value.trim().isEmpty ? 'popular destinations' : value.trim();
      setState(() {
        _queryVersion++;
        _query = query;
        _moreDestinations.clear();
        _loadingMore = false;
        _hasMore = true;
        _future = AppStore.instance.api.searchDestinations(_query);
      });
    });
  }

  Future<void> _loadMore(List<TravelDestination> firstPage) async {
    if (_loadingMore || !_hasMore) return;
    final query = _query;
    final version = _queryVersion;
    final offset = firstPage.length + _moreDestinations.length;
    setState(() => _loadingMore = true);
    try {
      final results = await AppStore.instance.api.searchDestinations(query, offset: offset);
      if (!mounted || version != _queryVersion) return;
      final keys = <String>{...firstPage.map((item) => item.id), ..._moreDestinations.map((item) => item.id)};
      final unique = results.where((item) => keys.add(item.id)).toList();
      setState(() {
        _moreDestinations.addAll(unique);
        _hasMore = results.length >= 24 && unique.isNotEmpty;
      });
    } catch (error) {
      if (mounted && version == _queryVersion) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Could not load more destinations: $error'),
          behavior: SnackBarBehavior.floating,
        ));
      }
    } finally {
      if (mounted && version == _queryVersion) setState(() => _loadingMore = false);
    }
  }

  void _retry() {
    setState(() => _future = AppStore.instance.api.searchDestinations(_query));
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Travel guide')),
      body: ResponsivePage(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeading(title: 'Find your next destination', subtitle: 'Real travel articles, photos and practical notes'),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              onChanged: _search,
              textInputAction: TextInputAction.search,
              decoration: const InputDecoration(prefixIcon: Icon(Icons.search_rounded), hintText: tr(context, 'Search a city, country or landmark…')),
            ),
            const SizedBox(height: 10),
            GlassSurface(
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
              radius: 15,
              tint: scheme.primaryContainer.withValues(alpha: 0.4),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Icon(Icons.travel_explore_rounded, size: 19, color: scheme.primary),
                const SizedBox(width: 9),
                Expanded(child: Text(
                  'Destination summaries come from Wikivoyage. Open an article for the complete guide, transport information and updated travel notes.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(height: 1.35, color: scheme.onSurface),
                )),
              ]),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: FutureBuilder<List<TravelDestination>>(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SkeletonGrid(itemCount: 8, bookCards: true);
                  }
                  if (snapshot.hasError) {
                    return ErrorPanel(message: snapshot.error.toString(), onRetry: _retry);
                  }
                  final firstPage = snapshot.data ?? const <TravelDestination>[];
                  final destinations = <TravelDestination>[...firstPage, ..._moreDestinations];
                  if (destinations.isEmpty) {
                    return const EmptyPanel(
                      icon: Icons.travel_explore_rounded,
                      title: 'No destination guides found',
                      message: tr(context, 'Try another city, country or landmark name.'),
                    );
                  }
                  final canLoadMore = _hasMore && destinations.length % 24 == 0;
                  return Column(children: [
                    Expanded(child: LayoutBuilder(builder: (context, constraints) {
                      if (constraints.maxWidth < 560) {
                        return ListView.separated(
                          itemCount: destinations.length,
                          cacheExtent: 360,
                          addAutomaticKeepAlives: false,
                          separatorBuilder: (_, _) => const SizedBox(height: 10),
                          itemBuilder: (context, index) => _DestinationListCard(
                            destination: destinations[index],
                            onTap: () => _showDetails(context, destinations[index]),
                          ),
                        );
                      }
                      final columns = constraints.maxWidth > 1100 ? 3 : 2;
                      return GridView.builder(
                        itemCount: destinations.length,
                        cacheExtent: 480,
                        addAutomaticKeepAlives: false,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: columns,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                          mainAxisExtent: 355,
                        ),
                        itemBuilder: (context, index) => _DestinationGridCard(
                          destination: destinations[index],
                          onTap: () => _showDetails(context, destinations[index]),
                        ),
                      );
                    })),
                    if (canLoadMore || _loadingMore)
                      Padding(
                        padding: const EdgeInsets.only(top: 10, bottom: 4),
                        child: SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: _loadingMore ? null : () => _loadMore(firstPage),
                            icon: _loadingMore
                                ? const SizedBox(width: 17, height: 17, child: CircularProgressIndicator(strokeWidth: 2))
                                : const Icon(Icons.add_location_alt_outlined),
                            label: Text(_loadingMore ? 'Loading more places…' : 'Load more destinations'),
                          ),
                        ),
                      ),
                  ]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDetails(BuildContext context, TravelDestination destination) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) => _DestinationDetails(destination: destination),
    );
  }
}

class _DestinationListCard extends StatelessWidget {
  const _DestinationListCard({required this.destination, required this.onTap});

  final TravelDestination destination;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 144,
          child: Row(
            children: [
              SizedBox(
                width: 122,
                height: double.infinity,
                child: destination.imageUrl.isEmpty
                    ? const ImagePlaceholder(icon: Icons.map_outlined)
                    : Image.network(
                        destination.imageUrl,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, progress) => progress == null ? child : const ImagePlaceholder(),
                        errorBuilder: (_, _, _) => const ImagePlaceholder(icon: Icons.map_outlined),
                      ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(13),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(destination.title, maxLines: 2, overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w800)),
                      const SizedBox(height: 6),
                      Expanded(
                        child: Text(
                          destination.summary,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                                height: 1.35,
                              ),
                        ),
                      ),
                      const Align(
                        alignment: Alignment.centerRight,
                        child: Icon(Icons.arrow_forward_rounded, size: 17),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DestinationGridCard extends StatelessWidget {
  const _DestinationGridCard({required this.destination, required this.onTap});

  final TravelDestination destination;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 165,
              width: double.infinity,
              child: destination.imageUrl.isEmpty
                  ? const ImagePlaceholder(icon: Icons.map_outlined)
                  : Image.network(
                      destination.imageUrl,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, progress) => progress == null ? child : const ImagePlaceholder(),
                      errorBuilder: (_, _, _) => const ImagePlaceholder(icon: Icons.map_outlined),
                    ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(destination.title, maxLines: 2, overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 7),
                    Expanded(
                      child: Text(
                        destination.summary,
                        maxLines: 5,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                              height: 1.4,
                            ),
                      ),
                    ),
                    Row(
                      children: [
                        Icon(Icons.menu_book_rounded, size: 16, color: Theme.of(context).colorScheme.primary),
                        const SizedBox(width: 6),
                        Text('Read travel guide', style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w800)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DestinationDetails extends StatelessWidget {
  const _DestinationDetails({required this.destination});

  final TravelDestination destination;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (destination.imageUrl.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Image.network(
                    destination.imageUrl,
                    height: 230,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => const SizedBox(height: 100, child: ImagePlaceholder()),
                  ),
                ),
              const SizedBox(height: 16),
              Text(
                destination.title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 10),
              SelectableText(destination.summary, style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.55)),
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: destination.pageUrl.isEmpty
                    ? null
                    : () => launchUrl(Uri.parse(destination.pageUrl), mode: LaunchMode.externalApplication),
                icon: const Icon(Icons.open_in_new_rounded),
                label: const Text('Open full Wikivoyage article'),
              ),
              const SizedBox(height: 10),
              Text(
                'Travel information comes from Wikivoyage and may change. Visit the source article for full details, updates and attribution information.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
