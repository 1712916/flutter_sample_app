import 'package:easy_localization/easy_localization.dart';
import 'package:equatable/equatable.dart';
import 'package:meow_app/feature/auto_play/auto_play_memory_game.dart';

import '../../../widgets/text.dart';
import 'cell_content.dart';

/// Factory class for creating different types of cell content
class CellContentFactory {
  static List<String> _meowImagePaths = [];

  //set the paths for meow images
  static void setMeowImagePaths(List<String> paths) {
    _meowImagePaths = paths;
  }

  static List<String> _gaowImagePaths = [];

  //set the paths for gaow images
  static void setGaowImagePaths(List<String> paths) {
    _gaowImagePaths = paths;
  }

  /// Create image-based content using asset paths
  static List<CellContent> createMeowContent() {
    if (_meowImagePaths.isEmpty) {
      return createPokemonContent();
    }

    return [
      for (int i = 0; i < _meowImagePaths.length; i++)
        ImageCellContent(
          id: i,
          imagePath: _meowImagePaths[i],
          isAsset: false,
        )
    ];
  }

  ///createGaowContent()

  static List<CellContent> createGaowContent() {
    if (_gaowImagePaths.isEmpty) {
      return createPokemonContent();
    }

    return [
      for (int i = 0; i < _gaowImagePaths.length; i++)
        ImageCellContent(
          id: i,
          imagePath: _gaowImagePaths[i],
          isAsset: false,
        )
    ];
  }

  static List<CellContent> createMixedContent() {
    // Combine Meow and Gaow content
    List<CellContent> mixedContent = [];
    //get a haft of each contents
    final meowCount = (_meowImagePaths.length / 2).ceil();
    final gaowCount = (_gaowImagePaths.length / 2).ceil();
    final cats = createMeowContent();
    cats.shuffle();

    final dogs = createGaowContent();
    dogs.shuffle();

    mixedContent.addAll(cats.take(meowCount));
    mixedContent.addAll(dogs.take(gaowCount));
    return mixedContent;
  }

  /// Create Pokemon-style content (example custom implementation)
  static List<CellContent> createPokemonContent() {
    final pokemonEmojis = ['⚡', '🔥', '💧', '🌿', '🌟', '👻', '🌙', '❄️', '🌈'];
    return List.generate(
        9,
        (index) => EmojiCellContent(
              id: index + 1,
              emoji: pokemonEmojis[index],
            ));
  }
}

/// Configuration class for easy content switching
class CellContentConfig extends Equatable {
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

  static List<CellContentConfig> get presets => [
        CellContentConfig(
          type: CellContentType.image,
          contentFactory: CellContentFactory.createMeowContent,
          name: 'Meow',
          description: LKey.catThemeDescription.tr(),
        ),
        CellContentConfig(
          type: CellContentType.image,
          contentFactory: CellContentFactory.createGaowContent,
          name: 'Gaow',
          description: LKey.dogThemeDescription.tr(),
        ),
        CellContentConfig(
          type: CellContentType.image,
          contentFactory: CellContentFactory.createMixedContent,
          name: 'Mixed',
          description: LKey.mixedThemeDescription.tr(),
        ),
      ];

  @override
  List<Object?> get props => [
        type,
        contentFactory,
        name,
        description,
      ];
}
