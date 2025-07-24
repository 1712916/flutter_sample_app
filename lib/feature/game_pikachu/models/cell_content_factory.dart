import 'package:flutter/material.dart';
import 'cell_content.dart';

/// Factory class for creating different types of cell content
class CellContentFactory {
  static const List<String> _animalEmojis = [
    '🐱', '🐶', '🐭', '🐹', '🐰', '🦊', '🐻', '🐼', '🐨'
  ];
  
  static const List<IconData> _gameIcons = [
    Icons.star,
    Icons.favorite,
    Icons.diamond,
    Icons.flash_on,
    Icons.local_fire_department,
    Icons.eco,
    Icons.water_drop,
    Icons.sunny,
    Icons.nightlight_round,
  ];
  
  /// Create number-based content (default)
  static List<CellContent> createNumberContent() {
    return List.generate(9, (index) => NumberCellContent(id: index + 1));
  }
  
  /// Create emoji-based content using animal emojis
  static List<CellContent> createEmojiContent() {
    return List.generate(9, (index) => 
      EmojiCellContent(
        id: index + 1,
        emoji: _animalEmojis[index],
      )
    );
  }
  
  /// Create icon-based content using Material icons
  static List<CellContent> createIconContent() {
    return List.generate(9, (index) => 
      IconCellContent(
        id: index + 1,
        iconData: _gameIcons[index],
      )
    );
  }
  
  /// Create image-based content using asset paths
  static List<CellContent> createImageContent(List<String> imagePaths) {
    assert(imagePaths.length >= 9, 'Need at least 9 image paths');
    return List.generate(9, (index) => 
      ImageCellContent(
        id: index + 1,
        imagePath: imagePaths[index],
        isAsset: true,
      )
    );
  }
  
  /// Create custom content using provided widget builders
  static List<CellContent> createCustomContent(
    List<Widget Function({
      required bool isSelected,
      required bool isMatched,
      required bool isHinted,
      double? size,
      Color? color,
    })> widgetBuilders
  ) {
    assert(widgetBuilders.length >= 9, 'Need at least 9 widget builders');
    return List.generate(9, (index) => 
      CustomCellContent(
        id: index + 1,
        widgetBuilder: widgetBuilders[index],
      )
    );
  }
  
  /// Create Pokemon-style content (example custom implementation)
  static List<CellContent> createPokemonContent() {
    final pokemonEmojis = ['⚡', '🔥', '💧', '🌿', '🌟', '👻', '🌙', '❄️', '🌈'];
    return List.generate(9, (index) => 
      EmojiCellContent(
        id: index + 1,
        emoji: pokemonEmojis[index],
      )
    );
  }
  
  /// Create geometric shapes content (example using custom widgets)
  static List<CellContent> createShapesContent() {
    final colors = [
      Colors.red, Colors.blue, Colors.green, Colors.orange,
      Colors.purple, Colors.pink, Colors.cyan, Colors.amber, Colors.indigo
    ];
    
    return List.generate(9, (index) => 
      CustomCellContent(
        id: index + 1,
        widgetBuilder: ({
          required bool isSelected, 
          required bool isMatched, 
          required bool isHinted, 
          double? size, 
          Color? color
        }) {
          return Container(
            width: size ?? 20,
            height: size ?? 20,
            decoration: BoxDecoration(
              color: isMatched ? Colors.grey : colors[index],
              shape: BoxShape.circle,
              border: isSelected ? Border.all(color: Colors.white, width: 2) : null,
            ),
          );
        },
      )
    );
  }
}

/// Configuration class for easy content switching
class CellContentConfig {
  final CellContentType type;
  final List<CellContent> Function() contentFactory;
  final String name;
  final String description;
  
  const CellContentConfig({
    required this.type,
    required this.contentFactory,
    required this.name,
    required this.description,
  });
  
  static const List<CellContentConfig> presets = [
    CellContentConfig(
      type: CellContentType.number,
      contentFactory: CellContentFactory.createNumberContent,
      name: 'Numbers',
      description: 'Classic numbered tiles (1-9)',
    ),
    CellContentConfig(
      type: CellContentType.emoji,
      contentFactory: CellContentFactory.createEmojiContent,
      name: 'Animals',
      description: 'Cute animal emojis',
    ),
    CellContentConfig(
      type: CellContentType.emoji,
      contentFactory: CellContentFactory.createPokemonContent,
      name: 'Pokemon Elements',
      description: 'Pokemon-style elemental symbols',
    ),
    CellContentConfig(
      type: CellContentType.icon,
      contentFactory: CellContentFactory.createIconContent,
      name: 'Icons',
      description: 'Material Design icons',
    ),
    CellContentConfig(
      type: CellContentType.custom,
      contentFactory: CellContentFactory.createShapesContent,
      name: 'Geometric Shapes',
      description: 'Colorful geometric shapes',
    ),
  ];
}
