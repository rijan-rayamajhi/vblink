import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';
import '../../../core/format.dart';
import '../../../economy/game_jackpots.dart';
import '../data/games.dart';

/// A game cover with its live jackpot pill on top and a HOT/NEW badge.
/// Shrinks slightly while pressed.
class GameTile extends ConsumerStatefulWidget {
  const GameTile({super.key, required this.game, required this.onTap});

  final GameInfo game;
  final VoidCallback onTap;

  @override
  ConsumerState<GameTile> createState() => _GameTileState();
}

class _GameTileState extends ConsumerState<GameTile> {
  bool _pressed = false;

  void _setPressed(bool value) => setState(() => _pressed = value);

  @override
  Widget build(BuildContext context) {
    final game = widget.game;
    final cents = ref.watch(gameJackpotsProvider.select((m) => m[game.id]!));

    return GestureDetector(
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.94 : 1,
        duration: const Duration(milliseconds: 90),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            final pillH = (w * 0.16).clamp(14.0, 30.0);
            return Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(child: _Cover(game: game)),
                Positioned(
                  top: -pillH * 0.35,
                  left: w * 0.1,
                  right: w * 0.1,
                  height: pillH,
                  child: _JackpotPill(cents: cents),
                ),
                Positioned(
                  top: pillH * 0.85,
                  left: -2,
                  child: _Badge(badge: game.badge, height: pillH * 0.95),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Cover extends StatelessWidget {
  const _Cover({required this.game});

  final GameInfo game;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Color(0x99000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: DecoratedBox(
        position: DecorationPosition.foreground,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.violet, width: 2),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: game.art != null
              ? Image.asset(game.art!, fit: BoxFit.cover)
              : _PlaceholderArt(game: game),
        ),
      ),
    );
  }
}

/// Gradient with the title, until the real cover art arrives.
class _PlaceholderArt extends StatelessWidget {
  const _PlaceholderArt({required this.game});

  final GameInfo game;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: game.colors,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              game.title.replaceFirst(' ', '\n'),
              textAlign: TextAlign.center,
              style: AppText.gold(22),
            ),
          ),
        ),
      ),
    );
  }
}

class _JackpotPill extends StatelessWidget {
  const _JackpotPill({required this.cents});

  final int cents;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: AppColors.deepPurple,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: AppColors.violet, width: 1.5),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          formatCents(cents),
          style: AppText.number(13)
              .copyWith(fontFeatures: const [FontFeature.tabularFigures()]),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.badge, required this.height});

  final GameBadge badge;
  final double height;

  @override
  Widget build(BuildContext context) {
    final hot = badge == GameBadge.hot;
    return Container(
      height: height,
      padding: EdgeInsets.symmetric(horizontal: height * 0.35),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: hot
              ? const [Color(0xFFFFC93C), Color(0xFFFF5A1F)]
              : const [Color(0xFF7CFF6B), Color(0xFF15A84A)],
        ),
        borderRadius: BorderRadius.circular(height * 0.3),
        border: Border.all(color: Colors.white, width: 1.2),
      ),
      child: Text(
        hot ? 'HOT' : 'NEW',
        style: AppText.label(height * 0.58)
            .copyWith(fontStyle: FontStyle.italic),
      ),
    );
  }
}
