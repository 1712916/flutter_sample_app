import 'package:flutter/material.dart';

import 'feature/game_memory/widget/image_selection_widget.dart';

// Điểm khởi đầu của ứng dụng
void main() {
  runApp(const MemoryGameApp());
}

// Ứng dụng chính, khởi tạo MaterialApp
class MemoryGameApp extends StatelessWidget {
  const MemoryGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ImageSelectionScreen(
        onSubmitImage: (imagePaths) {},
      ),
    );
  }
}
