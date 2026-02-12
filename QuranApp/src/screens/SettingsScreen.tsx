import React, {useState, useEffect} from 'react';
import {
  View,
  Text,
  TouchableOpacity,
  StyleSheet,
  Switch,
  Alert,
  ScrollView,
} from 'react-native';
import {NotificationService} from '../utils/NotificationService';

const SettingsScreen = () => {
  const [fridayReminderEnabled, setFridayReminderEnabled] = useState(false);
  const [permissionsGranted, setPermissionsGranted] = useState(false);
  const notificationService = NotificationService.getInstance();

  useEffect(() => {
    initializeSettings();
  }, []);

  const initializeSettings = async () => {
    try {
      // Initialize notification service
      notificationService.initialize();

      // Check current settings
      const isEnabled = await notificationService.isFridayReminderEnabled();
      setFridayReminderEnabled(isEnabled);

      // Check permissions
      const hasPermissions = await notificationService.checkPermissions();
      setPermissionsGranted(hasPermissions);
    } catch (error) {
      console.error('Error initializing settings:', error);
    }
  };

  const handleFridayReminderToggle = async (enabled: boolean) => {
    try {
      if (enabled) {
        // Request permissions if not granted
        if (!permissionsGranted) {
          const granted = await notificationService.requestPermissions();
          if (!granted) {
            Alert.alert(
              'Permissions Required',
              'Please enable notification permissions to use Friday reminders.',
              [{text: 'OK'}]
            );
            return;
          }
          setPermissionsGranted(true);
        }

        const success = await notificationService.enableFridayReminders();
        if (success) {
          setFridayReminderEnabled(true);
          Alert.alert(
            'Friday Reminders Enabled',
            'You will receive reminders every Friday morning at 8 AM to:\n\n• Perform Ghusul\n• Read Surah Al-Kahf\n• Send Salawat upon the Prophet (ﷺ)',
            [{text: 'OK'}]
          );
        } else {
          Alert.alert('Error', 'Failed to enable Friday reminders.');
        }
      } else {
        const success = await notificationService.disableFridayReminders();
        if (success) {
          setFridayReminderEnabled(false);
          Alert.alert('Friday Reminders Disabled', 'You will no longer receive Friday reminders.');
        } else {
          Alert.alert('Error', 'Failed to disable Friday reminders.');
        }
      }
    } catch (error) {
      console.error('Error toggling Friday reminders:', error);
      Alert.alert('Error', 'An error occurred while updating settings.');
    }
  };

  const sendTestNotification = () => {
    if (!permissionsGranted) {
      Alert.alert(
        'Permissions Required',
        'Please enable notification permissions first.',
        [{text: 'OK'}]
      );
      return;
    }

    notificationService.sendTestNotification();
    Alert.alert('Test Sent', 'A test notification has been sent.');
  };

  return (
    <View style={styles.container}>
      <Text style={styles.headerTitle}>Settings</Text>
      <Text style={styles.subtitle}>App Configuration</Text>

      <ScrollView style={styles.settingsContainer}>
        <View style={styles.section}>
          <Text style={styles.sectionTitle}>Notifications</Text>
          
          <View style={styles.settingItem}>
            <View style={styles.settingInfo}>
              <Text style={styles.settingTitle}>Friday Reminders</Text>
              <Text style={styles.settingDescription}>
                Receive weekly reminders every Friday morning for Islamic practices
              </Text>
            </View>
            <Switch
              value={fridayReminderEnabled}
              onValueChange={handleFridayReminderToggle}
              trackColor={{false: '#ccc', true: '#e8f5e8'}}
              thumbColor={fridayReminderEnabled ? '#2e7d32' : '#fff'}
            />
          </View>

          {permissionsGranted && (
            <View style={styles.settingItem}>
              <View style={styles.settingInfo}>
                <Text style={styles.settingTitle}>Test Notification</Text>
                <Text style={styles.settingDescription}>
                  Send a test notification to verify everything is working
                </Text>
              </View>
              <TouchableOpacity
                style={styles.testButton}
                onPress={sendTestNotification}>
                <Text style={styles.testButtonText}>Test</Text>
              </TouchableOpacity>
            </View>
          )}

          {!permissionsGranted && (
            <View style={styles.permissionWarning}>
              <Text style={styles.warningTitle}>⚠️ Permissions Required</Text>
              <Text style={styles.warningText}>
                Notification permissions are required to use reminder features.
              </Text>
              <TouchableOpacity
                style={styles.enableButton}
                onPress={async () => {
                  const granted = await notificationService.requestPermissions();
                  setPermissionsGranted(granted);
                }}>
                <Text style={styles.enableButtonText}>Enable Permissions</Text>
              </TouchableOpacity>
            </View>
          )}
        </View>

        <View style={styles.section}>
          <Text style={styles.sectionTitle}>About Friday Reminders</Text>
          <View style={styles.infoBox}>
            <Text style={styles.infoTitle}>What you'll be reminded about:</Text>
            <Text style={styles.infoItem}>🚿 Perform Ghusul (ritual bathing)</Text>
            <Text style={styles.infoItem}>📖 Read Surah Al-Kahf</Text>
            <Text style={styles.infoItem}>🤲 Send Salawat upon the Prophet (ﷺ)</Text>
            <Text style={styles.infoItem}>🕌 Prepare for Jumu'ah prayer</Text>
          </View>
        </View>

        <View style={styles.section}>
          <Text style={styles.sectionTitle}>App Info</Text>
          <View style={styles.infoItem}>
            <Text style={styles.infoLabel}>Version:</Text>
            <Text style={styles.infoValue}>1.0.0</Text>
          </View>
          <View style={styles.infoItem}>
            <Text style={styles.infoLabel}>Developer:</Text>
            <Text style={styles.infoValue}>Quran App Team</Text>
          </View>
        </View>
      </ScrollView>
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
  },
  subtitle: {
    fontSize: 18,
    color: '#666',
    textAlign: 'center',
    marginBottom: 20,
  },
  settingsContainer: {
    flex: 1,
    paddingHorizontal: 20,
  },
  section: {
    marginBottom: 30,
  },
  sectionTitle: {
    fontSize: 20,
    fontWeight: 'bold',
    color: '#333',
    marginBottom: 15,
  },
  settingItem: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    backgroundColor: 'white',
    padding: 15,
    borderRadius: 10,
    marginBottom: 10,
    elevation: 2,
    shadowColor: '#000',
    shadowOffset: {width: 0, height: 1},
    shadowOpacity: 0.2,
    shadowRadius: 2,
  },
  settingInfo: {
    flex: 1,
    marginRight: 15,
  },
  settingTitle: {
    fontSize: 16,
    fontWeight: 'bold',
    color: '#333',
    marginBottom: 5,
  },
  settingDescription: {
    fontSize: 14,
    color: '#666',
    lineHeight: 20,
  },
  testButton: {
    backgroundColor: '#2e7d32',
    paddingHorizontal: 15,
    paddingVertical: 8,
    borderRadius: 5,
  },
  testButtonText: {
    color: 'white',
    fontSize: 14,
    fontWeight: 'bold',
  },
  permissionWarning: {
    backgroundColor: '#fff3cd',
    borderColor: '#ffc107',
    borderWidth: 1,
    padding: 15,
    borderRadius: 10,
    marginBottom: 10,
  },
  warningTitle: {
    fontSize: 16,
    fontWeight: 'bold',
    color: '#856404',
    marginBottom: 8,
  },
  warningText: {
    fontSize: 14,
    color: '#856404',
    marginBottom: 10,
  },
  enableButton: {
    backgroundColor: '#ffc107',
    padding: 10,
    borderRadius: 5,
    alignItems: 'center',
  },
  enableButtonText: {
    color: '#000',
    fontSize: 14,
    fontWeight: 'bold',
  },
  infoBox: {
    backgroundColor: 'white',
    padding: 15,
    borderRadius: 10,
    elevation: 2,
    shadowColor: '#000',
    shadowOffset: {width: 0, height: 1},
    shadowOpacity: 0.2,
    shadowRadius: 2,
  },
  infoTitle: {
    fontSize: 16,
    fontWeight: 'bold',
    color: '#333',
    marginBottom: 10,
  },
  infoItem: {
    fontSize: 14,
    color: '#666',
    marginBottom: 5,
    lineHeight: 20,
  },
  infoLabel: {
    fontSize: 14,
    color: '#666',
    fontWeight: 'bold',
  },
  infoValue: {
    fontSize: 14,
    color: '#333',
  },
});

export default SettingsScreen;