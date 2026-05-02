# RadioBrowser Product Requirements Document

Last updated: 2026-05-02

## Overview

RadioBrowser is a Flutter mobile app for Android and iOS that lets users discover, play, and save internet radio stations. The app should feel production-ready while remaining small enough to explain clearly in a take-home interview.

This document is the source of truth for phased implementation until wireframes are provided. Wireframes will become the source of truth for visual layout and interaction details once shared.

## Product Goals

- Let users browse real internet radio stations from the Radio Browser API.
- Let users play a station quickly and control playback without losing discovery context.
- Let users favorite stations and access them later offline from local storage.
- Keep architecture clean, testable, and explainable.
- Add AI discovery only after the core radio experience works.

## Non-Goals

- Do not support desktop, web, smart TV, or watch platforms.
- Do not require user accounts or cloud sync.
- Do not implement recording, downloads, comments, reviews, or station submission.
- Do not build final UI before wireframes are provided.
- Do not commit API keys or local secrets.

## Target Platforms

- Android
- iOS

## Primary Users

- A casual listener who wants to quickly find and play stations by genre.
- A returning listener who wants fast access to favorite stations.
- An interview reviewer who wants to see clean architecture, sensible tradeoffs, and focused tests.

## Architecture Principles

- Use feature-first architecture under `lib/src/features`.
- Keep clear boundaries between `data`, `domain`, and `presentation`.
- Keep `domain` independent from Flutter, Dio, Hive, audio player packages, and UI concerns.
- Use repository interfaces in `domain` and implementations in `data`.
- Add use cases when they make business actions explicit and testable.
- Use BLoC/Cubit for presentation state.
- Keep dependency injection centralized under `lib/src/app/di`.
- Prefer small commits that map to one phase.

## Current Technical Stack

- Flutter and Dart
- `flutter_bloc` for BLoC/Cubit state management
- `equatable` for value equality
- `dio` for HTTP
- `just_audio` and `audio_session` for playback
- `hive` and `hive_flutter` for local favorites storage
- `bloc_test` and `mocktail` for tests

## External API Notes

Radio Browser is a free public API with JSON endpoints for stations, tags, countries, languages, and station click tracking.

Implementation should follow current Radio Browser guidance:

- Use the newer `api.radio-browser.info` server family, not the old `www.radio-browser.info` API.
- Resolve or fetch available mirrors instead of permanently hardcoding one server.
- Send a descriptive `User-Agent`, such as `RadioBrowser/1.0`.
- Use UUID fields such as `stationuuid`; do not rely on legacy numeric IDs.
- Prefer `countrycode` over the human-readable `country` field.
- Call `/json/url/{stationuuid}` when the user starts playback so the API can count station clicks and return the stream URL.

Reference endpoints planned for this app:

- `GET /json/servers`
- `GET /json/stations/search`
- `GET /json/tags`
- `GET /json/url/{stationuuid}`
- `GET /json/stations/byuuid?uuids={commaSeparatedUuids}`

Sources:

- [Radio Browser API reference](https://docs.radio-browser.info/)
- [Radio Browser API server guidance](https://api.radio-browser.info/)

## Data Model

### Station

The domain station entity should contain only app-relevant fields:

- `stationUuid`
- `name`
- `streamUrl`
- `resolvedStreamUrl`
- `faviconUrl`
- `countryCode`
- `language`
- `tags`
- `codec`
- `bitrate`
- `votes`
- `clickCount`
- `lastCheckOk`

`streamUrl` represents API metadata. `resolvedStreamUrl` represents the playable URL returned by click tracking when available.

### Genre

Genres should be represented by Radio Browser tags.

Fields:

- `name`
- `stationCount`

### Favorite Station

Favorites should be stored locally with enough information to render without a network call:

- `stationUuid`
- `name`
- `streamUrl`
- `resolvedStreamUrl`
- `faviconUrl`
- `countryCode`
- `language`
- `tags`
- `codec`
- `bitrate`
- `createdAt`

## Phase 1: API Network Layer And Business Logic

Commit message:

```text
feat: add radio browser data layer
```

### Goal

Build the non-UI foundation for connecting to Radio Browser: network client, data models, data source, repository contract/implementation, use cases, error handling, and dependency injection.

### Expected Files

- `lib/src/app/di/`
- `lib/src/core/config/`
- `lib/src/core/error/`
- `lib/src/core/network/`
- `lib/src/features/discover/data/`
- `lib/src/features/discover/domain/`
- `test/features/discover/`
- `test/core/`

### Requirements

- Create a `RadioBrowserApiClient` or equivalent wrapper around Dio.
- Configure base URL, headers, timeout, JSON parsing, and `User-Agent`.
- Add mirror/server discovery strategy with a safe fallback.
- Add typed API models for stations and tags.
- Map API DTOs into domain entities.
- Add a `StationRepository` domain interface.
- Add a `RadioBrowserStationRepository` data implementation.
- Add use cases:
  - `GetStations`
  - `SearchStations`
  - `GetGenres`
  - `ResolveStationStreamUrl`
  - `GetStationsByUuids`
- Add core failure/error types:
  - network failure
  - server failure
  - decoding failure
  - unavailable station failure
  - unknown failure
- Add dependency injection setup, but keep it lightweight.

### Acceptance Criteria

- Domain layer has no dependency on Flutter, Dio, or presentation code.
- Repository implementation converts Dio/API failures into app failures.
- Station parsing handles missing optional fields safely.
- Search supports name and genre/tag filters.
- Stream URL resolution calls the Radio Browser click endpoint before playback.
- No UI feature work is included in this phase.

### Tests

- DTO parsing tests for stations and tags.
- Mapper tests from DTO to domain entity.
- Repository tests for success and failure paths using mocks.
- Use case tests where they add clarity.

## Phase 2: Favorites Persistence With Hive

Commit message:

```text
feat: add favorites persistence layer
```

### Goal

Build the local favorites foundation using Hive without building the final favorites UI yet.

### Expected Files

- `lib/src/app/di/`
- `lib/src/core/error/`
- `lib/src/features/favorites/data/`
- `lib/src/features/favorites/domain/`
- `test/features/favorites/`

### Requirements

- Add Hive dependencies and initialization.
- Create a Hive favorite station model or adapter.
- Store favorites by `stationUuid`.
- Add a `FavoritesRepository` domain interface.
- Add a Hive-backed repository implementation.
- Add use cases:
  - `GetFavoriteStations`
  - `WatchFavoriteStations`
  - `AddFavoriteStation`
  - `RemoveFavoriteStation`
  - `ToggleFavoriteStation`
  - `IsFavoriteStation`
- Define duplicate handling. Adding the same station twice should be idempotent.
- Keep favorites available without network access.

### Acceptance Criteria

- Favorites can be added, removed, toggled, listed, and watched through domain APIs.
- Favorite identity is based on `stationUuid`.
- Hive is hidden behind data-layer abstractions.
- No final UI is included in this phase.

### Tests

- Hive model serialization tests if adapters are manually controlled.
- Repository tests using a temporary Hive box.
- Use case tests for add, remove, toggle, duplicate add, and missing remove.

## Phase 3: Station List Feature

Commit message:

```text
feat: build station discovery feature
```

### Goal

Build the first user-facing feature: browse stations, switch by genre tabs, and show a mini player only when playback is active. Wireframes should guide final layout.

### Expected Files

- `lib/src/features/discover/presentation/`
- `lib/src/features/player/presentation/`
- `lib/src/app/di/`
- `lib/src/app/navigation/` only if navigation becomes useful
- `test/features/discover/`

### Requirements

- Add Discover BLoC/Cubit for:
  - initial station loading
  - loading genres/tags
  - changing selected genre tab
  - refreshing stations
  - showing loading, empty, and error states
- List real stations from the repository.
- Represent genres as tabs based on Radio Browser tags.
- Keep the UI feature-based and wireframe-compatible.
- Add a mini player surface that is hidden when no station is playing.
- Mini player should show current station identity and playback state only after playback exists.
- Do not implement full-screen player view in this phase.

### Acceptance Criteria

- Users can see a station list backed by real API data.
- Users can switch between genre tabs and see stations update.
- Loading, empty, and error states exist.
- Mini player appears only while a station is active.
- Final visual design follows wireframes when available.

### Tests

- Discover BLoC/Cubit state tests.
- Widget tests for loading, empty, error, station list, and mini-player visibility.

## Phase 4: Full Player View

Commit message:

```text
feat: add full player experience
```

### Goal

Build the full-screen player opened from the mini player, including playback controls and favorite/unfavorite actions.

### Expected Files

- `lib/src/features/player/data/`
- `lib/src/features/player/domain/`
- `lib/src/features/player/presentation/`
- `lib/src/features/favorites/presentation/`
- `lib/src/app/di/`
- `test/features/player/`
- `test/features/favorites/`

### Requirements

- Add playback service abstraction around `just_audio` and `audio_session`.
- Add Player BLoC/Cubit for:
  - play station
  - pause
  - resume
  - stop
  - volume changes
  - playback errors
  - current station state
- Open full-screen player from the mini player.
- Show station name, artwork/favicon when available, metadata, playback state, volume, and controls.
- Allow favorite/unfavorite from the player.
- Keep audio package details out of presentation code.

### Acceptance Criteria

- Tapping a station starts playback.
- Mini player can open full-screen player.
- Full-screen player can pause, resume, stop, adjust volume, and favorite/unfavorite.
- Playback errors are visible and recoverable.
- Audio session is configured for mobile playback.

### Tests

- Player BLoC/Cubit tests using mocked playback service.
- Favorite interaction tests from player state.
- Widget tests for core full-player states.

## Phase 5: AI Discovery Features

Commit message:

```text
feat: add AI station recommendations
```

### Goal

Add optional AI-assisted discovery after the core radio app is working. AI should rank or select real Radio Browser stations, not invent stations.

### Expected Files

- `lib/src/features/ai_finder/data/`
- `lib/src/features/ai_finder/domain/`
- `lib/src/features/ai_finder/presentation/`
- `lib/src/core/config/`
- `lib/src/app/di/`
- `test/features/ai_finder/`
- `README.md`

### Requirements

- Add API key configuration through `--dart-define` only.
- Do not commit keys, `.env` files, or local secret files.
- Add an AI service abstraction so provider details stay in the data layer.
- Add use cases:
  - `GetRecommendedStationsForUser`
  - `SearchStationsWithAi`
- AI recommendations must operate on real station candidates returned by Radio Browser.
- AI search should translate user intent into station search/ranking criteria.
- Add a clear disabled state when no AI key is configured.
- Add README instructions for enabling AI locally.

### Acceptance Criteria

- Without an API key, the app still works and the AI feature is gracefully unavailable.
- With an API key, users can get station recommendations based on a mood/request.
- AI output references only real stations that can be opened in the app.
- AI failures do not break core discovery, playback, or favorites.

### Tests

- Config tests for missing/present API key behavior.
- AI repository tests with mocked HTTP/service responses.
- BLoC/Cubit tests for disabled, loading, success, empty, and failure states.

## Phase 6: System Player Surfaces

Commit message:

```text
feat: add system player surfaces
```

### Goal

Keep playback visible outside the app through native platform surfaces: Dynamic Island / Live Activities on supported iPhones, iOS lock screen / Control Center now-playing controls, and Android media-style notifications.

### Expected Files

- `lib/src/features/player/data/`
- `lib/src/features/player/domain/`
- `lib/src/features/player/presentation/`
- `ios/Runner/`
- `android/app/src/main/`
- `README.md`
- `test/features/player/`

### Requirements

- Add a single app-facing abstraction for publishing current playback metadata and actions to system surfaces.
- On iOS:
  - Publish now-playing metadata for lock screen and Control Center.
  - Add Dynamic Island / Live Activity support only where the OS and device support it.
  - Keep unsupported iOS devices working through regular now-playing controls.
- On Android:
  - Add a persistent media-style playback notification while a stream is active.
  - Expose play/pause controls through Android media session integration.
  - Make notification lifecycle match app playback state.
- Keep native/platform details out of Cubits and UI widgets.
- Do not show stale metadata after playback stops.

### Acceptance Criteria

- Starting a station publishes station name, artwork when available, and playback state to system surfaces.
- Pausing/resuming updates system controls without resetting app state unexpectedly.
- Stopping playback removes or deactivates the persistent system surface.
- Android users have an always-visible media notification during playback.
- iOS users have lock screen / Control Center controls, and Dynamic Island where supported.

### Tests

- Unit tests for the system player publisher abstraction.
- Player repository tests verifying publish/update/clear calls.
- Manual QA on iOS simulator/device and Android emulator/device because Dynamic Island and media notifications are platform-specific.

## Cross-Phase UX Requirements

- Prefer real data as soon as the relevant data layer exists.
- Do not show final visual treatments until wireframes are available.
- Keep screens responsive for common phone sizes.
- Avoid hiding errors; show clear retry paths.
- Preserve playback context while browsing.
- Make favorite state obvious wherever a station can be selected or played.
- Respect system light/dark mode without forcing a single theme.

## Cross-Phase Engineering Requirements

- Run `dart format .` after code changes.
- Run `flutter analyze` after code changes.
- Run `flutter test` when tests exist or behavior changes.
- Keep commits small and mapped to one phase.
- Update README when setup, dependencies, or runtime behavior changes.
- Keep secrets out of source control.
- Prefer explicit names over clever abstractions.

## Open Questions

- Which genre tabs should be shown by default if Radio Browser returns a very large tag list?
- Should the station list default to popular stations, top-voted stations, or a curated genre?
- Should favorites be available as a tab in the main station list or as a separate screen?
- Should the full player include station homepage/country/language details?
- What AI provider and model should be used in Phase 5?

## Success Metrics

- A reviewer can run the app from the README without extra setup.
- A reviewer can trace one feature from UI to BLoC/Cubit to use case to repository to data source.
- The app handles network failures and missing station fields gracefully.
- Favorites persist between app launches.
- Playback controls remain understandable and reliable.
- AI is optional and does not compromise the core app.
