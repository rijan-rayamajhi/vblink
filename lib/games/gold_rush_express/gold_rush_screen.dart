import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme.dart';
import '../../core/format.dart';
import '../../economy/game_jackpots.dart';
import '../../features/lobby/widgets/coin_display.dart';

const _id = 'gold_rush_express';
const _dir = 'assets/images/gold_rush_express';

/// Gold Rush Express slot screen. Shell for now: background, top strip and
/// an empty reel area; reels and controls arrive with the slot engine.
class GoldRushScreen extends StatelessWidget {
  const GoldRushScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            '$_dir/gre_bg.jpg',
            fit: BoxFit.cover,
            alignment: const Alignment(0, 0.3),
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              final h = constraints.maxHeight;
              return SafeArea(
                top: false,
                bottom: false,
                child: Stack(
                  children: [
                    // Frame is big and slightly overlaps the top/bottom
                    // strips; its art has transparent margins.
                    Positioned(
                      top: h * 0.1,
                      bottom: h * 0.09,
                      left: 0,
                      right: 0,
                      child: const Center(child: _ReelArea()),
                    ),
                    Positioned(
                      top: h * 0.03,
                      left: h * 0.03,
                      right: h * 0.03,
                      height: h * 0.11,
                      child: const _TopStrip(),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _TopStrip extends ConsumerWidget {
  const _TopStrip();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jackpot = ref.watch(gameJackpotsProvider.select((m) => m[_id]!));
    return LayoutBuilder(
      builder: (context, constraints) {
        final h = constraints.maxHeight;
        return Row(
          children: [
            Semantics(
              button: true,
              label: 'Back to lobby',
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: h,
                  height: h,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFFB57BFF), AppColors.violet],
                    ),
                    borderRadius: BorderRadius.circular(h * 0.3),
                    border: Border.all(color: Colors.white54, width: 1.5),
                  ),
                  child: Icon(
                    Icons.arrow_back_rounded,
                    color: Colors.white,
                    size: h * 0.65,
                  ),
                ),
              ),
            ),
            SizedBox(width: h * 0.3),
            CoinDisplay(height: h * 0.85),
            const Spacer(),
            Container(
              height: h * 0.85,
              padding: EdgeInsets.symmetric(horizontal: h * 0.4),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.deepPurple.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(h),
                border: Border.all(color: AppColors.gold, width: 1.5),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('JACKPOT', style: AppText.label(h * 0.3)),
                  SizedBox(width: h * 0.2),
                  Text(
                    formatCents(jackpot),
                    style: AppText.gold(h * 0.42).copyWith(
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Reel frame art with the 5x3 symbol window measured from the image.
class _ReelArea extends StatelessWidget {
  const _ReelArea();

  /// Inner window of gre_frame.png as fractions of its size (1536x1024 art).
  static const window = Rect.fromLTRB(0.104, 0.262, 0.896, 0.793);

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 3 / 2,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth, h = constraints.maxHeight;
          return Stack(
            children: [
              Positioned.fill(child: Image.asset('$_dir/gre_frame.png')),
              // Symbols go here once the engine lands.
              Positioned(
                left: window.left * w,
                top: window.top * h,
                width: window.width * w,
                height: window.height * h,
                child: const SizedBox.expand(),
              ),
            ],
          );
        },
      ),
    );
  }
}
