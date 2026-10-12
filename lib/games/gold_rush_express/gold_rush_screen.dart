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
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: h * 0.03),
                  child: Column(
                    children: [
                      SizedBox(height: h * 0.03),
                      SizedBox(height: h * 0.11, child: const _TopStrip()),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: h * 0.03),
                          child: const Center(child: _ReelArea()),
                        ),
                      ),
                      SizedBox(height: h * 0.16),
                    ],
                  ),
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

/// Placeholder 5x3 reel window until the reel frame art and engine land.
class _ReelArea extends StatelessWidget {
  const _ReelArea();

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 5 / 3,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xCC1A0A1E),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.gold, width: 3),
        ),
        child: Row(
          children: [
            for (var i = 0; i < 5; i++)
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: i == 0
                        ? null
                        : Border(
                            left: BorderSide(
                              color: AppColors.gold.withValues(alpha: 0.5),
                            ),
                          ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
