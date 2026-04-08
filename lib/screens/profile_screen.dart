import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../services/session.dart';
import '../services/sound_service.dart';
import '../theme/app_theme.dart';
import '../widgets/auth_playful_widgets.dart';
import 'welcome_screen.dart';

class ProfileScreen extends StatefulWidget {
  static const routeName = '/profile';

  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const List<String> _avatarOptions = [
    'assets/avatars/avatar_0_0.png',
    'assets/avatars/avatar_0_1.png',
    'assets/avatars/avatar_0_2.png',
    'assets/avatars/avatar_1_0.png',
    'assets/avatars/avatar_1_1.png',
    'assets/avatars/avatar_1_2.png',
    'assets/avatars/avatar_2_0.png',
    'assets/avatars/avatar_2_1.png',
    'assets/avatars/avatar_2_2.png',
  ];

  bool _isEditing = false;
  bool _isLoading = true;
  int _stars = 0;
  int _level = 1;
  String _avatarAsset = 'assets/avatars/avatar_0_0.png';
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _ageController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: 'Nimali Perera');
    _emailController = TextEditingController(text: 'nimali@example.com');
    _ageController = TextEditingController(text: '12');
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  void _toggleEditing() {
    setState(() => _isEditing = !_isEditing);
  }

  Future<void> _loadProfile() async {
    try {
      final uid = Session.currentUserId ?? 'demo';
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      if (doc.exists) {
        final data = doc.data() ?? {};
        _nameController.text = (data['name'] ?? _nameController.text).toString();
        _emailController.text =
            (data['email'] ?? _emailController.text).toString();
        _ageController.text = (data['age'] ?? _ageController.text).toString();
        _avatarAsset = (data['avatarAsset'] ?? _avatarAsset).toString();
        _stars = (data['stars'] ?? _stars) as int? ?? _stars;
        _level = (data['level'] ?? _level) as int? ?? _level;
      }
    } catch (_) {
      // Keep local defaults if Firestore read fails.
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _saveProfile() async {
    final uid = Session.currentUserId ?? 'demo';
    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'name': _nameController.text.trim(),
      'email': _emailController.text.trim(),
      'age': _ageController.text.trim(),
      'avatarAsset': _avatarAsset,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> _pickAvatar() async {
    SoundService.playTap();
    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
          decoration: const BoxDecoration(
            color: Color(0xFFFDFEFF),
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Choose Your Avatar',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF183B74),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Pick a fun friend for your profile',
                style: TextStyle(
                  color: AppTheme.textMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _avatarOptions.map((avatar) {
                  final isSelected = avatar == _avatarAsset;
                  return GestureDetector(
                    onTap: () => Navigator.pop(context, avatar),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF1E7CF2)
                            : const Color(0xFFF1F7FF),
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: (isSelected
                                    ? const Color(0xFF1E7CF2)
                                    : const Color(0xFF6A92C9))
                                .withOpacity(0.18),
                            blurRadius: 10,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: Image.asset(
                          avatar,
                          width: 62,
                          height: 62,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );

    if (selected == null) return;
    setState(() => _avatarAsset = selected);
    await _saveProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AuthSkyBackground(
        child: SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 20),
            child: Column(
              children: [
                _ProfileHeroCard(
                  avatarAsset: _avatarAsset,
                  displayName: _nameController.text.trim().isEmpty
                      ? 'ValiPilla Learner'
                      : _nameController.text.trim(),
                  level: _level,
                  stars: _stars,
                  onEditAvatar: _pickAvatar,
                ),
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
                          Color(0xFFFFF7EE),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(28),
                    ),
                    padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const _SectionBadge(
                              label: 'My Profile',
                              color: Color(0xFF1E7CF2),
                            ),
                            const Spacer(),
                            TextButton(
                              onPressed: () async {
                                SoundService.playTap();
                                if (_isEditing) {
                                  await _saveProfile();
                                }
                                _toggleEditing();
                              },
                              child: Text(
                                _isEditing ? 'Save' : 'Edit',
                                style: const TextStyle(
                                  color: Color(0xFF1E7CF2),
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (_isLoading)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 40),
                            child: Center(child: CircularProgressIndicator()),
                          ),
                        if (!_isLoading) ...[
                          _PlayfulPanel(
                            color: const Color(0xFFEAF6FF),
                            borderColor: const Color(0xFF9FD2FF),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Profile Details',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFF183B74),
                                  ),
                                ),
                                const SizedBox(height: 14),
                                _ProfileField(
                                  label: 'Name',
                                  controller: _nameController,
                                  enabled: _isEditing,
                                ),
                                const SizedBox(height: 12),
                                _ProfileField(
                                  label: 'Email',
                                  controller: _emailController,
                                  enabled: _isEditing,
                                  keyboardType: TextInputType.emailAddress,
                                ),
                                const SizedBox(height: 12),
                                _ProfileField(
                                  label: 'Age',
                                  controller: _ageController,
                                  enabled: _isEditing,
                                  keyboardType: TextInputType.number,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          _PlayfulPanel(
                            color: const Color(0xFFFFF3D9),
                            borderColor: const Color(0xFFFFD470),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'Learning Goals',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFF183B74),
                                  ),
                                ),
                                SizedBox(height: 14),
                                _GoalRow(text: 'Practice daily pronunciation'),
                                SizedBox(height: 8),
                                _GoalRow(text: 'Complete 3 games each day'),
                                SizedBox(height: 8),
                                _GoalRow(text: 'Unlock new avatar items'),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                SoundService.playTap();
                                SoundService.stopBgm();
                                Session.currentUserId = null;
                                Navigator.pushNamedAndRemoveUntil(
                                  context,
                                  WelcomeScreen.routeName,
                                  (route) => false,
                                );
                              },
                              icon: const Icon(
                                Icons.logout_rounded,
                                color: Colors.white,
                              ),
                              label: const Text(
                                'Log Out',
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 16,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFE74C3C),
                                foregroundColor: Colors.white,
                                elevation: 8,
                                shadowColor: const Color(0x55E74C3C),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 18,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                              ),
                            ),
                          ),
                        ],
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
  }
}



