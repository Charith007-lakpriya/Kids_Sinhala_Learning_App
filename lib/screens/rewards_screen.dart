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





