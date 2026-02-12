import React, {useState} from 'react';
import {
  View,
  Text,
  TouchableOpacity,
  StyleSheet,
  ScrollView,
  Alert,
} from 'react-native';
import {morningAdhkar, eveningAdhkar} from '../data/adhkarData';
import {Adhkar} from '../types';

const AdhkarScreen = () => {
  const [activeTab, setActiveTab] = useState<'morning' | 'evening'>('morning');
  const [completedCount, setCompletedCount] = useState<{[key: number]: number}>({});

  const currentAdhkar = activeTab === 'morning' ? morningAdhkar : eveningAdhkar;

  const handleAdhkarPress = (adhkar: Adhkar) => {
    const currentCount = completedCount[adhkar.id] || 0;
    
    if (currentCount < adhkar.count) {
      setCompletedCount(prev => ({
        ...prev,
        [adhkar.id]: currentCount + 1,
      }));
    }
    
    if (currentCount + 1 === adhkar.count) {
      Alert.alert('Completed!', `You have completed this dhikr: ${adhkar.text.substring(0, 30)}...`);
    }
  };

  const resetProgress = () => {
    setCompletedCount({});
    Alert.alert('Progress Reset', 'All progress has been reset.');
  };

  const renderAdhkarItem = (adhkar: Adhkar) => {
    const currentCount = completedCount[adhkar.id] || 0;
    const isCompleted = currentCount >= adhkar.count;
    const progress = (currentCount / adhkar.count) * 100;

    return (
      <TouchableOpacity
        key={adhkar.id}
        style={[styles.adhkarItem, isCompleted && styles.completedItem]}
        onPress={() => handleAdhkarPress(adhkar)}
        disabled={isCompleted}>
        <View style={styles.adhkarHeader}>
          <Text style={styles.adhkarText}>{adhkar.text}</Text>
          <Text style={styles.adhkarTranslation}>{adhkar.translation}</Text>
        </View>
        <View style={styles.progressContainer}>
          <View style={styles.progressBar}>
            <View style={[styles.progressFill, {width: `${progress}%`}]} />
          </View>
          <Text style={styles.countText}>
            {currentCount}/{adhkar.count}
          </Text>
        </View>
        {isCompleted && (
          <Text style={styles.completedText}>✓ Completed</Text>
        )}
      </TouchableOpacity>
    );
  };

  return (
    <View style={styles.container}>
      <Text style={styles.headerTitle}>أذكار المسلم</Text>
      <Text style={styles.subtitle}>Daily Remembrances</Text>
      
      <View style={styles.tabContainer}>
        <TouchableOpacity
          style={[styles.tab, activeTab === 'morning' && styles.activeTab]}
          onPress={() => setActiveTab('morning')}>
          <Text style={[styles.tabText, activeTab === 'morning' && styles.activeTabText]}>
            Morning Adhkar
          </Text>
        </TouchableOpacity>
        <TouchableOpacity
          style={[styles.tab, activeTab === 'evening' && styles.activeTab]}
          onPress={() => setActiveTab('evening')}>
          <Text style={[styles.tabText, activeTab === 'evening' && styles.activeTabText]}>
            Evening Adhkar
          </Text>
        </TouchableOpacity>
      </View>

      <ScrollView style={styles.adhkarList}>
        {currentAdhkar.map(renderAdhkarItem)}
      </ScrollView>

      <TouchableOpacity style={styles.resetButton} onPress={resetProgress}>
        <Text style={styles.resetButtonText}>Reset Progress</Text>
      </TouchableOpacity>
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
  tabContainer: {
    flexDirection: 'row',
    marginHorizontal: 20,
    marginBottom: 20,
    backgroundColor: '#e8f5e8',
    borderRadius: 10,
    padding: 4,
  },
  tab: {
    flex: 1,
    paddingVertical: 12,
    borderRadius: 8,
    alignItems: 'center',
  },
  activeTab: {
    backgroundColor: '#2e7d32',
  },
  tabText: {
    fontSize: 16,
    color: '#666',
    fontWeight: '600',
  },
  activeTabText: {
    color: 'white',
  },
  adhkarList: {
    flex: 1,
    paddingHorizontal: 20,
  },
  adhkarItem: {
    backgroundColor: 'white',
    marginVertical: 8,
    padding: 15,
    borderRadius: 10,
    elevation: 2,
    shadowColor: '#000',
    shadowOffset: {width: 0, height: 1},
    shadowOpacity: 0.2,
    shadowRadius: 2,
  },
  completedItem: {
    backgroundColor: '#e8f5e8',
    borderColor: '#2e7d32',
    borderWidth: 1,
  },
  adhkarHeader: {
    marginBottom: 10,
  },
  adhkarText: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#333',
    textAlign: 'right',
    marginBottom: 8,
    lineHeight: 28,
  },
  adhkarTranslation: {
    fontSize: 14,
    color: '#666',
    lineHeight: 20,
  },
  progressContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    marginTop: 10,
  },
  progressBar: {
    flex: 1,
    height: 8,
    backgroundColor: '#e0e0e0',
    borderRadius: 4,
    marginRight: 10,
  },
  progressFill: {
    height: '100%',
    backgroundColor: '#2e7d32',
    borderRadius: 4,
  },
  countText: {
    fontSize: 14,
    color: '#666',
    fontWeight: 'bold',
    minWidth: 50,
    textAlign: 'right',
  },
  completedText: {
    fontSize: 14,
    color: '#2e7d32',
    fontWeight: 'bold',
    textAlign: 'center',
    marginTop: 8,
  },
  resetButton: {
    backgroundColor: '#d32f2f',
    margin: 20,
    padding: 15,
    borderRadius: 10,
    alignItems: 'center',
  },
  resetButtonText: {
    color: 'white',
    fontSize: 16,
    fontWeight: 'bold',
  },
});

export default AdhkarScreen;