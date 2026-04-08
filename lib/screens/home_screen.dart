import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../services/session.dart';
import '../theme/app_theme.dart';
import '../widgets/app_card.dart';
import '../widgets/auth_playful_widgets.dart';

LinearGradient _gradientForType(String type) {
  switch (type) {
    case 'match':
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF67C76A), Color(0xFF3CA86A)],
      );
    case 'trace':
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFFFC93C), Color(0xFFFF9F1C)],
      );
    case 'quiz':
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF3E8CFF), Color(0xFF2757D7)],
      );
    case 'sound':
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFFF7B7B), Color(0xFFFF5B8A)],
      );
    default:
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF5BC0FF), Color(0xFF2B7BFF)],
      );
  }
}

Color _accentForType(String type) {
  switch (type) {
    case 'match':
      return const Color(0xFF2F8F54);
    case 'trace':
      return const Color(0xFFF28B18);
    case 'quiz':
      return const Color(0xFF234CC7);
    case 'sound':
      return const Color(0xFFE54C6B);
    default:
      return const Color(0xFF1E7CF2);
  }
}

Color _softColorForType(String type) {
  switch (type) {
    case 'match':
      return const Color(0xFFEAF8E8);
    case 'trace':
      return const Color(0xFFFFF2D8);
    case 'quiz':
      return const Color(0xFFEAF0FF);
    case 'sound':
      return const Color(0xFFFFEBF2);
    default:
      return const Color(0xFFEAF6FF);
  }
}

String _emojiForType(String type) {
  switch (type) {
    case 'match':
      return '🧩';
    case 'trace':
      return '✏️';
    case 'quiz':
      return '🚀';
    case 'sound':
      return '🎵';
    default:
      return '🎮';
  }
}

String _routeForType(String type) {
  switch (type) {
    case 'match':
      return '/games/match-words';
    case 'trace':
      return '/games/letter-tracing';
    case 'quiz':
      return '/games/picture-quiz';
    case 'sound':
      return '/games/sound-recognition';
    default:
      return '/games/match-words';
  }
}

class _GameCardData {
  final String title;
  final String description;
  final String icon;
  final String type;
  final Gradient gradient;
  final String route;
  final Color accent;
  final Color softColor;

  const _GameCardData({
    required this.title,
    required this.description,
    required this.icon,
    required this.type,
    required this.gradient,
    required this.route,
    required this.accent,
    required this.softColor,
  });
}
