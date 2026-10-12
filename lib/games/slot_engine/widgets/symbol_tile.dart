import 'package:flutter/material.dart';

import '../../../app/theme.dart';
import '../slot_config.dart';

/// One reel symbol: the art if it exists, else a colored placeholder tile.
class SymbolTile extends StatelessWidget {
  const SymbolTile({super.key, required this.symbol, this.highlight = false});

  final SlotSymbol symbol;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final child = symbol.asset != null
        // Art has its own padding; scale up so it fills the cell like the
        // placeholder tiles do.
        ? Transform.scale(
            scale: 1.2,
            child: Image.asset(symbol.asset!, fit: BoxFit.contain),
          )
        : _Placeholder(symbol: symbol);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: highlight
            ? Border.all(color: AppColors.gold, width: 3)
            : Border.all(color: Colors.transparent, width: 3),
        boxShadow: highlight
            ? [
                BoxShadow(
                  color: AppColors.gold.withValues(alpha: 0.8),
                  blurRadius: 12,
                ),
              ]
            : null,
      ),
      child: child,
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.symbol});

  final SlotSymbol symbol;

  @override
  Widget build(BuildContext context) {
    final base = Color(symbol.color);
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color.lerp(base, Colors.white, 0.25)!, base],
        ),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.7)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              symbol.label,
              textAlign: TextAlign.center,
              style: AppText.gold(30).copyWith(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
