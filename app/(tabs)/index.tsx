import { Image, StyleSheet, Platform,   View,
  NativeModules,
  Button, } from 'react-native';

import { HelloWave } from '@/components/HelloWave';
import ParallaxScrollView from '@/components/ParallaxScrollView';
import { ThemedText } from '@/components/ThemedText';
import { ThemedView } from '@/components/ThemedView';
import MapView from '../../MapView.js'

export default function HomeScreen() {
  return (
    <View style={{flex: 1}}>
    <View style={{height: 100, backgroundColor:"blue"}}/>
    <MapView style={{ flex: 1}}/>
    <View style={{height: 100, backgroundColor:"blue"}}/>
</View>
  );
}

const styles = StyleSheet.create({
  titleContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 8,
  },
  stepContainer: {
    gap: 8,
    marginBottom: 8,
  },
  reactLogo: {
    height: 178,
    width: 290,
    bottom: 0,
    left: 0,
    position: 'absolute',
  },
});
