import 'package:flutter/material.dart';

/// Configuration class for game background
class GameBackgroundConfig {
  final BackgroundType type;
  final List<Color>? gradientColors;
  final List<double>? gradientStops;
  final Alignment gradientBegin;
  final Alignment gradientEnd;
  final Color? solidColor;
  final String? imagePath;
  final bool isAssetImage;
  final BoxFit imageBoxFit;
  final double opacity;

  const GameBackgroundConfig({
    this.type = BackgroundType.gradient,
    this.gradientColors,
    this.gradientStops,
    this.gradientBegin = Alignment.topLeft,
    this.gradientEnd = Alignment.bottomRight,
    this.solidColor,
    this.imagePath,
    this.isAssetImage = true,
    this.imageBoxFit = BoxFit.cover,
    this.opacity = 1.0,
  });

  /// Create a gradient background config
  factory GameBackgroundConfig.gradient({
    required List<Color> colors,
    List<double>? stops,
    Alignment begin = Alignment.topLeft,
    Alignment end = Alignment.bottomRight,
    double opacity = 1.0,
  }) {
    return GameBackgroundConfig(
      type: BackgroundType.gradient,
      gradientColors: colors,
      gradientStops: stops,
      gradientBegin: begin,
      gradientEnd: end,
      opacity: opacity,
    );
  }

  /// Create a solid color background config
  factory GameBackgroundConfig.solid({
    required Color color,
    double opacity = 1.0,
  }) {
    return GameBackgroundConfig(
      type: BackgroundType.solid,
      solidColor: color,
      opacity: opacity,
    );
  }

  /// Create an image background config
  factory GameBackgroundConfig.image({
    required String imagePath,
    bool isAsset = true,
    BoxFit boxFit = BoxFit.cover,
    double opacity = 1.0,
  }) {
    return GameBackgroundConfig(
      type: BackgroundType.image,
      imagePath: imagePath,
      isAssetImage: isAsset,
      imageBoxFit: boxFit,
      opacity: opacity,
    );
  }

  /// Build the decoration based on the configuration
  BoxDecoration buildDecoration() {
    switch (type) {
      case BackgroundType.gradient:
        return BoxDecoration(
          gradient: LinearGradient(
            begin: gradientBegin,
            end: gradientEnd,
            colors: (gradientColors ?? _defaultGradientColors)
                .map((color) => color.withOpacity(opacity))
                .toList(),
            stops: gradientStops ?? _defaultGradientStops,
          ),
        );
      case BackgroundType.solid:
        return BoxDecoration(
          color: (solidColor ?? Colors.blue).withOpacity(opacity),
        );
      case BackgroundType.image:
        return BoxDecoration(
          image: imagePath != null
              ? DecorationImage(
                  image: isAssetImage
                      ? AssetImage(imagePath!)
                      : NetworkImage(imagePath!) as ImageProvider,
                  fit: imageBoxFit,
                  opacity: opacity,
                )
              : null,
        );
    }
  }

  /// Default gradient colors
  static const List<Color> _defaultGradientColors = [
    Color(0xFF1976D2), // Deep Blue
    Color(0xFF42A5F5), // Light Blue
    Color(0xFF81C784), // Light Green
    Color(0xFFFFB74D), // Light Orange
  ];

  /// Default gradient stops
  static const List<double> _defaultGradientStops = [0.0, 0.3, 0.7, 1.0];
}

/// Enum for background types
enum BackgroundType {
  gradient,
  solid,
  image,
}

/// Predefined background configurations
class BackgroundPresets {
  /// Gaming theme - Blue to orange gradient
  static final gaming = GameBackgroundConfig.gradient(
    colors: const [
      Color(0xFF1976D2), // Deep Blue
      Color(0xFF42A5F5), // Light Blue
      Color(0xFF81C784), // Light Green
      Color(0xFFFFB74D), // Light Orange
    ],
    stops: const [0.0, 0.3, 0.7, 1.0],
  );

  /// Sunset theme - Warm colors
  static final sunset = GameBackgroundConfig.gradient(
    colors: const [
      Color(0xFFFF5722), // Deep Orange
      Color(0xFFFF9800), // Orange
      Color(0xFFFFC107), // Amber
      Color(0xFFFFEB3B), // Yellow
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  /// Ocean theme - Cool blues
  static final ocean = GameBackgroundConfig.gradient(
    colors: const [
      Color(0xFF0D47A1), // Dark Blue
      Color(0xFF1976D2), // Blue
      Color(0xFF2196F3), // Light Blue
      Color(0xFF03DAC6), // Teal
    ],
  );

  /// Forest theme - Green tones
  static final forest = GameBackgroundConfig.gradient(
    colors: const [
      Color(0xFF1B5E20), // Dark Green
      Color(0xFF388E3C), // Green
      Color(0xFF66BB6A), // Light Green
      Color(0xFF81C784), // Very Light Green
    ],
  );

  /// Night theme - Dark colors
  static final night = GameBackgroundConfig.gradient(
    colors: const [
      Color(0xFF263238), // Dark Blue Grey
      Color(0xFF37474F), // Blue Grey
      Color(0xFF455A64), // Light Blue Grey
      Color(0xFF607D8B), // Very Light Blue Grey
    ],
  );

  /// Simple dark theme
  static final dark = GameBackgroundConfig.solid(
    color: const Color(0xFF212121),
  );

  /// Simple light theme
  static final light = GameBackgroundConfig.solid(
    color: const Color(0xFFF5F5F5),
  );

  /// Get all preset configurations
  static Map<String, GameBackgroundConfig> get all => {
        'Gaming': gaming,
        'Sunset': sunset,
        'Ocean': ocean,
        'Forest': forest,
        'Night': night,
        'Dark': dark,
        'Light': light,
      };
}
