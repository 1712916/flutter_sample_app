import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../pikachu_game_screen.dart';

/// Demo app to test the Pikachu game standalone
class PikachuGameDemo extends StatelessWidget {
  const PikachuGameDemo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pikachu Game Demo',
      theme: ThemeData(
        primarySwatch: Colors.yellow,
        useMaterial3: true,
      ),
      home: const PikachuGameScreen(),
      builder: (context, child) {
        // Force landscape mode for the demo
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ]);
        return child!;
      },
    );
  }
}

void main() {
  runApp(const PikachuGameDemo());
}
