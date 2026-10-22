import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'app_store.dart';
import 'models.dart';
import 'widgets.dart';

class CurrencyScreen extends StatefulWidget {
  const CurrencyScreen({super.key});

  @override
  State<CurrencyScreen> createState() => _CurrencyScreenState();
}

class _CurrencyScreenState extends State<CurrencyScreen> {
  final _amountController = TextEditingController(text: '1');
  Map<String, String> _currencies = {};
  Map<String, double> _rates = {};
  String _base = 'USD';
  String _target = 'INR';
  String _date = '';
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadInitial();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _loadInitial() async {
    setState(() { _loading = true; _error = null; });
    try {
      final api = AppStore.instance.api;
      final currencies = await api.fetchCurrencies();
      final sorted = currencies.keys.toList()..sort();
      final base = sorted.contains(_base) ? _base : sorted.first;
      final target = sorted.contains(_target) ? _target : (sorted.length > 1 ? sorted[1] : base);
      final rates = await api.fetchRates(base);
      if (!mounted) return;
      setState(() { _currencies = currencies; _base = base; _target = target; _rates = rates.rates; _date = rates.date; });
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _changeBase(String? code) async {
    if (code == null || code == _base) return;
    setState(() { _base = code; _loading = true; _error = null; });
    try {
      final rates = await AppStore.instance.api.fetchRates(code);
      if (!mounted) return;
      setState(() { _rates = rates.rates; _date = rates.date; });
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final codes = _currencies.keys.toList()..sort();
    final amount = double.tryParse(_amountController.text.trim()) ?? 0;
    final rate = _base == _target ? 1.0 : _rates[_target];
    final converted = rate == null ? null : amount * rate;
    return Scaffold(
      appBar: AppBar(title: const Text('Currency converter')),
      body: ResponsivePage(child: ListView(children: [
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF087F8C), Color(0xFF27A99A)], begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(24),
          ),
          child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(Icons.currency_exchange_rounded, color: Colors.white, size: 42),
            SizedBox(height: 16),
            Text('Know what it converts to.', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 24)),
            SizedBox(height: 8),
            Text('Reference rates from Frankfurter. Rates are updated on working days and may not be intraday market prices.',
              style: TextStyle(color: Colors.white, height: 1.45)),
          ]),
        ),
        const SizedBox(height: 22),
        if (_loading && _currencies.isEmpty) const LoadingPanel(label: 'Loading currency data…'),
        if (_error != null) ErrorPanel(message: _error!, onRetry: _loadInitial),
        if (_currencies.isNotEmpty) ...[
          TextField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(labelText: 'Amount', prefixIcon: Icon(Icons.calculate_outlined)),
          ),
          const SizedBox(height: 14),
          LayoutBuilder(builder: (context, constraints) {
            final stacked = constraints.maxWidth < 480;
            final baseField = DropdownButtonFormField<String>(
              initialValue: _base,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'From'),
              items: codes.map((code) => DropdownMenuItem(value: code, child: Text(code + ' · ' + (_currencies[code] ?? code), overflow: TextOverflow.ellipsis))).toList(),
              onChanged: _loading ? null : _changeBase,
            );
            final targetField = DropdownButtonFormField<String>(
              initialValue: _target,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'To'),
              items: codes.map((code) => DropdownMenuItem(value: code, child: Text(code + ' · ' + (_currencies[code] ?? code), overflow: TextOverflow.ellipsis))).toList(),
              onChanged: (code) => setState(() => _target = code ?? _target),
            );
            if (stacked) {
              return Column(children: [
                baseField,
                const SizedBox(height: 12),
                IconButton.filledTonal(onPressed: () {
                  final oldBase = _base;
                  final oldTarget = _target;
                  setState(() => _target = oldBase);
                  _changeBase(oldTarget);
                }, icon: const Icon(Icons.swap_vert_rounded)),
                const SizedBox(height: 12),
                targetField,
              ]);
            }
            return Row(children: [
              Expanded(child: baseField),
              IconButton(
                onPressed: () {
                  final oldBase = _base;
                  final oldTarget = _target;
                  setState(() => _target = oldBase);
                  _changeBase(oldTarget);
                },
                icon: const Icon(Icons.swap_horiz_rounded),
                tooltip: 'Swap currencies',
              ),
              Expanded(child: targetField),
            ]);
          }),
          const SizedBox(height: 20),
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('CONVERTED AMOUNT', style: Theme.of(context).textTheme.labelMedium?.copyWith(letterSpacing: 1.1, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Text(converted == null ? 'Rate unavailable' : converted.toStringAsFixed(2) + ' ' + _target,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900, letterSpacing: -0.7)),
              const SizedBox(height: 8),
              Text(rate == null ? 'No reference rate was returned for this pair.' : '1 ' + _base + ' = ' + rate.toStringAsFixed(5) + ' ' + _target,
                  style: Theme.of(context).textTheme.bodyMedium),
              if (_date.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text('Rate date: ' + _date, style: Theme.of(context).textTheme.bodySmall),
              ],
            ]),
          ),
          const SizedBox(height: 12),
          Text('Source: Frankfurter (central-bank reference rates). The result is informational only, not a quote for a transaction.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
        ],
      ])),
    );
  }
}

class PhotosScreen extends StatefulWidget {
  const PhotosScreen({super.key});

  @override
  State<PhotosScreen> createState() => _PhotosScreenState();
}

class _PhotosScreenState extends State<PhotosScreen> {
  final _controller = TextEditingController(text: 'world landmarks');
  Timer? _debounce;
  Future<List<PhotoItem>>? _future;
  String _query = 'world landmarks';
  final List<PhotoItem> _morePhotos = [];
  bool _loadingMore = false;
  bool _hasMore = true;
  int _queryVersion = 0;

  @override
  void initState() {
    super.initState();
    _future = AppStore.instance.api.searchCommons(_query);
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
      final query = value.trim().isEmpty ? 'world landmarks' : value.trim();
      setState(() {
        _queryVersion++;
        _query = query;
        _morePhotos.clear();
        _loadingMore = false;
        _hasMore = true;
        _future = AppStore.instance.api.searchCommons(_query);
      });
    });
  }

  Future<void> _loadMore(List<PhotoItem> firstPage) async {
    if (_loadingMore || !_hasMore) return;
    final query = _query;
    final version = _queryVersion;
    final offset = firstPage.length + _morePhotos.length;
    setState(() => _loadingMore = true);
    try {
      final results = await AppStore.instance.api.searchCommons(query, offset: offset);
      if (!mounted || version != _queryVersion) return;
      final keys = <String>{...firstPage.map((photo) => photo.id), ..._morePhotos.map((photo) => photo.id)};
      final unique = results.where((photo) => keys.add(photo.id)).toList();
      setState(() {
        _morePhotos.addAll(unique);
        _hasMore = results.length >= 24 && unique.isNotEmpty;
      });
    } catch (error) {
      if (mounted && version == _queryVersion) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Could not load more images: $error'),
          behavior: SnackBarBehavior.floating,
        ));
      }
    } finally {
      if (mounted && version == _queryVersion) setState(() => _loadingMore = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = AppStore.instance;
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Visual discovery')),
      body: ResponsivePage(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SectionHeading(title: 'A world in pictures', subtitle: 'Explore public images with clear credits'),
          const SizedBox(height: 18),
          TextField(
            controller: _controller,
            onChanged: _search,
            textInputAction: TextInputAction.search,
            decoration: const InputDecoration(prefixIcon: Icon(Icons.search_rounded), hintText: 'Landmark, country or landscape…'),
          ),
          const SizedBox(height: 12),
          GlassSurface(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
            radius: 15,
            tint: scheme.secondaryContainer.withValues(alpha: 0.45),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Icon(Icons.info_outline_rounded, size: 18, color: scheme.primary),
              const SizedBox(width: 9),
              Expanded(child: Text('Every image can have a different licence. Open its source page before reusing it.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(height: 1.35, color: scheme.onSurface))),
            ]),
          ),
          const SizedBox(height: 14),
          Expanded(child: AnimatedBuilder(
            animation: store,
            builder: (context, _) => FutureBuilder<List<PhotoItem>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SkeletonGrid(itemCount: 8, bookCards: true);
                }
                if (snapshot.hasError) {
                  return ErrorPanel(message: snapshot.error.toString(), onRetry: () {
                    setState(() {
                      _morePhotos.clear();
                      _hasMore = true;
                      _future = store.api.searchCommons(_query);
                    });
                  });
                }
                final firstPage = snapshot.data ?? const <PhotoItem>[];
                final photos = <PhotoItem>[...firstPage, ..._morePhotos];
                if (photos.isEmpty) {
                  return const EmptyPanel(icon: Icons.photo_library_outlined, title: 'No images found', message: 'Try another place or topic.');
                }
                final canLoadMore = _hasMore && photos.length % 24 == 0;
                return Column(children: [
                  Expanded(child: LayoutBuilder(builder: (context, constraints) {
                    final columns = constraints.maxWidth > 1000 ? 4 : (constraints.maxWidth > 620 ? 3 : 2);
                    return GridView.builder(
                      itemCount: photos.length,
                      cacheExtent: 500,
                      addAutomaticKeepAlives: false,
                      addRepaintBoundaries: true,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columns,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.72,
                      ),
                      itemBuilder: (context, index) {
                        final photo = photos[index];
                        final saved = store.savedPhotos.containsKey(photo.id);
                        return Card(
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(
                            onTap: () => _showPhoto(context, photo),
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Expanded(child: Stack(fit: StackFit.expand, children: [
                                Image.network(
                                  photo.imageUrl,
                                  fit: BoxFit.cover,
                                  loadingBuilder: (context, child, progress) => progress == null ? child : const ImagePlaceholder(),
                                  errorBuilder: (_, _, _) => const ImagePlaceholder(),
                                ),
                                Positioned(right: 6, top: 6, child: Material(
                                  color: scheme.surface.withValues(alpha: 0.96),
                                  shape: const CircleBorder(),
                                  child: IconButton(
                                    visualDensity: VisualDensity.compact,
                                    tooltip: saved ? 'Remove saved image' : 'Save image',
                                    icon: Icon(saved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded, color: saved ? scheme.primary : scheme.onSurface),
                                    onPressed: () => store.togglePhotoSaved(photo),
                                  ),
                                )),
                              ])),
                              Padding(padding: const EdgeInsets.all(10), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text(photo.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800)),
                                const SizedBox(height: 5),
                                Text(photo.license, maxLines: 1, overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.labelSmall?.copyWith(color: scheme.onSurfaceVariant)),
                              ])),
                            ]),
                          ),
                        );
                      },
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
                              : const Icon(Icons.add_photo_alternate_outlined),
                          label: Text(_loadingMore ? 'Loading more images…' : 'Load more images'),
                        ),
                      ),
                    ),
                ]);
              },
            ),
          )),
        ]),
      ),
    );
  }

  void _showPhoto(BuildContext context, PhotoItem photo) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) {
        final store = AppStore.instance;
        return AnimatedBuilder(
          animation: store,
          builder: (context, _) => SafeArea(child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
            child: SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              ClipRRect(borderRadius: BorderRadius.circular(18), child: Image.network(photo.imageUrl, height: 230, width: double.infinity, fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const SizedBox(height: 150, child: ImagePlaceholder()))),
              const SizedBox(height: 14),
              Text(photo.title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              Text('Creator: ' + photo.artist),
              Text('Licence: ' + photo.license),
              if (photo.licenseUrl.isNotEmpty) SelectableText(photo.licenseUrl),
              const SizedBox(height: 16),
              Wrap(spacing: 10, runSpacing: 10, children: [
                FilledButton.icon(
                  onPressed: () => store.togglePhotoSaved(photo),
                  icon: Icon(store.savedPhotos.containsKey(photo.id) ? Icons.bookmark_remove : Icons.bookmark_add_outlined),
                  label: Text(store.savedPhotos.containsKey(photo.id) ? 'Remove saved image' : 'Save image'),
                ),
                if (photo.pageUrl.isNotEmpty) OutlinedButton.icon(
                  onPressed: () => launchUrl(Uri.parse(photo.pageUrl), mode: LaunchMode.externalApplication),
                  icon: const Icon(Icons.open_in_new_rounded), label: const Text('Source page'),
                ),
              ]),
            ])),
          )),
        );
      },
    );
  }
}

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});
  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizQuestion {
  const _QuizQuestion({required this.answer, required this.options});
  final Country answer;
  final List<Country> options;
}

class _QuizScreenState extends State<QuizScreen> {
  final _random = Random();
  List<_QuizQuestion> _questions = const [];
  int _index = 0;
  int _score = 0;
  String? _selectedCode;
  bool _loading = true;
  String? _error;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    _prepare();
  }

  Future<void> _prepare() async {
    setState(() { _loading = true; _error = null; _finished = false; _index = 0; _score = 0; _selectedCode = null; });
    final store = AppStore.instance;
    await store.loadCountries();
    final countries = List<Country>.from(store.countries)..shuffle(_random);
    if (!mounted) return;
    if (countries.length < 4) {
      setState(() { _loading = false; _error = store.countriesError ?? 'Not enough country data to build a quiz. Connect to the internet and retry.'; });
      return;
    }
    final questions = <_QuizQuestion>[];
    for (final answer in countries.take(10)) {
      final choices = countries.where((country) => country.code != answer.code).toList()..shuffle(_random);
      final options = <Country>[answer, ...choices.take(3)]..shuffle(_random);
      questions.add(_QuizQuestion(answer: answer, options: options));
    }
    setState(() { _questions = questions; _loading = false; });
  }

  void _answer(Country country) {
    if (_selectedCode != null) return;
    setState(() {
      _selectedCode = country.code;
      if (country.code == _questions[_index].answer.code) _score++;
    });
  }

  Future<void> _next() async {
    if (_index + 1 >= _questions.length) {
      setState(() => _finished = true);
      await AppStore.instance.updateBestQuizScore(_score);
      return;
    }
    setState(() { _index++; _selectedCode = null; });
  }

  @override
  Widget build(BuildContext context) {
    final store = AppStore.instance;
    return Scaffold(
      appBar: AppBar(title: const Text('Country quiz')),
      body: ResponsivePage(child: _loading
        ? const LoadingPanel(label: 'Building a quiz from country data…')
        : _error != null
            ? ErrorPanel(message: _error!, onRetry: _prepare)
            : _finished
                ? Center(child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: Card(child: Padding(
                      padding: const EdgeInsets.all(26),
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        const Icon(Icons.emoji_events_rounded, size: 58, color: Color(0xFFE3A72F)),
                        const SizedBox(height: 12),
                        const Text('Quiz complete!', style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900)),
                        const SizedBox(height: 8),
                        Text(_score.toString() + ' / ' + _questions.length.toString(), style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900)),
                        const SizedBox(height: 8),
                        Text('Best score on this device: ' + max(store.bestQuizScore, _score).toString()),
                        const SizedBox(height: 22),
                        FilledButton.icon(onPressed: _prepare, icon: const Icon(Icons.replay_rounded), label: const Text('Play again')),
                      ]),
                    )),
                  ))
                : _questions.isEmpty
                    ? const EmptyPanel(icon: Icons.quiz_outlined, title: 'Quiz not ready', message: 'Load real country data to play.')
                    : ListView(children: [
                        Row(children: [
                          Expanded(child: Text('FLAG CHALLENGE', style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w900, letterSpacing: 1.1))),
                          Text('Question ' + (_index + 1).toString() + ' of ' + _questions.length.toString(), style: Theme.of(context).textTheme.bodySmall),
                        ]),
                        const SizedBox(height: 10),
                        ClipRRect(borderRadius: BorderRadius.circular(12), child: LinearProgressIndicator(value: (_index + 1) / _questions.length, minHeight: 7)),
                        const SizedBox(height: 22),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(28),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [Color(0xFF3E51A4), Color(0xFF7C54C7)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                            borderRadius: BorderRadius.circular(26),
                          ),
                          child: Column(children: [
                            Text(_questions[_index].answer.flagEmoji, style: const TextStyle(fontSize: 86)),
                            const SizedBox(height: 14),
                            const Text('Which country uses this flag?', textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.w900)),
                          ]),
                        ),
                        const SizedBox(height: 18),
                        ..._questions[_index].options.map((option) {
                          final picked = _selectedCode == option.code;
                          final correct = option.code == _questions[_index].answer.code;
                          Color? background;
                          if (_selectedCode != null && correct) background = Colors.green.withValues(alpha: 0.13);
                          if (picked && !correct) background = Theme.of(context).colorScheme.errorContainer;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Material(
                              color: background ?? Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.circular(16),
                              child: InkWell(
                                onTap: _selectedCode == null ? () => _answer(option) : null,
                                borderRadius: BorderRadius.circular(16),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), border: Border.all(color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5))),
                                  child: Row(children: [
                                    Text(option.flagEmoji, style: const TextStyle(fontSize: 25)),
                                    const SizedBox(width: 12),
                                    Expanded(child: Text(option.name, style: const TextStyle(fontWeight: FontWeight.w700))),
                                    if (_selectedCode != null && correct) const Icon(Icons.check_circle, color: Colors.green),
                                    if (picked && !correct) Icon(Icons.cancel, color: Theme.of(context).colorScheme.error),
                                  ]),
                                ),
                              ),
                            ),
                          );
                        }),
                        if (_selectedCode != null) ...[
                          const SizedBox(height: 6),
                          Text(_selectedCode == _questions[_index].answer.code ? 'Correct — great work!' : 'Correct answer: ' + _questions[_index].answer.name,
                              style: TextStyle(fontWeight: FontWeight.w800, color: _selectedCode == _questions[_index].answer.code ? Colors.green : Theme.of(context).colorScheme.error)),
                          const SizedBox(height: 14),
                          FilledButton(
                            onPressed: _next,
                            child: Text(_index + 1 == _questions.length ? 'See results' : 'Next question'),
                          ),
                        ],
                      ]),
      ),
    );
  }
}
