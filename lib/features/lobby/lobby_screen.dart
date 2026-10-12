import 'package:flutter/material.dart';

import 'widgets/bottom_bar.dart';
import 'widgets/games_panel.dart';
import 'widgets/lobby_background.dart';
import 'widgets/top_bar.dart';

/// Main lobby: top bar, game panel, bottom reward bar over the city backdrop.
/// Sizes are fractions of screen height so phones and iPads scale alike.
class LobbyScreen extends StatelessWidget {
  const LobbyScreen({super.key});

  static const topBarFraction = 0.095;
  static const bottomBarFraction = 0.19;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const LobbyBackground(),
          LayoutBuilder(
            builder: (context, constraints) {
              final h = constraints.maxHeight;
              return Column(
                children: [
                  SizedBox(height: h * topBarFraction, child: const TopBar()),
                  Expanded(
                    child: SafeArea(
                      top: false,
                      bottom: false,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          h * 0.04,
                          h * 0.05,
                          h * 0.04,
                          h * 0.04,
                        ),
                        child: const GamesPanel(),
                      ),
                    ),
                  ),
                  SafeArea(
                    top: false,
                    bottom: false,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: h * 0.12),
                      child: SizedBox(
                        height: h * bottomBarFraction,
                        child: const BottomBar(),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
