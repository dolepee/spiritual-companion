# Audio and Font Setup Instructions

## 🎵 Adding Adhan Audio File

### Option 1: Download from IslamCan.com (Recommended)
1. Visit: https://www.islamcan.com/audio/adhan/index.shtml
2. Right-click on any "Azan" link (Azan 1-21)
3. Select "Save link as..." or "Save target as..."
4. Save the MP3 file as `assets/audio/adhan.mp3`

### Option 2: Download from IslamFactory.com
1. Visit: https://islamfactory.com/audio/adhan
2. Right-click on any Adhan link (Adhan 1-21)
3. Select "Save link as..." or "Save target as..."
4. Save the MP3 file as `assets/audio/adhan.mp3`

### Option 3: Use Your Own Adhan
1. Record or obtain your preferred Adhan audio
2. Convert to MP3 format if needed
3. Save as `assets/audio/adhan.mp3`

## 🔤 Adding Amiri Fonts for Better Arabic Display

### Download Amiri Font (Free, Open Source)
1. Visit: https://www.fonts4free.net/amiri-font.html
2. Click the download button for Amiri Regular
3. Extract the ZIP file if needed
4. Copy `Amiri-Regular.ttf` to `assets/fonts/Amiri-Regular.ttf`
5. (Optional) Download `Amiri-Bold.ttf` for bold text

### Alternative Font Sources
- GitHub: https://github.com/alif-type/amiri-font/releases
- Google Fonts Alternative: Use "Noto Sans Arabic" if Amiri unavailable

## 📱 Setting Up Fonts in Flutter

### 1. Download Font Files
```bash
# Create fonts directory if not exists
mkdir -p assets/fonts

# Download Amiri font (replace with actual download commands)
curl -o assets/fonts/Amiri-Regular.ttf [FONT_DOWNLOAD_URL]
curl -o assets/fonts/Amiri-Bold.ttf [BOLD_FONT_DOWNLOAD_URL]
```

### 2. Update pubspec.yaml
```yaml
flutter:
  fonts:
    - family: Amiri
      fonts:
        - asset: assets/fonts/Amiri-Regular.ttf
        - asset: assets/fonts/Amiri-Bold.ttf
          weight: 700
```

### 3. Run Flutter Commands
```bash
flutter pub get
flutter clean
flutter run
```

## 🚀 Quick Setup Script

### For Adhan Audio:
```bash
# Download adhan.mp3 (example command - replace with actual URL)
curl -o assets/audio/adhan.mp3 https://www.islamcan.com/downloads/adhan1.mp3
```

### For Amiri Fonts:
```bash
# Download Amiri fonts (example commands - replace with actual URLs)
curl -o assets/fonts/Amiri-Regular.ttf https://github.com/alif-type/amiri-font/releases/download/v0.112/Amiri-Regular.ttf
curl -o assets/fonts/Amiri-Bold.ttf https://github.com/alif-type/amiri-font/releases/download/v0.112/Amiri-Bold.ttf
```

## ✅ Verification

After adding files, verify your setup:

1. **Check Audio File:**
   ```bash
   ls -la assets/audio/adhan.mp3
   ```

2. **Check Font Files:**
   ```bash
   ls -la assets/fonts/
   ```

3. **Test in App:**
   - Run the app
   - Check if Arabic text displays properly
   - Test Adhan playback (when prayer time comes)

## 🎨 Font Customization

The app uses Amiri font in these components:
- Quran text display
- Adhkar text
- Arabic labels

If you prefer a different Arabic font:
1. Download the font TTF files
2. Add to `assets/fonts/`
3. Update pubspec.yaml font declarations
4. Replace 'Amiri' with your font family name in the code

## 📝 Important Notes

- **License**: Amiri font is licensed under SIL Open Font License (free for commercial use)
- **File Size**: Keep audio file under 5MB for better performance
- **Format**: Use MP3 format for audio, TTF format for fonts
- **Location**: Ensure all assets are in the correct directory structure

## 🆘 Troubleshooting

### Audio Not Playing:
- Check if `assets/audio/adhan.mp3` exists
- Verify file is valid MP3 format
- Ensure file size is reasonable (1-5MB)

### Arabic Text Not Displaying:
- Verify font files are in `assets/fonts/`
- Check pubspec.yaml font declarations
- Run `flutter pub get` after adding fonts

### Asset Not Found Errors:
- Run `flutter clean`
- Check directory structure matches pubspec.yaml
- Ensure assets are properly declared in pubspec.yaml