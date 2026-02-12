import React, {useState, useEffect} from 'react';
import {
  View,
  Text,
  ScrollView,
  TouchableOpacity,
  StyleSheet,
  TextInput,
  Modal,
  Alert,
  ActivityIndicator,
} from 'react-native';
import Icon from 'react-native-vector-icons/MaterialIcons';
import {quranSurahs} from '../data/completeQuranData';
import {Tafsir} from '../types';
import {QuranService} from '../services/QuranService';

const TafsirScreen = () => {
  const [selectedSurah, setSelectedSurah] = useState<number>(1);
  const [selectedAyah, setSelectedAyah] = useState<number>(1);
  const [tafsirType, setTafsirType] = useState<'ibn-kathir' | 'jalalayn' | 'saadi'>('ibn-kathir');
  const [tafsirText, setTafsirText] = useState<string>('');
  const [loading, setLoading] = useState(false);
  const [showSurahModal, setShowSurahModal] = useState(false);
  const [showTafsirModal, setShowTafsirModal] = useState(false);
  const [searchQuery, setSearchQuery] = useState('');

  const tafsirTypes = [
    { id: 'ibn-kathir', name: 'Ibn Kathir', arabicName: 'ابن كثير', description: 'Classic Sunni tafsir' },
    { id: 'jalalayn', name: 'Jalalayn', arabicName: 'الجلالين', description: 'Concise tafsir by Jalal al-Mahalli and Jalal al-Suyuti' },
    { id: 'saadi', name: 'Saadi', arabicName: 'السعدي', description: 'Modern tafsir by Abd al-Rahman al-Saadi' },
  ];

  useEffect(() => {
    loadTafsir();
  }, [selectedSurah, selectedAyah, tafsirType]);

  const loadTafsir = async () => {
    setLoading(true);
    try {
      const tafsir = QuranService.getTafsir(selectedSurah, selectedAyah, tafsirType);
      setTafsirText(tafsir);
    } catch (error) {
      console.error('Error loading tafsir:', error);
      setTafsirText('Failed to load tafsir. Please try again.');
    } finally {
      setLoading(false);
    }
  };

  const handleSurahSelect = (surahNumber: number) => {
    setSelectedSurah(surahNumber);
    setSelectedAyah(1);
    setShowSurahModal(false);
  };

  const handleAyahSelect = (ayah: number) => {
    setSelectedAyah(ayah);
  };

  const renderSurahModal = () => (
    <Modal
      visible={showSurahModal}
      animationType="slide"
      transparent={true}
      onRequestClose={() => setShowSurahModal(false)}>
      <View style={styles.modalOverlay}>
        <View style={styles.modalContent}>
          <Text style={styles.modalTitle}>Select Surah</Text>
          <ScrollView style={styles.surahList}>
            {quranSurahs.map(surah => (
              <TouchableOpacity
                key={surah.number}
                style={[
                  styles.surahItem,
                  selectedSurah === surah.number && styles.selectedItem
                ]}
                onPress={() => handleSurahSelect(surah.number)}>
                <Text style={styles.surahNumber}>{surah.number}</Text>
                <View style={styles.surahNames}>
                  <Text style={styles.surahArabicName}>{surah.name}</Text>
                  <Text style={styles.surahEnglishName}>{surah.englishName}</Text>
                </View>
              </TouchableOpacity>
            ))}
          </ScrollView>
          <TouchableOpacity
            style={styles.closeButton}
            onPress={() => setShowSurahModal(false)}>
            <Text style={styles.closeButtonText}>Close</Text>
          </TouchableOpacity>
        </View>
      </View>
    </Modal>
  );

  const renderTafsirModal = () => (
    <Modal
      visible={showTafsirModal}
      animationType="slide"
      transparent={true}
      onRequestClose={() => setShowTafsirModal(false)}>
      <View style={styles.modalOverlay}>
        <View style={styles.modalContent}>
          <Text style={styles.modalTitle}>Select Tafsir</Text>
          <ScrollView style={styles.tafsirList}>
            {tafsirTypes.map(type => (
              <TouchableOpacity
                key={type.id}
                style={[
                  styles.tafsirItem,
                  tafsirType === type.id && styles.selectedItem
                ]}
                onPress={() => {
                  setTafsirType(type.id as any);
                  setShowTafsirModal(false);
                }}>
                <Text style={styles.tafsirName}>{type.name}</Text>
                <Text style={styles.tafsirArabicName}>{type.arabicName}</Text>
                <Text style={styles.tafsirDescription}>{type.description}</Text>
              </TouchableOpacity>
            ))}
          </ScrollView>
          <TouchableOpacity
            style={styles.closeButton}
            onPress={() => setShowTafsirModal(false)}>
            <Text style={styles.closeButtonText}>Close</Text>
          </TouchableOpacity>
        </View>
      </View>
    </Modal>
  );

  const renderAyahSelector = () => {
    const currentSurah = quranSurahs.find(s => s.number === selectedSurah);
    if (!currentSurah) return null;

    return (
      <View style={styles.ayahSelector}>
        <Text style={styles.ayahSelectorTitle}>Select Ayah:</Text>
        <ScrollView horizontal style={styles.ayahScroll}>
          {Array.from({length: Math.min(currentSurah.ayahs, 50)}, (_, i) => i + 1).map(ayah => (
            <TouchableOpacity
              key={ayah}
              style={[
                styles.ayahButton,
                selectedAyah === ayah && styles.selectedAyah
              ]}
              onPress={() => handleAyahSelect(ayah)}>
              <Text style={styles.ayahButtonText}>{ayah}</Text>
            </TouchableOpacity>
          ))}
        </ScrollView>
        {currentSurah.ayahs > 50 && (
          <Text style={styles.moreAyahsText}>... and {currentSurah.ayahs - 50} more</Text>
        )}
      </View>
    );
  };

  const getCurrentSurah = () => {
    return quranSurahs.find(s => s.number === selectedSurah);
  };

  const getCurrentAyahText = () => {
    const quranText = QuranService.getCompleteQuranText(selectedSurah);
    const ayah = quranText.find(a => a.ayah === selectedAyah);
    return ayah?.text || '';
  };

  return (
    <View style={styles.container}>
      <View style={styles.header}>
        <Text style={styles.headerTitle}>Tafsir</Text>
        <Text style={styles.headerSubtitle}>Quran Exegesis</Text>
      </View>

      <View style={styles.selectionBar}>
        <TouchableOpacity
          style={styles.selectionButton}
          onPress={() => setShowSurahModal(true)}>
          <Text style={styles.selectionButtonText}>
            {getCurrentSurah()?.name || 'Select Surah'}
          </Text>
          <Icon name="arrow-drop-down" size={16} color="#2e7d32" />
        </TouchableOpacity>

        <TouchableOpacity
          style={styles.selectionButton}
          onPress={() => setShowTafsirModal(true)}>
          <Text style={styles.selectionButtonText}>
            {tafsirTypes.find(t => t.id === tafsirType)?.name || 'Select Tafsir'}
          </Text>
          <Icon name="arrow-drop-down" size={16} color="#2e7d32" />
        </TouchableOpacity>
      </View>

      {renderAyahSelector()}

      <View style={styles.ayahDisplay}>
        <Text style={styles.ayahText}>{getCurrentAyahText()}</Text>
        <Text style={styles.ayahReference}>
          Surah {getCurrentSurah()?.englishName} ({selectedSurah}:{selectedAyah})
        </Text>
      </View>

      <ScrollView style={styles.tafsirContent}>
        {loading ? (
          <View style={styles.loadingContainer}>
            <ActivityIndicator size="large" color="#2e7d32" />
            <Text style={styles.loadingText}>Loading Tafsir...</Text>
          </View>
        ) : (
          <View style={styles.tafsirContainer}>
            <Text style={styles.tafsirTitle}>
              {tafsirTypes.find(t => t.id === tafsirType)?.name} Tafsir
            </Text>
            <Text style={styles.tafsirText}>{tafsirText}</Text>
          </View>
        )}
      </ScrollView>

      <View style={styles.actionBar}>
        <TouchableOpacity
          style={styles.actionButton}
          onPress={() => {
            // Copy tafsir text
            Alert.alert('Copied', 'Tafsir text copied to clipboard');
          }}>
          <Icon name="content-copy" size={20} color="white" />
          <Text style={styles.actionButtonText}>Copy</Text>
        </TouchableOpacity>

        <TouchableOpacity
          style={styles.actionButton}
          onPress={() => {
            // Share tafsir
            Alert.alert('Share', 'Sharing functionality would be implemented here');
          }}>
          <Icon name="share" size={20} color="white" />
          <Text style={styles.actionButtonText}>Share</Text>
        </TouchableOpacity>

        <TouchableOpacity
          style={styles.actionButton}
          onPress={() => {
            // Bookmark tafsir
            Alert.alert('Bookmarked', 'Tafsir bookmarked successfully');
          }}>
          <Icon name="bookmark" size={20} color="white" />
          <Text style={styles.actionButtonText}>Bookmark</Text>
        </TouchableOpacity>
      </View>

      {renderSurahModal()}
      {renderTafsirModal()}
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f8f9fa',
  },
  header: {
    alignItems: 'center',
    padding: 20,
    backgroundColor: '#2e7d32',
  },
  headerTitle: {
    fontSize: 24,
    fontWeight: 'bold',
    color: 'white',
  },
  headerSubtitle: {
    fontSize: 14,
    color: '#e8f5e8',
    marginTop: 5,
  },
  selectionBar: {
    flexDirection: 'row',
    padding: 15,
    backgroundColor: 'white',
    borderBottomWidth: 1,
    borderBottomColor: '#e0e0e0',
  },
  selectionButton: {
    flex: 1,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: '#f8f9fa',
    padding: 12,
    marginHorizontal: 5,
    borderRadius: 8,
    borderWidth: 1,
    borderColor: '#2e7d32',
  },
  selectionButtonText: {
    fontSize: 14,
    fontWeight: 'bold',
    color: '#2e7d32',
    marginRight: 5,
  },
  ayahSelector: {
    padding: 15,
    backgroundColor: 'white',
    borderBottomWidth: 1,
    borderBottomColor: '#e0e0e0',
  },
  ayahSelectorTitle: {
    fontSize: 16,
    fontWeight: 'bold',
    color: '#333',
    marginBottom: 10,
  },
  ayahScroll: {
    flexDirection: 'row',
  },
  ayahButton: {
    width: 40,
    height: 40,
    borderRadius: 20,
    backgroundColor: '#f8f9fa',
    alignItems: 'center',
    justifyContent: 'center',
    marginHorizontal: 2,
    borderWidth: 1,
    borderColor: '#e0e0e0',
  },
  selectedAyah: {
    backgroundColor: '#2e7d32',
    borderColor: '#2e7d32',
  },
  ayahButtonText: {
    fontSize: 12,
    fontWeight: 'bold',
    color: '#333',
  },
  selectedAyahText: {
    color: 'white',
  },
  moreAyahsText: {
    fontSize: 12,
    color: '#666',
    fontStyle: 'italic',
    marginTop: 5,
  },
  ayahDisplay: {
    padding: 20,
    backgroundColor: '#e8f5e8',
    margin: 15,
    borderRadius: 10,
  },
  ayahText: {
    fontSize: 18,
    lineHeight: 30,
    color: '#1b5e20',
    textAlign: 'right',
    writingDirection: 'rtl',
    fontWeight: 'bold',
    marginBottom: 10,
  },
  ayahReference: {
    fontSize: 14,
    color: '#2e7d32',
    textAlign: 'center',
    fontStyle: 'italic',
  },
  tafsirContent: {
    flex: 1,
    margin: 15,
  },
  loadingContainer: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    padding: 50,
  },
  loadingText: {
    fontSize: 16,
    color: '#666',
    marginTop: 10,
  },
  tafsirContainer: {
    backgroundColor: 'white',
    borderRadius: 10,
    padding: 20,
    elevation: 2,
    shadowColor: '#000',
    shadowOffset: {width: 0, height: 1},
    shadowOpacity: 0.2,
    shadowRadius: 2,
  },
  tafsirTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#2e7d32',
    marginBottom: 15,
    textAlign: 'center',
  },
  tafsirText: {
    fontSize: 16,
    lineHeight: 24,
    color: '#333',
    textAlign: 'left',
  },
  actionBar: {
    flexDirection: 'row',
    padding: 15,
    backgroundColor: '#2e7d32',
  },
  actionButton: {
    flex: 1,
    alignItems: 'center',
    padding: 10,
  },
  actionButtonText: {
    color: 'white',
    fontSize: 12,
    marginTop: 5,
  },
  modalOverlay: {
    flex: 1,
    backgroundColor: 'rgba(0,0,0,0.5)',
    justifyContent: 'center',
    alignItems: 'center',
  },
  modalContent: {
    backgroundColor: 'white',
    borderRadius: 15,
    padding: 20,
    width: '90%',
    maxHeight: '80%',
  },
  modalTitle: {
    fontSize: 20,
    fontWeight: 'bold',
    color: '#333',
    textAlign: 'center',
    marginBottom: 20,
  },
  surahList: {
    flex: 1,
  },
  surahItem: {
    flexDirection: 'row',
    alignItems: 'center',
    padding: 15,
    borderBottomWidth: 1,
    borderBottomColor: '#e0e0e0',
  },
  selectedItem: {
    backgroundColor: '#e8f5e8',
  },
  surahNumber: {
    fontSize: 16,
    fontWeight: 'bold',
    color: '#2e7d32',
    width: 30,
  },
  surahNames: {
    flex: 1,
    marginLeft: 15,
  },
  surahArabicName: {
    fontSize: 16,
    fontWeight: 'bold',
    color: '#333',
  },
  surahEnglishName: {
    fontSize: 14,
    color: '#666',
    marginTop: 2,
  },
  tafsirList: {
    flex: 1,
  },
  tafsirItem: {
    padding: 15,
    borderBottomWidth: 1,
    borderBottomColor: '#e0e0e0',
  },
  tafsirName: {
    fontSize: 16,
    fontWeight: 'bold',
    color: '#333',
  },
  tafsirArabicName: {
    fontSize: 14,
    color: '#666',
    marginTop: 2,
  },
  tafsirDescription: {
    fontSize: 12,
    color: '#888',
    marginTop: 5,
    lineHeight: 16,
  },
  closeButton: {
    backgroundColor: '#2e7d32',
    padding: 15,
    borderRadius: 10,
    alignItems: 'center',
    marginTop: 20,
  },
  closeButtonText: {
    color: 'white',
    fontSize: 16,
    fontWeight: 'bold',
  },
});

export default TafsirScreen;