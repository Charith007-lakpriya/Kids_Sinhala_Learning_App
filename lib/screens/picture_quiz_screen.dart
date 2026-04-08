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

class _QuizHeroCard extends StatelessWidget {
  const _QuizHeroCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 24, 22, 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(34),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF588BFF),
            Color(0xFF355CF3),
            Color(0xFF3A38C8),
          ],
        ),
        border: Border.all(color: Colors.white.withOpacity(0.72), width: 2.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x24000000),
            blurRadius: 20,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -12,
            right: -8,
            child: Container(
              width: 94,
              height: 94,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.14),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            right: 4,
            bottom: -2,
            child: Image.asset(
              'assets/icons/games/picture quiz icon.png',
              width: 104,
              height: 104,
              fit: BoxFit.contain,
            ),
          ),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Picture Quiz!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 6),
              SizedBox(
                width: 215,
                child: Text(
                  'Look carefully, choose the best word, and win a star',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _SectionBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.96, end: 1),
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          alignment: Alignment.centerLeft,
          child: child,
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(999),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.28),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _QuizStats extends StatelessWidget {
  final int score;
  final String? feedback;
  final int questionNumber;
  final int total;

  const _QuizStats({
    required this.score,
    required this.feedback,
    required this.questionNumber,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final message = feedback ?? 'Keep going';
    final messageColor = feedback == 'Good Job!'
        ? const Color(0xFF25A85C)
        : feedback == 'Try again'
            ? const Color(0xFFE46E40)
            : const Color(0xFF3A5A8F);

    return Row(
      children: [
        Expanded(
          child: _StatTile(
            color: const Color(0xFFEAF7FF),
            borderColor: const Color(0xFF9FD2FF),
            title: 'Score',
            value: '$score',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatTile(
            color: const Color(0xFFFFF3D8),
            borderColor: const Color(0xFFFFD470),
            title: 'Quiz',
            value: '$questionNumber/$total',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF8EEFF),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFD8B4FF), width: 1.4),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Status',
                  style: TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  message,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: messageColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  final Color color;
  final Color borderColor;
  final String title;
  final String value;

  const _StatTile({
    required this.color,
    required this.borderColor,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1.4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppTheme.textMuted,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF183B74),
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _PicturePromptCard extends StatelessWidget {
  final _QuizItem item;

  const _PicturePromptCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFF3D8),
            Color(0xFFFFFBF3),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFFFD884), width: 1.6),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF355CF3),
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Text(
              'Which Word Is Correct?',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            item.picture,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 92, height: 1),
          ),
          const SizedBox(height: 14),
          Text(
            item.prompt,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF183B74),
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _AnswerButton extends StatelessWidget {
  final String label;
  final List<Color> colors;
  final VoidCallback onTap;

  const _AnswerButton({
    required this.label,
    required this.colors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: colors,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [
              BoxShadow(
                color: Color(0x18000000),
                blurRadius: 16,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.22),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.touch_app_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
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

const List<List<Color>> _answerColors = [
  [Color(0xFF4A9DFF), Color(0xFF5F72FF)],
  [Color(0xFFFFB648), Color(0xFFFF8D5B)],
  [Color(0xFF4ACB74), Color(0xFF23B48B)],
  [Color(0xFFFF7BA5), Color(0xFFFFA75D)],
];

