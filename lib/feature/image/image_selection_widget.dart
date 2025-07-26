import 'dart:async'; // Để sử dụng Timer

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:meow_app/resources/theme/theme_data.dart';

import '../../core/util/image_util.dart';
import '../../widgets/widgets.dart';
import '../favourite/favourite_page.dart';
import 'cubit/image_list_cubit.dart';

/// Span ngang thì theo từng ảnh
/// Span dọc là theo nguyên hàng
/// Chọn ngay lập tức, nhưng khóa ô trong 200ms để ngăn cập nhật trạng thái liên tục
/// Cuộn ngay lập tức, mượt mà với tốc độ cố định ổn định khi kéo vượt ranh giới trang, tính toán chỉ số ô với padding

// Màn hình chọn ảnh
class ImageSelectionScreen extends StatefulWidget {
  ImageSelectionScreen({
    super.key,
    this.maxImage = 1,
    this.minImage = 1,
    required this.onSubmitImage,
    this.selectImageTitle = 'Choose Image',
  }) {
    assert(maxImage > 0, 'maxImage must be greater than 0');
    assert(minImage > 0, 'minImage must be greater than 0');
    assert(minImage <= maxImage, 'minImage must be less than or equal to maxImage');
  }

  final int minImage;
  final int maxImage;
  final Function(List<String> imagePaths) onSubmitImage;
  final String selectImageTitle;

  // Static key for auto-play access
  static final GlobalKey<_ImageSelectionScreenState> autoPlayKey = GlobalKey<_ImageSelectionScreenState>();

  @override
  _ImageSelectionScreenState createState() => _ImageSelectionScreenState();
}

class _ImageSelectionScreenState extends State<ImageSelectionScreen> {
  // Danh sách trạng thái chọn ảnh
  Set<int> _selectedImages = {};
  // Số lượng ảnh tối thiểu và tối đa
  int get _minImages => widget.minImage;
  int get _maxImages => widget.maxImage;
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
  // Timer cho tự động cuộn
  Timer? _scrollTimer;

  // Đếm số ảnh đã chọn
  int _getSelectedCount() {
    return _selectedImages.length;
  }

  // Method for auto-play to select images automatically
  void autoSelectImages(Set<int> indices) {
    if (mounted) {
      setState(() {
        _selectedImages.clear();
        _selectedImages.addAll(indices.take(_maxImages));
      });
    }
  }

  // Method for auto-play to start the game
  void autoStartGame() {
    if (mounted && _getSelectedCount() >= _minImages) {
      _startGame();
    }
  }

  // Xử lý bắt đầu trò chơi
  void _startGame() {
    final selectedCount = _getSelectedCount();
    if (selectedCount < _minImages) {
      SnackBarUtils.show(
        context,
        LKey.requireSelectImageDescription.tr(
          context: context,
          namedArgs: {
            "number": _minImages.toString(),
          },
        ),
      );

      return;
    }

    final imagePaths =
        _selectedImages.map((index) => context.read<ImageListCubit>().state.images![index].url!).toList();
    widget.onSubmitImage(imagePaths);
  }

  /// Tính chỉ số ô trong lưới từ tọa độ con trỏ, có tính đến vị trí cuộn và padding
  /// [localPosition]: Tọa độ con trỏ tương đối so với GridView
  /// [gridSize]: Kích thước của GridView
  /// [itemCount]: Số lượng ô trong lưới
  /// [scrollOffset]: Vị trí cuộn hiện tại của GridView
  /// [delta]: Độ dịch chuyển của con trỏ để xác định hướng kéo
  /// Trả về danh sách chỉ số (một ảnh nếu kéo ngang, cả hàng nếu kéo dọc) hoặc null nếu không hợp lệ
  List<int>? _getGridIndex(Offset localPosition, Size gridSize, int itemCount, double scrollOffset, Offset delta) {
    const crossAxisCount = 3; // Số cột cố định
    const paddingHorizontal = 8.0; // Padding trái và phải
    const paddingVertical = 80.0; // Padding trên
    final itemWidth = (gridSize.width - 2 * paddingHorizontal) / crossAxisCount;
    final itemHeight = itemWidth; // Giả định tỷ lệ 1:1 (childAspectRatio = 1)

    // Điều chỉnh tọa độ với padding và scroll offset
    final adjustedX = localPosition.dx - paddingHorizontal;
    final adjustedY = localPosition.dy + scrollOffset - paddingVertical;

    // Tính toán hàng và cột
    final column = (adjustedX / itemWidth).floor();
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
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: LText(LKey.choose),
        elevation: 0,
        actions: [
          ElevatedButton(
            onPressed: () {
              //clear selected
              setState(() {
                _selectedImages.clear();
              });
            },
            child: LText(
              LKey.clear,
              style: theme.textTheme.titleMedium,
            ),
          ),
          SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          // Lưới ảnh
          BlocBuilder<ImageListCubit, ImageListState>(builder: (context, state) {
            if (state.images == null || state.images!.isEmpty) {
              return RefreshIndicator(
                onRefresh: context.read<ImageListCubit>().refreshData,
                child: ListView(
                  children: [
                    const SizedBox(height: 100),
                    Icon(
                      HugeIcons.strokeRoundedFileEmpty02,
                      size: 64,
                    ),
                    const SizedBox(height: 4),
                    Center(
                      child: LText(
                        LKey.emptyData,
                        style: theme.textTheme.titleMedium,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          context.read<ImageListCubit>().refreshData();
                        },
                        child: LText(
                          LKey.refreshData,
                          style: theme.textTheme.titleMedium,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            final count = state.images?.length ?? 0;
            final w = MediaQuery.of(context).size.width;
            const crossAxisCount = 3;

            return GridView.builder(
              key: _gridKey,
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                childAspectRatio: 1,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: count,
              itemBuilder: (context, index) {
                if (index == count - 1) {
                  //load more
                  context.read<ImageListCubit>().loadMore(10);
                }
                final item = state.images![index];
                final memCacheWidth = ImageUtil.getCachedImageSizeFrom((item.width ?? w));
                return SelectionImageWidget(
                  url: item.url!,
                  memCacheWidth: memCacheWidth,
                  isSelected: _selectedImages.contains(index),
                  onSelected: (value) {
                    switch (value) {
                      case true:
                        if (_getSelectedCount() >= _maxImages) {
                          SnackBarUtils.show(
                            context,
                            LKey.maximumSelectImageDescription.tr(
                              context: context,
                              namedArgs: {
                                "number": _maxImages.toString(),
                              },
                            ),
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
            );
          }),
          // Nút bắt đầu chơi
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.actionBackground,
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  // Hiển thị số ảnh đã chọn
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        '${LKey.selectedTitle.tr(context: context)} ${_getSelectedCount()}/$_maxImages',
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _startGame,
                    child: Text(
                      widget.selectImageTitle,
                      style: theme.textTheme.titleMedium,
                    ),
                    // style: ButtonStyle(
                    //   backgroundColor: WidgetStateProperty.all(theme.highlightColor),
                    //   shape: WidgetStateProperty.all(
                    //     RoundedRectangleBorder(
                    //       borderRadius: BorderRadius.circular(20),
                    //       side: BorderSide(
                    //         color: theme.highlightColor2,
                    //         width: 2,
                    //       ),
                    //     ),
                    //   ),
                    // ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollTimer?.cancel();
    _scrollController.dispose();
    _lockTimers.forEach((_, timer) => timer.cancel());
    _lockTimers.clear();
    super.dispose();
  }
}

void gotoSelectImages(
  BuildContext context, {
  int maxImage = 1,
  int minImage = 1,
  required Function(List<String> imagePaths) onSubmitImage,
  String? selectImageTitle,
}) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ImageSelectionScreen(
        maxImage: maxImage,
        minImage: minImage,
        onSubmitImage: onSubmitImage,
        selectImageTitle: selectImageTitle ?? LKey.startGame.tr(context: context),
      ),
    ),
  );
}
