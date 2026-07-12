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

## Onboarding / sign-in flow
- Login is QR-code only: the code comes from the NoRiskClient Launcher (a separate PC download, linked as plain text in the guide — no in-app download button), scanned with this app — there is no email/password path.
- First-run order: `LanguageSelect` (pick DE/EN before any other copy is shown) -> `QrGuide` (explains where to get the QR code, with "Scan Now" / "Maybe Later" — shown once). Gating flags (`languageChosen`, `onboardingSeen`) live in `main.dart` and persist via `SharedPreferences` (`language`, `onboardingSeen` keys), following the same global-flag pattern as `userData`.
- No token is ever required to browse News: after onboarding, a user without a token lands directly in guest mode (`NoRiskClient(isGuest: true)`), not on a forced sign-in screen. Tapping "Scan Now" is the only path that shows `SignIn`, and only for one rebuild (`showSignInNow`, an ephemeral non-persisted flag in `main.dart`); "Maybe Later" goes straight to guest mode.
- Guest mode's bottom nav shows only News + a "Login" entry (reusing the profile icon) that pushes `SignIn` on top of guest browsing — canceling out of it (back button or the "continue without an account" link) simply pops back, it never dead-ends. Chat/McReal/Profile all require a token and are hidden, not shown disabled.
- `SignIn` shows an inline error message on failed login (invalid/expired QR vs. network failure) instead of silently resetting, and has a permanent "How do I get a QR code?" link back into `QrGuide`. It also conditionally shows a "continue without an account" link (only when reached via onboarding's "Scan Now") and a manual back button (only when pushed on top of another screen, e.g. from guest mode's Login tab) — it has no `AppBar`, so both are custom-built.
- The bottom nav's Gamescom tab (time-limited event placeholder, event has passed) was removed rather than left disabled; tab indices shifted down by one (You is now index 3).

## User preferences
- Keep existing project structure and stack.
- No placeholder or half-finished code — production-quality only.
- App text must stay available in German and English; add new copy to both `lib/l10n/app_de.arb`/`app_en.arb` and the generated `app_localizations*.dart` files (no `flutter gen-l10n` available in this sandbox — edit generated files by hand, matching existing getter patterns).
