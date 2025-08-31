import 'dart:io';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:meow_app/core/index.dart';
import 'package:meow_app/resources/theme/theme_data.dart';

import '../data/repositories/image_storage_repository.dart';

class AppImage extends StatelessWidget {
  const AppImage({
    super.key,
    this.memCacheHeight,
    this.memCacheWidth,
    required this.image,
    this.fit,
  });

  final int? memCacheHeight;
  final int? memCacheWidth;
  final String image;
  final BoxFit? fit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    switch (image.isUrl) {
      case true:
        return CachedNetworkImage(
          memCacheHeight: memCacheHeight,
          memCacheWidth: memCacheWidth,
          imageUrl: image,
          fit: fit ?? BoxFit.cover,
          placeholder: (context, url) {
            return Container(
              color: theme.cardColor2,
            );
          },
          errorWidget: (context, url, error) {
            return Container(
              color: theme.cardColor2,
              child: Center(
                child: Icon(
                  Icons.error,
                  color: theme.iconColor,
                ),
              ),
            );
          },
        );
      case false:
        return Image.file(
          File(image),
          cacheWidth: memCacheWidth,
          cacheHeight: memCacheHeight,
          fit: fit ?? BoxFit.cover,
          frameBuilder: (context, child, __, wasSynchronouslyLoaded) {
            return child;

            if (wasSynchronouslyLoaded) {
              return child;
            }
            return Container(
              color: theme.cardColor2,
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: theme.cardColor2,
              child: Center(
                child: Icon(
                  Icons.error,
                  color: theme.iconColor,
                ),
              ),
            );
          },
        );
    }
  }
}

class AppStorageImageView extends StatefulWidget {
  const AppStorageImageView({
    super.key,
    this.memCacheHeight,
    this.memCacheWidth,
    required this.imageId,
  });

  final int? memCacheHeight;
  final int? memCacheWidth;
  final int imageId;

  @override
  State<AppStorageImageView> createState() => _AppStorageImageViewState();
}

class _AppStorageImageViewState extends State<AppStorageImageView> {
  final ImageStorageRepository imageStorageRepository = ImageStorageRepository.instance;

  bool isLoading = true;
  ImageStorageModel? image;

  @override
  void initState() {
    super.initState();
    //load image model by id
    loadImage();
  }

  void loadImage() {
    imageStorageRepository.read(widget.imageId).then((value) {
      setState(() {
        image = value;
        isLoading = false;
      });
    }).catchError((error) {
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    if (image == null) {
      return const Center(
        child: Text('Image not found'),
      );
    }

    return StrImageWidget(
      image: image!,
      memCacheWidth: widget.memCacheWidth,
      memCacheHeight: widget.memCacheHeight,
    );
  }
}

class StrImageWidget extends StatelessWidget {
  const StrImageWidget({super.key, required this.image, this.memCacheHeight, this.memCacheWidth});

  final ImageStorageModel image;
  final int? memCacheHeight;
  final int? memCacheWidth;

// In-memory cache
  static final Map<String, ImageProvider> _imageCache = {};

  @override
  Widget build(BuildContext context) {
    if (image!.url != null) {
      return AppImage(
        memCacheHeight: memCacheHeight,
        memCacheWidth: memCacheWidth,
        image: image!.url ?? '',
      );
    }

    if (image?.path != null) {
      final path = image!.path!;
      if (_imageCache.containsKey(path)) {
        return Image(
          image: _imageCache[path]!,
          fit: BoxFit.cover,
          height: memCacheHeight?.toDouble(),
          width: memCacheWidth?.toDouble(),
        );
      }

      final fileImage = FileImage(File(path));
      _imageCache[path] = fileImage;
      return Image(
        image: fileImage,
        fit: BoxFit.cover,
        height: memCacheHeight?.toDouble(),
        width: memCacheWidth?.toDouble(),
      );
    }

    if (image?.bytes != null) {
      final bytes = Uint8List.fromList(image!.bytes!);
      final key = bytes.hashCode.toString(); // Use a better key if available

      if (_imageCache.containsKey(key)) {
        return Image(
          image: _imageCache[key]!,
          fit: BoxFit.cover,
          height: memCacheHeight?.toDouble(),
          width: memCacheWidth?.toDouble(),
        );
      }

      final memoryImage = MemoryImage(bytes);
      _imageCache[key] = memoryImage;
      return Image(
        image: memoryImage,
        fit: BoxFit.cover,
        height: memCacheHeight?.toDouble(),
        width: memCacheWidth?.toDouble(),
      );
    }
    return const Center(
      child: Text('Image not found'),
    );
  }
}

class ImagesStackView extends StatefulWidget {
  const ImagesStackView({super.key, required this.images, this.onImageTap});

  final List<String> images;
  final Function(String image)? onImageTap;

  @override
  State<ImagesStackView> createState() => _ImagesStackViewState();
}

class _ImagesStackViewState extends State<ImagesStackView> {
  bool isShowGridView = false;

  @override
  Widget build(BuildContext context) {
    if (isShowGridView) {
      final length = widget.images.length;
      // if (length == 1) {
      //
      // }
      final count = length.getCountByLength();

      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: count,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
        ),
        itemCount: widget.images.length,
        itemBuilder: (context, index) {
          return Container(
            foregroundDecoration: BoxDecoration(
              border: Border.all(
                color: Colors.white,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: GestureDetector(
                onTap: () {
                  widget.onImageTap?.call(widget.images[index]);
                },
                child: AppImage(
                  image: widget.images[index],
                  memCacheWidth: 140,
                  memCacheHeight: 140,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          );
        },
      );
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          isShowGridView = true;
        });
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Stack(
          fit: StackFit.loose,
          children: [
            for (int i = 0; i < widget.images.length; i++)
              Transform.rotate(
                angle: (i - (widget.images.length - 1) / 2) * 0.12,
                child: Container(
                  foregroundDecoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.white,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: GestureDetector(
                      onTap: widget.images.length == 1
                          ? () {
                              widget.onImageTap?.call(widget.images[i]);
                            }
                          : null,
                      child: AppImage(
                        image: widget.images[i],
                        memCacheWidth: 140,
                        memCacheHeight: 140,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

extension GetCountByLength on int {
  int getCountByLength() {
    if (this <= 3) {
      return this;
    }
    return 3;
  }
}
