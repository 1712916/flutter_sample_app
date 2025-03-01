import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:meow_app/resources/theme/theme_data.dart';
import 'package:meow_app/views/pages/game/crop_image_view.dart';

import '../../../cubits/cubits.dart';
import '../../../resources/resources.dart';
import '../../../routers/route.dart';
import '../../../utils/utils.dart';
import '../../../widgets/widgets.dart';
import '../base_page/base_page.dart';
import 'grid_view.dart';
import 'page_view.dart';

const double iconSize = 36.0;

class ImageListPage extends StatefulWidget {
  const ImageListPage({Key? key, required this.cubit}) : super(key: key);

  final ImageListCubit cubit;

  @override
  _ImageListPageState createState() => _ImageListPageState();
}

class _ImageListPageState extends CustomState<ImageListPage, ImageListCubit> {
  bool _isLoadMore = false;

  @override
  void initState() {
    super.initState();
    cubit.init();
    //add frame call back
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      cubit.showPageView(0);
    });
  }

  @override
  Widget buildContent(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        buildImageView(context),
        buildMenuView(context),
        Positioned(
          top: 16,
          left: 16,
          right: 16,
          child: SafeArea(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Opacity(
                  opacity: 0.0,
                  child: CircleAvatar(
                    backgroundColor: theme.actionBackground,
                    child: IconButton(
                      onPressed: () {},
                      icon: HugeIcon(
                        icon: HugeIcons.strokeRoundedSettings01,
                        color: theme.iconColor,
                        // size: iconSize,
                      ),
                    ),
                  ),
                ),
                AnimalDropdown(
                  onTapAction: (value) {
                    if (value == 'Meow') {
                      cubit.switchToCat();
                    } else {
                      cubit.switchToDog();
                    }
                  },
                ),
                CircleAvatar(
                  backgroundColor: theme.actionBackground,
                  child: IconButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed(RouteManager.settingPage);
                    },
                    icon: HugeIcon(
                      icon: HugeIcons.strokeRoundedSettings01,
                      color: theme.iconColor,
                      // size: iconSize,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget buildImageView(BuildContext) {
    return Navigator(
      key: cubit.navKey,
      clipBehavior: Clip.none,
      initialRoute: '/',
      transitionDelegate: const DefaultTransitionDelegate(),
      onGenerateRoute: (settings) {
        Widget page = SizedBox();

        final viewType = ImageViewType.fromPath(settings.name!);
        final arguments = settings.arguments;

        switch (viewType) {
          case ImageViewType.grid:
            {
              page = ImageGridView();
              break;
            }
          case ImageViewType.page:
            {
              page = ImagePageView();
              break;
            }
        }

        if (true) {
          return MaterialPageRoute(
            allowSnapshotting: true,
            fullscreenDialog: true,
            settings: settings,
            builder: (context) {
              return Material(
                color: theme.scaffoldBackgroundColor,
                child: page,
              );
            },
            // settings: settings,
          );
        }

        return PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 600),
          pageBuilder: (context, animation, secondaryAnimation) =>
              Material(color: theme.scaffoldBackgroundColor, child: page),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0); // Start off-screen (right)
            const end = Offset.zero; // End at normal position
            const curve = Curves.linear;

            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            var offsetAnimation = animation.drive(tween);

            // return FadeTransition(
            //   opacity: animation,
            //   child: Material(color: theme.scaffoldBackgroundColor, child: child),
            // );
            return ScaleTransition(
              scale: Tween<double>(begin: 1.0, end: 1.0).animate(
                CurvedAnimation(parent: animation, curve: curve),
              ),
              child: child,
            );
          },
        );
      },
    );
  }

  Widget buildMenuView(BuildContext) {
    return BlocBuilder<ImageListCubit, ImageListState>(
      builder: (context, state) {
        switch (state.viewType) {
          case ImageViewType.grid:
            return Positioned(
              bottom: 40,
              left: 40,
              right: 40,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TakeImageButton(
                        onTapAction: () {},
                      ),
                    ],
                  ),
                ],
              ),
            );
          case ImageViewType.page:
            return Positioned(
              bottom: 40,
              left: 40,
              right: 40,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () {
                          cubit.showGridView();
                        },
                        icon: HugeIcon(
                          icon: HugeIcons.strokeRoundedGridView,
                          color: theme.iconColor,
                          size: iconSize,
                        ),
                      ),
                      TakeImageButton(
                        onTapAction: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => CropImageView(
                                url: cubit.currentUrl!,
                              ),
                            ),
                          );
                          // Navigator.of(context).push(
                          //   MaterialPageRoute(
                          //     builder: (context) => GamePage2(
                          //       url: cubit.currentUrl,
                          //     ),
                          //   ),
                          // );
                        },
                      ),
                      IconButton(
                        onPressed: () {
                          ShareWidget(
                            url: cubit.currentUrl!,
                            onDelete: () {
                              Navigator.of(context).pop();
                              cubit.onDelete();
                            },
                          ).show(context);
                        },
                        icon: HugeIcon(
                          icon: HugeIcons.strokeRoundedUpload04,
                          color: theme.iconColor,
                          size: iconSize,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
        }
      },
    );
  }

  @override
  ImageListCubit get cubit => widget.cubit;
}

class TakeImageButton extends StatefulWidget {
  final VoidCallback onTapAction;

  const TakeImageButton({
    super.key,
    required this.onTapAction,
  });

  @override
  State<TakeImageButton> createState() => _TakeImageButtonState();
}

class _TakeImageButtonState extends State<TakeImageButton> {
  double _scale = 1.0;
  bool _isLongPressing = false;

  void _onTap() {
    if (!_isLongPressing) {
      widget.onTapAction(); // Tap một cái thực hiện luôn
    }
  }

  void _onLongPressDown(LongPressDownDetails details) {
    setState(() {
      _scale = 0.9;
      _isLongPressing = true;
    });
  }

  void _onLongPressUp() {
    setState(() {
      _scale = 1.0;
      _isLongPressing = false;
    });
    widget.onTapAction(); // Gọi action khi thả tay sau long press
  }

  void _onLongPressCancel() {
    setState(() {
      _scale = 1.0;
      _isLongPressing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: widget.onTapAction, // Tap một cái gọi ngay action
      onLongPressDown: _onLongPressDown,
      onLongPressUp: _onLongPressUp,
      onLongPressCancel: _onLongPressCancel,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 100),
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: theme.highlightColor2, width: 4),
          ),
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: theme.actionBackground,
              shape: BoxShape.circle,
            ),
            child: HugeIcon(
              icon: HugeIcons.strokeRoundedGameboy,
              color: theme.iconColor,
              size: 32.0,
            ),
          ),
        ),
      ),
    );
  }
}

class AnimalDropdown extends StatefulWidget {
  const AnimalDropdown({super.key, required this.onTapAction});

  final ValueChanged<String> onTapAction;

  @override
  State<AnimalDropdown> createState() => _AnimalDropdownState();
}

class _AnimalDropdownState extends State<AnimalDropdown> {
  final List<String> items = [
    'Meow',
    'Gaow',
  ];

  Map<String, String> animalMap = {
    'Meow': 'assets/icon/cat.svg',
    'Gaow': 'assets/icon/dog.svg',
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 120,
      child: CustomDropdownButton<String>(
        initial: SettingManager.isMeow ? 0 : 1,
        title: (item) {
          return Text(
            item ?? '',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.iconColor,
            ),
          );
        },
        items: items,
        itemBuilder: (item, isSelected) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  animalMap[item]!,
                  color: theme.iconColor,
                  width: 24,
                  height: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  item,
                  style: TextStyle(color: theme.iconColor),
                ),
              ],
            ),
          );
        },
        onChange: (index) {
          widget.onTapAction?.call(items[index]);
        },
      ),
    );
  }
}

class ShareWidget extends StatelessWidget {
  const ShareWidget({super.key, required this.url, required this.onDelete});

  final String url;
  final VoidCallback onDelete;

  Future show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      useSafeArea: true,
      // showDragHandle: true,
      backgroundColor: Theme.of(context).cardColor2,
      builder: (context) => this,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final textColor = theme.textColor2;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                height: 44,
                child: Text(
                  LocaleKeys.shareTo.tr(),
                  style: textTheme.titleMedium?.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                alignment: Alignment.center,
              ),
              Positioned(
                right: 0,
                child: CircleAvatar(
                  radius: 16,
                  backgroundColor: theme.actionBackground,
                  child: IconButton(
                    iconSize: 20,
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: Icon(
                      Icons.close,
                      color: theme.iconColor,
                      // size: iconSize,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconTitleWidget(
                icon: HugeIcons.strokeRoundedShare05,
                title: LocaleKeys.share.tr(),
                onTap: () {
                  ShareHelper.shareImage(url: url).whenComplete(
                    () {
                      Navigator.of(context).pop();
                    },
                  );
                },
              ),
              IconTitleWidget(
                icon: HugeIcons.strokeRoundedMessage02,
                title: LocaleKeys.message.tr(),
                onTap: () {
                  ShareHelper.shareToMessage(url: url);
                },
              ),
              IconTitleWidget(
                icon: HugeIcons.strokeRoundedInstagram,
                title: LocaleKeys.instagram.tr(),
                onTap: () {
                  ShareHelper.shareToInstagram(url: url);
                },
              ),
              IconTitleWidget(
                icon: HugeIcons.strokeRoundedTwitter,
                title: LocaleKeys.telegram.tr(),
                onTap: () {
                  ShareHelper.shareToTwitter(url: url);
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => onDownload(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: theme.actionBackground,
                      borderRadius: BorderRadius.circular(40),
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        HugeIcon(icon: HugeIcons.strokeRoundedDownloadSquare01, color: theme.iconColor),
                        const SizedBox(width: 4),
                        Text(
                          LocaleKeys.save.tr(context: context),
                          style: textTheme.titleMedium?.copyWith(
                            color: textColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: GestureDetector(
                  onTap: onDelete,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: theme.actionBackground,
                      borderRadius: BorderRadius.circular(40),
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        HugeIcon(icon: HugeIcons.strokeRoundedDelete02, color: theme.iconColor),
                        const SizedBox(width: 4),
                        Text(
                          LocaleKeys.delete.tr(context: context),
                          style: textTheme.titleMedium?.copyWith(
                            color: textColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void onDownload(BuildContext context) {
    DownloadHelper.downloadImage(url: url).whenComplete(
      () {
        Navigator.of(context).pop();
      },
    );
  }
}

class IconTitleWidget extends StatelessWidget {
  const IconTitleWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final textColor = theme.textColor2;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              // color: theme.actionBackground,
              shape: BoxShape.circle,
              border: Border.all(color: theme.actionBackground, width: 2),
            ),
            padding: const EdgeInsets.all(2),
            child: Container(
              decoration: BoxDecoration(
                color: theme.actionBackground,
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(8),
              child: Icon(
                icon,
                size: 20,
                color: theme.iconColor,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: textTheme.titleMedium?.copyWith(color: textColor),
          ),
        ],
      ),
    );
  }
}
