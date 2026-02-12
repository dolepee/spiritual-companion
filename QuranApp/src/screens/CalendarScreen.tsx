import React, {useState} from 'react';
import {
  View,
  Text,
  TouchableOpacity,
  StyleSheet,
  ScrollView,
  Dimensions,
} from 'react-native';
import Hijri from 'hijri';

const {width} = Dimensions.get('window');

const CalendarScreen = () => {
  const [currentDate, setCurrentDate] = useState(new Hijri());
  const [selectedDate, setSelectedDate] = useState<number | null>(null);

  const hijriMonths = [
    'محرم', 'صفر', 'ربيع الأول', 'ربيع الثاني', 'جمادى الأولى', 'جمادى الثانية',
    'رجب', 'شعبان', 'رمضان', 'شوال', 'ذو القعدة', 'ذو الحجة'
  ];

  const gregorianMonths = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  const getDaysInMonth = (hijriDate: Hijri) => {
    const days = [];
    const firstDay = new Hijri(hijriDate._year, hijriDate._month, 1);
    const lastDay = firstDay.daysInMonth();
    
    for (let i = 1; i <= lastDay; i++) {
      days.push(new Hijri(hijriDate._year, hijriDate._month, i));
    }
    
    return days;
  };

  const navigateMonth = (direction: 'prev' | 'next') => {
    const newDate = new Hijri(currentDate);
    if (direction === 'prev') {
      newDate._month--;
      if (newDate._month < 0) {
        newDate._month = 11;
        newDate._year--;
      }
    } else {
      newDate._month++;
      if (newDate._month > 11) {
        newDate._month = 0;
        newDate._year++;
      }
    }
    setCurrentDate(newDate);
    setSelectedDate(null);
  };

  const renderCalendarGrid = () => {
    const days = getDaysInMonth(currentDate);
    const firstDay = new Hijri(currentDate._year, currentDate._month, 1);
    const startDay = firstDay.day() || 7; // Sunday = 0, but we want Sunday = 7
    
    const grid = [];
    let week = [];

    // Add empty cells for days before month starts
    for (let i = 1; i < startDay; i++) {
      week.push(<View key={`empty-${i}`} style={styles.emptyDay} />);
    }

    // Add days of the month
    days.forEach((day, index) => {
      const isSelected = selectedDate === day._date;
      const isToday = day.isToday();
      
      week.push(
        <TouchableOpacity
          key={day._date}
          style={[
            styles.dayCell,
            isSelected && styles.selectedDay,
            isToday && styles.todayDay,
          ]}
          onPress={() => setSelectedDate(day._date)}>
          <Text style={[
            styles.dayText,
            isSelected && styles.selectedDayText,
            isToday && styles.todayDayText,
          ]}>
            {day._date}
          </Text>
          {isToday && <View style={styles.todayIndicator} />}
        </TouchableOpacity>
      );

      if (week.length === 7 || index === days.length - 1) {
        grid.push(
          <View key={`week-${Math.floor(index / 7)}`} style={styles.weekRow}>
            {week}
          </View>
        );
        week = [];
      }
    });

    return grid;
  };

  const getSelectedDateInfo = () => {
    if (!selectedDate) return null;
    
    const selectedHijri = new Hijri(currentDate._year, currentDate._month, selectedDate);
    const gregorian = selectedHijri.toGregorian();
    
    return {
      hijri: `${selectedHijri._date} ${hijriMonths[selectedHijri._month]} ${selectedHijri._year} AH`,
      gregorian: `${gregorian.getDate()} ${gregorianMonths[gregorian.getMonth()]} ${gregorian.getFullYear()} CE`,
    };
  };

  const selectedDateInfo = getSelectedDateInfo();

  return (
    <View style={styles.container}>
      <Text style={styles.headerTitle}>التقويم الهجري</Text>
      <Text style={styles.subtitle}>Hijri Calendar</Text>

      <View style={styles.currentDateContainer}>
        <Text style={styles.currentDate}>
          {currentDate._date} {hijriMonths[currentDate._month]} {currentDate._year} AH
        </Text>
        <Text style={styles.gregorianDate}>
          {new Date().toLocaleDateString('en-US', { 
            weekday: 'long', 
            year: 'numeric', 
            month: 'long', 
            day: 'numeric' 
          })}
        </Text>
      </View>

      <View style={styles.monthNavigation}>
        <TouchableOpacity
          style={styles.navButton}
          onPress={() => navigateMonth('prev')}>
          <Text style={styles.navButtonText}>←</Text>
        </TouchableOpacity>
        
        <Text style={styles.monthTitle}>
          {hijriMonths[currentDate._month]} {currentDate._year}
        </Text>
        
        <TouchableOpacity
          style={styles.navButton}
          onPress={() => navigateMonth('next')}>
          <Text style={styles.navButtonText}>→</Text>
        </TouchableOpacity>
      </View>

      <View style={styles.weekHeader}>
        {['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'].map(day => (
          <Text key={day} style={styles.weekHeaderText}>{day}</Text>
        ))}
      </View>

      <ScrollView style={styles.calendarContainer}>
        {renderCalendarGrid()}
      </ScrollView>

      {selectedDateInfo && (
        <View style={styles.selectedDateInfo}>
          <Text style={styles.selectedDateTitle}>Selected Date:</Text>
          <Text style={styles.selectedDateText}>{selectedDateInfo.hijri}</Text>
          <Text style={styles.selectedDateText}>{selectedDateInfo.gregorian}</Text>
        </View>
      )}

      <TouchableOpacity
        style={styles.todayButton}
        onPress={() => {
          const today = new Hijri();
          setCurrentDate(today);
          setSelectedDate(today._date);
        }}>
        <Text style={styles.todayButtonText}>Go to Today</Text>
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
  currentDateContainer: {
    backgroundColor: '#2e7d32',
    marginHorizontal: 20,
    padding: 15,
    borderRadius: 10,
    alignItems: 'center',
    marginBottom: 20,
  },
  currentDate: {
    fontSize: 20,
    fontWeight: 'bold',
    color: 'white',
    textAlign: 'center',
  },
  gregorianDate: {
    fontSize: 14,
    color: '#e8f5e8',
    marginTop: 5,
    textAlign: 'center',
  },
  monthNavigation: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    marginHorizontal: 20,
    marginBottom: 10,
  },
  navButton: {
    backgroundColor: '#2e7d32',
    width: 40,
    height: 40,
    borderRadius: 20,
    alignItems: 'center',
    justifyContent: 'center',
  },
  navButtonText: {
    color: 'white',
    fontSize: 18,
    fontWeight: 'bold',
  },
  monthTitle: {
    fontSize: 20,
    fontWeight: 'bold',
    color: '#333',
    textAlign: 'center',
  },
  weekHeader: {
    flexDirection: 'row',
    marginHorizontal: 20,
    marginBottom: 10,
  },
  weekHeaderText: {
    flex: 1,
    textAlign: 'center',
    fontSize: 12,
    fontWeight: 'bold',
    color: '#666',
  },
  calendarContainer: {
    flex: 1,
    marginHorizontal: 20,
  },
  weekRow: {
    flexDirection: 'row',
    marginBottom: 5,
  },
  dayCell: {
    flex: 1,
    aspectRatio: 1,
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: 'white',
    margin: 2,
    borderRadius: 8,
    elevation: 1,
    shadowColor: '#000',
    shadowOffset: {width: 0, height: 1},
    shadowOpacity: 0.1,
    shadowRadius: 1,
  },
  emptyDay: {
    flex: 1,
    margin: 2,
  },
  selectedDay: {
    backgroundColor: '#2e7d32',
  },
  todayDay: {
    backgroundColor: '#e8f5e8',
    borderColor: '#2e7d32',
    borderWidth: 2,
  },
  dayText: {
    fontSize: 14,
    fontWeight: 'bold',
    color: '#333',
  },
  selectedDayText: {
    color: 'white',
  },
  todayDayText: {
    color: '#2e7d32',
  },
  todayIndicator: {
    position: 'absolute',
    bottom: 2,
    width: 4,
    height: 4,
    backgroundColor: '#2e7d32',
    borderRadius: 2,
  },
  selectedDateInfo: {
    backgroundColor: 'white',
    margin: 20,
    padding: 15,
    borderRadius: 10,
    elevation: 2,
    shadowColor: '#000',
    shadowOffset: {width: 0, height: 1},
    shadowOpacity: 0.2,
    shadowRadius: 2,
  },
  selectedDateTitle: {
    fontSize: 16,
    fontWeight: 'bold',
    color: '#333',
    marginBottom: 8,
  },
  selectedDateText: {
    fontSize: 14,
    color: '#666',
    marginBottom: 4,
  },
  todayButton: {
    backgroundColor: '#2e7d32',
    margin: 20,
    padding: 15,
    borderRadius: 10,
    alignItems: 'center',
  },
  todayButtonText: {
    color: 'white',
    fontSize: 16,
    fontWeight: 'bold',
  },
});

export default CalendarScreen;