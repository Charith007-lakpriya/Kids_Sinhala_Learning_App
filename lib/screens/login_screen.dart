import 'package:flutter/material.dart';

import '../services/firestore_service.dart';
import '../services/session.dart';
import '../services/sound_service.dart';
import '../theme/app_theme.dart';
import '../widgets/auth_playful_widgets.dart';
import 'main_shell.dart';
import 'sign_up_screen.dart';

class LoginScreen extends StatelessWidget {
  static const routeName = '/login';

  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: AuthSkyBackground(
        child: _LoginForm(),
      ),
    );
  }
}

