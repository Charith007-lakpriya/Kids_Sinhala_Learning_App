import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../services/session.dart';
import '../theme/app_theme.dart';
import '../widgets/app_card.dart';
import '../widgets/auth_playful_widgets.dart';

class HomeScreen extends StatelessWidget {
  static const routeName = '/home';

  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = Session.currentUserId ?? 'demo';
    final userDoc =
        FirebaseFirestore.instance.collection('users').doc(uid).snapshots();
    final progressDoc = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('progress')
        .doc('overview')
        .snapshots();
    final gamesDoc = FirebaseFirestore.instance.collection('games').snapshots();

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: userDoc,
      builder: (context, userSnap) {
        final userData = userSnap.data?.data() ?? {};
        final username = (userData['name'] ?? 'Learner').toString();
        final avatarAsset =
            (userData['avatarAsset'] ?? 'assets/avatars/avatar_0_0.png')
                .toString();
        final avatarEmoji = (userData['avatarEmoji'] ?? '🐘').toString();
        final stars = (userData['stars'] ?? 0) as int? ?? 0;
        final streak = (userData['streak'] ?? 0) as int? ?? 0;
        final level = (userData['level'] ?? 1) as int? ?? 1;
        final bestStreak = (userData['bestStreak'] ?? 0) as int? ?? 0;
        final levelProgress = (stars % 20) / 20;

        return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: progressDoc,
          builder: (context, progressSnap) {
            final progress = progressSnap.data?.data() ?? {};
            final gamesPlayed = (progress['gamesPlayed'] ?? 0) as int? ?? 0;
            final accuracy = (progress['accuracy'] ?? 0) as int? ?? 0;

            return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: gamesDoc,
              builder: (context, gamesSnap) {
                final docs = gamesSnap.data?.docs ?? [];
                final gameCards = docs.map((doc) {
                  final data = doc.data();
                  final type = (data['type'] ?? '').toString();
                  return _GameCardData(
                    title: (data['title'] ?? 'Game').toString(),
                    description:
                        (data['description'] ?? 'Practice and play').toString(),
                    icon: (data['icon'] ?? _emojiForType(type)).toString(),
                    type: type,
                    gradient: _gradientForType(type),
                    route: _routeForType(type),
                    accent: _accentForType(type),
                    softColor: _softColorForType(type),
                  );
                }).toList();

                if (!gameCards.any((game) => game.type == 'sound')) {
                  gameCards.add(
                    _GameCardData(
                      title: 'Sound Word Match',
                      description: 'Play a sound and choose the matching word',
                      icon: _emojiForType('sound'),
                      type: 'sound',
                      gradient: _gradientForType('sound'),
                      route: _routeForType('sound'),
                      accent: _accentForType('sound'),
                      softColor: _softColorForType('sound'),
                    ),
                  );
                }

                final continueGame =
                    gameCards.isNotEmpty ? gameCards.first : null;

                return Scaffold(
                  backgroundColor: Colors.transparent,
                  body: AuthSkyBackground(
                    child: SafeArea(
                      bottom: false,
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(
                                20,
                                18,
                                20,
                                18,
                              ),
                              child: _HeroHeader(
                                username: username,
                                avatarAsset: avatarAsset,
                                avatarEmoji: avatarEmoji,
                                stars: stars,
                                streak: streak,
                                level: level,
                                levelProgress: levelProgress,
                              ),
                            ),
                            AuthPanel(
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Color(0xFFFDFEFF),
                                      Color(0xFFF4FBFF),
                                      Color(0xFFFFF8EC),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(28),
                                ),
                                padding: const EdgeInsets.all(8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const _SectionTitle(
                                      title: 'Today\'s Adventure',
                                      subtitle:
                                          'A simple place to keep learning and playing.',
                                      color: Color(0xFFFFA62B),
                                    ),
                                    const SizedBox(height: 16),
                                    AppCard(
                                      gradient: const LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          Color(0x33FFC857),
                                          Color(0x14FF9F1C),
                                        ],
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 56,
                                            height: 56,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFFFC94A),
                                              borderRadius:
                                                  BorderRadius.circular(18),
                                            ),
                                            child: const Icon(
                                              Icons.flag_rounded,
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(width: 14),
                                          const Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Daily Challenge',
                                                  style: TextStyle(
                                                    fontSize: 17,
                                                    fontWeight: FontWeight.w800,
                                                    color: Color(0xFF183B74),
                                                  ),
                                                ),
                                                SizedBox(height: 4),
                                                Text(
                                                  'Complete 3 games today!',
                                                  style: TextStyle(
                                                    color: AppTheme.textMuted,
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const Icon(
                                            Icons.chevron_right_rounded,
                                            color: Color(0xFFFFA62B),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 26),
                                    const _SectionTitle(
                                      title: 'Continue Learning',
                                      subtitle:
                                          'Jump back into your next activity.',
                                      color: Color(0xFF1E7CF2),
                                    ),
                                    const SizedBox(height: 14),
                                    if (continueGame != null)
                                      AppCard(
                                        gradient: continueGame.gradient,
                                        onTap: () => Navigator.pushNamed(
                                          context,
                                          continueGame.route,
                                        ),
                                        padding: const EdgeInsets.all(18),
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 58,
                                              height: 58,
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF1E7CF2),
                                                borderRadius:
                                                    BorderRadius.circular(18),
                                              ),
                                              child: Center(
                                                child: _GameIcon(
                                                  type: continueGame.type,
                                                  icon: continueGame.icon,
                                                  size: 38,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 14),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    continueGame.title,
                                                    style: const TextStyle(
                                                      fontSize: 17,
                                                      fontWeight:
                                                          FontWeight.w800,
                                                      color: Color(0xFF183B74),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    continueGame.description,
                                                    style: const TextStyle(
                                                      color: AppTheme.textMuted,
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 6),
                                                  const Text(
                                                    'Last played: Today',
                                                    style: TextStyle(
                                                      color: Color(0xFF1E7CF2),
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 18,
                                                vertical: 10,
                                              ),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF1E7CF2),
                                                borderRadius:
                                                    BorderRadius.circular(999),
                                                boxShadow: const [
                                                  BoxShadow(
                                                    color: Color(0x261E7CF2),
                                                    blurRadius: 10,
                                                    offset: Offset(0, 5),
                                                  ),
                                                ],
                                              ),
                                              child: const Text(
                                                'Play',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    const SizedBox(height: 26),
                                    const _SectionTitle(
                                      title: 'All Games',
                                      subtitle:
                                          'Choose a fun adventure and start playing.',
                                      color: Color(0xFF54B848),
                                    ),
                                    const SizedBox(height: 14),
                                    ...gameCards.map(
                                      (game) => Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 12),
                                        child: _GameAdventureButton(game: game),
                                      ),
                                    ),
                                    const SizedBox(height: 26),
                                    const _SectionTitle(
                                      title: 'Your Progress',
                                      subtitle:
                                          'See how well you are doing today.',
                                      color: Color(0xFFFF5C8A),
                                    ),
                                    const SizedBox(height: 14),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: _ProgressTile(
                                            icon: Icons.emoji_events_rounded,
                                            color: const Color(0xFF5C6CFF),
                                            value: gamesPlayed.toString(),
                                            label: 'Games',
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: _ProgressTile(
                                            icon: Icons.track_changes_rounded,
                                            color: const Color(0xFF28B5F5),
                                            value: '$accuracy%',
                                            label: 'Accuracy',
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: _ProgressTile(
                                            icon: Icons
                                                .local_fire_department_rounded,
                                            color: const Color(0xFFFFA62B),
                                            value: bestStreak.toString(),
                                            label: 'Best Streak',
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 18),
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
              },
            );
          },
        );
      },
    );
  }
}

LinearGradient _gradientForType(String type) {
  switch (type) {
    case 'match':
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF67C76A), Color(0xFF3CA86A)],
      );
    case 'trace':
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFFFC93C), Color(0xFFFF9F1C)],
      );
    case 'quiz':
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF3E8CFF), Color(0xFF2757D7)],
      );
    case 'sound':
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFFF7B7B), Color(0xFFFF5B8A)],
      );
    default:
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF5BC0FF), Color(0xFF2B7BFF)],
      );
  }
}

Color _accentForType(String type) {
  switch (type) {
    case 'match':
      return const Color(0xFF2F8F54);
    case 'trace':
      return const Color(0xFFF28B18);
    case 'quiz':
      return const Color(0xFF234CC7);
    case 'sound':
      return const Color(0xFFE54C6B);
    default:
      return const Color(0xFF1E7CF2);
  }
}

Color _softColorForType(String type) {
  switch (type) {
    case 'match':
      return const Color(0xFFEAF8E8);
    case 'trace':
      return const Color(0xFFFFF2D8);
    case 'quiz':
      return const Color(0xFFEAF0FF);
    case 'sound':
      return const Color(0xFFFFEBF2);
    default:
      return const Color(0xFFEAF6FF);
  }
}

String _emojiForType(String type) {
  switch (type) {
    case 'match':
      return '🧩';
    case 'trace':
      return '✏️';
    case 'quiz':
      return '🚀';
    case 'sound':
      return '🎵';
    default:
      return '🎮';
  }
}

String _routeForType(String type) {
  switch (type) {
    case 'match':
      return '/games/match-words';
    case 'trace':
      return '/games/letter-tracing';
    case 'quiz':
      return '/games/picture-quiz';
    case 'sound':
      return '/games/sound-recognition';
    default:
      return '/games/match-words';
  }
}

class _HeroHeader extends StatelessWidget {
  final String username;
  final String avatarAsset;
  final String avatarEmoji;
  final int stars;
  final int streak;
  final int level;
  final double levelProgress;

  const _HeroHeader({
    required this.username,
    required this.avatarAsset,
    required this.avatarEmoji,
    required this.stars,
    required this.streak,
    required this.level,
    required this.levelProgress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 26, 22, 22),
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
            top: 4,
            right: 4,
            child: Container(
              width: 86,
              height: 86,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            top: 34,
            right: 18,
            child: Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: const Color(0xFFFFE45E).withOpacity(0.95),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 62,
                    height: 62,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: avatarAsset.startsWith('assets/')
                          ? Image.asset(
                              avatarAsset,
                              width: 54,
                              height: 54,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Center(
                                child: Text(
                                  avatarEmoji,
                                  style: const TextStyle(fontSize: 32),
                                ),
                              ),
                            )
                          : Center(
                              child: Text(
                                avatarEmoji,
                                style: const TextStyle(fontSize: 32),
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hi, $username!',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Ready to learn and play?',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            height: 1.1,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: const [
                  _EmojiChip(label: 'Fun'),
                  _EmojiChip(label: 'Stars'),
                  _EmojiChip(label: 'Rewards'),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: _StatPill(
                      icon: Icons.star_rounded,
                      value: stars.toString(),
                      label: 'Stars',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatPill(
                      icon: Icons.local_fire_department_rounded,
                      value: streak.toString(),
                      label: 'Day Streak',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.16),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Level $level',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'Level ${level + 1}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value: levelProgress,
                        minHeight: 10,
                        backgroundColor: Colors.white24,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFFFFE45E),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color color;

  const _SectionTitle({
    required this.title,
    required this.subtitle,
    this.color = const Color(0xFF1E7CF2),
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TweenAnimationBuilder<double>(
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
              title,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          subtitle,
          style: const TextStyle(
            color: Color(0xFF59708E),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _StatPill extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final String? badgeEmoji;

  const _StatPill({
    required this.icon,
    required this.value,
    required this.label,
    this.badgeEmoji,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Colors.white.withOpacity(0.22),
        ),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: Colors.white),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (badgeEmoji != null)
            Positioned(
              right: -4,
              top: -6,
              child: Container(
                width: 22,
                height: 22,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    badgeEmoji!,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ProgressTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String value;
  final String label;

  const _ProgressTile({
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.97, end: 1),
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.scale(scale: value, child: child);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              color.withOpacity(0.98),
              Color.alphaBlend(Colors.white.withOpacity(0.12), color),
            ],
          ),
          borderRadius: BorderRadius.circular(26),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.28),
              blurRadius: 14,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              top: -2,
              right: -2,
              child: Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              bottom: 8,
              left: -4,
              child: Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.14),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Column(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, color: color, size: 26),
                ),
                const SizedBox(height: 8),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      color: color,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _GameAdventureButton extends StatelessWidget {
  final _GameCardData game;

  const _GameAdventureButton({required this.game});

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
          onTap: () => Navigator.pushNamed(context, game.route),
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
                            width: 118,
                            height: 118,
                            child: Center(
                              child: _GameIcon(
                                type: game.type,
                                icon: game.icon,
                                size: 104,
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

class _GameIcon extends StatelessWidget {
  final String type;
  final String icon;
  final double size;

  const _GameIcon({
    required this.type,
    required this.icon,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    if (type == 'match') {
      return Image.asset(
        'assets/icons/games/match words aliya new.png',
        width: size,
        height: size,
        fit: BoxFit.contain,
      );
    }

    if (type == 'trace') {
      return Image.asset(
        'assets/icons/games/letter tracing icon.png',
        width: size,
        height: size,
        fit: BoxFit.contain,
      );
    }

    if (type == 'quiz') {
      return Image.asset(
        'assets/icons/games/picture quiz icon.png',
        width: size,
        height: size,
        fit: BoxFit.contain,
      );
    }

    return Text(
      icon,
      style: TextStyle(fontSize: size * 0.72),
    );
  }
}

class _GameCardData {
  final String title;
  final String description;
  final String icon;
  final String type;
  final Gradient gradient;
  final String route;
  final Color accent;
  final Color softColor;

  const _GameCardData({
    required this.title,
    required this.description,
    required this.icon,
    required this.type,
    required this.gradient,
    required this.route,
    required this.accent,
    required this.softColor,
  });
}

class _EmojiChip extends StatelessWidget {
  final String label;

  const _EmojiChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.16),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
