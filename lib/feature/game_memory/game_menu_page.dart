import 'package:dotted_border/dotted_border.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:meow_app/feature/base_page.dart';
import 'package:meow_app/feature/image/cubit/image_list_cubit.dart';
import 'package:meow_app/resources/theme/theme_data.dart';
import 'package:meow_app/widgets/app_bar.dart';
import 'package:meow_app/widgets/image_view.dart';

import '../../routers/route.dart';
import '../../widgets/text.dart';
import 'memory_game_page.dart';
import 'widget/image_selection_widget.dart';

void goToGameMenu(BuildContext context) {
  Navigator.of(context).pushNamed(RouteManager.gameMenuPage);
}

class GameMenuPage extends StatefulWidget {
  const GameMenuPage({super.key});

  @override
  State<GameMenuPage> createState() => _GameMenuPageState();
}

class _GameMenuPageState extends StateTemplate<GameMenuPage> {
  @override
  PreferredSizeWidget? buildAppBar(BuildContext context) {
    return CustomAppBar(title: LKey.gameMenu.tr(context: context));
  }

  @override
  Widget buildBody(BuildContext context) {
    final ImageListCubit cubit = context.read<ImageListCubit>();
    final currentSelectedImage = cubit.currentImage?.url ?? '';
    return ListView(
      children: [
        MenuItemWidget(
          backgroundColor: Colors.transparent,
          title: LKey.sortGame.tr(context: context),
          imageUrl: currentSelectedImage,
          onTap: () {
            // Handle game menu tap
            goToCropImageView(currentSelectedImage, context: context);
          },
        ),
        MenuItemWidget(
          title: LKey.memoryGame.tr(context: context),
          backgroundColor: theme.cardColor2,
          imageUrl: null,
          onTap: () {
            // Handle game menu tap
            gotoSelectImages(
              context,
              minImage: 8,
              maxImage: 8,
              onSubmitImage: (imagePaths) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MemoryGamePage(
                      imagePaths: imagePaths,
                    ),
                  ),
                );
              },
            );
          },
        ),
        MenuItemWidget(
          title: LKey.sticker.tr(context: context),
          backgroundColor: theme.cardColor2,
          imageUrl: currentSelectedImage,
          onTap: () {
            // Handle game menu tap
            goToStickerPage(path: currentSelectedImage);
          },
        ),
      ],
    );
  }
}

class MenuItemWidget extends StatelessWidget {
  const MenuItemWidget({
    super.key,
    required this.title,
    required this.onTap,
    this.imageUrl,
    this.backgroundColor = Colors.white,
  });

  final String title;
  final String? imageUrl;
  final VoidCallback onTap;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: backgroundColor,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: 8,
            horizontal: 16,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 4),
                    if (imageUrl != null)
                      SizedBox(
                        width: 60,
                        height: 60,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: AppImage(
                            image: imageUrl ?? '',
                            memCacheWidth: 100,
                            memCacheHeight: 100,
                          ),
                        ),
                      )
                    else
                      const SelectImagePlaceHolder(),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: onTap,
                child: LText(
                  LKey.play,
                  style: theme.textTheme.titleMedium,
                ),
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(theme.highlightColor),
                  shape: WidgetStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: theme.highlightColor2,
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SelectImagePlaceHolder extends StatelessWidget {
  const SelectImagePlaceHolder({super.key});

  @override
  Widget build(BuildContext context) {
    final height = 60.0;
    final theme = context.appTheme;

    return SizedBox(
      height: height,
      width: height,
      child: DottedBorder(
        color: theme.textColor2,
        borderType: BorderType.RRect,
        radius: Radius.circular(8),
        dashPattern: const [6, 6],
        strokeCap: StrokeCap.butt,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Icon(
              HugeIcons.strokeRoundedImageAdd02,
            ),
          ),
        ),
      ),
    );
  }
}
