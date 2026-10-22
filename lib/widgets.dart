import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

class ResponsivePage extends StatelessWidget {
  const ResponsivePage({
    super.key,
    required this.child,
    this.maxWidth = 1280,
    this.padding = const EdgeInsets.fromLTRB(20, 18, 20, 28),
  });

  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final horizontal = constraints.maxWidth < 420 ? 16.0 : (constraints.maxWidth > maxWidth ? 28.0 : 22.0);
        return Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Padding(
              padding: constraints.maxWidth > maxWidth
                  ? padding
                  : EdgeInsets.fromLTRB(horizontal, 18, horizontal, 28),
              child: child,
            ),
          ),
        );
      },
    );
  }
}

class GlassSurface extends StatelessWidget {
  const GlassSurface({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.radius = 22,
    this.tint,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Color? tint;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final base = tint ?? scheme.surface;
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.alphaBlend(Colors.white.withValues(alpha: scheme.brightness == Brightness.dark ? 0.08 : 0.82), base),
                base.withValues(alpha: scheme.brightness == Brightness.dark ? 0.93 : 0.97),
                scheme.primary.withValues(alpha: scheme.brightness == Brightness.dark ? 0.10 : 0.035),
              ],
            ),
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.75), width: 1),
            boxShadow: [
              BoxShadow(
                color: scheme.primary.withValues(alpha: scheme.brightness == Brightness.dark ? 0.10 : 0.065),
                blurRadius: 24,
                offset: const Offset(0, 9),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class SectionHeading extends StatelessWidget {
  const SectionHeading({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.45,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                    height: 1.35,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class LoadingPanel extends StatelessWidget {
  const LoadingPanel({super.key, this.label = 'Loading public data…'});
  final String label;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 44),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(width: 28, height: 28, child: CircularProgressIndicator(strokeWidth: 2.5)),
        const SizedBox(height: 14),
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
      ],
    ),
  );
}

class SkeletonGrid extends StatefulWidget {
  const SkeletonGrid({
    super.key,
    this.itemCount = 6,
    this.bookCards = false,
    this.shrinkWrap = false,
    this.columns,
  });

  final int itemCount;
  final bool bookCards;
  final bool shrinkWrap;
  final int? columns;

  @override
  State<SkeletonGrid> createState() => _SkeletonGridState();
}

class _SkeletonGridState extends State<SkeletonGrid> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1450),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final dark = scheme.brightness == Brightness.dark;
    final count = widget.columns ?? (MediaQuery.sizeOf(context).width > 1000 ? 4 : (MediaQuery.sizeOf(context).width > 620 ? 3 : 2));
    final extent = widget.bookCards ? 306.0 : 104.0;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => ShaderMask(
        blendMode: BlendMode.softLight,
        shaderCallback: (bounds) => LinearGradient(
          begin: Alignment(-1.5 + (_controller.value * 3), 0),
          end: Alignment(-0.5 + (_controller.value * 3), 0),
          colors: dark
              ? const [Color(0xFF252B40), Color(0xFF3B4260), Color(0xFF252B40)]
              : const [Color(0xFFE7E9F6), Color(0xFFFDFDFF), Color(0xFFE7E9F6)],
          stops: const [0.1, 0.5, 0.9],
        ).createShader(bounds),
        child: GridView.builder(
          shrinkWrap: widget.shrinkWrap,
          physics: widget.shrinkWrap ? const NeverScrollableScrollPhysics() : const ClampingScrollPhysics(),
          itemCount: widget.itemCount,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: count.clamp(1, 4).toInt(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            mainAxisExtent: extent,
          ),
          itemBuilder: (context, index) => _SkeletonCard(bookCards: widget.bookCards),
        ),
      ),
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard({required this.bookCards});
  final bool bookCards;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final base = scheme.onSurface.withValues(alpha: scheme.brightness == Brightness.dark ? 0.07 : 0.055);
    Widget bar(double width, double height, {double radius = 8}) => Container(
      width: width,
      height: height,
      decoration: BoxDecoration(color: base, borderRadius: BorderRadius.circular(radius)),
    );

    return Container(
      decoration: BoxDecoration(
        color: scheme.surface.withValues(alpha: 0.93),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.55)),
      ),
      padding: EdgeInsets.all(bookCards ? 10 : 12),
      child: bookCards
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(color: base, borderRadius: BorderRadius.circular(14)),
                )),
                const SizedBox(height: 12),
                bar(100, 12),
                const SizedBox(height: 8),
                bar(70, 9),
                const SizedBox(height: 8),
                bar(46, 9),
              ],
            )
          : Row(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(color: base, borderRadius: BorderRadius.circular(16)),
                ),
                const SizedBox(width: 12),
                Expanded(child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    bar(112, 12),
                    const SizedBox(height: 9),
                    bar(76, 9),
                    const SizedBox(height: 9),
                    bar(92, 8),
                  ],
                )),
              ],
            ),
    );
  }
}

class ErrorPanel extends StatelessWidget {
  const ErrorPanel({super.key, required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: scheme.errorContainer.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: scheme.error.withValues(alpha: 0.18)),
      ),
      child: Column(
        children: [
          Icon(Icons.cloud_off_rounded, size: 34, color: scheme.error),
          const SizedBox(height: 10),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Try again'),
          ),
        ],
      ),
    );
  }
}

class EmptyPanel extends StatelessWidget {
  const EmptyPanel({super.key, required this.icon, required this.title, required this.message});
  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 34),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.65)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 42, color: scheme.primary),
          const SizedBox(height: 12),
          Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text(message, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}

class ImagePlaceholder extends StatelessWidget {
  const ImagePlaceholder({super.key, this.icon = Icons.image_outlined});
  final IconData icon;

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: Theme.of(context).colorScheme.surfaceContainerHighest,
    child: Center(child: Icon(icon, size: 30, color: Theme.of(context).colorScheme.onSurfaceVariant)),
  );
}

String formatCompactNumber(num value) {
  if (value >= 1000000000) return '${(value / 1000000000).toStringAsFixed(1)}B';
  if (value >= 1000000) return '${(value / 1000000).toStringAsFixed(1)}M';
  if (value >= 1000) return '${(value / 1000).toStringAsFixed(1)}K';
  return value.toString();
}

String weatherDescription(int code) {
  if (code == 0) return 'Clear sky';
  if (code == 1) return 'Mainly clear';
  if (code == 2) return 'Partly cloudy';
  if (code == 3) return 'Overcast';
  if (code == 45 || code == 48) return 'Fog';
  if ([51, 53, 55, 56, 57].contains(code)) return 'Drizzle';
  if ([61, 63, 65, 66, 67, 80, 81, 82].contains(code)) return 'Rain';
  if ([71, 73, 75, 77, 85, 86].contains(code)) return 'Snow';
  if ([95, 96, 99].contains(code)) return 'Thunderstorm';
  return 'Variable conditions';
}

IconData weatherIcon(int code, {bool isDay = true}) {
  if (code == 0 || code == 1) return isDay ? Icons.wb_sunny_rounded : Icons.nights_stay_rounded;
  if (code == 2) return Icons.cloud_queue_rounded;
  if (code == 3 || code == 45 || code == 48) return Icons.cloud_rounded;
  if ([51, 53, 55, 56, 57, 61, 63, 65, 66, 67, 80, 81, 82].contains(code)) return Icons.grain_rounded;
  if ([71, 73, 75, 77, 85, 86].contains(code)) return Icons.ac_unit_rounded;
  if ([95, 96, 99].contains(code)) return Icons.thunderstorm_rounded;
  return Icons.cloud_outlined;
}

String timeLabel(String value) {
  if (value.length < 16) return value;
  return value.substring(11, 16);
}

String weekdayLabel(String value) {
  final date = DateTime.tryParse(value);
  if (date == null) return value;
  const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  return days[date.weekday - 1];
}
