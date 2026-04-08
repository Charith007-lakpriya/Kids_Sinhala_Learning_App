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
