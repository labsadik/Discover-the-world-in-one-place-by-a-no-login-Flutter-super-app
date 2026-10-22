import 'package:flutter/material.dart';

import 'app.dart';
import 'app_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppStore.instance.initialize();
  runApp(const AtlasFlowApp());
}
