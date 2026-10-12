import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';
import '../../../core/format.dart';
import '../../../economy/wallet.dart';

/// Coin icon overlapping a dark pill with the balance.
/// The number rolls smoothly to its new value whenever the balance changes.
class CoinDisplay extends ConsumerWidget {
  const CoinDisplay({super.key, required this.height});

  final double height;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cents = ref.watch(walletProvider);
    final coinSize = height * 1.05;

    return SizedBox(
      height: height,
      width: height * 5.2,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.centerLeft,
        children: [
          Positioned(
            left: coinSize * 0.5,
            right: 0,
            top: height * 0.12,
            bottom: height * 0.12,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.deepPurple.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(height),
                border: Border.all(
                  color: AppColors.violet.withValues(alpha: 0.8),
                  width: 1.5,
                ),
              ),
              child: Padding(
                padding: EdgeInsets.only(
                  left: coinSize * 0.6,
                  right: height * 0.35,
                ),
                child: Align(
                  alignment: Alignment.center,
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(end: cents.toDouble()),
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, _) => FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        formatCents(value.round()),
                        style: AppText.number(height * 0.42),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Image.asset(
            'assets/images/icon_coin.png',
            width: coinSize,
            height: coinSize,
          ),
        ],
      ),
    );
  }
}
