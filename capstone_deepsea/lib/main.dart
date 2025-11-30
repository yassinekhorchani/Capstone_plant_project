import 'package:capstone_deepsea/screens/intro_screen.dart';
import 'package:capstone_deepsea/screens/onboarding_screen.dart';
import 'package:capstone_deepsea/screens/treatment_prevention_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/splash_screen.dart';
import 'screens/realtime_detection_screen.dart';
import 'screens/about_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const DeepSeaApp());
}

class DeepSeaApp extends StatelessWidget {
  const DeepSeaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DeepSea Plant Doctor',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.green,
      ),
      home: SplashScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/home': (context) => const IntroScreen(),
        '/treatment_prevention': (context) => const TreatmentPreventionScreen(),
        '/about': (context) => const AboutScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/realtime-detect': (context) => const RealtimeDetectionScreen(),
      },
    );
  }
}
