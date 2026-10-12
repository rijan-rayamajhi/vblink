import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';
import '../../profile/player.dart';
import '../../profile/profile_sheet.dart';
import '../../settings/settings_sheet.dart';
import 'coin_display.dart';
import 'jackpot_panel.dart';

/// Top strip: avatar, coins, Grand Jackpot, level, menu.
class TopBar extends StatelessWidget {
  const TopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF6A2BC4), // light sheen along the top
            AppColors.royalPurple,
            AppColors.deepPurple,
          ],
          stops: [0.0, 0.35, 1.0],
        ),
        border: const Border(
          bottom: BorderSide(color: AppColors.magenta, width: 2),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.magenta.withValues(alpha: 0.5),
            blurRadius: 16,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final h = constraints.maxHeight;
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: h * 0.3),
              child: Row(
                children: [
                  _Avatar(size: h * 0.86),
                  SizedBox(width: h * 0.25),
                  CoinDisplay(height: h * 0.72),
                  SizedBox(width: h * 0.3),
                  // Takes the leftover middle space; shrinks on squarer screens.
                  Expanded(
                    child: Center(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: JackpotPanel(height: h * 0.74),
                      ),
                    ),
                  ),
                  SizedBox(width: h * 0.3),
                  _LevelBadge(height: h * 0.6),
                  SizedBox(width: h * 0.3),
                  _MenuButton(size: h * 0.78),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Round player portrait; tap to open the profile.
class _Avatar extends ConsumerWidget {
  const _Avatar({required this.size});

  final double size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asset = ref.watch(playerProvider.select((p) => p.avatarAsset));
    // The art already includes its own glowing gold ring.
    return Semantics(
      button: true,
      label: 'Profile',
      child: GestureDetector(
        onTap: () => showProfileSheet(context),
        child: Image.asset(asset, width: size, height: size),
      ),
    );
  }
}

class _LevelBadge extends ConsumerWidget {
  const _LevelBadge({required this.height});

  final double height;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final player = ref.watch(playerProvider);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          'assets/images/icon_star.png',
          width: height * 1.4,
          height: height * 1.4,
        ),
        SizedBox(width: height * 0.15),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('LV.${player.level}', style: AppText.number(height * 0.6)),
            SizedBox(height: height * 0.12),
            // XP progress toward the next level.
            Container(
              width: height * 2.2,
              height: height * 0.16,
              decoration: BoxDecoration(
                color: Colors.black45,
                borderRadius: BorderRadius.circular(height),
              ),
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: player.levelProgress,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.gold, AppColors.goldDeep],
                    ),
                    borderRadius: BorderRadius.circular(height),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Rounded violet square with three bars, like the reference menu button.
class _MenuButton extends StatelessWidget {
  const _MenuButton({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showSettingsSheet(context),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFB57BFF), AppColors.violet],
          ),
          borderRadius: BorderRadius.circular(size * 0.3),
          border: Border.all(color: Colors.white54, width: 1.5),
        ),
        child: Icon(Icons.menu_rounded, color: Colors.white, size: size * 0.7),
      ),
    );
  }
}
