import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'games_screen.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'rewards_screen.dart';
import 'settings_screen.dart';
import '../services/sound_service.dart';

class MainShell extends StatefulWidget {
  static const routeName = '/app';

  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}
