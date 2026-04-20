# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
# Run the app
flutter run

# Run tests
flutter test

# Run a single test file
flutter test test/widget_test.dart

# Analyze (lint)
flutter analyze

# Get dependencies
flutter pub get
```

## Architecture

This is a minimal Flutter app using `MaterialApp` with named routes.

- `lib/main.dart` — entry point; defines `MyApp` with route table (`/settings` → `SettingsPage`)
- `lib/pages/home_page.dart` — stateful counter widget; home route
- `lib/pages/settings_page.dart` — placeholder stateless settings screen

New pages go in `lib/pages/`. Register named routes in `main.dart`'s `routes` map.

## Notes

- `analysis_options.yaml` inherits `flutter_lints/flutter.yaml` with no overrides currently active.
- The existing widget test (`test/widget_test.dart`) uses `Icons.add` to find the increment button, but the actual button in `home_page.dart` uses `Icons.plus_one` — this test will fail as-is.
