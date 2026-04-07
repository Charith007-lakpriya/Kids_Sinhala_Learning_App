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

class _LoginForm extends StatefulWidget {
  const _LoginForm();

  @override
  State<_LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<_LoginForm> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    SoundService.playTap();
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final identifier = _usernameController.text.trim();
      final account = await FirestoreService.getAccountByIdentifier(identifier);
      if (account == null) {
        setState(() => _error = 'Account not found');
        return;
      }

      final storedPassword = (account['password'] ?? '').toString();
      if (storedPassword != _passwordController.text) {
        setState(() => _error = 'Incorrect password');
        return;
      }

      final resolvedId =
          (account['_id'] ?? account['usernameLower'] ?? identifier)
              .toString()
              .toLowerCase();
      Session.currentUserId = resolvedId;
      await SoundService.playBgm();

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, MainShell.routeName);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Expanded(
          flex: 4,
          child: Padding(
            padding: EdgeInsets.fromLTRB(24, 20, 24, 18),
            child: Center(
              child: SingleChildScrollView(
                child: AuthHeroCard(
                  title: 'වැලිපිල්ල',
                  subtitle: '',
                  badge: 'SIGN IN',
                ),
              ),
            ),
          ),
        ),
        Expanded(
          flex: 5,
          child: AuthPanel(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: Text(
                      'Sign In',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF183B74),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  AuthField(
                    label: 'Username or Email',
                    controller: _usernameController,
                    icon: Icons.person_rounded,
                  ),
                  const SizedBox(height: 14),
                  AuthField(
                    label: 'Password',
                    controller: _passwordController,
                    icon: Icons.lock_rounded,
                    obscureText: true,
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _error!,
                      style: const TextStyle(
                        color: Color(0xFFE64949),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: AuthPillButton(
                      onPressed: _isLoading ? null : _submit,
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Sign In',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: TextButton(
                      onPressed: () {
                        SoundService.playTap();
                        Navigator.pushReplacementNamed(
                          context,
                          SignUpScreen.routeName,
                        );
                      },
                      child: const Text.rich(
                        TextSpan(
                          text: 'New here? ',
                          style: TextStyle(
                            color: AppTheme.textMuted,
                            fontWeight: FontWeight.w600,
                          ),
                          children: [
                            TextSpan(
                              text: 'Create New Account',
                              style: TextStyle(
                                color: Color(0xFF1E7CF2),
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
