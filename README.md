## How to Run the App

1. **Install Flutter**: Make sure you have [Flutter](https://docs.flutter.dev/get-started/install) 3.x or later installed and set up on your system.
2. **Get Dependencies**:

   ```sh
   flutter pub get
   ```

3. **Run the App**:

   ```sh
   flutter run
   ```

   - You can also use your IDE (VS Code, Android Studio, etc.) to run/debug the app.

4. **Android Permissions**:

   - **Do Not Disturb (DND) Permission**: When you add your first schedule, you will be prompted to grant DND permission. This is required for the app to automatically silence your device at scheduled times.
   - **Exact Alarms Permission**: On Android 12+ devices, you may also be prompted to grant "exact alarms" permission. This allows the app to schedule silencing actions at precise times, even if your device is in Doze or battery-saving mode. Without this permission, scheduled silencing may be delayed or unreliable.

# Auto Silencer

Auto Silencer is a cross-platform Flutter app that helps you automatically silence your device based on custom schedules. It is designed for convenience, privacy, and global usability.

## Features

- **Schedule Device Silence**: Create schedules to automatically silence your device during meetings, classes, or any custom time range. The app supports multiple schedules, each with a title, start, and end time.

- **Automatic Notification Alerts**: Receive notifications before your device is set to go silent, so you are always aware of upcoming silent periods. (Pre-silence alerts)

- **Global Time Display**: View the current time in major cities around the world on a dedicated screen. This helps you coordinate schedules across time zones.

- **Timezone Awareness**: All schedules are stored in UTC and displayed in your current local time zone. If your device's timezone changes, the app automatically updates all schedule displays and notifications.

- **Multilingual UI**: The app supports English and French. You can switch languages at any time from the Home screen.

- **Local Data Storage**: All schedules are saved securely on your device using local JSON storage (shared_preferences). No data leaves your device.

- **Import/Export Schedules**: Easily back up or restore your schedules using the Settings screen. Export schedules to a JSON file or import from a JSON file in your app's documents directory.

- **User Control**: Manage your notification preferences and schedule list. You can add, edit, or delete schedules at any time.

- **Android Do Not Disturb Integration**: On Android, the app requests DND permission to automatically silence and restore your device's ringer mode at scheduled times.

- **Security & Privacy**: All data is stored locally. The app does not require internet access or send your data anywhere.

## How It Works

1. **Add a Schedule**: Tap the + button to create a new silence schedule. Set the start and end time, and give it a title.
2. **Automatic Silence**: At the scheduled time, your device will go silent (Android only, with DND permission). A notification is sent before (5 minutes) the silence period begins.
3. **View Schedules**: See upcoming and past schedules, grouped by day. Today's schedules are clearly marked.
4. **Global Time**: Tap the clock icon to view current times in major world cities.
5. **Import/Export**: Use the Settings screen to back up or restore your schedules as a JSON file.
6. **Language Switch**: Use the language icon to switch between English and French.

## Timezone Service

- The app detects your device's current IANA (Internet Assigned Numbers Authority) timezone using the flutter_timezone and timezone packages.
- All schedules are stored in UTC for consistency and converted to your local time for display and notifications.
- If your device's timezone changes (e.g., you travel to a new country or region), the app automatically re-initializes the timezone service and updates all schedule times and notifications accordingly.
- This ensures you never miss a scheduled silence or notification due to timezone changes.

You do not need to configure anything—timezone handling is automatic and seamless.

## Localization

Auto Silencer supports multiple languages (currently English and French) using Flutter's localization system.

- The app automatically detects your device's language on first launch.
- You can manually switch languages at any time from the Home screen by tapping the language icon (globe) in the app bar and selecting your preferred language.
- All UI text, schedule dialogs, and notifications are localized.

To add more languages, update the `lib/l10n/app_localizations.dart` file and provide translations for each key.

## Requirements

- Flutter 3.x or later
- Android: DND permission required for automatic silence
- iOS/macOS: Notification support only (no ringer control as Apple has not exposed API to control focus mode)

## Folder Structure

The project is organized for clarity and modularity:

- `lib/` - Main Dart source code
  - `main.dart` - App entry point
  - `models/` - Data models (e.g., Schedule)
  - `screens/` - UI screens (Home, Settings, Global Time, etc.)
  - `services/` - Business logic and platform services (notifications, timezone, shared preferences)
  - `widgets/` - Reusable UI components (dialogs, etc.)
  - `l10n/` - Localization files

This structure makes it easy to extend, maintain, and localize the app.

## Security

All data is stored locally on your device. No internet access is required or used.
