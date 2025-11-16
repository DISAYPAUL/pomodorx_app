# PomodoRx

PomodoRx is a Flutter study companion for nursing students that keeps quizzes, reviewer notes, and progress completely offline using Hive. It includes a Tailwind-inspired design system, local reviewer generation, and optional text-to-speech playback.

## Features
- Local-first persistence with Hive boxes for topics, quizzes, results, and cached reviewers.
- Quick seeding from `assets/data/*.json` so the app is useful on first launch.
- Quiz play experience with navigation, scoring, and attempt history.
- Reviewer generator that summarizes quiz data and supports TTS playback.
- Backup and restore using JSON export/import plus shared preference-driven theme and TTS settings.

## Project Structure
```
lib/
	constants/        # Design tokens & global constants
	models/           # Hive-ready entities (Topic, Quiz, Question, Progress, ReviewerCache)
	providers/        # ChangeNotifier classes for settings, topics, quizzes, reviewers, auth
	services/         # Hive/bootstrap helpers, storage facade, import/export, TTS
	screens/          # Splash, home, topics, quiz flow, reviewer, results, settings
	widgets/          # Custom app bar, cards, option tiles, loaders, toast helper
assets/data/        # Seed JSON payloads imported on first run
```

## Getting Started
1. Ensure Flutter 3.10+ is installed and an Android device/emulator is available.
2. Fetch packages and generate platform code:
```powershell
flutter pub get
```
3. Run the app on a connected device:
```powershell
flutter run
```
The splash screen seeds Hive with the JSON files in `assets/data/` and then loads the dashboard.

## Testing
Run all unit and widget tests with:
```powershell
flutter test
```

## Seeding & Data Management
- Default quiz/topic content lives under `assets/data/*.json`. Update or add new files and list them in `AppConstants.seedFiles` to seed additional topics.
- Use the **Settings → Export JSON** action to copy a backup of all Hive boxes. Paste a JSON backup into **Import JSON** to restore.

## Build & Release
- Debug on a device: `flutter run`
- Build a release APK (after configuring your keystore and `key.properties`):
```powershell
flutter build apk --release
```
The signed APK will be emitted at `build/app/outputs/flutter-apk/`.

## Notes
- API keys or future secrets should be stored with `flutter_secure_storage` (see `AuthProvider`).
- When changing Hive schemas, bump adapter `typeId`s carefully and write migration helpers in `SeedService` or dedicated routines before shipping updates.
