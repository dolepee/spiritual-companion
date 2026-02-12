import {Platform} from 'react-native';
import PushNotification from 'react-native-push-notification';
import AsyncStorage from '@react-native-async-storage/async-storage';

export class NotificationService {
  private static instance: NotificationService;
  private FRIDAY_REMINDER_KEY = 'friday_reminder_enabled';

  static getInstance(): NotificationService {
    if (!NotificationService.instance) {
      NotificationService.instance = new NotificationService();
    }
    return NotificationService.instance;
  }

  initialize() {
    PushNotification.configure({
      onNotification: function(notification) {
        console.log('NOTIFICATION:', notification);
      },
      requestPermissions: Platform.OS === 'ios',
    });

    PushNotification.createChannel(
      {
        channelId: 'friday-reminders',
        channelName: 'Friday Reminders',
        channelDescription: 'Reminders for Friday prayers and Islamic practices',
        playSound: true,
        soundName: 'default',
        importance: 4,
        vibrate: true,
      },
      (created) => console.log(`Channel created: ${created}`)
    );
  }

  async scheduleFridayReminders() {
    try {
      const isEnabled = await AsyncStorage.getItem(this.FRIDAY_REMINDER_KEY);
      if (isEnabled !== 'true') {
        return;
      }

      // Cancel existing Friday reminders
      PushNotification.cancelLocalNotifications({id: 'friday-morning'});

      // Schedule new Friday morning reminder (8 AM)
      const nextFriday = this.getNextFriday();
      const reminderDate = new Date(nextFriday);
      reminderDate.setHours(8, 0, 0, 0);

      PushNotification.localNotificationSchedule({
        id: 'friday-morning',
        channelId: 'friday-reminders',
        title: 'Friday Reminder - جمعة مباركة',
        message: '🕌 Remember to perform Ghusul, read Surah Al-Kahf, and send Salawat upon the Prophet (ﷺ)',
        date: reminderDate,
        repeatType: 'week',
        allowWhileIdle: true,
        actions: ['Dismiss', 'View Adhkar'],
      });

      console.log('Friday reminders scheduled for:', reminderDate);
    } catch (error) {
      console.error('Error scheduling Friday reminders:', error);
    }
  }

  async enableFridayReminders() {
    try {
      await AsyncStorage.setItem(this.FRIDAY_REMINDER_KEY, 'true');
      await this.scheduleFridayReminders();
      return true;
    } catch (error) {
      console.error('Error enabling Friday reminders:', error);
      return false;
    }
  }

  async disableFridayReminders() {
    try {
      await AsyncStorage.setItem(this.FRIDAY_REMINDER_KEY, 'false');
      PushNotification.cancelLocalNotifications({id: 'friday-morning'});
      return true;
    } catch (error) {
      console.error('Error disabling Friday reminders:', error);
      return false;
    }
  }

  async isFridayReminderEnabled(): Promise<boolean> {
    try {
      const isEnabled = await AsyncStorage.getItem(this.FRIDAY_REMINDER_KEY);
      return isEnabled === 'true';
    } catch (error) {
      console.error('Error checking Friday reminder status:', error);
      return false;
    }
  }

  private getNextFriday(): Date {
    const today = new Date();
    const dayOfWeek = today.getDay(); // Sunday = 0, Friday = 5
    const daysUntilFriday = (5 - dayOfWeek + 7) % 7 || 7; // If today is Friday, schedule for next Friday
    
    const nextFriday = new Date(today);
    nextFriday.setDate(today.getDate() + daysUntilFriday);
    return nextFriday;
  }

  async checkPermissions(): Promise<boolean> {
    return new Promise((resolve) => {
      PushNotification.checkPermissions((permissions) => {
        resolve(permissions.alert || permissions.badge || permissions.sound);
      });
    });
  }

  async requestPermissions(): Promise<boolean> {
    return new Promise((resolve) => {
      PushNotification.requestPermissions((permissions) => {
        resolve(permissions.alert || permissions.badge || permissions.sound);
      });
    });
  }

  sendTestNotification() {
    PushNotification.localNotification({
      channelId: 'friday-reminders',
      title: 'Test Notification',
      message: 'This is a test notification from Quran App',
      allowWhileIdle: true,
    });
  }
}