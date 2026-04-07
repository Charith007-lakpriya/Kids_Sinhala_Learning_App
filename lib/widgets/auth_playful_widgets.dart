import 'package:flutter/material.dart';

class AuthSkyBackground extends StatelessWidget {
  final Widget child;

  const AuthSkyBackground({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF57B8FF),
            Color(0xFF1D82F5),
            Color(0xFF2957D8),
          ],
        ),
      ),
      child: Stack(
        children: [
          const Positioned(
            top: 36,
            left: 18,
            child: _Cloud(width: 76, height: 28),
          ),
          const Positioned(
            top: 92,
            right: 24,
            child: _Cloud(width: 58, height: 22),
          ),
          const Positioned(
            top: 172,
            left: 34,
            child: _Cloud(width: 94, height: 34),
          ),
          const Positioned(
            top: 210,
            right: -8,
            child: SizedBox(
              width: 160,
              height: 92,
              child: CustomPaint(
                painter: _RainbowPainter(),
              ),
            ),
          ),
          Positioned.fill(
            child: SafeArea(
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}

class AuthHeroCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String badge;

  const AuthHeroCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 170,
          height: 170,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(34),
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF45B6FF),
                Color(0xFF0F87FF),
              ],
            ),
            border: Border.all(color: Colors.white.withOpacity(0.75), width: 3),
            boxShadow: const [
              BoxShadow(
                color: Color(0x24000000),
                blurRadius: 18,
                offset: Offset(0, 12),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              const Positioned(top: 14, left: 14, child: _Cloud(width: 42, height: 16)),
              const Positioned(top: 24, right: 16, child: _Cloud(width: 34, height: 14)),
              Positioned(
                bottom: 28,
                child: Container(
                  width: 112,
                  height: 26,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF25C54),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x22000000),
                        blurRadius: 8,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 42,
                child: Container(
                  width: 98,
                  height: 24,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFC94A),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const Positioned(
                bottom: 46,
                left: 18,
                child: _Pencil(color: Color(0xFFF45B4E)),
              ),
              const Positioned(
                bottom: 46,
                right: 18,
                child: _Pencil(color: Color(0xFF3E7BFF), flip: true),
              ),
              Positioned(
                top: 28,
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1F2F88),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        badge,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: 78,
                      height: 78,
                      decoration: const BoxDecoration(
                        color: Color(0xFF6A3B1F),
                        shape: BoxShape.circle,
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Positioned(
                            top: 10,
                            left: 10,
                            child: Container(
                              width: 22,
                              height: 22,
                              decoration: const BoxDecoration(
                                color: Color(0xFF6A3B1F),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 10,
                            right: 10,
                            child: Container(
                              width: 22,
                              height: 22,
                              decoration: const BoxDecoration(
                                color: Color(0xFF6A3B1F),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          Container(
                            width: 54,
                            height: 54,
                            decoration: const BoxDecoration(
                              color: Color(0xFFF7EAD7),
                              shape: BoxShape.circle,
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _Eye(),
                              const SizedBox(width: 8),
                              _Eye(),
                            ],
                          ),
                          Positioned(
                            bottom: 18,
                            child: Container(
                              width: 12,
                              height: 10,
                              decoration: const BoxDecoration(
                                color: Color(0xFFFFA329),
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(10),
                                  bottomRight: Radius.circular(10),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.white.withOpacity(0.92),
          ),
        ),
      ],
    );
  }
}

class AuthPanel extends StatelessWidget {
  final Widget child;

  const AuthPanel({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 24),
      decoration: const BoxDecoration(
        color: Color(0xFFFDFEFF),
        borderRadius: BorderRadius.all(Radius.circular(34)),
        boxShadow: [
          BoxShadow(
            color: Color(0x260D2F6A),
            blurRadius: 24,
            offset: Offset(0, -10),
          ),
        ],
      ),
      child: child,
    );
  }
}

class AuthField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData icon;
  final TextInputType? keyboardType;
  final bool obscureText;

  const AuthField({
    super.key,
    required this.label,
    required this.controller,
    required this.icon,
    this.keyboardType,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF1E7CF2)),
        filled: true,
        fillColor: const Color(0xFFF1F7FF),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      ),
    );
  }
}

class AuthPillButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final Color color;

  const AuthPillButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.color = const Color(0xFF1E7CF2),
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return color.withOpacity(0.5);
          }
          if (states.contains(WidgetState.hovered)) {
            return Color.alphaBlend(Colors.white.withOpacity(0.08), color);
          }
          if (states.contains(WidgetState.pressed)) {
            return Color.alphaBlend(Colors.black.withOpacity(0.08), color);
          }
          return color;
        }),
        foregroundColor: WidgetStateProperty.all(Colors.white),
        shadowColor: WidgetStateProperty.all(const Color(0x662243B6)),
        elevation: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.hovered)) {
            return 12;
          }
          if (states.contains(WidgetState.pressed)) {
            return 4;
          }
          return 8;
        }),
        overlayColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.hovered)) {
            return Colors.white.withOpacity(0.08);
          }
          if (states.contains(WidgetState.pressed)) {
            return Colors.black.withOpacity(0.08);
          }
          return null;
        }),
        padding: WidgetStateProperty.all(
          const EdgeInsets.symmetric(vertical: 18),
        ),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
        ),
      ),
      child: child,
    );
  }
}

class AuthOutlineButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;

  const AuthOutlineButton({
    super.key,
    required this.onPressed,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.hovered)) {
            return Colors.white.withOpacity(0.14);
          }
          if (states.contains(WidgetState.pressed)) {
            return Colors.white.withOpacity(0.2);
          }
          return Colors.white.withOpacity(0.1);
        }),
        foregroundColor: WidgetStateProperty.all(Colors.white),
        side: WidgetStateProperty.resolveWith((states) {
          final width = states.contains(WidgetState.hovered) ? 2.5 : 2.0;
          return BorderSide(color: Colors.white.withOpacity(0.95), width: width);
        }),
        shadowColor: WidgetStateProperty.all(const Color(0x552243B6)),
        elevation: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.hovered)) {
            return 10;
          }
          if (states.contains(WidgetState.pressed)) {
            return 4;
          }
          return 6;
        }),
        overlayColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.hovered)) {
            return Colors.white.withOpacity(0.1);
          }
          if (states.contains(WidgetState.pressed)) {
            return Colors.black.withOpacity(0.06);
          }
          return null;
        }),
        padding: WidgetStateProperty.all(
          const EdgeInsets.symmetric(vertical: 18),
        ),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
        ),
      ),
      child: child,
    );
  }
}

class _Cloud extends StatelessWidget {
  final double width;
  final double height;

  const _Cloud({
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: width * 0.12,
            right: 0,
            bottom: 0,
            child: Container(
              height: height * 0.62,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.92),
                borderRadius: BorderRadius.circular(height),
              ),
            ),
          ),
          Positioned(
            left: 0,
            bottom: height * 0.14,
            child: Container(
              width: height * 0.8,
              height: height * 0.8,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.96),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            left: width * 0.24,
            top: 0,
            child: Container(
              width: height,
              height: height,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.96),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            right: width * 0.12,
            bottom: height * 0.12,
            child: Container(
              width: height * 0.86,
              height: height * 0.86,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Pencil extends StatelessWidget {
  final Color color;
  final bool flip;

  const _Pencil({
    required this.color,
    this.flip = false,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: flip ? 0.34 : -0.34,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 14,
            height: 34,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          Container(
            width: 14,
            height: 8,
            decoration: const BoxDecoration(
              color: Color(0xFFFEE4B4),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Eye extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 16,
      height: 16,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Container(
        width: 7,
        height: 7,
        decoration: const BoxDecoration(
          color: Color(0xFF19223B),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

class _RainbowPainter extends CustomPainter {
  const _RainbowPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width, size.height);
    final colors = [
      const Color(0xFFFF5A61),
      const Color(0xFFFFA62B),
      const Color(0xFFFFE45E),
      const Color(0xFF53D769),
      const Color(0xFF43B5FF),
    ];

    for (var i = 0; i < colors.length; i++) {
      final paint = Paint()
        ..color = colors[i].withOpacity(0.96)
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 11;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: 36 + (i * 11)),
        3.5,
        1.45,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
