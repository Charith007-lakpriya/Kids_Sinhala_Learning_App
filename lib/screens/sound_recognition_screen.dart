import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_card.dart';

class SoundRecognitionScreen extends StatelessWidget {
  static const routeName = '/games/sound-recognition';

  const SoundRecognitionScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
