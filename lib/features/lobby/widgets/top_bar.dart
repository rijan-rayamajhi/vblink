import 'package:flutter/material.dart';

import '../../../app/theme.dart';
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
                  _LevelPlaceholder(height: h * 0.6),
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

/// Round player portrait.
class _Avatar extends StatelessWidget {
  const _Avatar({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    // The art already includes its own glowing gold ring.
    return Image.asset(
      'assets/images/avatar_prince.png',
      width: size,
      height: size,
    );
  }
}

class _LevelPlaceholder extends StatelessWidget {
  const _LevelPlaceholder({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          'assets/images/icon_star.png',
          width: height * 1.4,
          height: height * 1.4,
        ),
        SizedBox(width: height * 0.15),
        Text('LV.1', style: AppText.number(height * 0.6)),
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
