import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../services/session.dart';
import '../theme/app_theme.dart';
import '../widgets/auth_playful_widgets.dart';

class RewardsScreen extends StatelessWidget {
  static const routeName = '/rewards';

  const RewardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = Session.currentUserId ?? 'demo';
    final rewardsStream = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('rewards')
        .snapshots();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AuthSkyBackground(
        child: SafeArea(
          bottom: false,
          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: rewardsStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final docs = snapshot.data?.docs ?? [];

              final rewards = docs.map((doc) {
                final data = doc.data();
                final title = (data['title'] ?? 'Reward').toString();
                final status = (data['status'] ?? 'locked').toString();
                final stars = (data['stars'] ?? 0).toString();
                return _RewardCardData(
                  title: title,
                  status: status,
                  stars: stars,
                  gradient: _gradientForStatus(status),
                  accent: _accentForStatus(status),
                );
              }).toList()
                ..addAll(_dummyLockedRewards);

              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 20),
                child: Column(
                  children: [
                    const _RewardsHeroCard(),
                    const SizedBox(height: 18),
                    AuthPanel(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color(0xFFFFFEFF),
                              Color(0xFFFFF8F0),
                              Color(0xFFFDF5FF),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(28),
                        ),
                        padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const _SectionBadge(
                              label: 'Reward Collection',
                              color: Color(0xFFFF8A34),
                            ),
                            const SizedBox(height: 10),
                            const Padding(
                              padding: EdgeInsets.only(left: 4),
                              child: Text(
                                'Collect stars and unlock fun surprises',
                                style: TextStyle(
                                  color: Color(0xFF6A6C88),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            ...rewards.map(
                              (reward) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _RewardAdventureCard(reward: reward),
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

class _RewardsHeroCard extends StatelessWidget {
  const _RewardsHeroCard();

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
            Color(0xFFFFB347),
            Color(0xFFFF8A34),
            Color(0xFFFF6675),
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
            top: -10,
            right: -6,
            child: Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
            ),
          ),
          const Positioned(
            top: 10,
            right: 18,
            child: Icon(Icons.workspace_premium_rounded,
                color: Colors.white, size: 38),
          ),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Rewards Time!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 6),
              Text(
                'Earn stars and unlock exciting rewards',
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

class _RewardAdventureCard extends StatelessWidget {
  final _RewardCardData reward;

  const _RewardAdventureCard({required this.reward});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.98, end: 1),
      duration: const Duration(milliseconds: 380),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.scale(scale: value, child: child);
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: reward.gradient,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: reward.accent.withOpacity(0.24),
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
                          reward.title,
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
                          reward.statusLabel,
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
                            '${reward.stars} Stars',
                            style: TextStyle(
                              color: reward.accent,
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
                      Container(
                        width: 88,
                        height: 88,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          reward.emoji,
                          style: const TextStyle(fontSize: 44),
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
                                  : reward.softColor,
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

LinearGradient _gradientForStatus(String status) {
  switch (status.toLowerCase()) {
    case 'unlocked':
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF67C76A), Color(0xFF3CA86A)],
      );
    case 'claimed':
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF8C6BFF), Color(0xFF5A47E5)],
      );
    default:
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFFFB347), Color(0xFFFF8A34)],
      );
  }
}

Color _accentForStatus(String status) {
  switch (status.toLowerCase()) {
    case 'unlocked':
      return const Color(0xFF2F8F54);
    case 'claimed':
      return const Color(0xFF5642D8);
    default:
      return const Color(0xFFFF7A1A);
  }
}

Color _softColorForStatus(String status) {
  switch (status.toLowerCase()) {
    case 'unlocked':
      return const Color(0xFFEAF8E8);
    case 'claimed':
      return const Color(0xFFEDE8FF);
    default:
      return const Color(0xFFFFF0DA);
  }
}

class _RewardCardData {
  final String title;
  final String status;
  final String stars;
  final Gradient gradient;
  final Color accent;

  const _RewardCardData({
    required this.title,
    required this.status,
    required this.stars,
    required this.gradient,
    required this.accent,
  });

  String get statusLabel {
    switch (status.toLowerCase()) {
      case 'unlocked':
        return 'Unlocked reward';
      case 'claimed':
        return 'Already collected';
      default:
        return 'Keep playing to unlock';
    }
  }

  String get emoji {
    switch (status.toLowerCase()) {
      case 'unlocked':
        return '\u{1F381}';
      case 'claimed':
        return '\u{1F3C6}';
      default:
        return '\u{1F512}';
    }
  }

  Color get softColor => _softColorForStatus(status);
}

const List<_RewardCardData> _dummyLockedRewards = [
  _RewardCardData(
    title: 'Rainbow Badge',
    status: 'locked',
    stars: '12',
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFFFFB347), Color(0xFFFF8A34)],
    ),
    accent: Color(0xFFFF7A1A),
  ),
  _RewardCardData(
    title: 'Super Star Crown',
    status: 'locked',
    stars: '18',
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFFFFB347), Color(0xFFFF8A34)],
    ),
    accent: Color(0xFFFF7A1A),
  ),
  _RewardCardData(
    title: 'Magic Pencil Pack',
    status: 'locked',
    stars: '24',
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFFFFB347), Color(0xFFFF8A34)],
    ),
    accent: Color(0xFFFF7A1A),
  ),
  _RewardCardData(
    title: 'Jungle Explorer',
    status: 'locked',
    stars: '30',
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFFFFB347), Color(0xFFFF8A34)],
    ),
    accent: Color(0xFFFF7A1A),
  ),
  _RewardCardData(
    title: 'Treasure Chest',
    status: 'locked',
    stars: '40',
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFFFFB347), Color(0xFFFF8A34)],
    ),
    accent: Color(0xFFFF7A1A),
  ),
];
