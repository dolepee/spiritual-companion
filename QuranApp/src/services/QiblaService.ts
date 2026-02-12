import {LocationObject} from 'expo-location';
import Geolocation from '@react-native-community/geolocation';

export class QiblaService {
  private static instance: QiblaService;
  
  // Kaaba coordinates (Mecca)
  private readonly KAABA_LATITUDE = 21.4225;
  private readonly KAABA_LONGITUDE = 39.8262;

  static getInstance(): QiblaService {
    if (!QiblaService.instance) {
      QiblaService.instance = new QiblaService();
    }
    return QiblaService.instance;
  }

  // Calculate Qibla direction from current location
  calculateQiblaDirection(latitude: number, longitude: number): number {
    const lat1 = latitude * Math.PI / 180;
    const lat2 = this.KAABA_LATITUDE * Math.PI / 180;
    const longDiff = (this.KAABA_LONGITUDE - longitude) * Math.PI / 180;

    const x = Math.sin(longDiff) * Math.cos(lat2);
    const y = Math.cos(lat1) * Math.sin(lat2) - 
              Math.sin(lat1) * Math.cos(lat2) * Math.cos(longDiff);

    let qibla = Math.atan2(x, y) * 180 / Math.PI;
    qibla = (qibla + 360) % 360; // Normalize to 0-360 degrees

    return qibla;
  }

  // Get current device location
  async getCurrentLocation(): Promise<{latitude: number; longitude: number; accuracy: number}> {
    return new Promise((resolve, reject) => {
      Geolocation.getCurrentPosition(
        (position) => {
          resolve({
            latitude: position.coords.latitude,
            longitude: position.coords.longitude,
            accuracy: position.coords.accuracy || 0,
          });
        },
        (error) => {
          reject(error);
        },
        {
          enableHighAccuracy: true,
          timeout: 15000,
          maximumAge: 10000,
        }
      );
    });
  }

  // Calculate distance to Kaaba
  calculateDistanceToKaaba(latitude: number, longitude: number): number {
    const R = 6371; // Earth's radius in kilometers
    const lat1 = latitude * Math.PI / 180;
    const lat2 = this.KAABA_LATITUDE * Math.PI / 180;
    const latDiff = (this.KAABA_LATITUDE - latitude) * Math.PI / 180;
    const longDiff = (this.KAABA_LONGITUDE - longitude) * Math.PI / 180;

    const a = Math.sin(latDiff / 2) * Math.sin(latDiff / 2) +
              Math.cos(lat1) * Math.cos(lat2) *
              Math.sin(longDiff / 2) * Math.sin(longDiff / 2);
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));

    return R * c;
  }

  // Get compass bearing from device magnetometer
  async getCompassHeading(): Promise<number> {
    return new Promise((resolve, reject) => {
      // This would require device magnetometer access
      // For now, returning a simulated value
      resolve(0);
    });
  }

  // Check if location services are enabled
  async isLocationEnabled(): Promise<boolean> {
    return new Promise((resolve) => {
      Geolocation.requestAuthorization(
        () => resolve(true),
        () => resolve(false)
      );
    });
  }

  // Request location permissions
  async requestLocationPermission(): Promise<boolean> {
    return new Promise((resolve) => {
      Geolocation.requestAuthorization(
        () => resolve(true),
        () => resolve(false)
      );
    });
  }

  // Get Qibla direction with compass correction
  async getQiblaWithCompass(): Promise<{
    qiblaDirection: number;
    compassHeading: number;
    relativeDirection: number;
    distance: number;
  }> {
    try {
      const location = await this.getCurrentLocation();
      const qiblaDirection = this.calculateQiblaDirection(location.latitude, location.longitude);
      const compassHeading = await this.getCompassHeading();
      const distance = this.calculateDistanceToKaaba(location.latitude, location.longitude);
      
      // Calculate relative direction (where user should face)
      let relativeDirection = qiblaDirection - compassHeading;
      relativeDirection = (relativeDirection + 360) % 360;

      return {
        qiblaDirection,
        compassHeading,
        relativeDirection,
        distance,
      };
    } catch (error) {
      throw new Error(`Failed to get Qibla direction: ${error}`);
    }
  }

  // Get nearby masjids (would integrate with Places API)
  async getNearbyMasjids(latitude: number, longitude: number, radius: number = 5000): Promise<any[]> {
    // This would integrate with Google Places API or similar
    // For demo, returning empty array
    return [];
  }

  // Get Islamic prayer direction info
  getIslamicDirectionInfo(latitude: number, longitude: number) {
    const qiblaDirection = this.calculateQiblaDirection(latitude, longitude);
    const distance = this.calculateDistanceToKaaba(latitude, longitude);
    
    return {
      qiblaDirection: Math.round(qiblaDirection),
      distance: Math.round(distance),
      kaabaCoordinates: {
        latitude: this.KAABA_LATITUDE,
        longitude: this.KAABA_LONGITUDE,
      },
      currentCoordinates: {
        latitude,
        longitude,
      },
      directionDescription: this.getDirectionDescription(qiblaDirection),
    };
  }

  // Get human-readable direction description
  private getDirectionDescription(degrees: number): string {
    const directions = [
      'North', 'North-Northeast', 'Northeast', 'East-Northeast',
      'East', 'East-Southeast', 'Southeast', 'South-Southeast',
      'South', 'South-Southwest', 'Southwest', 'West-Southwest',
      'West', 'West-Northwest', 'Northwest', 'North-Northwest'
    ];
    
    const index = Math.round(degrees / 22.5) % 16;
    return directions[index];
  }

  // Check if user is facing Qibla (with tolerance)
  isFacingQibla(compassHeading: number, qiblaDirection: number, tolerance: number = 15): boolean {
    const diff = Math.abs(compassHeading - qiblaDirection);
    return diff <= tolerance || diff >= (360 - tolerance);
  }

  // Get Qibla arrow angle for UI display
  getQiblaArrowAngle(compassHeading: number, qiblaDirection: number): number {
    return qiblaDirection - compassHeading;
  }
}