import 'dart:io';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
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
