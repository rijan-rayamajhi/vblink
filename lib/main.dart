import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/theme.dart';
import 'core/storage.dart';
import 'features/lobby/lobby_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  // Full-screen game feel: hide status and navigation bars.
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  // Load saved progress before the first frame so the lobby never flashes
  // default values.
  final storage = await Storage.load();
  runApp(
    ProviderScope(
      overrides: [storageProvider.overrideWithValue(storage)],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vblink',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: const LobbyScreen(),
    );
  }
}
