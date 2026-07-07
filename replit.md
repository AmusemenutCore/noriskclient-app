# NoRisk Client Mobile App

Flutter mobile app (v2.0.7) for the NoRisk Client Minecraft community — featuring McReal (social feed), private chat, news, and player profiles.

## Stack
- **Language**: Dart / Flutter 3.x
- **State management**: `provider` (locale), global Maps + StreamController (auth/cache)
- **Key dependencies**: `mobile_scanner`, `shared_preferences`, `http`, `flutter_localizations`, `vibration`, `url_launcher`, `package_info_plus`, `fluttertoast`

## Running locally
```bash
flutter pub get
flutter gen-l10n     # generate translations
flutter run          # starts in debug mode on connected device / emulator
```

Targets: Android, iOS (primary). Also compiles for Linux, macOS, Windows, Web (web is secondary).

## Project layout
```
lib/
  config/           # Colors, Config constants
  l10n/             # Localisation (DE, EN)
  provider/         # LocaleProvider (ChangeNotifier)
  screens/          # Full-screen views (McReal, Chat, News, Profile, Settings, SignIn …)
  utils/            # BlockingManager, NoRiskApi, NoRiskIcon, …
  widgets/          # Shared reusable widgets (McRealPost, NoRiskButton, …)
  main.dart         # App entry point, global state (userData, cache, updateStream)
  NoRiskClient.dart # Root scaffold with bottom nav
```

## Architecture notes
- Auth token and UUID are stored in `SharedPreferences` (plain text).
- Global `userData` and `cache` Maps in `main.dart` are mutated across the app and coordinated via `updateStream` (a `StreamController<List>`).
- `BlockingManager` is a singleton with a per-user in-memory cache; call `BlockingManager().invalidate()` on sign-out (already wired in `main.dart`).

## User preferences
- Keep existing project structure and stack.
- No placeholder or half-finished code — production-quality only.
