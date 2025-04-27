import 'dart:math';

import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';
import 'package:meow_app/widgets/image_view.dart';

import 'feature/game_matching/widget/image_selection_widget.dart';

// Điểm khởi đầu của ứng dụng
void main() {
  runApp(const MemoryGameApp());
}

// Ứng dụng chính, khởi tạo MaterialApp
class MemoryGameApp extends StatelessWidget {
  const MemoryGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: ImageSelectionScreen(),
    );
  }
}

// Màn hình trò chơi chính, nhận danh sách đường dẫn ảnh qua constructor
class MemoryGameScreen extends StatefulWidget {
  final List<String> imagePaths; // Danh sách đường dẫn ảnh

  const MemoryGameScreen({super.key, required this.imagePaths});

  @override
  _MemoryGameScreenState createState() => _MemoryGameScreenState();
}

class _MemoryGameScreenState extends State<MemoryGameScreen> with SingleTickerProviderStateMixin {
  // Danh sách nội dung thẻ (đường dẫn ảnh)
  late List<String> _cardContents;
  // Danh sách nội dung đã xáo trộn
  late List<String> _scrambledContents;
  // Danh sách controller cho mỗi thẻ
  late List<GlobalKey<FlipCardState>> _cardKeys;
  // Trạng thái thẻ đã ghép
  late List<bool> _matchedCards;
  // Chỉ số thẻ đầu tiên được lật
  int? _firstCardIndex;
  // Đang xử lý lật thẻ
  bool _isFlipping = false;
  // Đếm số lần lật thẻ
  int _flipCount = 0;
  // Controller cho hiệu ứng rung khi ghép sai
  late AnimationController _shakeController;

  @override
  void initState() {
    super.initState();
    // Tạo danh sách nội dung từ đường dẫn ảnh (mỗi ảnh lặp lại 2 lần)
    _cardContents = widget.imagePaths.expand((path) => [path, path]).toList();
    // Khởi tạo trạng thái trò chơi
    _resetGame();
    // Khởi tạo controller cho hiệu ứng rung
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  // Khởi tạo hoặc reset trò chơi
  void _resetGame() {
    setState(() {
      _scrambledContents = [..._cardContents]..shuffle(Random());
      _cardKeys = List.generate(_scrambledContents.length, (_) => GlobalKey<FlipCardState>());
      _matchedCards = List.filled(_scrambledContents.length, false);
      _firstCardIndex = null;
      _isFlipping = false;
      _flipCount = 0;
    });
  }

  // Xử lý khi nhấp vào thẻ
  Future<void> _onCardTapped(int index) async {
    // Ngăn nhấp khi đang xử lý, thẻ đã ghép, hoặc nhấp lại vào thẻ đã lật
    if (_isFlipping || _matchedCards[index] || _firstCardIndex == index) return;

    setState(() {
      _isFlipping = true;
      _flipCount++;
    });

    // Lật thẻ
    _cardKeys[index].currentState?.toggleCard();

    // Chờ hiệu ứng lật hoàn tất
    await Future.delayed(const Duration(milliseconds: 600));

    setState(() {
      if (_firstCardIndex == null) {
        // Lật thẻ đầu tiên
        _firstCardIndex = index;
      } else {
        // Lật thẻ thứ hai, kiểm tra ghép
        if (_scrambledContents[_firstCardIndex!] == _scrambledContents[index]) {
          // Ghép đúng
          _matchedCards[_firstCardIndex!] = true;
          _matchedCards[index] = true;

          // Kiểm tra chiến thắng
          if (_matchedCards.every((matched) => matched)) {
            _showWinDialog();
          }
        } else {
          // Ghép sai, lật lại thẻ và thêm hiệu ứng rung
          _shakeController.forward().then((_) => _shakeController.reset());
          _cardKeys[_firstCardIndex!].currentState?.toggleCard();
          _cardKeys[index].currentState?.toggleCard();
        }
        _firstCardIndex = null;
      }
      _isFlipping = false;
    });
  }

  // Hiển thị dialog khi thắng
  void _showWinDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chúc mừng!'),
        content: Text('Bạn đã ghép hết tất cả cặp! Số lần lật: $_flipCount'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _resetGame();
            },
            child: const Text('Chơi lại'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context); // Quay lại ImageSelectionScreen
            },
            child: const Text('Chọn ảnh khác'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Memory Game'),
        actions: [
          // Nút reset trò chơi
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetGame,
          ),
        ],
      ),
      body: Column(
        children: [
          // Hiển thị số lần lật
          // Padding(
          //   padding: const EdgeInsets.all(8.0),
          //   child: Text(
          //     'Số lần lật: $_flipCount',
          //     style: const TextStyle(fontSize: 18),
          //   ),
          // ),
          // Lưới thẻ
          Flexible(
            child: GridView.builder(
              padding: const EdgeInsets.all(8.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 1,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
              ),
              itemCount: _scrambledContents.length,
              itemBuilder: (context, index) {
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  child: _matchedCards[index]
                      ? const SizedBox() // Ẩn thẻ đã ghép
                      : GestureDetector(
                          onTap: () => _onCardTapped(index),
                          child: AnimatedBuilder(
                            animation: _shakeController,
                            builder: (context, child) {
                              // Thêm hiệu ứng rung khi ghép sai
                              final offset = sin(_shakeController.value * pi * 4) * 2;
                              return Transform.translate(
                                offset: Offset(offset, 0),
                                child: child,
                              );
                            },
                            child: FlipCard(
                              key: _cardKeys[index],
                              direction: FlipDirection.HORIZONTAL,
                              front: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.white30),
                                  color: Colors.black38,
                                ),
                                alignment: Alignment.center,
                                child: SizedBox(
                                  width: 60,
                                  height: 60,
                                  child: Image.asset('assets/icon/icon.png'),
                                ),
                              ),
                              back: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.white30),
                                  color: Colors.black38,
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: AppImage(
                                    image: _scrambledContents[index],
                                  ),
                                ),
                              ),
                              flipOnTouch: false,
                              fill: Fill.fillBack,
                            ),
                          ),
                        ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
