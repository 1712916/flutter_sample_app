import 'dart:io';

import 'package:flutter/material.dart';

/// Enum defining different types of cell content
enum CellContentType {
  number, // Display numbers 1-9
  emoji, // Display emoji symbols
  icon, // Display Material icons
  image, // Display custom images
  custom, // Display custom widgets
}

/// Abstract base class for cell content
abstract class CellContent {
  final int id; // Unique identifier for matching (1-9)
  final CellContentType type;

  const CellContent({
    required this.id,
    required this.type,
  });

  /// Build the widget to display in the cell
  Widget buildWidget({
    double? fontSize,
    Color? color,
    bool isSelected = false,
    bool isMatched = false,
    bool isHinted = false,
  });

  /// Check if this content matches another content
  bool matches(CellContent other) => id == other.id && type == other.type;

  /// Get background color for this content based on ID
  Color getBackgroundColor() {
    // Define a consistent color palette for IDs 1-9
    const colors = [
      Color(0xFFFFCDD2), // Light Red
      Color(0xFFF8BBD9), // Light Pink
      Color(0xFFE1BEE7), // Light Purple
      Color(0xFFD1C4E9), // Light Deep Purple
      Color(0xFFC5CAE9), // Light Indigo
      Color(0xFFBBDEFB), // Light Blue
      Color(0xFFB3E5FC), // Light Light Blue
      Color(0xFFB2EBF2), // Light Cyan
      Color(0xFFB2DFDB), // Light Teal
    ];

    // Use modulo to ensure we stay within array bounds
    return colors[(id - 1) % colors.length];
  }

  /// Create a copy of this content
  CellContent copy();
}

/// Number-based cell content (default)
class NumberCellContent extends CellContent {
  const NumberCellContent({required int id}) : super(id: id, type: CellContentType.number);

  @override
  Widget buildWidget({
    double? fontSize,
    Color? color,
    bool isSelected = false,
    bool isMatched = false,
    bool isHinted = false,
  }) {
    return Text(
      id.toString(),
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: fontSize ?? 16,
        color: color ?? (isMatched ? Colors.grey : Colors.black),
      ),
    );
  }

  @override
  CellContent copy() => NumberCellContent(id: id);
}

/// Emoji-based cell content
class EmojiCellContent extends CellContent {
  final String emoji;

  const EmojiCellContent({
    required int id,
    required this.emoji,
  }) : super(id: id, type: CellContentType.emoji);

  @override
  Widget buildWidget({
    double? fontSize,
    Color? color,
    bool isSelected = false,
    bool isMatched = false,
    bool isHinted = false,
  }) {
    return Text(
      emoji,
      style: TextStyle(
        fontSize: fontSize ?? 20,
        color: isMatched ? Colors.grey : null,
      ),
    );
  }

  @override
  CellContent copy() => EmojiCellContent(id: id, emoji: emoji);
}

/// Icon-based cell content
class IconCellContent extends CellContent {
  final IconData iconData;

  const IconCellContent({
    required int id,
    required this.iconData,
  }) : super(id: id, type: CellContentType.icon);

  @override
  Widget buildWidget({
    double? fontSize,
    Color? color,
    bool isSelected = false,
    bool isMatched = false,
    bool isHinted = false,
  }) {
    return Icon(
      iconData,
      size: fontSize ?? 20,
      color: color ?? (isMatched ? Colors.grey : Colors.black),
    );
  }

  @override
  CellContent copy() => IconCellContent(id: id, iconData: iconData);
}

/// Image-based cell content
class ImageCellContent extends CellContent {
  final String imagePath;
  final bool isAsset;

  const ImageCellContent({
    required int id,
    required this.imagePath,
    this.isAsset = true,
  }) : super(id: id, type: CellContentType.image);

  @override
  Widget buildWidget({
    double? fontSize,
    Color? color,
    bool isSelected = false,
    bool isMatched = false,
    bool isHinted = false,
  }) {
    Widget image = isAsset
        ? Image.asset(
            imagePath,
            width: fontSize ?? 24,
            height: fontSize ?? 24,
            fit: BoxFit.contain,
          )
        : Image.file(
            File(imagePath),
            width: 100,
            height: 100,
            cacheWidth: 100,
            cacheHeight: 100,
            fit: BoxFit.contain,
          );

    return isMatched
        ? ColorFiltered(
            colorFilter: const ColorFilter.mode(Colors.grey, BlendMode.saturation),
            child: image,
          )
        : image;
  }

  @override
  CellContent copy() => ImageCellContent(id: id, imagePath: imagePath, isAsset: isAsset);
}

/// Custom widget-based cell content
class CustomCellContent extends CellContent {
  final Widget Function({
    required bool isSelected,
    required bool isMatched,
    required bool isHinted,
    double? size,
    Color? color,
  }) widgetBuilder;

  const CustomCellContent({
    required int id,
    required this.widgetBuilder,
  }) : super(id: id, type: CellContentType.custom);

  @override
  Widget buildWidget({
    double? fontSize,
    Color? color,
    bool isSelected = false,
    bool isMatched = false,
    bool isHinted = false,
  }) {
    return widgetBuilder(
      isSelected: isSelected,
      isMatched: isMatched,
      isHinted: isHinted,
      size: fontSize,
      color: color,
    );
  }

  @override
  CellContent copy() => CustomCellContent(id: id, widgetBuilder: widgetBuilder);
}
