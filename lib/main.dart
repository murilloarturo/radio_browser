import 'package:flutter/material.dart';

import 'src/app/app.dart';
import 'src/app/debug/radio_browser_api_smoke.dart';
import 'src/app/di/service_locator.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  runRadioBrowserApiSmokeIfEnabled();
  runApp(const RadioBrowserApp());
}
