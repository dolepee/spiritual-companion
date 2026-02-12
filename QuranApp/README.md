# Quran App - Islamic Mobile Application

A React Native mobile application inspired by Quran Majeed, featuring Quran reading, Adhkar (remembrances), Hijri calendar, and Friday reminders.

## Features

### ✅ Implemented Features

1. **Quran Reading**
   - Display of Quranic surahs with Arabic text
   - Surah list with English names and verse counts
   - Clean, readable Arabic typography

2. **Adhkar (Remembrances)**
   - Morning and evening Adhkar collection
   - Interactive counter for each dhikr
   - Progress tracking with visual indicators
   - Reset functionality

3. **Hijri Calendar**
   - Full monthly Hijri calendar display
   - Gregorian date conversion
   - Current date highlighting
   - Month navigation
   - Date selection with detailed information

4. **Friday Reminders**
   - Weekly notification system for Friday mornings
   - Reminders for:
     - Performing Ghusul (ritual bathing)
     - Reading Surah Al-Kahf
     - Sending Salawat upon the Prophet (ﷺ)
   - Permission management
   - Test notification functionality

5. **Settings & Configuration**
   - Notification preferences
   - Permission management
   - App information

## Technical Stack

- **React Native** with TypeScript
- **React Navigation** for navigation
- **Hijri.js** for Islamic calendar functionality
- **React Native Push Notification** for reminders
- **Async Storage** for settings persistence
- **Vector Icons** for UI elements

## Installation

### Prerequisites

- Node.js (v14 or higher)
- React Native CLI
- Android Studio (for Android development)
- Xcode (for iOS development - macOS only)

### Setup Instructions

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd QuranApp
   ```

2. **Install dependencies**
   ```bash
   npm install
   ```

3. **iOS Setup (macOS only)**
   ```bash
   cd ios
   pod install
   cd ..
   ```

4. **Android Setup**
   - Open Android Studio
   - Create an AVD (Android Virtual Device)
   - Or connect a physical Android device

5. **Run the application**
   ```bash
   # For Android
   npm run android
   
   # For iOS (macOS only)
   npm run ios
   ```

## Project Structure

```
QuranApp/
├── src/
│   ├── components/     # Reusable UI components
│   ├── data/          # Static data (Quran, Adhkar)
│   ├── navigation/    # Navigation configuration
│   ├── screens/       # Main app screens
│   ├── types/         # TypeScript type definitions
│   ├── utils/         # Utility functions and services
│   └── App.tsx        # Main app component
├── android/           # Android-specific files
├── ios/              # iOS-specific files
└── package.json      # Dependencies and scripts
```

## Key Features Explained

### Quran Screen
- Displays a list of Quranic surahs
- Tap any surah to view its Arabic text
- Clean, right-to-left Arabic typography
- Surah metadata (verse count, revelation type)

### Adhkar Screen
- Toggle between morning and evening remembrances
- Interactive dhikr counter with progress tracking
- Visual completion indicators
- Reset progress functionality

### Calendar Screen
- Full Hijri calendar with Arabic month names
- Gregorian date display and conversion
- Navigate between months
- Select dates for detailed information
- "Go to Today" quick navigation

### Settings Screen
- Enable/disable Friday reminders
- Notification permission management
- Test notification functionality
- App information and version details

## Friday Reminders

The app includes a comprehensive Friday reminder system that sends notifications every Friday morning at 8 AM with reminders for:
- Performing Ghusul (ritual bathing)
- Reading Surah Al-Kahf (recommended Friday practice)
- Sending Salawat upon the Prophet Muhammad (ﷺ)
- General preparation for Jumu'ah (Friday) prayer

## Styling & Theme

The app uses Islamic-themed colors and styling:
- Primary green color (#2e7d32) representing Islamic tradition
- Clean, minimalist design
- Proper Arabic text rendering with right-to-left support
- Consistent spacing and typography

## Future Enhancements

### Planned Features
- Audio Quran recitation
- More Quranic surahs and translations
- Prayer times calculator
- Qibla compass
- Bookmark functionality
- Search functionality
- Dark mode theme
- More Adhkar collections

### Audio Recitation (Priority)
- Integration with Quran audio files
- Multiple reciters support
- Background playback
- Ayah-by-Ayah audio synchronization

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project is for educational purposes. Please ensure compliance with Islamic content usage guidelines and respect for religious materials.

## Support

For issues, questions, or suggestions:
- Create an issue in the repository
- Contact the development team

## Acknowledgments

- Inspired by Quran Majeed app by Pakdata
- Islamic content sources for authenticity
- React Native community for tools and libraries