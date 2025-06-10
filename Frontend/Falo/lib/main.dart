// lib/main.dart
import 'package:anewdehli12/OnboardingScreen/Onboarding_screen.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import provider

// Adjust package name if needed
import 'package:anewdehli12/screens/chat_screen.dart';
import 'theme_notifier.dart'; // Import the notifier

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    // Wrap the entire app with ChangeNotifierProvider
    ChangeNotifierProvider(
      create: (_) => ThemeNotifier(),
      // Create the notifier instance
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Consume the ThemeNotifier to get the current theme
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return MaterialApp(
      title: 'Misinformation Detector',
      debugShowCheckedModeBanner: false,
      // Set the theme directly based on the notifier's currentTheme getter
      theme: themeNotifier.currentTheme,
      // We don't need darkTheme or themeMode here anymore,
      // as currentTheme handles the logic based on preference and system.
      initialRoute: '/on',
      routes: {
        '/on':(context)=>OnboardingScreen()
      },
      home: const ChatScreen(),
    );
  }
}