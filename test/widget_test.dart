import 'package:atlasflow/localization.dart' as atlas;
import 'package:atlasflow/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shared text follows the selected app language', (tester) async {
    await tester.pumpWidget(const MaterialApp(locale: Locale('bn'), home: Scaffold(body: atlas.Text('Home'))));
    expect(find.text('হোম'), findsOneWidget);
  });

  testWidgets('skeleton grid builds while content is loading', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(height: 620, child: SkeletonGrid(itemCount: 6, bookCards: true)),
        ),
      ),
    );

    expect(find.byType(SkeletonGrid), findsOneWidget);
    expect(find.byType(GridView), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 180));
    await tester.binding.setSurfaceSize(null);
  });

  testWidgets('responsive page renders its content', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ResponsivePage(child: Text('AtlasFlow ready')),
        ),
      ),
    );

    expect(find.text('AtlasFlow ready'), findsOneWidget);
    await tester.binding.setSurfaceSize(null);
  });
}
