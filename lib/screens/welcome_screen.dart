import 'package:flutter/material.dart';

import '../services/sound_service.dart';
import '../widgets/auth_playful_widgets.dart';
import 'login_screen.dart';
import 'sign_up_screen.dart';

class WelcomeScreen extends StatelessWidget {
  static const routeName = '/';

  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AuthSkyBackground(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
          child: Column(
            children: [
              const Spacer(flex: 2),
              const AuthHeroCard(
                title: 'වැලිපිල්ල',
                subtitle: 'Learn Sinhala in fun way',
                badge: 'APP',
              ),
              const SizedBox(height: 28),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: AuthPillButton(
                        color: const Color(0xFFFF8A34),
                        onPressed: () {
                          SoundService.playTap();
                          Navigator.pushNamed(context, SignUpScreen.routeName);
                        },
                        child: const Text(
                          'Create New Account',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: AuthOutlineButton(
                        onPressed: () {
                          SoundService.playTap();
                          Navigator.pushNamed(context, LoginScreen.routeName);
                        },
                        child: const Text(
                          'Sign In',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
