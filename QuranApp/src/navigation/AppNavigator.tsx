import React from 'react';
import {NavigationContainer} from '@react-navigation/native';
import {createBottomTabNavigator} from '@react-navigation/bottom-tabs';
import Icon from 'react-native-vector-icons/MaterialIcons';

import EnhancedQuranScreen from '../screens/EnhancedQuranScreen';
import AdhkarScreen from '../screens/AdhkarScreen';
import CalendarScreen from '../screens/CalendarScreen';
import SettingsScreen from '../screens/SettingsScreen';
import TafsirScreen from '../screens/TafsirScreen';
import PrayerTimesScreen from '../screens/PrayerTimesScreen';
import QiblaScreen from '../screens/QiblaScreen';
import MemorizationScreen from '../screens/MemorizationScreen';
import AllahNamesScreen from '../screens/AllahNamesScreen';
import ZakatScreen from '../screens/ZakatScreen';
import PlaylistsScreen from '../screens/PlaylistsScreen';
import MasjidsScreen from '../screens/MasjidsScreen';

const Tab = createBottomTabNavigator();

const AppNavigator = () => {
  return (
    <NavigationContainer>
      <Tab.Navigator
        screenOptions={({route}) => ({
          tabBarIcon: ({focused, color, size}) => {
            let iconName: string;

            if (route.name === 'Quran') {
              iconName = 'book';
            } else if (route.name === 'Adhkar') {
              iconName = 'favorite';
            } else if (route.name === 'Calendar') {
              iconName = 'event';
            } else if (route.name === 'Settings') {
              iconName = 'settings';
            } else if (route.name === 'Tafsir') {
              iconName = 'menu-book';
            } else if (route.name === 'PrayerTimes') {
              iconName = 'schedule';
            } else if (route.name === 'Qibla') {
              iconName = 'explore';
            } else if (route.name === 'Memorization') {
              iconName = 'school';
            } else if (route.name === 'AllahNames') {
              iconName = 'stars';
            } else if (route.name === 'Zakat') {
              iconName = 'account-balance-wallet';
            } else if (route.name === 'Playlists') {
              iconName = 'playlist-play';
            } else if (route.name === 'Masjids') {
              iconName = 'mosque';
            } else {
              iconName = 'help';
            }

            return <Icon name={iconName} size={size} color={color} />;
          },
          tabBarActiveTintColor: '#2e7d32',
          tabBarInactiveTintColor: 'gray',
          headerStyle: {
            backgroundColor: '#2e7d32',
          },
          headerTintColor: '#fff',
          tabBarStyle: {
            backgroundColor: '#fff',
            elevation: 8,
            shadowColor: '#000',
            shadowOffset: {width: 0, height: -2},
            shadowOpacity: 0.1,
            shadowRadius: 4,
          },
        })}>
        <Tab.Screen
          name="Quran"
          component={EnhancedQuranScreen}
          options={{title: 'القرآن'}}
        />
        <Tab.Screen
          name="Adhkar"
          component={AdhkarScreen}
          options={{title: 'أذكار'}}
        />
        <Tab.Screen
          name="Calendar"
          component={CalendarScreen}
          options={{title: 'التقويم'}}
        />
        <Tab.Screen
          name="Tafsir"
          component={TafsirScreen}
          options={{title: 'تفسير'}}
        />
        <Tab.Screen
          name="PrayerTimes"
          component={PrayerTimesScreen}
          options={{title: 'مواقيت'}}
        />
        <Tab.Screen
          name="Qibla"
          component={QiblaScreen}
          options={{title: 'القبلة'}}
        />
        <Tab.Screen
          name="Memorization"
          component={MemorizationScreen}
          options={{title: 'حفظ'}}
        />
        <Tab.Screen
          name="AllahNames"
          component={AllahNamesScreen}
          options={{title: 'أسماء الله'}}
        />
        <Tab.Screen
          name="Zakat"
          component={ZakatScreen}
          options={{title: 'زكاة'}}
        />
        <Tab.Screen
          name="Playlists"
          component={PlaylistsScreen}
          options={{title: 'قوائم'}}
        />
        <Tab.Screen
          name="Masjids"
          component={MasjidsScreen}
          options={{title: 'مساجد'}}
        />
        <Tab.Screen
          name="Settings"
          component={SettingsScreen}
          options={{title: 'اعدادات'}}
        />
      </Tab.Navigator>
    </NavigationContainer>
  );
};

export default AppNavigator;