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




