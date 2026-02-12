# Spiritual Companion App - README

A comprehensive Muslim spiritual companion app built with Flutter, featuring prayer times, Quran reading, Islamic calendar, and more.

## Features

### 🕌 Prayer Times & Adhan
- Automatic location-based prayer time calculation
- Full Adhan audio playback at prayer times
- Local notifications for each prayer
- Qibla compass with accurate direction

### 📖 Quran Companion
- Complete Quran with Surah and Ayah browsing
- Reading progress tracking with Shared Preferences
- Post-prayer Quran reading prompts
- Beautiful Arabic text display

### 📅 Islamic Calendar
- Full Hijri calendar display
- Gregorian to Hijri date conversion
- Islamic events and reminders
- Monthly calendar view

### 📿 Adhkar & Tasbih
- Morning and evening Adhkar collection
- Digital Tasbih counter with vibration
- Customizable Dhikr and target counts
- Progress tracking

### 🎯 Special Features
- Friday reminders for Surah Al-Kahf
- Post-prayer Quran reading suggestions
- Material Design 3 with serene color palette
- Clean, modern, and user-friendly interface

## Technical Implementation

### Architecture
- **MVVM Pattern** with clean separation of concerns
- **Service Layer** for business logic
- **Widget Layer** for reusable UI components
- **Screen Layer** for main app screens

### Key Dependencies
- `adhan` - Prayer time calculations
- `geolocator` - Location services
- `flutter_compass` - Qibla direction
- `just_audio` - Adhan playback
- `flutter_local_notifications` - Prayer notifications
- `hijri` - Islamic calendar
- `shared_preferences` - Progress tracking

### Services
- **LocationService** - GPS and location management
- **PrayerService** - Prayer time calculations and notifications
- **QuranService** - Quran data and reading progress
- **NotificationService** - Local notifications
- **PostPrayerService** - Post-prayer Quran prompts

## Installation

1. Clone the repository
2. Run `flutter pub get` to install dependencies
3. Add assets to your project:
   - `assets/audio/adhan.mp3`
   - `assets/quran.json`
   - `assets/adhkar.txt`
4. Configure platform-specific permissions:
   - Android: Location, notifications, storage
   - iOS: Location, notifications

## Usage

1. **First Launch**: Grant location and notification permissions
2. **Home Screen**: View Hijri date, next prayer, and quick actions
3. **Prayer Screen**: See all prayer times and Qibla direction
4. **Quran Screen**: Read Quran with progress tracking
5. **Calendar Screen**: View Hijri calendar and Islamic events
6. **Adhkar Screen**: Read morning and evening remembrances
7. **Tasbih Screen**: Use digital counter for Dhikr

## File Structure

```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
│   ├── quran.dart
│   └── prayer_times.dart
├── services/                 # Business logic
│   ├── location_service.dart
│   ├── prayer_service.dart
│   ├── quran_service.dart
│   ├── notification_service.dart
│   ├── post_prayer_service.dart
│   └── vibration_service.dart
├── screens/                   # Main screens
│   ├── home_screen.dart
│   ├── prayer_screen.dart
│   ├── quran_screen.dart
│   ├── calendar_screen.dart
│   ├── adhkar_screen.dart
│   └── tasbih_screen.dart
└── widgets/                  # Reusable components
    ├── prayer_time_card.dart
    ├── qibla_compass.dart
    ├── prayer_times_list.dart
    ├── quran_page_viewer.dart
    ├── surah_list.dart
    └── hijri_calendar_widget.dart
```

## Contributing

This app is designed as a comprehensive spiritual companion for Muslims. Feel free to contribute features, report issues, or suggest improvements.

## License

This project is open source and available under the MIT License.