import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'screens/avatar_customization_screen.dart';
import 'screens/games_screen.dart';
import 'screens/home_screen.dart';
import 'screens/main_shell.dart';
import 'screens/letter_tracing_screen.dart';
import 'screens/login_screen.dart';
import 'screens/match_words_screen.dart';
import 'screens/picture_quiz_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/rewards_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/sign_up_screen.dart';
import 'screens/sound_recognition_screen.dart';
import 'screens/welcome_screen.dart';
import 'theme/app_theme.dart';
import 'services/sound_service.dart';
import 'services/firestore_service.dart';
import 'services/session.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await SoundService.init();
  await FirestoreService.seedMatchWordsIfEmpty();
  runApp(const ValiPillaApp());
}

class ValiPillaApp extends StatefulWidget {
  const ValiPillaApp({super.key});

  @override
  State<ValiPillaApp> createState() => _ValiPillaAppState();
}

class _ValiPillaAppState extends State<ValiPillaApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed &&
        Session.currentUserId != null &&
        !SoundService.muted) {
      SoundService.playBgm();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Valipilla',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      initialRoute: WelcomeScreen.routeName,
      routes: {
        WelcomeScreen.routeName: (_) => const WelcomeScreen(),
        HomeScreen.routeName: (_) => const HomeScreen(),
        MainShell.routeName: (_) => const MainShell(),
        LoginScreen.routeName: (_) => const LoginScreen(),
        SignUpScreen.routeName: (_) => const SignUpScreen(),
        GamesScreen.routeName: (_) => const GamesScreen(),
        RewardsScreen.routeName: (_) => const RewardsScreen(),
        ProfileScreen.routeName: (_) => const ProfileScreen(),
        AvatarCustomizationScreen.routeName: (_) =>
            const AvatarCustomizationScreen(),
        SettingsScreen.routeName: (_) => const SettingsScreen(),
        MatchWordsScreen.routeName: (_) => const MatchWordsScreen(),
        LetterTracingScreen.routeName: (_) => const LetterTracingScreen(),
        PictureQuizScreen.routeName: (_) => const PictureQuizScreen(),
        SoundRecognitionScreen.routeName: (_) =>
            const SoundRecognitionScreen(),
      },
    );
  }
}
