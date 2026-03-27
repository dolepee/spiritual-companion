import 'package:flutter/material.dart';

import '../app_theme.dart';

class DecorativeBackdrop extends StatelessWidget {
  const DecorativeBackdrop({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.cream,
                  Color(0xFFF9F5ED),
                  Color(0xFFF4EEE2),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: -80,
          right: -30,
          child: _GlowOrb(
            size: 220,
            color: AppColors.emerald.withOpacity(0.10),
          ),
        ),
        Positioned(
          top: 180,
          left: -70,
          child: _GlowOrb(
            size: 170,
            color: AppColors.gold.withOpacity(0.10),
          ),
        ),
        Positioned(
          bottom: -110,
          right: -40,
          child: _GlowOrb(
            size: 240,
            color: AppColors.moss.withOpacity(0.10),
          ),
        ),
        SafeArea(child: child),
      ],
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({
    required this.size,
    required this.color,
  });

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color,
              color.withOpacity(0.45),
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }
}
