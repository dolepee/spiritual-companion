import React, {useState, useEffect} from 'react';
import {
  View,
  Text,
  StyleSheet,
  TouchableOpacity,
  ScrollView,
  Alert,
  ActivityIndicator,
  Modal,
  Switch,
} from 'react-native';
import Icon from 'react-native-vector-icons/MaterialIcons';
import {PrayerTimesService} from '../services/PrayerTimesService';
import {PrayerTimes} from '../types';

const PrayerTimesScreen = () => {
  const [prayerTimes, setPrayerTimes] = useState<PrayerTimes | null>(null);
  const [loading, setLoading] = useState(false);
  const [athanEnabled, setAthanEnabled] = useState(false);
  const [showLocationModal, setShowLocationModal] = useState(false);
  const [calculationMethod, setCalculationMethod] = useState('MuslimWorldLeague');
  const [currentLocation, setCurrentLocation] = useState<{latitude: number; longitude: number} | null>(null);
  const [nextPrayer, setNextPrayer] = useState<{name: string; time: string; minutesUntil: number} | null>(null);

  const prayerService = PrayerTimesService.getInstance();

  useEffect(() => {
    initializePrayerTimes();
    loadAthanSettings();
  }, []);

  useEffect(() => {
    if (currentLocation) {
      loadPrayerTimes();
    }
  }, [currentLocation, calculationMethod]);

  const initializePrayerTimes = async () => {
    prayerService.initializeAthanChannel();
  };

  const loadAthanSettings = async () => {
    const enabled = await prayerService.isAthanEnabled();
    setAthanEnabled(enabled);
  };

  const loadPrayerTimes = async () => {
    if (!currentLocation) return;

    setLoading(true);
    try {
      const today = new Date();
      const times = prayerService.calculatePrayerTimes(
        currentLocation.latitude,
        currentLocation.longitude,
        today,
        calculationMethod
      );
      setPrayerTimes(times);

      const next = prayerService.getNextPrayer(times);
      setNextPrayer(next);

      // Schedule Athan notifications
      await prayerService.scheduleAthanNotifications(times, 'Current Location');
    } catch (error) {
      console.error('Error loading prayer times:', error);
      Alert.alert('Error', 'Failed to load prayer times');
    } finally {
      setLoading(false);
    }
  };

  const getCurrentLocation = async () => {
    setLoading(true);
    try {
      const location = await prayerService.getCurrentLocation();
      setCurrentLocation(location);
      setShowLocationModal(false);
    } catch (error) {
      console.error('Error getting location:', error);
      Alert.alert('Location Error', 'Failed to get current location. Please enable GPS.');
    } finally {
      setLoading(false);
    }
  };

  const toggleAthan = async (enabled: boolean) => {
    try {
      await prayerService.setAthanEnabled(enabled);
      setAthanEnabled(enabled);
      
      if (enabled && prayerTimes) {
        await prayerService.scheduleAthanNotifications(prayerTimes, 'Current Location');
      }
    } catch (error) {
      console.error('Error toggling Athan:', error);
      Alert.alert('Error', 'Failed to update Athan settings');
    }
  };

  const getCurrentTime = () => {
    const now = new Date();
    return now.toLocaleTimeString('en-US', {
      hour: '2-digit',
      minute: '2-digit',
    });
  };

  const getCurrentDate = () => {
    const now = new Date();
    return now.toLocaleDateString('en-US', {
      weekday: 'long',
      year: 'numeric',
      month: 'long',
      day: 'numeric',
    });
  };

  const getPrayerTimeStyle = (prayerName: string) => {
    const nextPrayerName = nextPrayer?.name;
    if (nextPrayerName && prayerName.includes(nextPrayerName)) {
      return styles.nextPrayerTime;
    }
    return styles.prayerTime;
  };

  const getPrayerTextStyle = (prayerName: string) => {
    const nextPrayerName = nextPrayer?.name;
    if (nextPrayerName && prayerName.includes(nextPrayerName)) {
      return styles.nextPrayerText;
    }
    return styles.prayerText;
  };

  const isRamadanTime = () => {
    // Check if current date is in Ramadan
    const now = new Date();
    const ramadanStart = new Date(now.getFullYear(), 3, 11); // Approximate
    const ramadanEnd = new Date(now.getFullYear(), 4, 9);
    return now >= ramadanStart && now <= ramadanEnd;
  };

  const calculationMethods = [
    { id: 'MuslimWorldLeague', name: 'Muslim World League' },
    { id: 'IslamicSociety', name: 'Islamic Society of North America' },
    { id: 'Egyptian', name: 'Egyptian General Authority' },
    { id: 'UmmAlQura', name: 'Umm al-Qura University' },
    { id: 'Karachi', name: 'University of Islamic Sciences, Karachi' },
    { id: 'Tehran', name: 'Institute of Geophysics, Tehran' },
    { id: 'Makkah', name: 'Umm al-Qura, Makkah' },
  ];

  const renderPrayerTimes = () => {
    if (!prayerTimes) return null;

    const isRamadan = isRamadanTime();

    return (
      <View style={styles.prayerTimesContainer}>
        <View style={styles.timeRow}>
          <View style={styles.prayerNameContainer}>
            <Icon name="wb-twilight" size={24} color="#ff9800" />
            <Text style={styles.prayerName}>Fajr</Text>
            {isRamadan && <Text style={styles.seharIftar}>Sehar</Text>}
          </View>
          <Text style={getPrayerTextStyle('Fajr')}>{prayerTimes.fajr}</Text>
        </View>

        <View style={styles.timeRow}>
          <View style={styles.prayerNameContainer}>
            <Icon name="wb-sunny" size={24} color="#ffc107" />
            <Text style={styles.prayerName}>Sunrise</Text>
          </View>
          <Text style={styles.prayerText}>{prayerTimes.sunrise}</Text>
        </View>

        <View style={styles.timeRow}>
          <View style={styles.prayerNameContainer}>
            <Icon name="wb-sunny" size={24} color="#ff9800" />
            <Text style={styles.prayerName}>Dhuhr</Text>
          </View>
          <Text style={getPrayerTextStyle('Dhuhr')}>{prayerTimes.dhuhr}</Text>
        </View>

        <View style={styles.timeRow}>
          <View style={styles.prayerNameContainer}>
            <Icon name="wb-cloudy" size={24} color="#ff5722" />
            <Text style={styles.prayerName}>Asr</Text>
          </View>
          <Text style={getPrayerTextStyle('Asr')}>{prayerTimes.asr}</Text>
        </View>

        <View style={styles.timeRow}>
          <View style={styles.prayerNameContainer}>
            <Icon name="nights-stay" size={24} color="#673ab7" />
            <Text style={styles.prayerName}>Maghrib</Text>
            {isRamadan && <Text style={styles.seharIftar}>Iftar</Text>}
          </View>
          <Text style={getPrayerTextStyle('Maghrib')}>{prayerTimes.maghrib}</Text>
        </View>

        <View style={styles.timeRow}>
          <View style={styles.prayerNameContainer}>
            <Icon name="bedtime" size={24} color="#3f51b5" />
            <Text style={styles.prayerName}>Isha</Text>
          </View>
          <Text style={getPrayerTextStyle('Isha')}>{prayerTimes.isha}</Text>
        </View>
      </View>
    );
  };

  const renderNextPrayerInfo = () => {
    if (!nextPrayer) return null;

    return (
      <View style={styles.nextPrayerContainer}>
        <Text style={styles.nextPrayerTitle}>Next Prayer</Text>
        <Text style={styles.nextPrayerName}>{nextPrayer.name}</Text>
        <Text style={styles.nextPrayerTime}>{nextPrayer.time}</Text>
        <Text style={styles.timeRemaining}>
          in {nextPrayer.minutesUntil} minutes
        </Text>
      </View>
    );
  };

  const renderLocationModal = () => (
    <Modal
      visible={showLocationModal}
      animationType="slide"
      transparent={true}
      onRequestClose={() => setShowLocationModal(false)}>
      <View style={styles.modalOverlay}>
        <View style={styles.modalContent}>
          <Text style={styles.modalTitle}>Location Settings</Text>
          <TouchableOpacity
            style={styles.locationButton}
            onPress={getCurrentLocation}>
            <Icon name="location-on" size={24} color="#2e7d32" />
            <Text style={styles.locationButtonText}>Use Current Location</Text>
          </TouchableOpacity>
          <Text style={styles.locationInfo}>
            or enter coordinates manually
          </Text>
          <TouchableOpacity
            style={styles.closeButton}
            onPress={() => setShowLocationModal(false)}>
            <Text style={styles.closeButtonText}>Close</Text>
          </TouchableOpacity>
        </View>
      </View>
    </Modal>
  );

  return (
    <View style={styles.container}>
      <View style={styles.header}>
        <Text style={styles.headerTitle}>مواقيت الصلاة</Text>
        <Text style={styles.headerSubtitle}>Prayer Times</Text>
        <TouchableOpacity
          style={styles.locationButton}
          onPress={() => setShowLocationModal(true)}>
          <Icon name="location-on" size={24} color="white" />
        </TouchableOpacity>
      </View>

      <View style={styles.dateTimeContainer}>
        <Text style={styles.currentTime}>{getCurrentTime()}</Text>
        <Text style={styles.currentDate}>{getCurrentDate()}</Text>
        {isRamadanTime() && (
          <View style={styles.ramadanBadge}>
            <Text style={styles.ramadanText}>Ramadan</Text>
          </View>
        )}
      </View>

      {renderNextPrayerInfo()}

      <ScrollView style={styles.content}>
        <View style={styles.settingsContainer}>
          <View style={styles.settingRow}>
            <Text style={styles.settingLabel}>Athan Notifications</Text>
            <Switch
              value={athanEnabled}
              onValueChange={toggleAthan}
              trackColor={{false: '#ccc', true: '#e8f5e8'}}
              thumbColor={athanEnabled ? '#2e7d32' : '#fff'}
            />
          </View>

          <View style={styles.settingRow}>
            <Text style={styles.settingLabel}>Calculation Method</Text>
            <TouchableOpacity
              style={styles.methodButton}
              onPress={() => setShowLocationModal(true)}>
              <Text style={styles.methodText}>
                {calculationMethods.find(m => m.id === calculationMethod)?.name}
              </Text>
              <Icon name="arrow-drop-down" size={16} color="#2e7d32" />
            </TouchableOpacity>
          </View>
        </View>

        {loading ? (
          <View style={styles.loadingContainer}>
            <ActivityIndicator size="large" color="#2e7d32" />
            <Text style={styles.loadingText}>Loading prayer times...</Text>
          </View>
        ) : (
          renderPrayerTimes()
        )}
      </ScrollView>

      <View style={styles.footer}>
        <TouchableOpacity style={styles.refreshButton}>
          <Icon name="refresh" size={20} color="white" />
        </TouchableOpacity>
        <TouchableOpacity style={styles.calendarButton}>
          <Icon name="calendar-month" size={20} color="white" />
        </TouchableOpacity>
        <TouchableOpacity style={styles.qiblaButton}>
          <Icon name="explore" size={20} color="white" />
        </TouchableOpacity>
      </View>

      {renderLocationModal()}
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
    fontSize: 20,
    fontWeight: 'bold',
    color: 'white',
  },
  headerSubtitle: {
    fontSize: 14,
    color: '#e8f5e8',
  },
  locationButton: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  dateTimeContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    padding: 15,
    backgroundColor: 'white',
    borderBottomWidth: 1,
    borderBottomColor: '#e0e0e0',
  },
  currentTime: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#2e7d32',
  },
  currentDate: {
    fontSize: 16,
    color: '#666',
  },
  ramadanBadge: {
    backgroundColor: '#ff9800',
    paddingHorizontal: 10,
    paddingVertical: 5,
    borderRadius: 15,
  },
  ramadanText: {
    color: 'white',
    fontSize: 12,
    fontWeight: 'bold',
  },
  nextPrayerContainer: {
    backgroundColor: '#e8f5e8',
    padding: 20,
    alignItems: 'center',
    margin: 15,
    borderRadius: 10,
  },
  nextPrayerTitle: {
    fontSize: 14,
    color: '#666',
    marginBottom: 5,
  },
  nextPrayerName: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#2e7d32',
    marginBottom: 5,
  },
  nextPrayerTime: {
    fontSize: 32,
    fontWeight: 'bold',
    color: '#1b5e20',
  },
  timeRemaining: {
    fontSize: 14,
    color: '#666',
    marginTop: 5,
  },
  content: {
    flex: 1,
  },
  settingsContainer: {
    backgroundColor: 'white',
    margin: 15,
    padding: 15,
    borderRadius: 10,
    elevation: 2,
    shadowColor: '#000',
    shadowOffset: {width: 0, height: 1},
    shadowOpacity: 0.2,
    shadowRadius: 2,
  },
  settingRow: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    paddingVertical: 10,
    borderBottomWidth: 1,
    borderBottomColor: '#f0f0f0',
  },
  settingLabel: {
    fontSize: 16,
    color: '#333',
  },
  methodButton: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  methodText: {
    fontSize: 14,
    color: '#2e7d32',
    marginRight: 5,
  },
  prayerTimesContainer: {
    backgroundColor: 'white',
    margin: 15,
    borderRadius: 10,
    elevation: 2,
    shadowColor: '#000',
    shadowOffset: {width: 0, height: 1},
    shadowOpacity: 0.2,
    shadowRadius: 2,
  },
  timeRow: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    paddingVertical: 15,
    paddingHorizontal: 20,
    borderBottomWidth: 1,
    borderBottomColor: '#f0f0f0',
  },
  prayerNameContainer: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  prayerName: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#333',
    marginLeft: 10,
  },
  seharIftar: {
    fontSize: 12,
    color: '#ff9800',
    marginLeft: 5,
    fontWeight: 'bold',
  },
  prayerTime: {
    fontSize: 20,
    fontWeight: 'bold',
    color: '#666',
  },
  nextPrayerTime: {
    fontSize: 22,
    fontWeight: 'bold',
    color: '#2e7d32',
    backgroundColor: '#e8f5e8',
    paddingHorizontal: 15,
    paddingVertical: 8,
    borderRadius: 8,
  },
  nextPrayerText: {
    color: '#2e7d32',
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
  footer: {
    flexDirection: 'row',
    backgroundColor: '#2e7d32',
    paddingVertical: 15,
    justifyContent: 'space-around',
  },
  refreshButton: {
    width: 50,
    height: 50,
    borderRadius: 25,
    backgroundColor: 'rgba(255,255,255,0.1)',
    alignItems: 'center',
    justifyContent: 'center',
  },
  calendarButton: {
    width: 50,
    height: 50,
    borderRadius: 25,
    backgroundColor: 'rgba(255,255,255,0.1)',
    alignItems: 'center',
    justifyContent: 'center',
  },
  qiblaButton: {
    width: 50,
    height: 50,
    borderRadius: 25,
    backgroundColor: 'rgba(255,255,255,0.1)',
    alignItems: 'center',
    justifyContent: 'center',
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
  },
  modalTitle: {
    fontSize: 20,
    fontWeight: 'bold',
    color: '#333',
    textAlign: 'center',
    marginBottom: 20,
  },
  locationButton: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: '#2e7d32',
    padding: 15,
    borderRadius: 10,
    marginBottom: 15,
  },
  locationButtonText: {
    color: 'white',
    fontSize: 16,
    marginLeft: 10,
  },
  locationInfo: {
    fontSize: 14,
    color: '#666',
    textAlign: 'center',
    marginBottom: 15,
  },
  closeButton: {
    backgroundColor: '#2e7d32',
    padding: 15,
    borderRadius: 10,
    alignItems: 'center',
  },
  closeButtonText: {
    color: 'white',
    fontSize: 16,
    fontWeight: 'bold',
  },
});

export default PrayerTimesScreen;