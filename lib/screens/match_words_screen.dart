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
