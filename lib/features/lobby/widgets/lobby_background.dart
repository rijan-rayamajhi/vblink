import 'package:flutter/material.dart';

import '../../../app/theme.dart';

/// Neon city backdrop. Fills the screen (cropping top/bottom on wide phones)
/// and darkens the edges slightly so the top and bottom bars stay readable.
class LobbyBackground extends StatelessWidget {
  const LobbyBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          'assets/images/lobby_bg.jpg',
          fit: BoxFit.cover,
          alignment: const Alignment(0, 0.15),
          filterQuality: FilterQuality.medium,
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.deepPurple.withValues(alpha: 0.55),
                Colors.transparent,
                Colors.transparent,
                AppColors.deepPurple.withValues(alpha: 0.45),
              ],
              stops: const [0.0, 0.2, 0.75, 1.0],
            ),
          ),
        ),
      ],
    );
  }
}
