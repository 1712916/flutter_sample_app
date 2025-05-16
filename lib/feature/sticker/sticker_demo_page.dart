import 'dart:io';
import 'dart:ui' as ui;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_subject_segmentation/google_mlkit_subject_segmentation.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meow_app/core/index.dart';
import 'package:meow_app/resources/theme/theme_data.dart';

import '../../widgets/image_picker_widget.dart';
import '../../widgets/text.dart';
import '../game_memory/game_menu_page.dart';
import '../game_memory/widget/image_selection_widget.dart';

class StickerPage extends StatefulWidget {
  const StickerPage({super.key, required this.path});

  final String? path;

  @override
  State<StickerPage> createState() => _StickerPageState();
}

class _StickerPageState extends State<StickerPage> {
  bool showRaw = true;
  bool inProcess = false;

  String? _path;

  List<Subject>? subjects;

  final SubjectSegmenter _segmenter = SubjectSegmenter(
    options: SubjectSegmenterOptions(
      enableForegroundConfidenceMask: false,
      enableForegroundBitmap: false,
      enableMultipleSubjects: SubjectResultOptions(
        enableConfidenceMask: true,
        enableSubjectBitmap: true,
      ),
    ),
  );

  //bitmap
  ui.Image? image;

  @override
  void initState() {
    super.initState();
    _path = widget.path;
  }

  @override
  void dispose() {
    _segmenter.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.blueGrey,
      appBar: AppBar(
        title: const Text('Sticker Demo'),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              if (_path == null)
                Expanded(child: Center(child: const SelectImagePlaceHolder()))
              else
                Expanded(
                  child: SingleChildScrollView(
                    child: (image != null && subjects != null)
                        ? Column(
                            children: [
                              // FutureBuilder(
                              //   future: image!.toByteData(),
                              //   builder: (context, snapshot) {
                              //     if (snapshot.connectionState == ConnectionState.done) {
                              //       final byteData = snapshot.data;
                              //       if (byteData != null) {
                              //         return Image.memory(
                              //           byteData.buffer.asUint8List(),
                              //         );
                              //         return Image(
                              //           image: ResizeImage(
                              //             MemoryImage(
                              //               byteData.buffer.asUint8List(),
                              //             ),
                              //             width: 50,
                              //             height: 100,
                              //           ),
                              //         );
                              //       }
                              //     }
                              //     return const SizedBox();
                              //   },
                              // ),
                              RatioView(
                                width: image!.width.toDouble(),
                                height: image!.height.toDouble(),
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    RawImage(
                                      image: image,
                                      color: showRaw ? null : Colors.transparent,
                                    ), // Positioned(
                                    //   left: (screenSize.width * (subjects![0].startX.toDouble() / image!.width)),
                                    //   top: (screenSize.width * (subjects![0].startY.toDouble() / image!.width)),
                                    //   child: Builder(builder: (context) {
                                    //     //print confidenceMask
                                    //     return Image.memory(
                                    //       subjects![0].bitmap!,
                                    //       // fit: BoxFit.fitWidth,
                                    //       width: (screenSize.width * ((subjects![0].width) / image!.width)),
                                    //       color: Colors.white,
                                    //       // height: screenSize.height * (subjects![0].height / image!.height),
                                    //     );
                                    //   }),
                                    // ),
                                    Positioned(
                                      left: screenSize.width * (subjects![0].startX.toDouble() / image!.width),
                                      top: screenSize.width * (subjects![0].startY.toDouble() / image!.width),
                                      child: Builder(builder: (context) {
                                        //print confidenceMask
                                        return Image.memory(
                                          subjects![0].bitmap!,
                                          width: screenSize.width * (subjects![0].width / image!.width),
                                          // height: screenSize.height * (subjects![0].height / image!.height),
                                        );
                                      }),
                                    ),

                                    // Positioned(
                                    //   left: screenSize.width * (subjects![1].startX.toDouble() / image!.width),
                                    //   top: screenSize.width * (subjects![1].startY.toDouble() / image!.width),
                                    //   child: Image.memory(
                                    //     subjects![1].bitmap!,
                                    //     // fit: BoxFit.scaleDown,
                                    //     width: screenSize.width * (subjects![1].width / image!.width),
                                    //     // height: screenSize.height * (subjects![0].height / image!.height),
                                    //   ),
                                    // ),
                                  ],
                                ),
                              ),
                            ],
                          )
                        : const SizedBox(),
                  ),
                ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    SelectImageMenu(
                      onImageSelected: (p0) {
                        _path = p0;
                        setState(() {});
                        onProcessImage();
                      },
                    ),
                    VerticalDivider(width: 0.1),
                    _ImageOptionButton(
                      icon: HugeIcons.strokeRoundedImage01,
                      label: 'Raw Image',
                      onTap: () {
                        showRaw = !showRaw;
                        setState(() {});
                      },
                    ),
                    VerticalDivider(width: 0.1),
                    _ImageOptionButton(
                      icon: HugeIcons.strokeRoundedDownload01,
                      label: 'Download',
                      onTap: () {
                        //download image
                        // downloadImage(image);
                        DownloadHelper.downloadFromBitmap(subjects![0].bitmap!);
                      },
                    ),
                    VerticalDivider(width: 0.1),
                    _ImageOptionButton(
                      icon: HugeIcons.strokeRoundedShare01,
                      label: 'Share',
                      onTap: () {
                        ShareHelper.shareBitmap(
                          subjects![0].bitmap!,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (inProcess)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.5),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void onProcessImage() async {
    if (inProcess) {
      return;
    }

    inProcess = true;
    setState(() {});

    final bool isUrl = _path!.isUrl;
    InputImage inputImage;

    if (isUrl) {
      final file = await CachedNetworkImageProvider.defaultCacheManager.getSingleFile(_path!);

      inputImage = InputImage.fromFile(file);

      image = await decodeImageFromList(file.readAsBytesSync());
    } else {
      final file = File(_path!);
      inputImage = InputImage.fromFile(file);

      image = await decodeImageFromList(file.readAsBytesSync());
    }
    final rs = await _segmenter.processImage(inputImage);

    subjects = rs.subjects;
    inProcess = false;
    setState(() {});
  }
}

class SubjectPainter extends CustomPainter {
  final List<Subject> subjects;
  final ui.Image? image;

  SubjectPainter(this.subjects, this.image);

  @override
  void paint(Canvas canvas, Size size) {
    if (image == null) return;

    // Scale the image to fit the canvas
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

    // Draw the image
    // canvas.drawImageRect(
    //   image!,
    //   Rect.fromLTWH(0, 0, image!.width.toDouble(), image!.height.toDouble()),
    //   Rect.fromLTWH(dx, dy, image!.width * scale, image!.height * scale),
    //   Paint(),
    // );

    // Draw subjects
    for (var subject in subjects) {
      final rect = Rect.fromLTWH(
        dx + subject.startX * scale,
        dy + subject.startY * scale,
        subject.width * scale,
        subject.height * scale,
      );

      // Draw bitmap if available
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

      // Draw bounding box
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

//create ratio view
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
  /// Callback triggered when an image path is selected.
  final void Function(String) onImageSelected;

  const SelectImageMenu({
    super.key,
    required this.onImageSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _ImageOptionButton(
          icon: HugeIcons.strokeRoundedCamera01,
          label: 'Camera',
          onTap: () => _handleCamera(context),
        ),
        VerticalDivider(width: 0.1),
        _ImageOptionButton(
          icon: HugeIcons.strokeRoundedImage01,
          label: 'Gallery',
          onTap: () => _handleGallery(context),
        ),
        VerticalDivider(width: 0.1),
        _ImageOptionButton(
          icon: HugeIcons.strokeRoundedGridTable,
          label: 'App',
          onTap: () => _handleAppImages(context),
        ),
      ],
    );
  }

  /// Opens the camera and handles the selected image path.
  Future<void> _handleCamera(BuildContext context) async {
    final path = await openImage(ImageSource.camera);
    if (path != null) {
      onImageSelected(path);
    }
  }

  /// Opens the gallery and handles the selected image path.
  Future<void> _handleGallery(BuildContext context) async {
    final path = await openImage(ImageSource.gallery);
    if (path != null) {
      onImageSelected(path);
    }
  }

  /// Opens the app's image selection screen and handles the selected image path.
  void _handleAppImages(BuildContext context) {
    gotoSelectImages(
      context,
      minImage: 1,
      maxImage: 1,
      onSubmitImage: (imagePaths) {
        if (imagePaths.isNotEmpty) {
          onImageSelected(imagePaths.first);
          //pop
          Navigator.of(context).pop();
        }
      },
      selectImageTitle: LKey.choose,
    );
  }
}

/// A reusable button widget for image selection options.
class _ImageOptionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ImageOptionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  // Constants for styling
  static const double _padding = 10.0;
  static const double _iconSize = 20.0;
  static const double _spacing = 4.0;
  static const double _borderRadius = 0.0;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(_padding),
        constraints: BoxConstraints(
          minWidth: 60,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(_borderRadius),
          color: theme.actionBackground, // Assuming theme is globally accessible
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: _iconSize,
            ),
            const SizedBox(height: _spacing),
            Text(
              label,
              style: theme.textTheme.labelSmall,
            ),
          ],
        ),
      ),
    );
  }
}
