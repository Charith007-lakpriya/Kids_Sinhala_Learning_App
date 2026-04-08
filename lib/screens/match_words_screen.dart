import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../services/firestore_service.dart';
import '../services/session.dart';
import '../services/sound_service.dart';
import '../theme/app_theme.dart';
import '../widgets/auth_playful_widgets.dart';

class MatchWordsScreen extends StatelessWidget {
  static const routeName = '/games/match-words';

  const MatchWordsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _MatchWordsGame();
  }
}

class _MatchWordsGame extends StatefulWidget {
  const _MatchWordsGame();

  @override
  State<_MatchWordsGame> createState() => _MatchWordsGameState();
}

class _MatchWordsGameState extends State<_MatchWordsGame> {
  List<_MatchItem> _items = [];
  int _score = 0;
  String? _feedback;
  bool _isLocked = false;
  bool _showStar = false;
  List<int> _order = [];
  int _orderIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    final snapshot = await FirebaseFirestore.instance.collection('match_words').get();
    final items = snapshot.docs
        .map((doc) {
          final data = doc.data();
          return _MatchItem(
            word: (data['word'] ?? '').toString(),
            emoji: (data['emoji'] ?? '').toString(),
          );
        })
        .where((item) => item.word.isNotEmpty && item.emoji.isNotEmpty)
        .toList();

    if (!mounted || items.isEmpty) return;
    setState(() {
      _items = items;
      _order = List.generate(_items.length, (index) => index)..shuffle();
      _orderIndex = 0;
    });
  }
 void _pick(String emoji) {
    if (_isLocked || _items.isEmpty) return;
    final current = _items[_order[_orderIndex]];

    if (emoji == current.emoji) {
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
      FirestoreService.setLastPlayedWord(userId: userId, word: current.word);

      Future.delayed(const Duration(milliseconds: 700), () {
        if (!mounted) return;
        setState(() => _showStar = false);
      });

      Future.delayed(const Duration(milliseconds: 850), () {
        if (!mounted) return;
        _next();
      });
    } else {
      SoundService.playWrong();
      setState(() {
        _feedback = 'Try again';
      });
    }
  }

  void _next() {
    setState(() {
      _feedback = null;
      _isLocked = false;
      if (_orderIndex < _order.length - 1) {
        _orderIndex += 1;
      } else {
        _orderIndex = 0;
        _order.shuffle();
      }
    });
  }
 @override
  Widget build(BuildContext context) {
    final hasItems = _items.isNotEmpty;
    final current = hasItems ? _items[_order[_orderIndex]] : null;
    final choices = current == null ? const <String>[] : _buildChoices(current);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AuthSkyBackground(
        child: SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 20),
            child: Column(
              children: [
                const _MatchHeroCard(),
                const SizedBox(height: 18),
                AuthPanel(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xFFFFFEFF),
                          Color(0xFFF2FBFF),
                          Color(0xFFFFF7E9),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(28),
                    ),
                    padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _SectionBadge(
                          label: 'Match Words',
                          color: Color(0xFF34B76B),
                        ),
                        const SizedBox(height: 10),
                        const Padding(
                          padding: EdgeInsets.only(left: 4),
                          child: Text(
                            'Read the word and tap the correct picture',
                            style: TextStyle(
                              color: Color(0xFF6A6C88),
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _MatchStats(
                          score: _score,
                          feedback: _feedback,
                          total: _items.length,
                        ),
                        const SizedBox(height: 16),
                        if (!hasItems)
                          const _EmptyStateCard()
                        else ...[
                          _WordPromptCard(word: current!.word),
                          const SizedBox(height: 16),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 14,
                              mainAxisSpacing: 14,
                              childAspectRatio: 0.95,
                            ),
                            itemCount: choices.length,
                            itemBuilder: (context, index) {
                              return _ChoiceCard(
                                emoji: choices[index],
                                colors: _cardColors[index % _cardColors.length],
                                onTap: () => _pick(choices[index]),
                              );
                            },
                          ),
                          const SizedBox(height: 14),
                          Center(
                            child: Text(
                              _isLocked ? 'Next word is coming...' : 'Tap the matching picture',
                              style: const TextStyle(
                                color: AppTheme.textMuted,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<String> _buildChoices(_MatchItem current) {
    final pool = _items.where((item) => item.emoji != current.emoji).toList()..shuffle();
    final distractors = pool.take(pool.length >= 3 ? 3 : pool.length).toList();
    while (distractors.length < 3) {
      distractors.add(current);
    }

    return <String>[
      current.emoji,
      distractors[0].emoji,
      distractors[1].emoji,
      distractors[2].emoji,
    ]..shuffle();
  }
}
class _MatchHeroCard extends StatelessWidget {
  const _MatchHeroCard();

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
            Color(0xFF42C86B),
            Color(0xFF2FB8A1),
            Color(0xFF1E94E8),
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
            right: 8,
            bottom: 0,
            child: Image.asset(
              'assets/icons/games/match words aliya new.png',
              width: 96,
              height: 96,
              fit: BoxFit.contain,
            ),
          ),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Match Words!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 6),
              SizedBox(
                width: 210,
                child: Text(
                  'Pick the right picture and collect stars as you play',
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

class _MatchStats extends StatelessWidget {
  final int score;
  final String? feedback;
  final int total;

  const _MatchStats({
    required this.score,
    required this.feedback,
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
            title: 'Words',
            value: total == 0 ? '-' : '$total',
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

class _WordPromptCard extends StatelessWidget {
  final String word;

  const _WordPromptCard({required this.word});

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
            Color(0xFFEEF9FF),
            Color(0xFFFFF7E7),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFD9EDFF), width: 1.6),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF1E94E8),
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Text(
              'Find This Word',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 14),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 320),
            transitionBuilder: (child, animation) {
              return ScaleTransition(
                scale: animation,
                child: FadeTransition(opacity: animation, child: child),
              );
            },
            child: Text(
              word,
              key: ValueKey(word),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF183B74),
                fontSize: 34,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChoiceCard extends StatelessWidget {
  final String emoji;
  final List<Color> colors;
  final VoidCallback onTap;

  const _ChoiceCard({
    required this.emoji,
    required this.colors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: colors,
            ),
            borderRadius: BorderRadius.circular(28),
            boxShadow: const [
              BoxShadow(
                color: Color(0x18000000),
                blurRadius: 16,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.22),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                bottom: 12,
                left: 12,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Center(
                child: Text(
                  emoji,
                  style: const TextStyle(fontSize: 72),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyStateCard extends StatelessWidget {
  const _EmptyStateCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FBFF),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFDCEBFF)),
      ),
      child: const Column(
        children: [
          CircularProgressIndicator(
            color: Color(0xFF1E94E8),
            strokeWidth: 3,
          ),
          SizedBox(height: 16),
          Text(
            'Loading match words...',
            style: TextStyle(
              color: Color(0xFF183B74),
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Please wait while we get your game ready.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppTheme.textMuted,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _MatchItem {
  final String word;
  final String emoji;

  const _MatchItem({
    required this.word,
    required this.emoji,
  });
}

const List<List<Color>> _cardColors = [
  [Color(0xFFFFB648), Color(0xFFFF8D5B)],
  [Color(0xFF4ACB74), Color(0xFF23B48B)],
  [Color(0xFF4A9DFF), Color(0xFF5F72FF)],
  [Color(0xFFFF7BA5), Color(0xFFFFA75D)],
];
