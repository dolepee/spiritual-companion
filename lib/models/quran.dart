class Surah {
  final int number;
  final String name;
  final String englishName;
  final String englishNameTranslation;
  final int numberOfAyahs;
  final String revelationType;
  final List<Ayah> ayahs;

  Surah({
    required this.number,
    required this.name,
    required this.englishName,
    required this.englishNameTranslation,
    required this.numberOfAyahs,
    required this.revelationType,
    required this.ayahs,
  });

  factory Surah.fromJson(Map<String, dynamic> json) {
    final surahNum = json['number'] as int;
    final ayahsList = (json['ayahs'] as List<dynamic>)
        .map((ayah) => Ayah.fromJson(ayah, surahNumber: surahNum))
        .toList();

    return Surah(
      number: json['number'],
      name: json['name'],
      englishName: json['englishName'],
      englishNameTranslation: json['englishNameTranslation'],
      numberOfAyahs: json['numberOfAyahs'],
      revelationType: json['revelationType'],
      ayahs: ayahsList,
    );
  }
}

class Ayah {
  final int number;
  final String text;
  final int numberInSurah;
  final int juz;
  final int manzil;
  final int page;
  final int ruku;
  final int hizbQuarter;
  final String sajda;
  final int surahNumber;

  Ayah({
    required this.number,
    required this.text,
    required this.numberInSurah,
    required this.juz,
    required this.manzil,
    required this.page,
    required this.ruku,
    required this.hizbQuarter,
    required this.sajda,
    this.surahNumber = 0,
  });

  factory Ayah.fromJson(Map<String, dynamic> json, {int surahNumber = 0}) {
    return Ayah(
      number: json['number'],
      text: json['text'],
      numberInSurah: json['numberInSurah'],
      juz: json['juz'],
      manzil: json['manzil'],
      page: json['page'],
      ruku: json['ruku'],
      hizbQuarter: json['hizbQuarter'],
      sajda: json['sajda'] ?? '',
      surahNumber: surahNumber,
    );
  }
}

class QuranData {
  final List<Surah> surahs;

  QuranData({required this.surahs});

  factory QuranData.fromJson(Map<String, dynamic> json) {
    final surahsList = (json['surahs'] as List<dynamic>)
        .map((surah) => Surah.fromJson(surah))
        .toList();

    return QuranData(surahs: surahsList);
  }
}