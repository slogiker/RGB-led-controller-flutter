# LED IR Controller App Blueprint

## Overview

This document outlines the plan for creating the "LED IR Controller" Flutter application. The app will allow users to control LED strip lights using their phone's IR blaster.

## Project Structure

The project will be organized as follows:

```
lib/
├── main.dart
├── ui/
│   ├── remote_screen.dart
│   ├── settings_screen.dart
├── services/
│   ├── ir_service.dart
│   ├── code_store.dart
└── assets/
    └── default_codes.json
```

## Core Features

-   Single LED strip control
-   Instant IR send on button tap
-   Modern remote UI with circular buttons
-   Full RGB color picker with preview
-   Dark / Light theme toggle
-   Settings screen: import new IR codes JSON
-   Local storage of IR codes
-   Offline only

## Plan

1.  **Create Project Structure:** Set up the directories and empty files as defined above.
2.  **Add Dependencies:** Add the required packages to `pubspec.yaml` (`path_provider`, `file_picker`, `flutter_colorpicker`, `shared_preferences`).
3.  **Implement `main.dart`:** Set up the main application widget, including theme management.
4.  **Create `default_codes.json`:** Populate the default IR codes.
5.  **Implement `code_store.dart`:** Write the logic for loading, merging, and saving IR codes.
6.  **Implement `ir_service.dart`:** Create the platform channel for IR transmission.
7.  **Implement `remote_screen.dart`:** Build the main remote control UI.
8.  **Implement `settings_screen.dart`:** Build the settings UI for theme toggling and code import.
9.  **Implement Android `MainActivity.kt`:** Write the native code for IR transmission.
