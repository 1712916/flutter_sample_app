import 'dart:io';
import 'dart:ui' as ui;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_subject_segmentation/google_mlkit_subject_segmentation.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meow_app/core/index.dart';
import 'package:meow_app/resources/theme/theme_data.dart';
import 'package:meow_app/widgets/app_bar.dart';
import 'package:meow_app/widgets/image_view.dart';

import '../../core/util/image_util.dart';
import '../../widgets/image_picker_widget.dart';
import '../../widgets/text.dart';
import '../game/game_menu_page.dart';
import '../image/image_selection_widget.dart';

class StickerPage extends StatefulWidget {
  const StickerPage({super.key, this.path});

  final String? path;

  @override
  State<StickerPage> createState() => _StickerPageState();
}

class _StickerPageState extends State<StickerPage> {
  final _showRaw = ValueNotifier<bool>(false);
  final _inProcess = ValueNotifier<bool>(false);
  final _path = ValueNotifier<String?>(null);
  final _subjects = ValueNotifier<List<Subject>?>(null);
  final _imageSize = ValueNotifier<Size?>(null);

  bool get isDisabled => _subjects.value == null || _subjects.value!.isEmpty;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    _path.value = widget.path;
    _processImage();
  }

  @override
  void dispose() {
    _showRaw.dispose();
    _inProcess.dispose();
    _path.dispose();
    _subjects.dispose();
    _imageSize.dispose();
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    super.dispose();
  }

  Future<void> _processImage() async {
    if (_inProcess.value || _path.value == null) return;

    _inProcess.value = true;
    _showRaw.value = true;
    _imageSize.value = null;
    _subjects.value = null;

    try {
      _imageSize.value = await ImageUtil.getImageSize(_path.value!);
      final Data data = Data(isolateToken: null, path: _path.value!);
      _subjects.value = await processImage(data);
      // _subjects.value = await compute(processImage, data);
      _showRaw.value = false;
    } catch (e) {
      // Handle error gracefully, e.g., show a snackbar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error processing image: $e')),
        );
      }
    } finally {
      _inProcess.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor2,
      appBar: CustomAppBar(
        title: LKey.sticker.tr(context: context),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(child: _buildImageView(theme)),
              _buildBottomMenu(theme),
            ],
          ),
          ValueListenableBuilder<bool>(
            valueListenable: _inProcess,
            builder: (context, inProcess, _) {
              return inProcess
                  ? const Center(child: CircularProgressIndicator(strokeWidth: 1))
                  : const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildImageView(theme) {
    return ValueListenableBuilder<String?>(
      valueListenable: _path,
      builder: (context, path, _) {
        if (path == null) {
          return const Center(child: SelectImagePlaceHolder());
        }
        return ValueListenableBuilder<Size?>(
          valueListenable: _imageSize,
          builder: (context, imageSize, _) {
            return ValueListenableBuilder<List<Subject>?>(
              valueListenable: _subjects,
              builder: (context, subjects, _) {
                return ValueListenableBuilder<bool>(
                  valueListenable: _showRaw,
                  builder: (context, showRaw, _) {
                    return RatioView(
                      height: imageSize?.height ?? 1,
                      width: imageSize?.width ?? 1,
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final screenSize = constraints.maxWidth;
                          return Center(
                            child: Stack(
                              fit: StackFit.loose,
                              children: [
                                AnimatedOpacity(
                                  duration: const Duration(milliseconds: 300),
                                  opacity: showRaw ? 1 : 0,
                                  child: path.isUrl
                                      ? AppImage(image: path, fit: BoxFit.scaleDown)
                                      : Image.file(File(path), fit: BoxFit.scaleDown),
                                ),
                                if (subjects != null && subjects.isNotEmpty)
                                  Positioned(
                                    left: screenSize * (subjects[0].startX / (imageSize?.width ?? 1)),
                                    top: screenSize * (subjects[0].startY / (imageSize?.width ?? 1)),
                                    child: Image.memory(
                                      subjects[0].bitmap!,
                                      width: screenSize * (subjects[0].width / (imageSize?.width ?? 1)),
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildBottomMenu(theme) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          SelectImageMenu(
            onImageSelected: (newPath) {
              _path.value = newPath;
              _processImage();
            },
          ),
          ListenableBuilder(
            listenable: Listenable.merge([
              _inProcess,
              _subjects,
            ]),
            builder: (context, child) {
              return Row(
                children: [
                  const VerticalDivider(width: 0.1),
                  ValueListenableBuilder<bool>(
                    valueListenable: _showRaw,
                    builder: (context, showRaw, _) {
                      return _ImageOptionButton(
                        icon: showRaw ? HugeIcons.strokeRoundedBackground : HugeIcons.strokeRoundedImage01,
                        label: showRaw ? LKey.sticker.tr(context: context) : LKey.original.tr(context: context),
                        isDisabled: isDisabled,
                        onTap: () => _showRaw.value = !showRaw,
                      );
                    },
                  ),
                  const VerticalDivider(width: 0.1),
                  _ImageOptionButton(
                    icon: HugeIcons.strokeRoundedDownload01,
                    label: LKey.download.tr(context: context),
                    isDisabled: isDisabled,
                    onTap: () => DownloadHelper.downloadFromBitmap(_subjects.value![0].bitmap!),
                  ),
                  const VerticalDivider(width: 0.1),
                  _ImageOptionButton(
                    icon: HugeIcons.strokeRoundedShare01,
                    label: LKey.share.tr(context: context),
                    isDisabled: isDisabled,
                    onTap: () => ShareHelper.shareBitmap(_subjects.value![0].bitmap!),
                  ),
                ],
              );
            },
          )
        ],
      ),
    );
  }
}

class SubjectPainter extends CustomPainter {
  final List<Subject> subjects;
  final ui.Image? image;
  final Size? imageSize;

  SubjectPainter(this.subjects, this.image, this.imageSize);

  @override
  void paint(Canvas canvas, Size size) {
    if (image == null || imageSize == null) return;

    final imageAspect = image!.width / image!.height;
    final canvasAspect = size.width / size.height;
    double scale;
    double dx = 0, dy = 0;

    if (imageAspect > canvasAspect) {
      scale = size.width / image!.width;
      dy = (size.height - image!.height * scale) / 2;
    } else {
      scale = size.height / image!.height;
      dx = (size.width - image!.width * scale) / 2;
    }

    for (var subject in subjects) {
      final rect = Rect.fromLTWH(
        dx + subject.startX * scale,
        dy + subject.startY * scale,
        subject.width * scale,
        subject.height * scale,
      );

      if (subject.bitmap != null) {
        ui.decodeImageFromList(subject.bitmap!, (result) {
          canvas.drawImageRect(
            result,
            Rect.fromLTWH(0, 0, result.width.toDouble(), result.height.toDouble()),
            rect,
            Paint(),
          );
        });
      }

      canvas.drawRect(
        rect,
        Paint()
          ..color = Colors.red
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class RatioView extends StatelessWidget {
  const RatioView({
    super.key,
    required this.width,
    required this.height,
    required this.child,
  });

  final double width;
  final double height;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: width / height,
      child: child,
    );
  }
}

class SelectImageMenu extends StatelessWidget {
  final void Function(String) onImageSelected;

  const SelectImageMenu({super.key, required this.onImageSelected});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _ImageOptionButton(
          icon: HugeIcons.strokeRoundedCamera01,
          label: LKey.camera.tr(context: context),
          onTap: () => _handleCamera(context),
        ),
        const VerticalDivider(width: 0.1),
        _ImageOptionButton(
          icon: HugeIcons.strokeRoundedImage01,
          label: LKey.gallery.tr(context: context),
          onTap: () => _handleGallery(context),
        ),
        const VerticalDivider(width: 0.1),
        _ImageOptionButton(
          icon: HugeIcons.strokeRoundedGridTable,
          label: 'Meow',
          onTap: () => _handleAppImages(context),
        ),
      ],
    );
  }

  Future<void> _handleCamera(BuildContext context) async {
    final path = await openImage(ImageSource.camera);
    if (path != null) onImageSelected(path);
  }

  Future<void> _handleGallery(BuildContext context) async {
    final path = await openImage(ImageSource.gallery);
    if (path != null) onImageSelected(path);
  }

  void _handleAppImages(BuildContext context) {
    gotoSelectImages(
      context,
      minImage: 1,
      maxImage: 1,
      onSubmitImage: (imagePaths) {
        if (imagePaths.isNotEmpty) {
          onImageSelected(imagePaths.first);
          Navigator.of(context).pop();
        }
      },
      selectImageTitle: LKey.choose.tr(context: context),
    );
  }
}

class _ImageOptionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDisabled;

  const _ImageOptionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDisabled = false,
  });

  static const double _padding = 10.0;
  static const double _iconSize = 20.0;
  static const double _spacing = 4.0;
  static const double _borderRadius = 0.0;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: isDisabled ? 0.5 : 1,
      child: InkWell(
        onTap: isDisabled ? null : onTap,
        child: Container(
          padding: const EdgeInsets.all(_padding),
          constraints: const BoxConstraints(minWidth: 60),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(_borderRadius),
            color: theme.actionBackground,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: _iconSize),
              const SizedBox(height: _spacing),
              Text(label, style: theme.textTheme.labelSmall),
            ],
          ),
        ),
      ),
    );
  }
}

Future<List<Subject>?> processImage(Data data) async {
  // BackgroundIsolateBinaryMessenger.ensureInitialized(data.isolateToken);

  final segmenter = SubjectSegmenter(
    options: SubjectSegmenterOptions(
      enableForegroundConfidenceMask: false,
      enableForegroundBitmap: false,
      enableMultipleSubjects: SubjectResultOptions(
        enableConfidenceMask: true,
        enableSubjectBitmap: true,
      ),
    ),
  );
  final path = data.path;
  try {
    final inputImage = path.isUrl
        ? InputImage.fromFile(await CachedNetworkImageProvider.defaultCacheManager.getSingleFile(path))
        : InputImage.fromFile(File(path));
    final result = await segmenter.processImage(inputImage);
    return result.subjects;
  } catch (e) {
    return null;
  } finally {
    segmenter.close();
  }
}

class Data {
  //token
  final RootIsolateToken? isolateToken;
  final String path;

  Data({required this.isolateToken, required this.path});
}
