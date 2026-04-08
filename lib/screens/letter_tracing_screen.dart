import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../services/firestore_service.dart';
import '../services/session.dart';
import '../services/sound_service.dart';
import '../theme/app_theme.dart';
import '../widgets/auth_playful_widgets.dart';

class LetterTracingScreen extends StatefulWidget {
  static const routeName = '/games/letter-tracing';

  const LetterTracingScreen({super.key});

  @override
  State<LetterTracingScreen> createState() => _LetterTracingScreenState();
}

class _LetterTracingScreenState extends State<LetterTracingScreen> {
  static const List<String> _letters = [
    '\u0D85',
    '\u0D86',
    '\u0D8B',
    '\u0D89',
    '\u0D9C',
    '\u0DA9',
    '\u0DAF',
    '\u0DBD',
    '\u0DB8',
    '\u0D9A',
    '\u0DB4',
    '\u0DBA',
    '\u0DBB',
    '\u0DB6',
    '\u0DB1',
    '\u0DC0',
    '\u0D8A',
  ];

  final math.Random _random = math.Random();
  final List<Offset?> _points = [];
  late List<String> _shuffledLetters;
  int _currentIndex = 0;
  bool _completed = false;
  bool _busy = false;

  String get _currentLetter => _shuffledLetters[_currentIndex];

  @override
  void initState() {
    super.initState();
    _shuffledLetters = List<String>.from(_letters)..shuffle(_random);
  }
 void _clearTrace() {
    setState(() {
      _points.clear();
      _completed = false;
    });
  }

  void _nextLetter() {
    setState(() {
      _points.clear();
      _completed = false;
      _currentIndex = (_currentIndex + 1) % _shuffledLetters.length;
      if (_currentIndex == 0) {
        _shuffledLetters.shuffle(_random);
      }
    });
  }
 Future<void> _handleTraceEnd(Size size) async {
    if (_busy || _completed) return;
    final tracedPoints = _points.whereType<Offset>().toList();
    if (tracedPoints.length < 18) return;

    final xs = tracedPoints.map((p) => p.dx).toList();
    final ys = tracedPoints.map((p) => p.dy).toList();
    final width = xs.reduce(math.max) - xs.reduce(math.min);
    final height = ys.reduce(math.max) - ys.reduce(math.min);

    double pathLength = 0;
    for (var i = 1; i < _points.length; i++) {
      final a = _points[i - 1];
      final b = _points[i];
      if (a != null && b != null) {
        pathLength += (b - a).distance;
      }
    }

    final tracedEnough =
        width > size.width * 0.18 &&
        height > size.height * 0.18 &&
        pathLength > size.width * 0.55;

    if (!tracedEnough) return;

    setState(() {
      _completed = true;
      _busy = true;
    });
SoundService.playCorrect();
    final userId = Session.currentUserId;
    if (userId != null) {
      await FirestoreService.addStars(userId: userId, delta: 1);
      await FirestoreService.addCorrectAnswer(userId: userId, delta: 1);
      final leveled = await FirestoreService.updateLevelForStars(userId: userId);
      if (leveled) {
        SoundService.playLevelUp();
      }
      await FirestoreService.setLastPlayedWord(userId: userId, word: _currentLetter);
    }

    if (!mounted) return;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text(
            'Good Job!',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: Color(0xFF183B74),
            ),
          ),
          content: Text(
            'You traced $_currentLetter correctly and earned 1 star.',
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Next Letter',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        );
      },
    );

    if (!mounted) return;
    _nextLetter();
    setState(() => _busy = false);
  }
