import {Surah} from '../types';

export const quranSurahs: Surah[] = [
  {number: 1, name: 'الفاتحة', englishName: 'Al-Fatihah', ayahs: 7, type: 'meccan'},
  {number: 2, name: 'البقرة', englishName: 'Al-Baqarah', ayahs: 286, type: 'medinan'},
  {number: 3, name: 'آل عمران', englishName: 'Aal-E-Imran', ayahs: 200, type: 'medinan'},
  {number: 4, name: 'النساء', englishName: 'An-Nisa', ayahs: 176, type: 'medinan'},
  {number: 5, name: 'المائدة', englishName: 'Al-Ma\'idah', ayahs: 120, type: 'medinan'},
  {number: 6, name: 'الأنعام', englishName: 'Al-An\'am', ayahs: 165, type: 'meccan'},
  {number: 7, name: 'الأعراف', englishName: 'Al-A\'raf', ayahs: 206, type: 'meccan'},
  {number: 8, name: 'الأنفال', englishName: 'Al-Anfal', ayahs: 75, type: 'medinan'},
  {number: 9, name: 'التوبة', englishName: 'At-Tawbah', ayahs: 129, type: 'medinan'},
  {number: 10, name: 'يونس', englishName: 'Yunus', ayahs: 109, type: 'meccan'},
];

export const getSurahText = (surahNumber: number): string => {
  const surahTexts: {[key: number]: string} = {
    1: 'بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ\n\n' +
       'الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ\n' +
       'الرَّحْمَنِ الرَّحِيمِ\n' +
       'مَالِكِ يَوْمِ الدِّينِ\n' +
       'إِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ\n' +
       'اهْدِنَا الصِّرَاطَ الْمُسْتَقِيمَ\n' +
       'صِرَاطَ الَّذِينَ أَنْعَمْتَ عَلَيْهِمْ غَيْرِ الْمَغْضُوبِ عَلَيْهِمْ وَلَا الضَّالِّينَ',
    
    2: 'بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ\n\n' +
       'الم\n' +
       'ذَلِكَ الْكِتَابُ لَا رَيْبَ فِيهِ هُدًى لِلْمُتَّقِينَ\n' +
       'الَّذِينَ يُؤْمِنُونَ بِالْغَيْبِ وَيُقِيمُونَ الصَّلَاةَ وَمِمَّا رَزَقْنَاهُمْ يُنْفِقُونَ\n' +
       'وَالَّذِينَ يُؤْمِنُونَ بِمَا أُنْزِلَ إِلَيْكَ وَمَا أُنْزِلَ مِنْ قَبْلِكَ وَبِالْآخِرَةِ هُمْ يُوقِنُونَ\n' +
       'أُولَئِكَ عَلَى هُدًى مِنْ رَبِّهِمْ وَأُولَئِكَ هُمُ الْمُفْلِحُونَ',
    
    3: 'بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ\n\n' +
       'الم\n' +
       'اللَّهُ لَا إِلَهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ\n' +
       'نَزَّلَ عَلَيْكَ الْكِتَابَ بِالْحَقِّ مُصَدِّقًا لِمَا بَيْنَ يَدَيْهِ وَأَنْزَلَ التَّوْرَاةَ وَالْإِنْجِيلَ\n' +
       'مِنْ قَبْلُ هُدًى لِلنَّاسِ وَأَنْزَلَ الْفُرْقَانَ إِنَّ الَّذِينَ كَفَرُوا بِآيَاتِ اللَّهِ لَهُمْ عَذَابٌ شَدِيدٌ وَاللَّهُ عَزِيزٌ ذُو انْتِقَامٍ',
  };
  
  return surahTexts[surahNumber] || 'Surah text not available yet.';
};