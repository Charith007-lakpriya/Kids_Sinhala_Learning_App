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

class _SignUpFormState extends State<_SignUpForm> {
  final _usernameController = TextEditingController();
  final _parentEmailController = TextEditingController();
  final _passwordController = TextEditingController();

  double _age = 12;
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _usernameController.dispose();
    _parentEmailController.dispose();
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
      final userId = _usernameController.text.trim().toLowerCase();
      await FirestoreService.createAccount(
        userId: userId,
        username: _usernameController.text.trim(),
        parentEmail: _parentEmailController.text.trim(),
        password: _passwordController.text,
      );
      await FirestoreService.seedSampleData(userId: userId);
      await FirestoreService.updateUserProfile(
        userId: userId,
        name: _usernameController.text.trim(),
        email: _parentEmailController.text.trim(),
        parentEmail: _parentEmailController.text.trim(),
        age: _age.toInt(),
      );
      Session.currentUserId = userId;

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, MainShell.routeName);
    } catch (e) {
      setState(() => _error = e.toString());
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
                  badge: 'SIGN UP',
                ),
              ),
            ),
          ),
        ),
        Expanded(
          flex: 6,
          child: AuthPanel(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: Text(
                      'Create New Account',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF183B74),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  AuthField(
                    label: 'Username',
                    controller: _usernameController,
                    icon: Icons.face_rounded,
                  ),
                  const SizedBox(height: 14),
                  AuthField(
                    label: 'Parent Email',
                    controller: _parentEmailController,
                    icon: Icons.email_rounded,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 14),
                  AuthField(
                    label: 'Password',
                    controller: _passwordController,
                    icon: Icons.lock_rounded,
                    obscureText: true,
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4F8FF),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.cake_rounded,
                              color: Color(0xFF1E7CF2),
                            ),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: Text(
                                'Age',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF183B74),
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                _age.toInt().toString(),
                                style: const TextStyle(
                                  color: Color(0xFF1E7CF2),
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Slider(
                          value: _age,
                          min: 5,
                          max: 18,
                          divisions: 13,
                          label: _age.toInt().toString(),
                          onChanged: (value) => setState(() => _age = value),
                        ),
                      ],
                    ),
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
                              'Create New Account',
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
                          LoginScreen.routeName,
                        );
                      },
                      child: const Text.rich(
                        TextSpan(
                          text: 'Already have an account? ',
                          style: TextStyle(
                            color: AppTheme.textMuted,
                            fontWeight: FontWeight.w600,
                          ),
                          children: [
                            TextSpan(
                              text: 'Sign In',
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
