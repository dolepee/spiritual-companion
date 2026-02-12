import PushNotification from 'react-native-push-notification';
import AsyncStorage from '@react-native-async-storage/async-storage';
import {PrayerTimes} from '../types';

export class PrayerTimesService {
  private static instance: PrayerTimesService;
  private PRAYER_TIMES_KEY = 'prayer_times_settings';
  private ATHAN_ENABLED_KEY = 'athan_enabled';

  static getInstance(): PrayerTimesService {
    if (!PrayerTimesService.instance) {
      PrayerTimesService.instance = new PrayerTimesService();
    }
    return PrayerTimesService.instance;
  }

  // Calculate prayer times for given location and date
  calculatePrayerTimes(
    latitude: number,
    longitude: number,
    date: Date,
    calculationMethod: string = 'MuslimWorldLeague'
  ): PrayerTimes {
    // This is a simplified calculation - in production, use a proper prayer times library
    const dayOfYear = this.getDayOfYear(date);
    const declination = this.calculateDeclination(dayOfYear);
    const equationOfTime = this.calculateEquationOfTime(dayOfYear);
    
    // Calculate prayer times (simplified)
    const fajr = this.calculateTime(5, latitude, longitude, declination, equationOfTime);
    const sunrise = this.calculateTime(6, latitude, longitude, declination, equationOfTime);
    const dhuhr = this.calculateTime(12, latitude, longitude, declination, equationOfTime);
    const asr = this.calculateTime(15, latitude, longitude, declination, equationOfTime);
    const maghrib = this.calculateTime(18, latitude, longitude, declination, equationOfTime);
    const isha = this.calculateTime(20, latitude, longitude, declination, equationOfTime);

    return {
      fajr: this.formatTime(fajr),
      sunrise: this.formatTime(sunrise),
      dhuhr: this.formatTime(dhuhr),
      asr: this.formatTime(asr),
      maghrib: this.formatTime(maghrib),
      isha: this.formatTime(isha),
      date: date.toISOString().split('T')[0],
      location: `${latitude.toFixed(4)}, ${longitude.toFixed(4)}`,
    };
  }

  // Schedule Athan notifications for all prayers
  async scheduleAthanNotifications(
    prayerTimes: PrayerTimes,
    location: string
  ): Promise<void> {
    try {
      const isAthanEnabled = await AsyncStorage.getItem(this.ATHAN_ENABLED_KEY);
      if (isAthanEnabled !== 'true') {
        return;
      }

      // Cancel existing notifications
      PushNotification.cancelLocalNotifications({id: 'athan-fajr'});
      PushNotification.cancelLocalNotifications({id: 'athan-dhuhr'});
      PushNotification.cancelLocalNotifications({id: 'athan-asr'});
      PushNotification.cancelLocalNotifications({id: 'athan-maghrib'});
      PushNotification.cancelLocalNotifications({id: 'athan-isha'});

      const today = new Date();
      const prayers = [
        { name: 'Fajr', time: prayerTimes.fajr, id: 'athan-fajr' },
        { name: 'Dhuhr', time: prayerTimes.dhuhr, id: 'athan-dhuhr' },
        { name: 'Asr', time: prayerTimes.asr, id: 'athan-asr' },
        { name: 'Maghrib', time: prayerTimes.maghrib, id: 'athan-maghrib' },
        { name: 'Isha', time: prayerTimes.isha, id: 'athan-isha' },
      ];

      prayers.forEach(prayer => {
        const [hours, minutes] = prayer.time.split(':').map(Number);
        const notificationTime = new Date(today);
        notificationTime.setHours(hours, minutes, 0, 0);

        // Only schedule if time is in the future
        if (notificationTime > new Date()) {
          PushNotification.localNotificationSchedule({
            id: prayer.id,
            channelId: 'athan-notifications',
            title: `🕌 Athan - ${prayer.name} Prayer`,
            message: `It's time for ${prayer.name} prayer in ${location}`,
            playSound: true,
            soundName: 'athan.mp3',
            date: notificationTime,
            allowWhileIdle: true,
            actions: ['Dismiss', 'Snooze'],
          });
        }
      });

      console.log('Athan notifications scheduled for:', prayerTimes);
    } catch (error) {
      console.error('Error scheduling Athan notifications:', error);
    }
  }

  // Enable/disable Athan notifications
  async setAthanEnabled(enabled: boolean): Promise<void> {
    try {
      await AsyncStorage.setItem(this.ATHAN_ENABLED_KEY, enabled.toString());
      if (!enabled) {
        // Cancel all Athan notifications
        const prayerIds = ['athan-fajr', 'athan-dhuhr', 'athan-asr', 'athan-maghrib', 'athan-isha'];
        prayerIds.forEach(id => {
          PushNotification.cancelLocalNotifications({id});
        });
      }
    } catch (error) {
      console.error('Error setting Athan enabled:', error);
    }
  }

  // Check if Athan is enabled
  async isAthanEnabled(): Promise<boolean> {
    try {
      const enabled = await AsyncStorage.getItem(this.ATHAN_ENABLED_KEY);
      return enabled === 'true';
    } catch (error) {
      console.error('Error checking Athan enabled:', error);
      return false;
    }
  }

  // Get next prayer time
  getNextPrayer(prayerTimes: PrayerTimes): { name: string; time: string; minutesUntil: number } | null {
    const now = new Date();
    const currentMinutes = now.getHours() * 60 + now.getMinutes();
    
    const prayers = [
      { name: 'Fajr', time: prayerTimes.fajr },
      { name: 'Dhuhr', time: prayerTimes.dhuhr },
      { name: 'Asr', time: prayerTimes.asr },
      { name: 'Maghrib', time: prayerTimes.maghrib },
      { name: 'Isha', time: prayerTimes.isha },
    ];

    for (const prayer of prayers) {
      const [hours, minutes] = prayer.time.split(':').map(Number);
      const prayerMinutes = hours * 60 + minutes;
      
      if (prayerMinutes > currentMinutes) {
        return {
          name: prayer.name,
          time: prayer.time,
          minutesUntil: prayerMinutes - currentMinutes,
        };
      }
    }

    // If all prayers have passed, return tomorrow's Fajr
    const [fajrHours, fajrMinutes] = prayerTimes.fajr.split(':').map(Number);
    const fajrMinutes = fajrHours * 60 + fajrMinutes;
    return {
      name: 'Fajr (Tomorrow)',
      time: prayerTimes.fajr,
      minutesUntil: (24 * 60) - currentMinutes + fajrMinutes,
    };
  }

  // Get Ramadan times (Sehar and Iftar)
  getRamadanTimes(latitude: number, longitude: number, date: Date): PrayerTimes {
    const prayerTimes = this.calculatePrayerTimes(latitude, longitude, date);
    
    // During Ramadan, Sehar is 10 minutes before Fajr, Iftar is at Maghrib
    const [fajrHours, fajrMinutes] = prayerTimes.fajr.split(':').map(Number);
    const seharMinutes = fajrHours * 60 + fajrMinutes - 10;
    const seharHours = Math.floor(seharMinutes / 60);
    const seharMins = seharMinutes % 60;

    return {
      ...prayerTimes,
      fajr: this.formatTime(seharHours, seharMins), // Sehar time
      maghrib: prayerTimes.maghrib, // Iftar time
    };
  }

  // Helper methods for prayer times calculation
  private getDayOfYear(date: Date): number {
    const start = new Date(date.getFullYear(), 0, 0);
    const diff = date.getTime() - start.getTime();
    const oneDay = 1000 * 60 * 60 * 24;
    return Math.floor(diff / oneDay);
  }

  private calculateDeclination(dayOfYear: number): number {
    return 23.45 * Math.sin((360 * (284 + dayOfYear) / 365) * Math.PI / 180);
  }

  private calculateEquationOfTime(dayOfYear: number): number {
    return -0.128 * Math.sin((360 * (dayOfYear - 2) / 365) * Math.PI / 180);
  }

  private calculateTime(
    baseHour: number,
    latitude: number,
    longitude: number,
    declination: number,
    equationOfTime: number
  ): number {
    // Simplified calculation - in production, use proper astronomical calculations
    const timezone = Math.round(longitude / 15);
    const solarTime = baseHour + timezone + equationOfTime / 60;
    
    // Adjust for latitude and declination
    const latitudeRad = latitude * Math.PI / 180;
    const declinationRad = declination * Math.PI / 180;
    const hourAngle = Math.acos(-Math.tan(latitudeRad) * Math.tan(declinationRad)) * 180 / Math.PI;
    
    return solarTime + (hourAngle / 15);
  }

  private formatTime(hours: number, minutes: number = 0): string {
    const h = Math.round(hours) % 24;
    const m = Math.round(minutes);
    return `${String(h).padStart(2, '0')}:${String(m).padStart(2, '0')}`;
  }

  // Initialize Athan notification channel
  initializeAthanChannel() {
    PushNotification.createChannel({
      channelId: 'athan-notifications',
      channelName: 'Athan Notifications',
      channelDescription: 'Prayer time notifications with Athan',
      playSound: true,
      soundName: 'athan.mp3',
      importance: 5,
      vibrate: true,
    });
  }
}