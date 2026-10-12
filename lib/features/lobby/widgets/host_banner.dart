import 'package:flutter/material.dart';

import '../../../app/theme.dart';

/// Tall card on the left of the game panel with the hostess over a pink glow.
class HostBanner extends StatelessWidget {
  const HostBanner({super.key});

  @override
  Widget build(BuildContext context) {
    // Glow sits behind the card; the border is painted on top of the image.
    // (A foreground shadow would tint the whole picture pink.)
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.hotPink.withValues(alpha: 0.45),
            blurRadius: 14,
          ),
        ],
      ),
      child: DecoratedBox(
        position: DecorationPosition.foreground,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.hotPink, width: 2.5),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: DecoratedBox(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFE85BD0),
                  Color(0xFF8E2BD6),
                  Color(0xFF3A0F7A),
                ],
              ),
            ),
            // Top-aligned crop keeps her face, crown and coins in view.
            child: Image.asset(
              'assets/images/host_banner.png',
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
            ),
          ),
        ),
      ),
    );
  }
}
