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

