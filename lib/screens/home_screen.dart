import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../services/session.dart';
import '../theme/app_theme.dart';
import '../widgets/app_card.dart';
import '../widgets/auth_playful_widgets.dart';

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
