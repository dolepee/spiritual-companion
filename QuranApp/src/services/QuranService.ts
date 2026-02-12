// Complete Quran text service - This would normally connect to a Quran API
// For demo purposes, I'll include key surahs and structure for all 114

export interface QuranText {
  surah: number;
  ayah: number;
  text: string;
  juz: number;
  page: number;
}

// Sample complete Quran text structure (in real app, this would connect to Quran.com API)
export const getCompleteQuranText = (surahNumber: number): QuranText[] => {
  const quranData: {[key: number]: QuranText[]} = {
    1: [
      {surah: 1, ayah: 1, text: 'بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ', juz: 1, page: 1},
      {surah: 1, ayah: 2, text: 'الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ', juz: 1, page: 1},
      {surah: 1, ayah: 3, text: 'الرَّحْمَنِ الرَّحِيمِ', juz: 1, page: 1},
      {surah: 1, ayah: 4, text: 'مَالِكِ يَوْمِ الدِّينِ', juz: 1, page: 1},
      {surah: 1, ayah: 5, text: 'إِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ', juz: 1, page: 1},
      {surah: 1, ayah: 6, text: 'اهْدِنَا الصِّرَاطَ الْمُسْتَقِيمَ', juz: 1, page: 1},
      {surah: 1, ayah: 7, text: 'صِرَاطَ الَّذِينَ أَنْعَمْتَ عَلَيْهِمْ غَيْرِ الْمَغْضُوبِ عَلَيْهِمْ وَلَا الضَّالِّينَ', juz: 1, page: 1},
    ],
    // In a real implementation, all 114 surahs would be included
    // For brevity, showing structure - actual app would connect to Quran API
  };

  return quranData[surahNumber] || [];
};

// Translation service
export const getTranslation = (surah: number, ayah: number, language: string): string => {
  // This would connect to translation APIs
  const translations: {[key: string]: {[key: number]: {[key: number]: string}}} = {
    'en': {
      1: {
        1: 'In the name of Allah, the Entirely Merciful, the Especially Merciful.',
        2: 'All praise is due to Allah, Lord of the worlds',
        3: 'The Entirely Merciful, the Especially Merciful',
        4: 'Sovereign of the Day of Recompense',
        5: 'It is You we worship and You we ask for help',
        6: 'Guide us to the straight path',
        7: 'The path of those upon whom You have bestowed favor, not of those who have evoked [Your] anger or of those who are astray.',
      }
    },
    'ur': {
      1: {
        1: 'اللہ کے نام سے جو بہت مہربان رحیم ہے',
        2: 'تمام تعریفیں اللہ ہی کے لیے ہیں جو تمام جہانوں کا پالنے والا ہے',
        3: 'بہت مہربان رحیم ہے',
        4: 'جزا کے دن کا مالک',
        5: 'ہم تجھ ہی عبادت کرتے ہیں اور تجھ ہی سے مدد چاہتے ہیں',
        6: 'ہمیں سیدھی راہ دکھا',
        7: 'ان لوگوں کی راہ جن پر تو نے انعام فرمایا، نہ ان لوگوں کی راہ جن پر غضب ہوا اور نہ گمراہوں کی راہ',
      }
    }
  };

  return translations[language]?.[surah]?.[ayah] || 'Translation not available';
};

// Tafsir service
export const getTafsir = (surah: number, ayah: number, tafsirType: string): string => {
  // This would connect to Tafsir APIs
  const tafsirs: {[key: string]: {[key: number]: {[key: number]: string}}} = {
    'ibn-kathir': {
      1: {
        1: 'بسم الله الرحمن الرحيم: ابتداء القراءة باسم الله، والرحمن: من أسماء الله، والرحيم: من أسماء الله.',
        2: 'الحمد لله رب العالمين: الثناء على الله بصفاته التي كلها أوصاف كمال، ونعمائه التي كلها نعم عم.',
      }
    },
    'jalalayn': {
      1: {
        1: 'بسم الله الرحمن الرحيم: أبدأ باسم الله، والرحمن الرحيم: اسمان من أسماء الله.',
        2: 'الحمد لله رب العالمين: الشكر لله وحده مالك جميع الخلق.',
      }
    }
  };

  return tafsirs[tafsirType]?.[surah]?.[ayah] || 'Tafsir not available';
};

// Audio service
export const getAudioUrl = (surah: number, reciterId: number): string => {
  // This would construct URLs for audio files
  const reciters: {[key: number]: string} = {
    1: 'abdul-basit',
    2: 'mishari-rashid',
    3: 'saad-ghamdi',
    // ... more reciters
  };

  const baseUrl = 'https://audio.quran.com/arabic';
  const reciterName = reciters[reciterId] || 'abdul-basit';
  return `${baseUrl}/${reciterName}/${String(surah).padStart(3, '0')}.mp3`;
};

// Search service
export const searchQuran = (query: string): QuranText[] => {
  // This would search through Quran text
  // For demo, returning empty array
  return [];
};

// Juz and Hizb information
export const getJuzInfo = (juzNumber: number) => {
  const juzData = [
    { number: 1, startSurah: 1, startAyah: 1, endSurah: 2, endAyah: 141 },
    { number: 2, startSurah: 2, startAyah: 142, endSurah: 2, endAyah: 252 },
    // ... all 30 juz
  ];

  return juzData[juzNumber - 1] || null;
};

// Prayer times calculation service
export const getPrayerTimes = (latitude: number, longitude: number, date: Date) => {
  // This would implement prayer times calculation
  // For demo, returning sample data
  return {
    fajr: '05:30',
    sunrise: '06:45',
    dhuhr: '12:30',
    asr: '15:45',
    maghrib: '18:15',
    isha: '19:30',
  };
};

// Qibla direction calculation
export const getQiblaDirection = (latitude: number, longitude: number): number => {
  // Calculate Qibla direction from given coordinates
  const kaabaLat = 21.4225;
  const kaabaLng = 39.8262;
  
  const latDiff = (kaabaLat - latitude) * Math.PI / 180;
  const lngDiff = (kaabaLng - longitude) * Math.PI / 180;
  
  const y = Math.sin(lngDiff) * Math.cos(kaabaLat * Math.PI / 180);
  const x = Math.cos(latitude * Math.PI / 180) * Math.sin(kaabaLat * Math.PI / 180) -
           Math.sin(latitude * Math.PI / 180) * Math.cos(kaabaLat * Math.PI / 180) * Math.cos(lngDiff);
  
  const qibla = Math.atan2(y, x) * 180 / Math.PI;
  return (qibla + 360) % 360;
};