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
 @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AuthSkyBackground(
        child: SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 20),
            child: Column(
              children: [
                const _TracingHeroCard(),
                const SizedBox(height: 18),
                AuthPanel(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xFFFFFEFF),
                          Color(0xFFF4FBFF),
                          Color(0xFFFFF8EC),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(28),
                    ),
                    padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _SectionBadge(
                          label: 'Letter Tracing',
                          color: Color(0xFFF28B18),
                        ),
                        const SizedBox(height: 10),
                        const Padding(
                          padding: EdgeInsets.only(left: 4),
                          child: Text(
                            'Trace the dotted Sinhala letter with your finger',
                            style: TextStyle(
                              color: Color(0xFF6A6C88),
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _TracingStats(letter: _currentLetter),
                        const SizedBox(height: 16),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final boardSize = Size(
                              constraints.maxWidth,
                              constraints.maxWidth,
                            );
                            return Container(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Color(0xFFFFF2D8),
                                    Color(0xFFFFFBF3),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x14000000),
                                    blurRadius: 16,
                                    offset: Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(18, 18, 18, 8),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 14,
                                            vertical: 8,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF28B18),
                                            borderRadius:
                                                BorderRadius.circular(999),
                                          ),
                                          child: Text(
                                            _currentLetter,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 28,
                                              fontWeight: FontWeight.w900,
                                            ),
                                          ),
                                        ),
                                        const Spacer(),
                                        TextButton(
                                          onPressed: _clearTrace,
                                          child: const Text(
                                            'Clear',
                                            style: TextStyle(
                                              color: Color(0xFFF28B18),
                                              fontWeight: FontWeight.w900,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
                                    child: AspectRatio(
                                      aspectRatio: 1,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(26),
                                        child: GestureDetector(
                                          onPanStart: (details) {
                                            setState(() {
                                              _points.add(details.localPosition);
                                            });
                                          },
                                          onPanUpdate: (details) {
                                            setState(() {
                                              _points.add(details.localPosition);
                                            });
                                          },
                                          onPanEnd: (_) {
                                            setState(() => _points.add(null));
                                            _handleTraceEnd(boardSize);
                                          },
                                          child: CustomPaint(
                                            painter: _TracingBoardPainter(
                                              letter: _currentLetter,
                                              points: _points,
                                              completed: _completed,
                                            ),
                                            child: const SizedBox.expand(),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
