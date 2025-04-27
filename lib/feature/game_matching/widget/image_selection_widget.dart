import 'dart:async'; // Để sử dụng Timer
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../main_4.dart';
import '../../favourite/favourite_page.dart';
import '../../image/cubit/image_list_cubit.dart';

/// Span ngang thì theo từng ảnh
/// Span dọc là theo nguyên hàng
/// Chọn ngay lập tức, nhưng khóa ô trong 100ms để ngăn cập nhật trạng thái liên tục

// Màn hình chọn ảnh
class ImageSelectionScreen extends StatefulWidget {
  const ImageSelectionScreen({super.key});

  @override
  _ImageSelectionScreenState createState() => _ImageSelectionScreenState();
}

class _ImageSelectionScreenState extends State<ImageSelectionScreen> {
  // Danh sách trạng thái chọn ảnh
  Set<int> _selectedImages = {};
  // Số lượng ảnh tối thiểu và tối đa
  static const int _minImages = 2;
  static const int _maxImages = 116;
  // Trạng thái kéo (true = chọn, false = bỏ chọn)
  bool? _dragSelectionMode;
  // GlobalKey để truy cập kích thước GridView
  final GlobalKey _gridKey = GlobalKey();
  // ScrollController để theo dõi vị trí cuộn
  final ScrollController _scrollController = ScrollController();
  // Danh sách các ô bị khóa (không cho cập nhật trạng thái)
  final Set<int> _lockedIndices = {};
  // Danh sách timer để mở khóa ô
  final Map<int, Timer> _lockTimers = {};

  // Xử lý khi nhấp vào ảnh
  void _toggleImageSelection(int index) {
    setState(() {
      if (_selectedImages.contains(index)) {
        _selectedImages.remove(index);
      } else {
        if (_selectedImages.length >= _maxImages) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Bạn chỉ có thể chọn tối đa 116 ảnh!')),
          );
          return;
        }
        _selectedImages.add(index);
      }
    });
  }

  // Đếm số ảnh đã chọn
  int _getSelectedCount() {
    return _selectedImages.length;
  }

  // Xử lý bắt đầu trò chơi
  void _startGame() {
    final selectedCount = _getSelectedCount();
    if (selectedCount < _minImages) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn ít nhất 2 ảnh!')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MemoryGameScreen(
          imagePaths: _selectedImages.map((index) => context.read<ImageListCubit>().state.images![index].url!).toList(),
        ),
      ),
    );
  }

  /// Tính chỉ số ô trong lưới từ tọa độ con trỏ, có tính đến vị trí cuộn
  /// [localPosition]: Tọa độ con trỏ tương đối so với GridView
  /// [gridSize]: Kích thước của GridView
  /// [itemCount]: Số lượng ô trong lưới
  /// [scrollOffset]: Vị trí cuộn hiện tại của GridView
  /// [delta]: Độ dịch chuyển của con trỏ để xác định hướng kéo
  /// Trả về danh sách chỉ số (một ảnh nếu kéo ngang, cả hàng nếu kéo dọc) hoặc null nếu không hợp lệ
  List<int>? _getGridIndex(Offset localPosition, Size gridSize, int itemCount, double scrollOffset, Offset delta) {
    const crossAxisCount = 3; // Số cột cố định
    final itemWidth = gridSize.width / crossAxisCount;
    final itemHeight = itemWidth; // Giả định tỷ lệ 1:1 (childAspectRatio = 1)

    // Điều chỉnh tọa độ y bằng scroll offset
    final adjustedY = localPosition.dy + scrollOffset;

    // Tính toán hàng và cột
    final column = (localPosition.dx / itemWidth).floor();
    final row = (adjustedY / itemHeight).floor();

    // Kiểm tra tính hợp lệ của hàng và cột
    if (row < 0 || row >= (itemCount / crossAxisCount).ceil() || column < 0 || column >= crossAxisCount) {
      return null;
    }

    // Xác định hướng kéo
    final isHorizontal = delta.dx.abs() > delta.dy.abs();

    if (isHorizontal) {
      // Kéo ngang: chọn một ảnh
      final index = row * crossAxisCount + column;
      if (index >= 0 && index < itemCount) {
        return [index];
      }
    } else {
      // Kéo dọc: chọn cả hàng
      final startIndex = row * crossAxisCount;
      final endIndex = startIndex + crossAxisCount;
      final indices = <int>[];
      for (int i = startIndex; i < endIndex && i < itemCount; i++) {
        indices.add(i);
      }
      return indices;
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chọn ảnh cho trò chơi'),
      ),
      body: Column(
        children: [
          // Hiển thị số ảnh đã chọn
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Đã chọn: ${_getSelectedCount()}/$_maxImages ảnh',
              style: const TextStyle(fontSize: 18),
            ),
          ),
          // Lưới ảnh
          Expanded(
            child: BlocBuilder<ImageListCubit, ImageListState>(builder: (context, state) {
              final images = state.images!;
              final itemSize = MediaQuery.of(context).size.width / 3 - 16; // 3 cột, padding 8 mỗi bên

              return GestureDetector(
                onPanUpdate: (details) {
                  final renderBox = _gridKey.currentContext?.findRenderObject() as RenderBox?;
                  if (renderBox == null) return;

                  final localPosition = renderBox.globalToLocal(details.globalPosition);
                  final indices = _getGridIndex(
                    localPosition,
                    renderBox.size,
                    images.length,
                    _scrollController.offset,
                    details.delta,
                  );

                  log('indices: $indices');

                  if (indices != null) {
                    setState(() {
                      // if (_dragSelectionMode == null) {
                      //   _dragSelectionMode = !_selectedImages.contains(indices[0]);
                      // }
                      final timerDuration = const Duration(milliseconds: 200);
                      for (final index in indices) {
                        // Chỉ xử lý nếu ô không bị khóa
                        if (_lockTimers.containsKey(index)) {
                          _lockTimers[index]?.cancel();
                          _lockTimers[index] = Timer(timerDuration, () {
                            _lockTimers.remove(index);
                          });
                        } else {
                          if (!_selectedImages.contains(index)) {
                            if (_selectedImages.length < _maxImages) {
                              _selectedImages.add(index);
                            }
                          } else if (_selectedImages.contains(index)) {
                            _selectedImages.remove(index);
                          }

                          _lockTimers[index]?.cancel();
                          _lockTimers[index] = Timer(timerDuration, () {
                            _lockTimers.remove(index);
                          });
                        }
                      }
                    });
                  }
                },
                onPanEnd: (details) {
                  _lockTimers.forEach((_, timer) => timer.cancel());
                  _lockTimers.clear();
                  _lockedIndices.clear();
                  setState(() {
                    _dragSelectionMode = null;
                  });
                },
                child: GridView.builder(
                  key: _gridKey,
                  controller: _scrollController,
                  padding: const EdgeInsets.all(8.0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 1,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: state.images?.length ?? 0,
                  itemBuilder: (context, index) {
                    return SelectionImageWidget(
                      url: state.images![index].url!,
                      isSelected: _selectedImages.contains(index),
                      onSelected: (value) {
                        switch (value) {
                          case true:
                            if (_getSelectedCount() >= _maxImages) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Bạn chỉ có thể chọn tối đa 116 ảnh!')),
                              );
                              return;
                            }
                            setState(() {
                              _selectedImages.add(index);
                            });
                            break;
                          case false:
                            setState(() {
                              _selectedImages.remove(index);
                            });
                            break;
                        }
                      },
                    );
                  },
                ),
              );
            }),
          ),
          // Nút bắt đầu chơi
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _startGame,
              child: const Text('Bắt đầu chơi'),
            ),
          ),
        ],
      ),
    );
  }
}

void gotoSelectImages(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const ImageSelectionScreen(),
    ),
  );
}
