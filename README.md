# RadioBrowser

RadioBrowser is a Flutter take-home project for browsing and listening to internet radio stations on Android and iOS.

## Status

Phase 1 is intentionally only the project foundation. Feature implementation starts in later phases after the architecture is in place and wireframes are available.

## Requirements

- Flutter stable with Dart 3.7 or newer
- Android Studio or Xcode for running on mobile simulators/devices
- No API keys are required for the current scaffold

## Getting Started

```sh
flutter pub get
flutter run
```

## Checks

```sh
dart format .
flutter analyze
flutter test
```

## Debugging Radio Browser API Calls

The app does not call the Radio Browser API during normal placeholder startup yet. To force a debug-only startup smoke request, run:

```sh
flutter run --dart-define=RADIO_BROWSER_API_SMOKE=true
```

In Android Studio, add this to the run configuration's **Additional run args**:

```sh
--dart-define=RADIO_BROWSER_API_SMOKE=true
```

Then filter Run output or Logcat for:

```text
RadioBrowserAPI
```

## Architecture

The project uses a feature-first structure under `lib/src`:

- `app`: application bootstrap, dependency injection, navigation when needed, and theme setup
- `core`: shared configuration, networking, error handling, and reusable widgets
- `features`: isolated product areas with `data`, `domain`, and `presentation` boundaries

State management will use BLoC/Cubit via `flutter_bloc` and `equatable`. Data access uses `dio`, playback will be isolated behind a `just_audio`/`audio_session` service, and local favorites use a small persistence abstraction over Hive.

API keys must not be committed. Any optional OpenAI work later should use `--dart-define`.
