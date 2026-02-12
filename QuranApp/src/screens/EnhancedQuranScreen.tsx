import React, {useState, useEffect, useRef} from 'react';
import {
  View,
  Text,
  FlatList,
  TouchableOpacity,
  StyleSheet,
  ScrollView,
  Dimensions,
  TextInput,
  Modal,
  Alert,
  ActivityIndicator,
} from 'react-native';
import Icon from 'react-native-vector-icons/MaterialIcons';
import {quranSurahs, audioReciters, translationLanguages} from '../data/completeQuranData';
import {Surah, AudioReciter, Bookmark, Translation} from '../types';
import {AudioService} from '../services/AudioService';
import {QuranService} from '../services/QuranService';

const {width, height} = Dimensions.get('window');

const QuranScreen = () => {
  const [selectedSurah, setSelectedSurah] = useState<Surah | null>(null);
  const [searchQuery, setSearchQuery] = useState('');
  const [showSearch, setShowSearch] = useState(false);
  const [selectedReciter, setSelectedReciter] = useState<AudioReciter>(audioReciters[0]);
  const [showReciterModal, setShowReciterModal] = useState(false);
  const [showTranslationModal, setShowTranslationModal] = useState(false);
  const [selectedLanguage, setSelectedLanguage] = useState('en');
  const [showTranslations, setShowTranslations] = useState(false);
  const [bookmarks, setBookmarks] = useState<Bookmark[]>([]);
  const [fontSize, setFontSize] = useState(18);
  const [showFontModal, setShowFontModal] = useState(false);
  const [isPlaying, setIsPlaying] = useState(false);
  const [currentAyah, setCurrentAyah] = useState(0);
  const [loading, setLoading] = useState(false);

  const audioService = AudioService.getInstance();
  const flatListRef = useRef<FlatList>(null);

  useEffect(() => {
    // Initialize audio service listener
    audioService.addListener((playing) => {
      setIsPlaying(playing);
    });

    return () => {
      audioService.removeListener(() => {});
    };
  }, []);

  const renderSurahItem = ({item}: {item: Surah}) => (
    <TouchableOpacity
      style={styles.surahItem}
      onPress={() => handleSurahPress(item)}>
      <View style={styles.surahHeader}>
        <View style={styles.surahNumberContainer}>
          <Text style={styles.surahNumber}>{item.number}</Text>
        </View>
        <View style={styles.surahNames}>
          <Text style={styles.surahArabicName}>{item.name}</Text>
          <Text style={styles.surahEnglishName}>{item.englishName}</Text>
          <Text style={styles.surahMeta}>{item.ayahs} verses • {item.type}</Text>
        </View>
        <View style={styles.surahActions}>
          <TouchableOpacity
            style={styles.playButton}
            onPress={() => playSurahAudio(item)}>
            <Icon name="play-arrow" size={20} color="#2e7d32" />
          </TouchableOpacity>
          <TouchableOpacity
            style={styles.bookmarkButton}
            onPress={() => toggleBookmark(item)}>
            <Icon 
              name={isBookmarked(item) ? "bookmark" : "bookmark-border"} 
              size={20} 
              color="#2e7d32" 
            />
          </TouchableOpacity>
        </View>
      </View>
    </TouchableOpacity>
  );

  const handleSurahPress = (surah: Surah) => {
    setSelectedSurah(surah);
    setCurrentAyah(0);
  };

  const playSurahAudio = async (surah: Surah) => {
    setLoading(true);
    try {
      const success = await audioService.playAudio(surah.number, selectedReciter);
      if (!success) {
        Alert.alert('Error', 'Failed to play audio');
      }
    } catch (error) {
      Alert.alert('Error', 'Failed to play audio');
    } finally {
      setLoading(false);
    }
  };

  const toggleBookmark = (surah: Surah) => {
    const bookmarkId = `surah-${surah.number}`;
    const existingBookmark = bookmarks.find(b => b.id === bookmarkId);
    
    if (existingBookmark) {
      setBookmarks(bookmarks.filter(b => b.id !== bookmarkId));
    } else {
      const newBookmark: Bookmark = {
        id: bookmarkId,
        surah: surah.number,
        ayah: 0,
        timestamp: new Date(),
        type: 'surah',
      };
      setBookmarks([...bookmarks, newBookmark]);
    }
  };

  const isBookmarked = (surah: Surah): boolean => {
    return bookmarks.some(b => b.id === `surah-${surah.number}`);
  };

  const renderAyahItem = ({item, index}: {item: any; index: number}) => (
    <View style={styles.ayahContainer}>
      <View style={styles.ayahHeader}>
        <Text style={styles.ayahNumber}>{index + 1}</Text>
        <View style={styles.ayahActions}>
          <TouchableOpacity
            style={styles.ayahPlayButton}
            onPress={() => playAyahAudio(index + 1)}>
            <Icon name="play-arrow" size={16} color="#2e7d32" />
          </TouchableOpacity>
          <TouchableOpacity
            style={styles.ayahBookmarkButton}
            onPress={() => toggleAyahBookmark(index + 1)}>
            <Icon name="bookmark-border" size={16} color="#2e7d32" />
          </TouchableOpacity>
        </View>
      </View>
      <Text style={[styles.ayahText, {fontSize}]}>{item.text}</Text>
      {showTranslations && (
        <Text style={styles.translationText}>
          {QuranService.getTranslation(selectedSurah!.number, index + 1, selectedLanguage)}
        </Text>
      )}
    </View>
  );

  const playAyahAudio = async (ayah: number) => {
    // This would play specific ayah audio
    console.log(`Playing ayah ${ayah} from surah ${selectedSurah?.number}`);
  };

  const toggleAyahBookmark = (ayah: number) => {
    if (!selectedSurah) return;
    
    const bookmarkId = `ayah-${selectedSurah.number}-${ayah}`;
    const existingBookmark = bookmarks.find(b => b.id === bookmarkId);
    
    if (existingBookmark) {
      setBookmarks(bookmarks.filter(b => b.id !== bookmarkId));
    } else {
      const newBookmark: Bookmark = {
        id: bookmarkId,
        surah: selectedSurah.number,
        ayah: ayah,
        timestamp: new Date(),
        type: 'ayah',
      };
      setBookmarks([...bookmarks, newBookmark]);
    }
  };

  const renderReciterModal = () => (
    <Modal
      visible={showReciterModal}
      animationType="slide"
      transparent={true}
      onRequestClose={() => setShowReciterModal(false)}>
      <View style={styles.modalOverlay}>
        <View style={styles.modalContent}>
          <Text style={styles.modalTitle}>Select Reciter</Text>
          <ScrollView style={styles.reciterList}>
            {audioReciters.map(reciter => (
              <TouchableOpacity
                key={reciter.id}
                style={[
                  styles.reciterItem,
                  selectedReciter.id === reciter.id && styles.selectedReciter
                ]}
                onPress={() => {
                  setSelectedReciter(reciter);
                  setShowReciterModal(false);
                }}>
                <Text style={styles.reciterName}>{reciter.name}</Text>
                <Text style={styles.reciterArabicName}>{reciter.arabicName}</Text>
                <Text style={styles.reciterQuality}>{reciter.bitrate}</Text>
              </TouchableOpacity>
            ))}
          </ScrollView>
          <TouchableOpacity
            style={styles.closeButton}
            onPress={() => setShowReciterModal(false)}>
            <Text style={styles.closeButtonText}>Close</Text>
          </TouchableOpacity>
        </View>
      </View>
    </Modal>
  );

  const renderFontModal = () => (
    <Modal
      visible={showFontModal}
      animationType="slide"
      transparent={true}
      onRequestClose={() => setShowFontModal(false)}>
      <View style={styles.modalOverlay}>
        <View style={styles.modalContent}>
          <Text style={styles.modalTitle}>Font Size</Text>
          <View style={styles.fontControls}>
            <TouchableOpacity
              style={styles.fontButton}
              onPress={() => setFontSize(Math.max(12, fontSize - 2))}>
              <Icon name="remove" size={20} color="#2e7d32" />
            </TouchableOpacity>
            <Text style={styles.fontSizeText}>{fontSize}</Text>
            <TouchableOpacity
              style={styles.fontButton}
              onPress={() => setFontSize(Math.min(30, fontSize + 2))}>
              <Icon name="add" size={20} color="#2e7d32" />
            </TouchableOpacity>
          </View>
          <TouchableOpacity
            style={styles.closeButton}
            onPress={() => setShowFontModal(false)}>
            <Text style={styles.closeButtonText}>Close</Text>
          </TouchableOpacity>
        </View>
      </View>
    </Modal>
  );

  if (selectedSurah) {
    const quranText = QuranService.getCompleteQuranText(selectedSurah.number);
    
    return (
      <View style={styles.container}>
        <View style={styles.surahViewHeader}>
          <TouchableOpacity
            style={styles.backButton}
            onPress={() => setSelectedSurah(null)}>
            <Icon name="arrow-back" size={24} color="white" />
          </TouchableOpacity>
          <View style={styles.surahTitleContainer}>
            <Text style={styles.surahTitle}>{selectedSurah.name}</Text>
            <Text style={styles.surahSubtitle}>{selectedSurah.englishName}</Text>
          </View>
          <TouchableOpacity
            style={styles.optionsButton}
            onPress={() => setShowFontModal(true)}>
            <Icon name="text-fields" size={24} color="white" />
          </TouchableOpacity>
        </View>

        <View style={styles.audioControls}>
          <TouchableOpacity
            style={styles.reciterButton}
            onPress={() => setShowReciterModal(true)}>
            <Text style={styles.reciterButtonText}>{selectedReciter.name}</Text>
            <Icon name="arrow-drop-down" size={16} color="white" />
          </TouchableOpacity>
          <TouchableOpacity
            style={styles.playControlButton}
            onPress={() => playSurahAudio(selectedSurah)}>
            {loading ? (
              <ActivityIndicator size="small" color="white" />
            ) : (
              <Icon name={isPlaying ? "pause" : "play-arrow"} size={24} color="white" />
            )}
          </TouchableOpacity>
          <TouchableOpacity
            style={styles.translationButton}
            onPress={() => setShowTranslations(!showTranslations)}>
            <Icon name="translate" size={24} color="white" />
          </TouchableOpacity>
        </View>

        <FlatList
          ref={flatListRef}
          data={quranText}
          renderItem={renderAyahItem}
          keyExtractor={(item, index) => index.toString()}
          style={styles.ayahList}
          showsVerticalScrollIndicator={false}
        />

        {renderReciterModal()}
        {renderFontModal()}
      </View>
    );
  }

  return (
    <View style={styles.container}>
      <View style={styles.header}>
        <Text style={styles.headerTitle}>القرآن الكريم</Text>
        <Text style={styles.headerSubtitle}>Holy Quran</Text>
        <TouchableOpacity
          style={styles.searchButton}
          onPress={() => setShowSearch(!showSearch)}>
          <Icon name="search" size={24} color="#2e7d32" />
        </TouchableOpacity>
      </View>

      {showSearch && (
        <View style={styles.searchContainer}>
          <TextInput
            style={styles.searchInput}
            placeholder="Search Quran..."
            value={searchQuery}
            onChangeText={setSearchQuery}
            placeholderTextColor="#666"
          />
        </View>
      )}

      <View style={styles.quickActions}>
        <TouchableOpacity
          style={styles.quickActionButton}
          onPress={() => setShowReciterModal(true)}>
          <Icon name="headset" size={20} color="#2e7d32" />
          <Text style={styles.quickActionText}>Reciter</Text>
        </TouchableOpacity>
        <TouchableOpacity
          style={styles.quickActionButton}
          onPress={() => setShowTranslationModal(true)}>
          <Icon name="translate" size={20} color="#2e7d32" />
          <Text style={styles.quickActionText}>Translate</Text>
        </TouchableOpacity>
        <TouchableOpacity
          style={styles.quickActionButton}>
          <Icon name="bookmark" size={20} color="#2e7d32" />
          <Text style={styles.quickActionText}>Bookmarks</Text>
        </TouchableOpacity>
        <TouchableOpacity
          style={styles.quickActionButton}>
          <Icon name="playlist-play" size={20} color="#2e7d32" />
          <Text style={styles.quickActionText}>Playlist</Text>
        </TouchableOpacity>
      </View>

      <FlatList
        data={quranSurahs}
        renderItem={renderSurahItem}
        keyExtractor={item => item.number.toString()}
        style={styles.surahList}
        showsVerticalScrollIndicator={false}
      />

      {renderReciterModal()}
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f8f9fa',
  },
  header: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
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
  },
  searchButton: {
    padding: 8,
  },
  searchContainer: {
    padding: 15,
    backgroundColor: 'white',
    borderBottomWidth: 1,
    borderBottomColor: '#e0e0e0',
  },
  searchInput: {
    height: 40,
    borderColor: '#ddd',
    borderWidth: 1,
    borderRadius: 20,
    paddingHorizontal: 15,
    fontSize: 16,
  },
  quickActions: {
    flexDirection: 'row',
    padding: 15,
    backgroundColor: 'white',
    borderBottomWidth: 1,
    borderBottomColor: '#e0e0e0',
  },
  quickActionButton: {
    flex: 1,
    alignItems: 'center',
    padding: 10,
  },
  quickActionText: {
    fontSize: 12,
    color: '#666',
    marginTop: 4,
  },
  surahList: {
    flex: 1,
  },
  surahItem: {
    backgroundColor: 'white',
    marginVertical: 2,
    marginHorizontal: 10,
    padding: 15,
    borderRadius: 8,
    elevation: 2,
    shadowColor: '#000',
    shadowOffset: {width: 0, height: 1},
    shadowOpacity: 0.2,
    shadowRadius: 2,
  },
  surahHeader: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  surahNumberContainer: {
    width: 40,
    height: 40,
    borderRadius: 20,
    backgroundColor: '#e8f5e8',
    alignItems: 'center',
    justifyContent: 'center',
  },
  surahNumber: {
    fontSize: 16,
    fontWeight: 'bold',
    color: '#2e7d32',
  },
  surahNames: {
    flex: 1,
    marginLeft: 15,
  },
  surahArabicName: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#333',
    textAlign: 'right',
  },
  surahEnglishName: {
    fontSize: 14,
    color: '#666',
    marginTop: 2,
  },
  surahMeta: {
    fontSize: 12,
    color: '#888',
    marginTop: 2,
  },
  surahActions: {
    flexDirection: 'row',
  },
  playButton: {
    width: 35,
    height: 35,
    borderRadius: 20,
    backgroundColor: '#e8f5e8',
    alignItems: 'center',
    justifyContent: 'center',
    marginLeft: 8,
  },
  bookmarkButton: {
    width: 35,
    height: 35,
    borderRadius: 20,
    backgroundColor: '#e8f5e8',
    alignItems: 'center',
    justifyContent: 'center',
    marginLeft: 8,
  },
  surahViewHeader: {
    flexDirection: 'row',
    alignItems: 'center',
    padding: 15,
    backgroundColor: '#2e7d32',
  },
  backButton: {
    padding: 8,
  },
  surahTitleContainer: {
    flex: 1,
    alignItems: 'center',
  },
  surahTitle: {
    fontSize: 20,
    fontWeight: 'bold',
    color: 'white',
  },
  surahSubtitle: {
    fontSize: 14,
    color: '#e8f5e8',
  },
  optionsButton: {
    padding: 8,
  },
  audioControls: {
    flexDirection: 'row',
    alignItems: 'center',
    padding: 15,
    backgroundColor: '#1b5e20',
  },
  reciterButton: {
    flex: 1,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: 'rgba(255,255,255,0.1)',
    padding: 10,
    borderRadius: 20,
  },
  reciterButtonText: {
    color: 'white',
    fontSize: 14,
    marginRight: 5,
  },
  playControlButton: {
    width: 50,
    height: 50,
    borderRadius: 25,
    backgroundColor: '#4caf50',
    alignItems: 'center',
    justifyContent: 'center',
    marginHorizontal: 15,
  },
  translationButton: {
    width: 40,
    height: 40,
    borderRadius: 20,
    backgroundColor: 'rgba(255,255,255,0.1)',
    alignItems: 'center',
    justifyContent: 'center',
  },
  ayahList: {
    flex: 1,
  },
  ayahContainer: {
    backgroundColor: 'white',
    marginVertical: 2,
    marginHorizontal: 10,
    padding: 15,
    borderRadius: 8,
  },
  ayahHeader: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    marginBottom: 10,
  },
  ayahNumber: {
    fontSize: 14,
    fontWeight: 'bold',
    color: '#2e7d32',
  },
  ayahActions: {
    flexDirection: 'row',
  },
  ayahPlayButton: {
    width: 30,
    height: 30,
    borderRadius: 15,
    backgroundColor: '#e8f5e8',
    alignItems: 'center',
    justifyContent: 'center',
    marginLeft: 5,
  },
  ayahBookmarkButton: {
    width: 30,
    height: 30,
    borderRadius: 15,
    backgroundColor: '#e8f5e8',
    alignItems: 'center',
    justifyContent: 'center',
    marginLeft: 5,
  },
  ayahText: {
    fontSize: 18,
    lineHeight: 30,
    color: '#333',
    textAlign: 'right',
    writingDirection: 'rtl',
    marginBottom: 10,
  },
  translationText: {
    fontSize: 14,
    color: '#666',
    lineHeight: 20,
    fontStyle: 'italic',
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
    width: width * 0.9,
    maxHeight: height * 0.7,
  },
  modalTitle: {
    fontSize: 20,
    fontWeight: 'bold',
    color: '#333',
    textAlign: 'center',
    marginBottom: 20,
  },
  reciterList: {
    flex: 1,
  },
  reciterItem: {
    padding: 15,
    borderBottomWidth: 1,
    borderBottomColor: '#e0e0e0',
  },
  selectedReciter: {
    backgroundColor: '#e8f5e8',
  },
  reciterName: {
    fontSize: 16,
    fontWeight: 'bold',
    color: '#333',
  },
  reciterArabicName: {
    fontSize: 14,
    color: '#666',
    marginTop: 2,
  },
  reciterQuality: {
    fontSize: 12,
    color: '#888',
    marginTop: 2,
  },
  fontControls: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    padding: 20,
  },
  fontButton: {
    width: 40,
    height: 40,
    borderRadius: 20,
    backgroundColor: '#e8f5e8',
    alignItems: 'center',
    justifyContent: 'center',
  },
  fontSizeText: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#333',
    marginHorizontal: 30,
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

export default QuranScreen;