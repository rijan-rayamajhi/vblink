import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme.dart';
import '../../core/format.dart';
import '../../economy/game_jackpots.dart';
import '../../economy/wallet.dart';
import '../../features/lobby/widgets/coin_display.dart';
import '../../features/settings/settings.dart';
import '../slot_engine/slot_session.dart';
import '../slot_engine/widgets/slot_reels.dart';
import '../slot_engine/widgets/spin_button.dart';
import 'config.dart';

const _dir = 'assets/images/gold_rush_express';

/// Gold Rush Express slot: framed reels in the middle, bet and win on the
/// left, SPIN on the right.
class GoldRushScreen extends ConsumerWidget {
  const GoldRushScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(slotSessionProvider(goldRushConfig));

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            '$_dir/gre_bg.jpg',
            fit: BoxFit.cover,
            alignment: const Alignment(0, 0.3),
          ),
          SafeArea(
            top: false,
            bottom: false,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final h = constraints.maxHeight;
                final w = constraints.maxWidth;
                final side = h * 0.34;
                final frameH = [
                  h * 0.8,
                  (w - 2 * side) / 1.5,
                ].reduce((a, b) => a < b ? a : b);
                return Stack(
                  children: [
                    Positioned(
                      top: h * 0.1 + (h * 0.8 - frameH) / 2,
                      height: frameH,
                      left: 0,
                      right: 0,
                      child: const Center(child: _ReelArea()),
                    ),
                    Positioned(
                      top: h * 0.03,
                      left: h * 0.03,
                      right: h * 0.03,
                      height: h * 0.11,
                      child: _TopStrip(hiddenCents: session.pendingCents),
                    ),
                    Positioned(
                      left: h * 0.03,
                      width: side - h * 0.05,
                      top: h * 0.2,
                      bottom: h * 0.06,
                      child: const _BetAndWin(),
                    ),
                    Positioned(
                      right: h * 0.03,
                      width: side - h * 0.05,
                      top: h * 0.2,
                      bottom: h * 0.06,
                      child: const Center(child: _SpinButton()),
                    ),
                    if (session.inFreeSpins || session.freeSpinsTotalCents > 0)
                      Positioned(
                        top: h * 0.155,
                        left: 0,
                        right: 0,
                        child: Center(child: _FreeSpinsBanner(session)),
                      ),
                  ],
                );
              },
            ),
          ),
          if (!session.spinning && _isBigWin(session))
            _BigWinOverlay(
              key: ValueKey(session.spinId),
              cents: session.lastWinCents,
              jackpot: session.lastJackpotCents > 0,
            ),
        ],
      ),
    );
  }

  static bool _isBigWin(SlotState s) {
    final bet = goldRushConfig.betStepsCents[s.betIndex];
    return s.lastJackpotCents > 0 || s.lastWinCents >= bet * 10;
  }
}

class _TopStrip extends ConsumerWidget {
  const _TopStrip({required this.hiddenCents});

  final int hiddenCents;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jackpot = ref.watch(
      gameJackpotsProvider.select((m) => m[goldRushConfig.id]!),
    );
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
            CoinDisplay(height: h * 0.85, hiddenCents: hiddenCents),
            // Logo fills the gap between coins and jackpot, slightly taller
            // than the strip so it reads as the game's title.
            Expanded(
              child: OverflowBox(
                maxHeight: h * 1.45,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: h * 0.3),
                  child: Image.asset(
                    '$_dir/gre_logo.png',
                    height: h * 1.45,
                    fit: BoxFit.contain,
                    semanticLabel: 'Gold Rush Express',
                  ),
                ),
              ),
            ),
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

/// Reel frame art with the reels placed in its measured 5x3 window.
class _ReelArea extends ConsumerWidget {
  const _ReelArea();

  /// Inner window of gre_frame.png as fractions of its size (1536x1024 art).
  static const window = Rect.fromLTRB(0.104, 0.262, 0.896, 0.793);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(slotSessionProvider(goldRushConfig));
    final notifier = ref.read(slotSessionProvider(goldRushConfig).notifier);
    final haptics = ref.read(settingsProvider.notifier);

    return AspectRatio(
      aspectRatio: 3 / 2,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth, h = constraints.maxHeight;
          return Stack(
            children: [
              Positioned.fill(child: Image.asset('$_dir/gre_frame.png')),
              Positioned(
                left: window.left * w,
                top: window.top * h,
                width: window.width * w,
                height: window.height * h,
                child: SlotReels(
                  config: goldRushConfig,
                  result: session.result,
                  spinId: session.spinId,
                  onReelStop: haptics.tapFeedback,
                  onStopped: () {
                    notifier.reveal();
                    final s = ref.read(slotSessionProvider(goldRushConfig));
                    if (s.lastWinCents > 0 &&
                        ref.read(settingsProvider).vibration) {
                      HapticFeedback.mediumImpact();
                    }
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _BetAndWin extends ConsumerWidget {
  const _BetAndWin();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(slotSessionProvider(goldRushConfig));
    final notifier = ref.read(slotSessionProvider(goldRushConfig).notifier);
    final balance = ref.watch(walletProvider) - session.pendingCents;
    final steps = goldRushConfig.betStepsCents;
    final locked = session.spinning || session.inFreeSpins;
    final canUp =
        !locked &&
        session.betIndex < steps.length - 1 &&
        steps[session.betIndex + 1] <= balance;
    final canDown = !locked && session.betIndex > 0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _Panel(
              label: 'BET',
              width: w,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _RoundIconButton(
                    icon: Icons.remove_rounded,
                    label: 'Lower bet',
                    enabled: canDown,
                    onTap: () => notifier.changeBet(-1),
                  ),
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        formatCents(steps[session.betIndex])
                            .replaceAll('.00', ''),
                        style: AppText.number(20),
                      ),
                    ),
                  ),
                  _RoundIconButton(
                    icon: Icons.add_rounded,
                    label: 'Raise bet',
                    enabled: canUp,
                    onTap: () => notifier.changeBet(1),
                  ),
                ],
              ),
            ),
            SizedBox(height: w * 0.1),
            _Panel(
              label: 'WIN',
              width: w,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  formatCents(session.spinning ? 0 : session.lastWinCents),
                  style: AppText.gold(22),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.label, required this.width, required this.child});

  final String label;
  final double width;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
      decoration: BoxDecoration(
        color: AppColors.deepPurple.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.gold, width: 1.5),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: AppText.label(12).copyWith(color: const Color(0xFFCDB8F5)),
          ),
          const SizedBox(height: 4),
          SizedBox(height: 30, child: Center(child: child)),
        ],
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({
    required this.icon,
    required this.label,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: Opacity(
          opacity: enabled ? 1 : 0.35,
          child: Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.violet,
              border: Border.all(color: Colors.white54),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
        ),
      ),
    );
  }
}

/// Code-drawn 2.5D SPIN button; shows free spins left during the feature.
class _SpinButton extends ConsumerWidget {
  const _SpinButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(slotSessionProvider(goldRushConfig));
    return LayoutBuilder(
      builder: (context, constraints) => SpinButton(
        size: constraints.maxWidth.clamp(60.0, 130.0),
        spinning: session.spinning,
        freeSpinsLeft: session.freeSpinsLeft,
        onTap: () {
          ref.read(settingsProvider.notifier).tapFeedback();
          final outcome = ref
              .read(slotSessionProvider(goldRushConfig).notifier)
              .spin();
          if (outcome == SpinOutcome.notEnoughCoins) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                const SnackBar(
                  content: Text('Not enough coins. Lower your bet.'),
                  duration: Duration(seconds: 2),
                ),
              );
          }
        },
      ),
    );
  }
}

class _FreeSpinsBanner extends StatelessWidget {
  const _FreeSpinsBanner(this.session);

  final SlotState session;

  @override
  Widget build(BuildContext context) {
    final text = session.inFreeSpins
        ? 'FREE SPINS: ${session.freeSpinsLeft} LEFT  ·  WINS x3'
        : 'FREE SPINS WON ${formatCents(session.freeSpinsTotalCents)}';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF15A84A), Color(0xFF0B6B2E)],
        ),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: AppColors.gold, width: 1.5),
      ),
      child: Text(text, style: AppText.label(13)),
    );
  }
}

/// Celebration for wins of 10x bet or more; tap anywhere to close.
class _BigWinOverlay extends StatefulWidget {
  const _BigWinOverlay({super.key, required this.cents, required this.jackpot});

  final int cents;
  final bool jackpot;

  @override
  State<_BigWinOverlay> createState() => _BigWinOverlayState();
}

class _BigWinOverlayState extends State<_BigWinOverlay> {
  bool _visible = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _visible = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_visible) return const SizedBox.shrink();
    return GestureDetector(
      onTap: () => setState(() => _visible = false),
      child: ColoredBox(
        color: Colors.black54,
        child: Center(
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.4, end: 1),
            duration: const Duration(milliseconds: 500),
            curve: Curves.elasticOut,
            builder: (context, scale, child) =>
                Transform.scale(scale: scale, child: child),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.jackpot ? 'JACKPOT!' : 'BIG WIN',
                  style: AppText.gold(64),
                ),
                const SizedBox(height: 8),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: widget.cents.toDouble()),
                  duration: const Duration(milliseconds: 1500),
                  curve: Curves.easeOutCubic,
                  builder: (context, v, _) =>
                      Text(formatCents(v.round()), style: AppText.number(40)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
