# Contact App

A Flutter contact management application with offline storage, favorites, and multi-platform support.

## Installation

```bash
git clone <repository-url>
cd contact-info
flutter pub get
flutter run
```

## Features

- Add, edit, delete contacts
- Mark favorites
- Custom avatars
- Local SQLite storage
- Android, iOS, Web, Windows, macOS, Linux support

## Project Structure

```
lib/
├── main.dart
├── controllers/
│   └── contact_controller.dart
├── database/
│   └── db_helper.dart
├── models/
│   └── contact_model.dart
├── routes/
│   └── app_router.dart
├── screens/
│   ├── splash_screen.dart
│   ├── home_screen.dart
│   ├── contacts_screen.dart
│   ├── contact_detail_screen.dart
│   ├── add_edit_contact_screen.dart
│   ├── favorites_screen.dart
│   └── contact_app_main.dart
├── utils/
│   ├── constants.dart
│   └── theme.dart
└── widgets/
    ├── contact_tile.dart
    ├── avatar_picker.dart
    └── empty_state.dart
```

## Build

```bash
# Android APK
flutter build apk --release

# iOS
flutter build ios --release

# Web
flutter build web --release

# Windows
flutter build windows --release

# macOS
flutter build macos --release

# Linux
flutter build linux --release
```

## Tech Stack

- Flutter / Dart
- SQLite Database
- Custom Routing
