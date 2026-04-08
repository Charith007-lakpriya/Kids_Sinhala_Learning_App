import 'dart:math' as math;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../services/session.dart';
import '../services/sound_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_card.dart';
import '../widgets/auth_playful_widgets.dart';

class SoundRecognitionScreen extends StatelessWidget {
  static const routeName = '/games/sound-recognition';

  const SoundRecognitionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _SoundRecognitionGame();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sound Recognition'),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0x22FF6B6B),
              Color(0x116C63FF),
              AppTheme.background,
            ],
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              AppCard(
                child: Row(
                  children: const [
                    Text('🔊', style: TextStyle(fontSize: 24)),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Listen and choose the correct word!',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: const [
                  _AnimatedChip(
                    label: '🔊 Sound',
                    colors: [Color(0x33FF6B6B), Color(0x11FF6B6B)],
                    delayMs: 0,
                  ),
                  SizedBox(width: 8),
                  _AnimatedChip(
                    label: '⭐ Stars',
                    colors: [Color(0x336C63FF), Color(0x116C63FF)],
                    delayMs: 120,
                  ),
                  SizedBox(width: 8),
                  _AnimatedChip(
                    label: '🎧 Listen',
                    colors: [Color(0x334CC9F0), Color(0x114CC9F0)],
                    delayMs: 240,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              AppCard(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: AppTheme.secondary.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.volume_up,
                          size: 36, color: AppTheme.primary),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Tap to hear the sound',
                      style: TextStyle(color: AppTheme.textMuted),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              AppCard(
                child: const ListTile(
                  leading: Text('අලි', style: TextStyle(fontSize: 18)),
                  title: Text('Answer choice example'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
class _AnimatedChip extends StatefulWidget {
  final String label;
  final List<Color> colors;
  final int delayMs;

  const _AnimatedChip({
    required this.label,
    required this.colors,
    required this.delayMs,
  });

  @override
  State<_AnimatedChip> createState() => _AnimatedChipState();
}

class _AnimatedChipState extends State<_AnimatedChip> {
  double _opacity = 0;
  double _scale = 0.9;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: widget.delayMs), () {
      if (!mounted) return;
      setState(() {
        _opacity = 1;
        _scale = 1;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _opacity,
      duration: const Duration(milliseconds: 300),
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 300),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: widget.colors),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            widget.label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

class _SoundRecognitionGame extends StatefulWidget {
  const _SoundRecognitionGame();

  @override
  State<_SoundRecognitionGame> createState() => _SoundRecognitionGameState();
}

class _SoundRecognitionGameState extends State<_SoundRecognitionGame> {
  final math.Random _random = math.Random();
  final AudioPlayer _promptPlayer = AudioPlayer();

  late List<_SoundItem> _items;
  int _currentIndex = 0;
  int _score = 0;
  String? _feedback;
  bool _isLocked = false;
  bool _showStar = false;
  bool _isPlayingPrompt = false;

  _SoundItem get _currentItem => _items[_currentIndex];

  @override
  void initState() {
    super.initState();
    _items = List<_SoundItem>.from(_soundItems)..shuffle(_random);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _playPrompt();
      }
    });
  }

  @override
  void dispose() {
    _promptPlayer.dispose();
    super.dispose();
  }

  Future<void> _playPrompt() async {
    if (_isPlayingPrompt) return;

    setState(() => _isPlayingPrompt = true);
    try {
      await _promptPlayer.stop();
      await _promptPlayer.play(AssetSource(_currentItem.audioAsset));
    } catch (_) {
      try {
        await _promptPlayer.stop();
        await _promptPlayer.play(AssetSource('audio/tap.wav'));
      } catch (_) {}
    } finally {
      if (mounted) {
        setState(() => _isPlayingPrompt = false);
      }
    }
  }

  void _pick(_SoundItem answer) {
    if (_isLocked) return;

    if (answer.word == _currentItem.word) {
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
      FirestoreService.setLastPlayedWord(userId: userId, word: _currentItem.word);

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
      setState(() => _feedback = 'Failed, try again');
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Failed, try again'),
            behavior: SnackBarBehavior.floating,
            duration: Duration(milliseconds: 1200),
          ),
        );
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
    _playPrompt();
  }

  List<_SoundItem> _buildChoices() {
    final current = _currentItem;
    final distractors = _items.where((item) => item.word != current.word).toList()
      ..shuffle(_random);

    return <_SoundItem>[
      current,
      ...distractors.take(3),
    ]..shuffle(_random);
  }

  @override
  Widget build(BuildContext context) {
    final current = _currentItem;
    final choices = _buildChoices();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AuthSkyBackground(
        child: SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 20),
            child: Column(
              children: [
                const _SoundHeroCard(),
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
                          Color(0xFFFFF7EC),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(28),
                    ),
                    padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _SoundSectionBadge(
                          label: 'Sound Recognition',
                          color: Color(0xFFF56E4A),
                        ),
                        const SizedBox(height: 10),
                        const Padding(
                          padding: EdgeInsets.only(left: 4),
                          child: Text(
                            'Listen to the word and tap the matching answer',
                            style: TextStyle(
                              color: Color(0xFF6A6C88),
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _SoundStats(
                          score: _score,
                          feedback: _feedback,
                          questionNumber: _currentIndex + 1,
                          total: _items.length,
                        ),
                        const SizedBox(height: 16),
                        _PromptCard(
                          item: current,
                          isPlaying: _isPlayingPrompt,
                          onPlay: _playPrompt,
                        ),
                        const SizedBox(height: 12),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            'Temporary sample audio plays if the real word files are not added yet.',
                            style: TextStyle(
                              color: AppTheme.textMuted,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 14,
                            mainAxisSpacing: 14,
                            childAspectRatio: 1.05,
                          ),
                          itemCount: choices.length,
                          itemBuilder: (context, index) {
                            return _AnswerCard(
                              item: choices[index],
                              colors: _answerColors[index % _answerColors.length],
                              onTap: () => _pick(choices[index]),
                            );
                          },
                        ),
                        const SizedBox(height: 14),
                        Center(
                          child: Text(
                            _isLocked
                                ? 'Great listening! Next sound is coming...'
                                : 'Tap the emoji card that matches the sound',
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
                const SizedBox(height: 16),
                if (_showStar) const _StarBurst(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SoundHeroCard extends StatelessWidget {
  const _SoundHeroCard();

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
            Color(0xFFFF8B54),
            Color(0xFFFF6B6B),
            Color(0xFFEC4F9D),
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
            top: -10,
            right: -8,
            child: Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.14),
                shape: BoxShape.circle,
              ),
            ),
          ),
          const Positioned(
            right: 6,
            bottom: 2,
            child: Text(
              '🔊',
              style: TextStyle(fontSize: 72),
            ),
          ),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sound Game!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 6),
              SizedBox(
                width: 220,
                child: Text(
                  'Play the sound, listen carefully, and choose the correct word',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    height: 1.35,
                    fontWeight: FontWeight.w600,
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

class _SoundSectionBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _SoundSectionBadge({
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _SoundStats extends StatelessWidget {
  final int score;
  final String? feedback;
  final int questionNumber;
  final int total;

  const _SoundStats({
    required this.score,
    required this.feedback,
    required this.questionNumber,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final feedbackColor = switch (feedback) {
      'Good Job!' => const Color(0xFF28A745),
      'Failed, try again' => const Color(0xFFE25A52),
      _ => const Color(0xFF8B8FA8),
    };

    return Row(
      children: [
        Expanded(
          child: _StatBubble(
            label: 'Score',
            value: '$score',
            color: const Color(0xFFFF8C42),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatBubble(
            label: 'Round',
            value: '$questionNumber/$total',
            color: const Color(0xFF4A79FF),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatBubble(
            label: 'Status',
            value: feedback ?? 'Listen',
            color: feedbackColor,
          ),
        ),
      ],
    );
  }
}

class _StatBubble extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatBubble({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.14)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _PromptCard extends StatelessWidget {
  final _SoundItem item;
  final bool isPlaying;
  final VoidCallback onPlay;

  const _PromptCard({
    required this.item,
    required this.isPlaying,
    required this.onPlay,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFF4E7),
            Color(0xFFFFF9F0),
            Color(0xFFF4F8FF),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        children: [
          Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isPlaying
                    ? const [Color(0xFFFFA45F), Color(0xFFFF5E7A)]
                    : const [Color(0xFFFFC060), Color(0xFFFF8A4C)],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF8A4C).withOpacity(0.28),
                  blurRadius: 18,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: IconButton(
              onPressed: onPlay,
              iconSize: 38,
              color: Colors.white,
              icon: Icon(isPlaying ? Icons.graphic_eq : Icons.volume_up_rounded),
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Tap to hear the word',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Find the matching answer for ${item.emoji}',
            style: const TextStyle(
              color: AppTheme.textMuted,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _AnswerCard extends StatelessWidget {
  final _SoundItem item;
  final List<Color> colors;
  final VoidCallback onTap;

  const _AnswerCard({
    required this.item,
    required this.colors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: colors,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: colors.first.withOpacity(0.18),
                blurRadius: 14,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  item.emoji,
                  style: const TextStyle(fontSize: 44),
                ),
                const SizedBox(height: 12),
                Text(
                  item.word,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
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

class _StarBurst extends StatelessWidget {
  const _StarBurst();

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.6, end: 1),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.scale(scale: value, child: child);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF3C8),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: const Color(0xFFFFD460), width: 2),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('⭐', style: TextStyle(fontSize: 20)),
            SizedBox(width: 8),
            Text(
              '+1 point',
              style: TextStyle(
                color: Color(0xFF9D6400),
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SoundItem {
  final String word;
  final String emoji;
  final String audioAsset;

  const _SoundItem({
    required this.word,
    required this.emoji,
    required this.audioAsset,
  });
}

const List<_SoundItem> _soundItems = [
  _SoundItem(
    word: 'අම්මා',
    emoji: '👩',
    audioAsset: 'audio/sound_recognition/amma.mp3',
  ),
  _SoundItem(
    word: 'ගස',
    emoji: '🌳',
    audioAsset: 'audio/sound_recognition/gasa.mp3',
  ),
  _SoundItem(
    word: 'පාසල',
    emoji: '🏫',
    audioAsset: 'audio/sound_recognition/pasala.mp3',
  ),
  _SoundItem(
    word: 'මල',
    emoji: '🌸',
    audioAsset: 'audio/sound_recognition/mala.mp3',
  ),
  _SoundItem(
    word: 'අලියා',
    emoji: '🐘',
    audioAsset: 'audio/sound_recognition/aliya.mp3',
  ),
];

const List<List<Color>> _answerColors = [
  [Color(0xFFFFF0D6), Color(0xFFFFE2C3)],
  [Color(0xFFE2F3FF), Color(0xFFD2E6FF)],
  [Color(0xFFEAF9E8), Color(0xFFD7F2D5)],
  [Color(0xFFFFE8F0), Color(0xFFFFD6E5)],
];
