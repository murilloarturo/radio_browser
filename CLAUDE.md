# CLAUDE.md

## Project Ground Rules

RadioBrowser is a Flutter take-home project for Android and iOS. Work in small, interview-friendly phases and do not implement future phases early.

Before each phase, state the goal, the files expected to change, and the commit message. After each phase, run formatting, analysis, and tests where appropriate, then summarize what changed.

Do not build final screens until wireframes are provided. Placeholder UI is allowed only when needed for compilation.

## Architecture

Use a production-ready, feature-first structure without over-engineering:

```text
lib/
  main.dart
  src/
    app/
      app.dart
      di/
      theme/
    core/
      config/
      error/
      network/
      widgets/
    features/
      discover/
        data/
        domain/
        presentation/
      player/
        data/
        domain/
        presentation/
      favorites/
        data/
        domain/
        presentation/
      ai_finder/
        data/
        domain/
        presentation/
```

Feature boundaries:

- `data`: DTOs/models, remote/local data sources, repository implementations
- `domain`: entities, repository interfaces, and use cases when they add clarity
- `presentation`: BLoCs/Cubits, pages, and widgets for the feature

Shared code belongs in `core` only when it is genuinely reusable across features. App-level composition, dependency wiring, theme, and future navigation belong in `app`.

## Stack Decisions

- Use `flutter_bloc` and `equatable` for state management.
- Use `dio` for HTTP access to the Radio Browser API.
- Hide playback details behind a service abstraction backed by `just_audio` and `audio_session`.
- Use Hive through a small abstraction for favorites persistence.
- Use OpenAI only behind the `ai_finder` feature boundary. AI may rank or explain real Radio Browser stations, but it must not invent stations.
- Add `go_router` only if navigation complexity justifies it.
- Use `bloc_test` and `mocktail` for focused tests.

## Secrets

Never commit API keys or local secrets. OpenAI configuration must read from `--dart-define`, not from committed files.

## Testing Expectations

Prefer focused tests that explain the boundary being protected:

- model parsing and mapper tests for API data
- repository tests around error handling
- BLoC/Cubit tests for loading, success, empty, and failure states
- widget tests only where they add meaningful confidence

Keep generated sample code out of the project. Each phase should leave the app compiling and explainable.
