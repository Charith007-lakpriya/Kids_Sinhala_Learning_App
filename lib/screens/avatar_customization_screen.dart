import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AvatarCustomizationScreen extends StatelessWidget {
  static const routeName = '/avatar';

  const AvatarCustomizationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _SimpleScreen(
      title: 'Avatar',
      subtitle: 'Member-owned screen',
      icon: Icons.face_retouching_natural,
    );
  }
}

class _SimpleScreen extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _SimpleScreen({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 72, color: AppTheme.primary),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: const TextStyle(color: AppTheme.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}
