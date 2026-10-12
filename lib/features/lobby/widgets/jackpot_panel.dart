import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';
import '../../../core/format.dart';
import '../../../economy/jackpot.dart';

/// Glowing pink "GRAND JACKPOT" plate with the live, ticking amount in gold.
class JackpotPanel extends ConsumerWidget {
  const JackpotPanel({super.key, required this.height});

  final double height;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cents = ref.watch(grandJackpotProvider);

    return Container(
      height: height,
      padding: EdgeInsets.symmetric(horizontal: height * 0.45),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFF6FC8), AppColors.hotPink, Color(0xFFB0127A)],
        ),
        borderRadius: BorderRadius.circular(height * 0.5),
        border: Border.all(color: const Color(0xFFFFD6F0), width: 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.hotPink.withValues(alpha: 0.7),
            blurRadius: 14,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('GRAND JACKPOT', style: AppText.label(height * 0.36)),
          SizedBox(width: height * 0.3),
          // Fixed-width digits stop the text jittering as the value ticks.
          Text(
            formatCents(cents),
            style: AppText.gold(height * 0.48)
                .copyWith(fontFeatures: const [FontFeature.tabularFigures()]),
          ),
        ],
      ),
    );
  }
}
