import 'package:atlasflow/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
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
