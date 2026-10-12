import 'package:flutter/material.dart';

import '../../../app/theme.dart';
import '../data/games.dart';
import 'game_tile.dart';
import 'host_banner.dart';

/// Framed panel: host banner, the big featured game, then a 2x2 grid.
class GamesPanel extends StatelessWidget {
  const GamesPanel({super.key});

  void _openGame(BuildContext context, GameInfo game) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('${game.title} is coming soon!'),
          duration: const Duration(seconds: 2),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final h = constraints.maxHeight;
        final pad = h * 0.06;
        final gap = h * 0.045;
        final inner = h - 2 * pad;
        // Room above each tile for its jackpot pill.
        final pillRoom = inner * 0.07;
        final tileArea = inner - pillRoom;
        final small = (tileArea - pillRoom - gap) / 2;

        final panel = Container(
          padding: EdgeInsets.all(pad),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xFF3A5BFF).withValues(alpha: 0.55),
                AppColors.royalPurple.withValues(alpha: 0.85),
              ],
            ),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: const Color(0xFF8FA8FF).withValues(alpha: 0.8),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF3A5BFF).withValues(alpha: 0.35),
                blurRadius: 18,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: inner * 0.62,
                height: inner,
                child: const HostBanner(),
              ),
              SizedBox(width: gap),
              Padding(
                padding: EdgeInsets.only(top: pillRoom),
                child: SizedBox(
                  width: tileArea * 0.64,
                  height: tileArea,
                  child: GameTile(
                    game: featuredGame,
                    onTap: () => _openGame(context, featuredGame),
                  ),
                ),
              ),
              SizedBox(width: gap),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  for (var row = 0; row < 2; row++)
                    Padding(
                      padding: EdgeInsets.only(top: pillRoom),
                      child: Row(
                        children: [
                          for (var col = 0; col < 2; col++) ...[
                            if (col == 1) SizedBox(width: gap),
                            SizedBox.square(
                              dimension: small,
                              child: GameTile(
                                game: gridGames[row * 2 + col],
                                onTap: () => _openGame(
                                  context,
                                  gridGames[row * 2 + col],
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
        );

        // Shrink as a whole on narrow screens instead of overflowing.
        return Center(
          child: FittedBox(fit: BoxFit.scaleDown, child: panel),
        );
      },
    );
  }
}
