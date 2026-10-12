import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:vblink/features/lobby/lobby_screen.dart';
import 'package:vblink/features/lobby/widgets/bottom_bar.dart';
import 'package:vblink/features/lobby/widgets/coin_display.dart';
import 'package:vblink/features/lobby/widgets/jackpot_panel.dart';
import 'package:vblink/features/lobby/widgets/lobby_background.dart';
import 'package:vblink/features/lobby/widgets/top_bar.dart';
import 'package:vblink/main.dart';

// Landscape logical sizes: iPhone 18 Pro, small iPhone, iPad Pro 13".
const _screens = {
  'iPhone 18 Pro': Size(874, 402),
  'small iPhone': Size(667, 375),
  'iPad Pro 13"': Size(1376, 1032),
};

void main() {
  for (final MapEntry(key: name, value: size) in _screens.entries) {
    testWidgets('Lobby lays out without overflow on $name', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(const ProviderScope(child: MyApp()));
      await tester.pump(const Duration(seconds: 1));

      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('App opens on the lobby with its main parts', (tester) async {
    tester.view.physicalSize = const Size(874, 402);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const ProviderScope(child: MyApp()));
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(LobbyScreen), findsOneWidget);
    expect(find.byType(LobbyBackground), findsOneWidget);
    expect(find.byType(TopBar), findsOneWidget);
    expect(find.byType(BottomBar), findsOneWidget);
    expect(find.byType(CoinDisplay), findsOneWidget);
    expect(find.byType(JackpotPanel), findsOneWidget);
    expect(find.text('10,000.00'), findsOneWidget);
    expect(find.text('GRAND JACKPOT'), findsOneWidget);
  });
}
