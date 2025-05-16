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

import '../../data/repositories/image_storage_repository.dart';
import '../../routers/route.dart';
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
  bool showRaw = false;
  bool inProcess = false;

  String? _path;

  List<Subject>? subjects;

  bool get isDisabled => subjects == null || subjects!.isEmpty;

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
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

    super.initState();
    _path = widget.path;
    onProcessImage();
  }

  @override
  void dispose() {
    _segmenter.close();
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor2,
      appBar: CustomAppBar(
        title: LKey.sticker.tr(context: context),
        actions: [
          IconButton(
            onPressed: () {
              goToStickerListPage();
            },
            icon: Icon(HugeIcons.strokeRoundedBookmark02, color: theme.iconColor),
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              if (_path == null)
                Expanded(child: Center(child: const SelectImagePlaceHolder()))
              else
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
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
                      if (image != null && !inProcess)
                        Expanded(
                          child: RatioView(
                            width: image!.width.toDouble(),
                            height: image!.height.toDouble(),
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                final screenSize = !constraints.isTight ? constraints.maxWidth : constraints.minWidth;
                                //maxHeight - minHeight
                                //scale height
                                // final h = constraints.maxHeight - constraints.minHeight;
                                final scale = constraints.minHeight / image!.height;
                                return Center(
                                  child: Stack(
                                    fit: StackFit.loose,
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
                                      if (subjects != null && subjects!.isNotEmpty)
                                        Positioned(
                                          left: screenSize * (subjects![0].startX.toDouble() / image!.width),
                                          top: screenSize * (subjects![0].startY.toDouble() / image!.width),
                                          child: Builder(builder: (context) {
                                            //print confidenceMask
                                            return Image.memory(
                                              subjects![0].bitmap!,
                                              width: screenSize * (subjects![0].width / image!.width),
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
                                );
                              },
                            ),
                          ),
                        )
                      else
                        Expanded(
                          child: Builder(builder: (context) {
                            if (_path!.isUrl) {
                              return AppImage(
                                image: _path!,
                                fit: BoxFit.scaleDown,
                              );
                            }
                            return Image.file(
                              File(_path!),
                              fit: BoxFit.scaleDown,
                            );
                          }),
                        ),
                    ],
                  ),
                ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    SelectImageMenu(
                      onImageSelected: (p0) {
                        _path = p0;
                        image = null;
                        subjects = null;
                        setState(() {});
                        onProcessImage();
                      },
                    ),
                    VerticalDivider(width: 0.1),
                    _ImageOptionButton(
                      icon: !showRaw ? HugeIcons.strokeRoundedImage01 : HugeIcons.strokeRoundedBackground,
                      label: !showRaw ? LKey.original.tr(context: context) : LKey.sticker.tr(context: context),
                      isDisabled: isDisabled,
                      onTap: () {
                        showRaw = !showRaw;
                        setState(() {});
                      },
                    ),
                    VerticalDivider(width: 0.1),
                    _ImageOptionButton(
                      icon: HugeIcons.strokeRoundedDownload01,
                      label: LKey.download.tr(context: context),
                      isDisabled: isDisabled,
                      onTap: () {
                        //download image
                        // downloadImage(image);
                        DownloadHelper.downloadFromBitmap(subjects![0].bitmap!);
                      },
                    ),
                    VerticalDivider(width: 0.1),
                    _ImageOptionButton(
                      icon: HugeIcons.strokeRoundedShare01,
                      label: LKey.share.tr(context: context),
                      isDisabled: isDisabled,
                      onTap: () {
                        ShareHelper.shareBitmap(
                          subjects![0].bitmap!,
                        );
                      },
                    ),
                    VerticalDivider(width: 0.1),
                    _ImageOptionButton(
                      icon: HugeIcons.strokeRoundedBookmark02,
                      label: LKey.save.tr(context: context),
                      isDisabled: isDisabled,
                      onTap: () {
                        ImageStorageRepository.instance.create(
                          ImageStorageModel(
                            id: -1,
                            bytes: subjects![0].bitmap,
                          ),
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
                // color: Colors.
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
    if (inProcess || _path == null) {
      return;
    }

    inProcess = true;
    image = null;
    subjects = null;
    setState(() {});

    try {
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
      setState(() {});
      final rs = await _segmenter.processImage(inputImage);

      subjects = rs.subjects;
      showRaw = false;
    } catch (e) {}

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
          label: LKey.camera.tr(context: context),
          onTap: () => _handleCamera(context),
        ),
        VerticalDivider(width: 0.1),
        _ImageOptionButton(
          icon: HugeIcons.strokeRoundedImage01,
          label: LKey.gallery.tr(context: context),
          onTap: () => _handleGallery(context),
        ),
        VerticalDivider(width: 0.1),
        _ImageOptionButton(
          icon: HugeIcons.strokeRoundedGridTable,
          label: 'Meow',
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
      selectImageTitle: LKey.choose.tr(context: context),
    );
  }
}

/// A reusable button widget for image selection options.
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

  // Constants for styling
  static const double _padding = 10.0;
  static const double _iconSize = 20.0;
  static const double _spacing = 4.0;
  static const double _borderRadius = 0.0;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;

    return AnimatedOpacity(
      duration: Duration(milliseconds: 300),
      opacity: isDisabled ? 0.5 : 1,
      child: InkWell(
        onTap: isDisabled ? null : onTap,
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
      ),
    );
  }
}
