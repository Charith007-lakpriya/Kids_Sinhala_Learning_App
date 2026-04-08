import 'package:flutter/material.dart';

import '../services/firestore_service.dart';
import '../services/session.dart';
import '../services/sound_service.dart';
import '../theme/app_theme.dart';
import '../widgets/auth_playful_widgets.dart';
import 'login_screen.dart';
import 'main_shell.dart';

class SignUpScreen extends StatelessWidget {
  static const routeName = '/signup';

  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: AuthSkyBackground(
        child: _SignUpForm(),
      ),
    );
  }
}

class _SignUpForm extends StatefulWidget {
  const _SignUpForm();

  @override
  State<_SignUpForm> createState() => _SignUpFormState();
}

