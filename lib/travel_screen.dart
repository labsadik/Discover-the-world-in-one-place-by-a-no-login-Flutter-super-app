import 'dart:async';

import 'package:flutter/material.dart';
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
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      setState(() {
        _query = value.trim().isEmpty ? 'popular destinations' : value.trim();
        _future = AppStore.instance.api.searchDestinations(_query);
      });
    });
  }

  void _retry() {
    setState(() => _future = AppStore.instance.api.searchDestinations(_query));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Travel guide')),
      body: ResponsivePage(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeading(
              title: 'Find your next destination',
              subtitle: 'Real travel articles from English Wikivoyage',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              onChanged: _search,
              textInputAction: TextInputAction.search,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search_rounded),
                hintText: 'Search a city, country or landmark…',
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Discover city guides, regional highlights and practical travel notes. Open the source article for full information and licensing details.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: FutureBuilder<List<TravelDestination>>(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const LoadingPanel(label: 'Searching Wikivoyage…');
                  }
                  if (snapshot.hasError) {
                    return ErrorPanel(message: snapshot.error.toString(), onRetry: _retry);
                  }
                  final destinations = snapshot.data ?? const <TravelDestination>[];
                  if (destinations.isEmpty) {
                    return const EmptyPanel(
                      icon: Icons.travel_explore_rounded,
                      title: 'No destination guides found',
                      message: 'Try another city, country or landmark name.',
                    );
                  }
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      if (constraints.maxWidth < 560) {
                        return ListView.separated(
                          itemCount: destinations.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 10),
                          itemBuilder: (context, index) => _DestinationListCard(
                            destination: destinations[index],
                            onTap: () => _showDetails(context, destinations[index]),
                          ),
                        );
                      }
                      final columns = constraints.maxWidth > 1050 ? 3 : 2;
                      return GridView.builder(
                        itemCount: destinations.length,
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
                    },
                  );
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
