import 'package:flutter/material.dart';

import '../services/sound_service.dart';
import '../theme/app_theme.dart';
import '../widgets/auth_playful_widgets.dart';

class SettingsScreen extends StatelessWidget {
  static const routeName = '/settings';

  const SettingsScreen({super.key});

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
                const _SettingsHeroCard(),
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
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SectionBadge(
                          label: 'Sound Settings',
                          color: Color(0xFF1E7CF2),
                        ),
                        SizedBox(height: 10),
                        Padding(
                          padding: EdgeInsets.only(left: 4),
                          child: Text(
                            'Control music and sounds across the app',
                            style: TextStyle(
                              color: Color(0xFF6A6C88),
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        SizedBox(height: 14),
                        _SoundSettingsCard(),
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

class _SettingsHeroCard extends StatelessWidget {
  const _SettingsHeroCard();

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
            child: Icon(Icons.settings_rounded, color: Colors.white, size: 36),
          ),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Settings',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 6),
              Text(
                'Customize your learning experience',
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

class _SoundSettingsCard extends StatefulWidget {
  const _SoundSettingsCard();

  @override
  State<_SoundSettingsCard> createState() => _SoundSettingsCardState();
}

class _SoundSettingsCardState extends State<_SoundSettingsCard> {
  bool _muted = SoundService.muted;
  double _music = SoundService.musicVolume;
  double _sfx = SoundService.sfxVolume;

  @override
  Widget build(BuildContext context) {
    return _PlayfulPanel(
      color: const Color(0xFFEAF6FF),
      borderColor: const Color(0xFF9FD2FF),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Sound & Music',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: Color(0xFF183B74),
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                const Icon(Icons.volume_off_rounded, color: AppTheme.primary),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Mute All',
                    style: TextStyle(
                      color: Color(0xFF183B74),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Switch(
                  value: _muted,
                  onChanged: (value) async {
                    setState(() => _muted = value);
                    await SoundService.setMuted(value);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          const _SliderLabel(
            icon: Icons.music_note_rounded,
            label: 'Music Volume',
            color: Color(0xFF1E7CF2),
          ),
          Slider(
            value: _music,
            min: 0,
            max: 1,
            divisions: 10,
            label: '${(_music * 100).round()}%',
            onChanged: _muted
                ? null
                : (value) async {
                    setState(() => _music = value);
                    await SoundService.setMusicVolume(value);
                  },
          ),
          const SizedBox(height: 6),
          const _SliderLabel(
            icon: Icons.graphic_eq_rounded,
            label: 'SFX Sounds Effects',
            color: Color(0xFFFF8A34),
          ),
          Slider(
            value: _sfx,
            min: 0,
            max: 1,
            divisions: 10,
            label: '${(_sfx * 100).round()}%',
            onChanged: _muted
                ? null
                : (value) async {
                    setState(() => _sfx = value);
                    await SoundService.setSfxVolume(value);
                  },
          ),
        ],
      ),
    );
  }
}

class _SliderLabel extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _SliderLabel({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: color.withOpacity(0.14),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF183B74),
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _PlayfulPanel extends StatelessWidget {
  final Color color;
  final Color borderColor;
  final Widget child;

  const _PlayfulPanel({
    required this.color,
    required this.borderColor,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor, width: 1.4),
        boxShadow: [
          BoxShadow(
            color: borderColor.withOpacity(0.18),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}
