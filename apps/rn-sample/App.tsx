import React from 'react';
import { StatusBar, StyleSheet, View, Text } from 'react-native';
import { SafeAreaProvider, SafeAreaView } from 'react-native-safe-area-context';
import { SduiView } from 'react-native-sdui';

const mockSduiData = JSON.stringify(
  {
    "type": "column",
    "style": {
      "width": "match_parent",
      "backgroundColor": "#F5F7FA",
      "padding": { "top": 40, "left": 16, "right": 16, "bottom": 40 }
    },
    "children": [
      {
        "type": "text",
        "text": "SDUI Unified Layout",
        "fontSize": 28,
        "color": "#1A1A1A",
        "style": { "margin": { "bottom": 8 } }
      },
      {
        "type": "text",
        "text": "Build once, render beautifully on Android, iOS, and Web.",
        "fontSize": 16,
        "color": "#666666",
        "style": { "align": "center", "margin": { "bottom": 32 } }
      },
      {
        "type": "row",
        "style": {
          "width": "match_parent",
          "arrangement": "space-between",
          "margin": { "bottom": 32 }
        },
        "children": [
          {
            "type": "button",
            "label": "Home",
            "action": "go_home"
          },
          {
            "type": "button",
            "label": "Profile",
            "action": "go_profile"
          },
          {
            "type": "button",
            "label": "Settings",
            "action": "go_settings"
          }
        ]
      },
      {
        "type": "column",
        "style": {
          "width": "match_parent",
          "backgroundColor": "#FFFFFF",
          "round": "16",
          "padding": { "top": 24, "bottom": 24, "left": 20, "right": 20 }
        },
        "children": [
          {
            "type": "text",
            "text": "Beautiful Containers",
            "fontSize": 20,
            "color": "#1A1A1A",
            "style": { "margin": { "bottom": 12 } }
          },
          {
            "type": "text",
            "text": "Containers support padding, margin, exact or responsive dimensions, layout arrangements, scaling, and rounded corners natively in the framework.",
            "fontSize": 16,
            "color": "#444444"
          }
        ]
      }
    ]
  }
);

function App() {
  return (
    <SduiView
      json={mockSduiData}
      style={styles.sduiView}
    />
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#ffffffff',
  },
  header: {
    padding: 20,
    backgroundColor: '#FFFFFF',
    borderBottomWidth: 1,
    borderBottomColor: '#EEEEEE',
  },
  title: {
    fontSize: 20,
    fontWeight: 'bold',
    color: '#1A1A1A',
  },
  sduiView: {
    flex: 1,
  },
});

export default App;
