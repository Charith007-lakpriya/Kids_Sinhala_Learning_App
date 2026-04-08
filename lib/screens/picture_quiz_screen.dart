import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../services/firestore_service.dart';
import '../services/session.dart';
import '../services/sound_service.dart';
import '../theme/app_theme.dart';
import '../widgets/auth_playful_widgets.dart';

class PictureQuizScreen extends StatelessWidget {
  static const routeName = '/games/picture-quiz';

  const PictureQuizScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _PictureQuizGame();
  }
}

class _PictureQuizGame extends StatefulWidget {
  const _PictureQuizGame();

  @override
  State<_PictureQuizGame> createState() => _PictureQuizGameState();
}

class _PictureQuizGameState extends State<_PictureQuizGame> {
  final math.Random _random = math.Random();

  late List<_QuizItem> _items;
  int _currentIndex = 0;
  int _score = 0;
  String? _feedback;
  bool _isLocked = false;
  bool _showStar = false;

  _QuizItem get _currentItem => _items[_currentIndex];

  @override
  void initState() {
    super.initState();
    _items = List<_QuizItem>.from(_quizItems)..shuffle(_random);
  }

  void _pick(String answer) {
    if (_isLocked) return;
    final current = _currentItem;

    if (answer == current.correctAnswer) {
      setState(() {
        _score += 1;
        _feedback = 'Good Job!';
        _isLocked = true;
        _showStar = true;
      });

      final userId = Session.currentUserId ?? 'demo';
      SoundService.playCorrect();
      FirestoreService.addStars(userId: userId, delta: 1);
      FirestoreService.addCorrectAnswer(userId: userId, delta: 1);
      FirestoreService.updateLevelForStars(userId: userId).then((leveled) {
        if (leveled) {
          SoundService.playLevelUp();
        }
      });
      FirestoreService.setLastPlayedWord(userId: userId, word: current.correctAnswer);

      Future.delayed(const Duration(milliseconds: 700), () {
        if (!mounted) return;
        setState(() => _showStar = false);
      });

      Future.delayed(const Duration(milliseconds: 900), () {
        if (!mounted) return;
        _nextQuestion();
      });
    } else {
      SoundService.playWrong();
      setState(() {
        _feedback = 'Try again';
      });
    }
  }

  void _nextQuestion() {
    setState(() {
      _feedback = null;
      _isLocked = false;
      _currentIndex = (_currentIndex + 1) % _items.length;
      if (_currentIndex == 0) {
        _items.shuffle(_random);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final current = _currentItem;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AuthSkyBackground(
        child: SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 20),
            child: Column(
              children: [
                const _QuizHeroCard(),
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
                    padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _SectionBadge(
                          label: 'Picture Quiz',
                          color: Color(0xFF4A79FF),
                        ),
                        const SizedBox(height: 10),
                        const Padding(
                          padding: EdgeInsets.only(left: 4),
                          child: Text(
                            'Look at the picture and choose the correct word',
                            style: TextStyle(
                              color: Color(0xFF6A6C88),
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _QuizStats(
                          score: _score,
                          feedback: _feedback,
                          questionNumber: _currentIndex + 1,
                          total: _items.length,
                        ),
                        const SizedBox(height: 16),
                        _PicturePromptCard(item: current),
                        const SizedBox(height: 16),
                        ...List.generate(
                          current.choices.length,
                          (index) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _AnswerButton(
                              label: current.choices[index],
                              colors: _answerColors[index % _answerColors.length],
                              onTap: () => _pick(current.choices[index]),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Center(
                          child: Text(
                            _isLocked ? 'Awesome! Next quiz is coming...' : 'Tap the correct word',
                            style: const TextStyle(
                              color: AppTheme.textMuted,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
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

class _QuizItem {
  final String picture;
  final String prompt;
  final String correctAnswer;
  final List<String> choices;

  const _QuizItem({
    required this.picture,
    required this.prompt,
    required this.correctAnswer,
    required this.choices,
  });
}

const List<_QuizItem> _quizItems = [
  _QuizItem(
    picture: '\u{1F418}',
    prompt: 'What do you see in the picture?',
    correctAnswer: '\u0D85\u0DBD\u0DD2\u0DBA\u0DCF',
    choices: [
      '\u0D85\u0DBD\u0DD2\u0DBA\u0DCF',
      '\u0DBB\u0DAE\u0DBA',
      '\u0D9C\u0DC3',
      '\u0DB8\u0DC4\u0DD4\u0DAF\u0DD4 \u0DB8\u0DCF\u0DBD\u0DD4\u0DC0\u0DCF',
    ],
  ),
  _QuizItem(
    picture: '\u{1F697}',
    prompt: 'Choose the correct word for this picture',
    correctAnswer: '\u0DBB\u0DAE\u0DBA',
    choices: [
      '\u0D9C\u0DC0\u0DBA\u0DCF',
      '\u0DBB\u0DAE\u0DBA',
      '\u0D9A\u0DD9\u0DC3\u0DD9\u0DBD\u0DCA',
      '\u0DB6\u0DBD\u0DCA\u0DBD\u0DCF',
    ],
  ),
  _QuizItem(
    picture: '\u{1F333}',
    prompt: 'Which word matches the picture?',
    correctAnswer: '\u0D9C\u0DC3',
    choices: [
      '\u0D9C\u0DC3',
      '\u0DB6\u0DD2\u0DBD\u0DCA\u0DBD\u0DCF',
      '\u0D9A\u0DD4\u0DBB\u0DD4\u0DBD\u0DCA\u0DBD\u0DCF',
      '\u0D85\u0DB9',
    ],
  ),
  _QuizItem(
    picture: '\u{1F404}',
    prompt: 'Look carefully and choose the answer',
    correctAnswer: '\u0D9C\u0DC0\u0DBA\u0DCF',
    choices: [
      '\u0D9C\u0DC0\u0DBA\u0DCF',
      '\u0D85\u0DBD\u0DD2\u0DBA\u0DCF',
      '\u0DB6\u0DC3\u0DCA \u0DBB\u0DAE\u0DBA',
      '\u0D87\u0DB4\u0DD2\u0DBD\u0DCA',
    ],
  ),
  _QuizItem(
    picture: '\u{1F41F}',
    prompt: 'Tap the correct word',
    correctAnswer: '\u0DB8\u0DC4\u0DD4\u0DAF\u0DD4 \u0DB8\u0DCF\u0DBD\u0DD4\u0DC0\u0DCF',
    choices: [
      '\u0DB8\u0DBD',
      '\u0DB8\u0DC4\u0DD4\u0DAF\u0DD4 \u0DB8\u0DCF\u0DBD\u0DD4\u0DC0\u0DCF',
      '\u0DB4\u0DDC\u0DAD',
      '\u0DB6\u0DBD\u0DCA\u0DBD\u0DCF',
    ],
  ),
  _QuizItem(
    picture: '\u{1F436}',
    prompt: 'What is this picture?',
    correctAnswer: '\u0DB6\u0DBD\u0DCA\u0DBD\u0DCF',
    choices: [
      '\u0DB8\u0DC4\u0DD4\u0DAF\u0DD4 \u0DB8\u0DCF\u0DBD\u0DD4\u0DC0\u0DCF',
      '\u0DB6\u0DBD\u0DCA\u0DBD\u0DCF',
      '\u0D9C\u0DC0\u0DBA\u0DCF',
      '\u0D9C\u0DC3',
    ],
  ),
  _QuizItem(
    picture: '\u{1F34C}',
    prompt: 'Find the matching word',
    correctAnswer: '\u0D9A\u0DD9\u0DC3\u0DD9\u0DBD\u0DCA',
    choices: [
      '\u0D85\u0DB9',
      '\u0D9A\u0DD9\u0DC3\u0DD9\u0DBD\u0DCA',
      '\u0DB6\u0DD2\u0DBD\u0DCA\u0DBD\u0DCF',
      '\u0DB6\u0DDD\u0DA7\u0DCA\u0DA7\u0DD4\u0DC0',
    ],
  ),
  _QuizItem(
    picture: '\u{1F431}',
    prompt: 'Choose the correct answer',
    correctAnswer: '\u0DB6\u0DD2\u0DBD\u0DCA\u0DBD\u0DCF',
    choices: [
      '\u0D9C\u0DC3',
      '\u0DBB\u0DAE\u0DBA',
      '\u0DB6\u0DD2\u0DBD\u0DCA\u0DBD\u0DCF',
      '\u0DB8\u0DC4\u0DD4\u0DAF\u0DD4 \u0DB8\u0DCF\u0DBD\u0DD4\u0DC0\u0DCF',
    ],
  ),
];


