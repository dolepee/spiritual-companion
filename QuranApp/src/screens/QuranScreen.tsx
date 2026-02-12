import React, {useState} from 'react';
import {
  View,
  Text,
  FlatList,
  TouchableOpacity,
  StyleSheet,
  ScrollView,
  Dimensions,
} from 'react-native';
import {quranSurahs, getSurahText} from '../data/quranData';
import {Surah} from '../types';

const {width, height} = Dimensions.get('window');

const QuranScreen = () => {
  const [selectedSurah, setSelectedSurah] = useState<Surah | null>(null);

  const renderSurahItem = ({item}: {item: Surah}) => (
    <TouchableOpacity
      style={styles.surahItem}
      onPress={() => setSelectedSurah(item)}>
      <View style={styles.surahHeader}>
        <Text style={styles.surahNumber}>{item.number}</Text>
        <View style={styles.surahNames}>
          <Text style={styles.surahArabicName}>{item.name}</Text>
          <Text style={styles.surahEnglishName}>{item.englishName}</Text>
        </View>
        <View style={styles.surahMeta}>
          <Text style={styles.ayahCount}>{item.ayahs} verses</Text>
          <Text style={styles.revelationType}>{item.type}</Text>
        </View>
      </View>
    </TouchableOpacity>
  );

  if (selectedSurah) {
    return (
      <View style={styles.container}>
        <View style={styles.surahViewHeader}>
          <TouchableOpacity
            style={styles.backButton}
            onPress={() => setSelectedSurah(null)}>
            <Text style={styles.backButtonText}>← Back</Text>
          </TouchableOpacity>
          <Text style={styles.surahTitle}>{selectedSurah.name}</Text>
        </View>
        <ScrollView style={styles.surahContent}>
          <Text style={styles.surahText}>{getSurahText(selectedSurah.number)}</Text>
        </ScrollView>
      </View>
    );
  }

  return (
    <View style={styles.container}>
      <Text style={styles.headerTitle}>القرآن الكريم</Text>
      <Text style={styles.subtitle}>Holy Quran</Text>
      <FlatList
        data={quranSurahs}
        renderItem={renderSurahItem}
        keyExtractor={item => item.number.toString()}
        style={styles.surahList}
        showsVerticalScrollIndicator={false}
      />
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f8f9fa',
  },
  headerTitle: {
    fontSize: 28,
    fontWeight: 'bold',
    color: '#2e7d32',
    textAlign: 'center',
    marginTop: 20,
    fontFamily: 'Arial',
  },
  subtitle: {
    fontSize: 18,
    color: '#666',
    textAlign: 'center',
    marginBottom: 20,
  },
  surahList: {
    flex: 1,
    paddingHorizontal: 10,
  },
  surahItem: {
    backgroundColor: 'white',
    marginVertical: 5,
    marginHorizontal: 5,
    padding: 15,
    borderRadius: 10,
    elevation: 2,
    shadowColor: '#000',
    shadowOffset: {width: 0, height: 1},
    shadowOpacity: 0.2,
    shadowRadius: 2,
  },
  surahHeader: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
  },
  surahNumber: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#2e7d32',
    backgroundColor: '#e8f5e8',
    width: 35,
    height: 35,
    textAlign: 'center',
    borderRadius: 20,
    paddingTop: 5,
  },
  surahNames: {
    flex: 1,
    marginLeft: 15,
  },
  surahArabicName: {
    fontSize: 20,
    fontWeight: 'bold',
    color: '#333',
    textAlign: 'right',
    fontFamily: 'Arial',
  },
  surahEnglishName: {
    fontSize: 14,
    color: '#666',
    marginTop: 2,
  },
  surahMeta: {
    alignItems: 'flex-end',
  },
  ayahCount: {
    fontSize: 12,
    color: '#888',
  },
  revelationType: {
    fontSize: 12,
    color: '#2e7d32',
    fontWeight: 'bold',
    marginTop: 2,
  },
  surahViewHeader: {
    flexDirection: 'row',
    alignItems: 'center',
    padding: 15,
    backgroundColor: '#2e7d32',
  },
  backButton: {
    marginRight: 15,
  },
  backButtonText: {
    color: 'white',
    fontSize: 16,
    fontWeight: 'bold',
  },
  surahTitle: {
    fontSize: 20,
    fontWeight: 'bold',
    color: 'white',
    flex: 1,
    textAlign: 'center',
  },
  surahContent: {
    flex: 1,
    padding: 20,
  },
  surahText: {
    fontSize: 18,
    lineHeight: 35,
    color: '#333',
    textAlign: 'right',
    fontFamily: 'Arial',
    writingDirection: 'rtl',
  },
});

export default QuranScreen;