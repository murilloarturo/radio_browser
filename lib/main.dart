import 'package:flutter/material.dart';
import 'package:just_audio_background/just_audio_background.dart';

import 'src/app/app.dart';
import 'src/app/debug/radio_browser_api_smoke.dart';
import 'src/app/di/service_locator.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await JustAudioBackground.init(
    androidNotificationChannelId:
        'com.murilloarturo.radio_browser.channel.audio',
    androidNotificationChannelName: 'Radio playback',
    androidNotificationOngoing: true,
  );
  await configureDependencies();
  runRadioBrowserApiSmokeIfEnabled();
  runApp(const RadioBrowserApp());
}
