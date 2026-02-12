export interface Surah {
  number: number;
  name: string;
  englishName: string;
  ayahs: number;
  type: 'meccan' | 'medinan';
  revelationOrder?: number;
}

export interface Ayah {
  number: number;
  text: string;
  surah: number;
  juz: number;
  page: number;
  hizb?: number;
  sajda?: boolean;
}

export interface Adhkar {
  id: number;
  text: string;
  translation: string;
  type: 'morning' | 'evening' | 'general' | 'sleep' | 'food';
  count: number;
  category?: string;
}

export interface AudioReciter {
  id: number;
  name: string;
  arabicName: string;
  bitrate: string;
  style?: 'murattal' | 'mujawwad';
}

export interface Translation {
  surah: number;
  ayah: number;
  text: string;
  language: string;
  translator: string;
}

export interface Tafsir {
  surah: number;
  ayah: number;
  text: string;
  author: string;
  type: 'ibn-kathir' | 'jalalayn' | 'saadi' | 'tabari';
}

export interface Bookmark {
  id: string;
  surah: number;
  ayah: number;
  timestamp: Date;
  note?: string;
  type: 'ayah' | 'surah';
}

export interface PrayerTimes {
  fajr: string;
  sunrise: string;
  dhuhr: string;
  asr: string;
  maghrib: string;
  isha: string;
  date: string;
  location: string;
}

export interface Theme {
  id: string;
  name: string;
  primaryColor: string;
  backgroundColor: string;
  textColor: string;
  arabicFont: string;
  isDark: boolean;
}

export interface QuranPlaylist {
  id: string;
  name: string;
  surahs: number[];
  reciterId: number;
  createdAt: Date;
  isDefault?: boolean;
}

export interface MemorizationProgress {
  surah: number;
  ayahs: number[];
  masteredAyahs: number[];
  lastReviewed: Date;
  repetitionCount: number;
}

export interface QuranEngagement {
  date: string;
  pagesRead: number;
  timeSpent: number; // minutes
  surahsCompleted: string[];
  bookmarksAdded: number;
  notesAdded: number;
}

export interface ZakatRecord {
  id: string;
  type: 'gold' | 'silver' | 'cash' | 'property' | 'business';
  amount: number;
  value: number;
  nisab: number;
  zakatDue: number;
  date: Date;
  paid: boolean;
}

export interface AllahName {
  id: number;
  name: string;
  meaning: string;
  description: string;
  audioUrl?: string;
}

export interface IslamicEvent {
  id: string;
  name: string;
  hijriDate: string;
  type: 'eid' | 'ramadan' | 'hajj' | 'other';
  description: string;
}

export interface Masjid {
  id: string;
  name: string;
  address: string;
  latitude: number;
  longitude: number;
  distance?: number;
  prayerTimes?: PrayerTimes;
  facilities: string[];
}

export interface HifzRecording {
  id: string;
  surah: number;
  ayah: number;
  audioPath: string;
  timestamp: Date;
  quality: 'excellent' | 'good' | 'needs-improvement';
}