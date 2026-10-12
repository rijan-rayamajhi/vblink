import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../economy/game_jackpots.dart';
import '../../economy/jackpot.dart';
import '../../economy/wallet.dart';
import '../../features/profile/player.dart';
import 'slot_config.dart';
import 'slot_math.dart';

class SlotState {
  const SlotState({
    required this.betIndex,
    this.result,
    this.spinId = 0,
    this.spinning = false,
    this.freeSpinsLeft = 0,
    this.freeSpinsTotalCents = 0,
    this.lastWinCents = 0,
    this.pendingCents = 0,
    this.lastJackpotCents = 0,
    this.levelsGained = 0,
  });

  final int betIndex;
  final SpinResult? result;

  /// Bumps on every spin so the reels know to animate.
  final int spinId;
  final bool spinning;
  final int freeSpinsLeft;
  final int freeSpinsTotalCents;

  /// Shown in the WIN box once the reels stop.
  final int lastWinCents;

  /// Already credited to the wallet but hidden until the reels stop.
  final int pendingCents;
  final int lastJackpotCents;
  final int levelsGained;

  bool get inFreeSpins => freeSpinsLeft > 0;

  SlotState copyWith({
    int? betIndex,
    SpinResult? result,
    int? spinId,
    bool? spinning,
    int? freeSpinsLeft,
    int? freeSpinsTotalCents,
    int? lastWinCents,
    int? pendingCents,
    int? lastJackpotCents,
    int? levelsGained,
  }) => SlotState(
    betIndex: betIndex ?? this.betIndex,
    result: result ?? this.result,
    spinId: spinId ?? this.spinId,
    spinning: spinning ?? this.spinning,
    freeSpinsLeft: freeSpinsLeft ?? this.freeSpinsLeft,
    freeSpinsTotalCents: freeSpinsTotalCents ?? this.freeSpinsTotalCents,
    lastWinCents: lastWinCents ?? this.lastWinCents,
    pendingCents: pendingCents ?? this.pendingCents,
    lastJackpotCents: lastJackpotCents ?? this.lastJackpotCents,
    levelsGained: levelsGained ?? this.levelsGained,
  );
}

enum SpinOutcome { started, busy, notEnoughCoins }

/// One slot game's session: bet, spins, free spins, and settling money.
///
/// The result is decided and the wallet settled the moment SPIN is pressed,
/// so closing the app mid-animation can never lose or duplicate coins. The
/// win is only *shown* once [reveal] is called after the reels stop.
final slotSessionProvider = NotifierProvider.autoDispose
    .family<SlotSessionNotifier, SlotState, SlotConfig>(
      SlotSessionNotifier.new,
    );

class SlotSessionNotifier extends Notifier<SlotState> {
  SlotSessionNotifier(this.config);

  final SlotConfig config;
  late final SlotMath _math = SlotMath(config);

  /// Swappable for tests; the app always uses a secure generator.
  static Random Function() rng = Random.secure;
  late final Random _rng = rng();

  /// Shares of each paid bet that feed the jackpots.
  static const gameJackpotShare = 0.01;
  static const grandJackpotShare = 0.005;

  @override
  SlotState build() => const SlotState(betIndex: 2);

  int get betCents => config.betStepsCents[state.betIndex];

  void changeBet(int delta) {
    if (state.spinning || state.inFreeSpins) return;
    final i = (state.betIndex + delta).clamp(
      0,
      config.betStepsCents.length - 1,
    );
    state = state.copyWith(betIndex: i);
  }

  SpinOutcome spin() {
    if (state.spinning) return SpinOutcome.busy;
    final free = state.inFreeSpins;
    final bet = betCents;
    final wallet = ref.read(walletProvider.notifier);
    if (!free && !wallet.spend(bet)) return SpinOutcome.notEnoughCoins;

    final result = _math.spin(_rng, totalBetCents: bet, freeSpin: free);
    final jackpots = ref.read(gameJackpotsProvider.notifier);

    // Jackpot scales with bet: max bet wins it all.
    final jackpotPay = result.jackpotHit
        ? jackpots.claim(config.id, bet / config.maxBetCents)
        : 0;
    final win = result.totalCents + jackpotPay;
    wallet.add(win);

    if (!free) {
      jackpots.contribute(config.id, (bet * gameJackpotShare).round());
      ref
          .read(grandJackpotProvider.notifier)
          .contribute((bet * grandJackpotShare).round());
    }
    final levels = ref
        .read(playerProvider.notifier)
        .recordSpin(betCents: free ? 0 : bet, winCents: win);

    final left = free
        ? state.freeSpinsLeft - 1 + result.freeSpinsAwarded
        : result.freeSpinsAwarded;
    state = state.copyWith(
      result: result,
      spinId: state.spinId + 1,
      spinning: true,
      freeSpinsLeft: left,
      freeSpinsTotalCents: free || left > 0
          ? state.freeSpinsTotalCents + (free ? win : 0)
          : 0,
      pendingCents: win,
      lastJackpotCents: jackpotPay,
      levelsGained: levels,
    );
    return SpinOutcome.started;
  }

  /// Called when the reels finish: shows the win.
  void reveal() {
    if (!state.spinning) return;
    state = state.copyWith(
      spinning: false,
      lastWinCents: state.pendingCents,
      pendingCents: 0,
    );
  }

  /// Starts a fresh free-spins tally (after the summary has been shown).
  void clearFreeSpinsTotal() => state = state.copyWith(freeSpinsTotalCents: 0);
}
