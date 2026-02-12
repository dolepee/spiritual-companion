import Sound from 'react-native-sound';
import {AudioReciter} from '../types';

Sound.setCategory('Playback');

export class AudioService {
  private static instance: AudioService;
  private currentSound: Sound | null = null;
  private currentReciter: AudioReciter | null = null;
  private isPlaying: boolean = false;
  private currentSurah: number = 0;
  private listeners: Set<(isPlaying: boolean) => void> = new Set();

  static getInstance(): AudioService {
    if (!AudioService.instance) {
      AudioService.instance = new AudioService();
    }
    return AudioService.instance;
  }

  // Play audio for specific surah and reciter
  async playAudio(surah: number, reciter: AudioReciter): Promise<boolean> {
    try {
      // Stop current audio if playing
      if (this.currentSound) {
        await this.stopAudio();
      }

      const audioUrl = this.getAudioUrl(surah, reciter.id);
      
      return new Promise((resolve) => {
        const sound = new Sound(audioUrl, '', (error) => {
          if (error) {
            console.error('Failed to load sound', error);
            resolve(false);
            return;
          }

          this.currentSound = sound;
          this.currentReciter = reciter;
          this.currentSurah = surah;
          this.isPlaying = true;
          this.notifyListeners();

          sound.play((success) => {
            if (!success) {
              console.error('Playback failed');
            }
            this.isPlaying = false;
            this.notifyListeners();
          });

          resolve(true);
        });
      });
    } catch (error) {
      console.error('Error playing audio:', error);
      return false;
    }
  }

  // Pause current audio
  async pauseAudio(): Promise<void> {
    if (this.currentSound && this.isPlaying) {
      this.currentSound.pause();
      this.isPlaying = false;
      this.notifyListeners();
    }
  }

  // Resume current audio
  async resumeAudio(): Promise<void> {
    if (this.currentSound && !this.isPlaying) {
      this.currentSound.play();
      this.isPlaying = true;
      this.notifyListeners();
    }
  }

  // Stop current audio
  async stopAudio(): Promise<void> {
    if (this.currentSound) {
      this.currentSound.stop();
      this.currentSound.release();
      this.currentSound = null;
      this.currentReciter = null;
      this.currentSurah = 0;
      this.isPlaying = false;
      this.notifyListeners();
    }
  }

  // Seek to specific position (in seconds)
  async seekTo(position: number): Promise<void> {
    if (this.currentSound) {
      this.currentSound.setCurrentTime(position);
    }
  }

  // Get current position (in seconds)
  async getCurrentPosition(): Promise<number> {
    return new Promise((resolve) => {
      if (this.currentSound) {
        this.currentSound.getCurrentTime((seconds) => {
          resolve(seconds);
        });
      } else {
        resolve(0);
      }
    });
  }

  // Get audio duration (in seconds)
  async getDuration(): Promise<number> {
    return new Promise((resolve) => {
      if (this.currentSound) {
        this.currentSound.getDuration((seconds) => {
          resolve(seconds);
        });
      } else {
        resolve(0);
      }
    });
  }

  // Set playback speed (if supported)
  async setPlaybackSpeed(speed: number): Promise<void> {
    // This would require additional audio library support
    console.log(`Setting playback speed to ${speed}x`);
  }

  // Enable repetition
  async setRepetition(count: number): Promise<void> {
    // This would require custom audio handling
    console.log(`Setting repetition to ${count} times`);
  }

  // Get audio URL for surah and reciter
  private getAudioUrl(surah: number, reciterId: number): string {
    const baseUrl = 'https://audio.quran.com/arabic';
    const reciters: {[key: number]: string} = {
      1: 'abdul-basit',
      2: 'mishari-rashid',
      3: 'saad-ghamdi',
      4: 'abu-bakr-shatry',
      5: 'ahmed-ajmi',
      6: 'al-huzaifi',
      7: 'mahir-muayqali',
      8: 'minshawi',
      9: 'ayub',
      10: 'husari',
    };

    const reciterName = reciters[reciterId] || 'abdul-basit';
    return `${baseUrl}/${reciterName}/${String(surah).padStart(3, '0')}.mp3`;
  }

  // Get current playback state
  getPlaybackState() {
    return {
      isPlaying: this.isPlaying,
      currentSurah: this.currentSurah,
      currentReciter: this.currentReciter,
    };
  }

  // Add listener for playback state changes
  addListener(listener: (isPlaying: boolean) => void) {
    this.listeners.add(listener);
  }

  // Remove listener
  removeListener(listener: (isPlaying: boolean) => void) {
    this.listeners.delete(listener);
  }

  // Notify all listeners
  private notifyListeners() {
    this.listeners.forEach(listener => listener(this.isPlaying));
  }

  // Cleanup
  cleanup() {
    this.stopAudio();
    this.listeners.clear();
  }
}

// Audio controls component helper
export const useAudioPlayer = () => {
  const audioService = AudioService.getInstance();
  
  return {
    playAudio: audioService.playAudio.bind(audioService),
    pauseAudio: audioService.pauseAudio.bind(audioService),
    resumeAudio: audioService.resumeAudio.bind(audioService),
    stopAudio: audioService.stopAudio.bind(audioService),
    seekTo: audioService.seekTo.bind(audioService),
    getCurrentPosition: audioService.getCurrentPosition.bind(audioService),
    getDuration: audioService.getDuration.bind(audioService),
    getPlaybackState: audioService.getPlaybackState.bind(audioService),
    addListener: audioService.addListener.bind(audioService),
    removeListener: audioService.removeListener.bind(audioService),
  };
};