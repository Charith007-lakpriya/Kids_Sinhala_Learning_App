import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/auth_playful_widgets.dart';

class GamesScreen extends StatelessWidget {
  static const routeName = '/games';

  const GamesScreen({super.key});

  void _openGame(BuildContext context, String type) {
    switch (type) {
      case 'match':
        Navigator.pushNamed(context, '/games/match-words');
        break;
      case 'trace':
        Navigator.pushNamed(context, '/games/letter-tracing');
        break;
      case 'quiz':
        Navigator.pushNamed(context, '/games/picture-quiz');
        break;
      case 'sound':
        Navigator.pushNamed(context, '/games/sound-recognition');
        break;
      default:
        Navigator.pushNamed(context, '/games/match-words');
    }
  }

  @override
  Widget build(BuildContext context) {
    final gamesStream = FirebaseFirestore.instance.collection('games').snapshots();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AuthSkyBackground(
        child: SafeArea(
          bottom: false,
          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: gamesStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final docs = snapshot.data?.docs ?? [];
              if (docs.isEmpty) {
                return const Center(
                  child: Text('No games yet. Seed Firestore data in Settings.'),
                );
              }

              final games = docs.map((doc) {
                final data = doc.data();
                final type = (data['type'] ?? '').toString();
                return _GameCardData(
                  title: (data['title'] ?? 'Game').toString(),
                  description:
                      (data['description'] ?? 'Practice and play').toString(),
                  icon: (data['icon'] ?? _emojiForType(type)).toString(),
                  type: type,
                  difficulty: (data['difficulty'] ?? 1).toString(),
                  gradient: _gradientForType(type),
                  accent: _accentForType(type),
                  softColor: _softColorForType(type),
                );
              }).toList();

              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 20),
                child: Column(
                  children: [
                    const _GamesHeroCard(),
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
                              label: 'Game Adventures',
                              color: Color(0xFF52B947),
                            ),
                            const SizedBox(height: 10),
                            const Padding(
                              padding: EdgeInsets.only(left: 4),
                              child: Text(
                                'Learn Sinhala with fun, interactive games!',
                                style: TextStyle(
                                  color: Color(0xFF5A718D),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            ...games.map(
                              (game) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _GameAdventureButton(
                                  game: game,
                                  onTap: () => _openGame(context, game.type),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _GamesHeroCard extends StatelessWidget {
  const _GamesHeroCard();

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
            Color(0xFF47B7FF),
            Color(0xFF1E7CF2),
            Color(0xFF2957D8),
          ],
        ),
        border: Border.all(color: Colors.white.withOpacity(0.7), width: 2.5),
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
            top: -8,
            right: -8,
            child: Container(
              width: 94,
              height: 94,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          const Positioned(
            top: 10,
            right: 16,
            child: Icon(
              Icons.sports_esports_rounded,
              color: Colors.white,
              size: 36,
            ),
          ),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Games Time!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 6),
              Text(
                'Pick a big colorful game and start playing',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
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

  const _SectionBadge({
    required this.label,
    required this.color,
  });

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

class _GameAdventureButton extends StatelessWidget {
  final _GameCardData game;
  final VoidCallback onTap;

  const _GameAdventureButton({
    required this.game,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.98, end: 1),
      duration: const Duration(milliseconds: 380),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.scale(scale: value, child: child);
      },
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          child: Ink(
            decoration: BoxDecoration(
              gradient: game.gradient,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: game.accent.withOpacity(0.24),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned(
                  top: -8,
                  right: -8,
                  child: Container(
                    width: 82,
                    height: 82,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.14),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Positioned(
                  bottom: -12,
                  right: 24,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.16),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              game.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                height: 1,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              game.description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.94),
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Difficulty ${game.difficulty}',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.92),
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                'Play Now',
                                style: TextStyle(
                                  color: game.accent,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        children: [
                          SizedBox(
                            width: 122,
                            height: 122,
                            child: Center(
                              child: _GameIcon(
                                type: game.type,
                                icon: game.icon,
                                size: 108,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: List.generate(
                              3,
                              (index) => Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 3),
                                child: _MiniShape(
                                  color: index.isEven
                                      ? Colors.white
                                      : game.softColor,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
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

class _MiniShape extends StatelessWidget {
  final Color color;

  const _MiniShape({required this.color});

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: 0.35,
      child: Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }
}



class _GameCardData {
  final String title;
  final String description;
  final String icon;
  final String type;
  final String difficulty;
  final Gradient gradient;
  final Color accent;
  final Color softColor;

  const _GameCardData({
    required this.title,
    required this.description,
    required this.icon,
    required this.type,
    required this.difficulty,
    required this.gradient,
    required this.accent,
    required this.softColor,
  });
}




