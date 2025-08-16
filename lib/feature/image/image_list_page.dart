import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:meow_app/feature/app_menu/cubit/app_menu_cubit.dart';
import 'package:meow_app/resources/theme/theme_data.dart';
import 'package:showcaseview/showcaseview.dart';

import '../../../routers/route.dart';
import '../../../widgets/image_picker_widget.dart';
import '../../../widgets/widgets.dart';
import '../../core/index.dart';
import '../base_page.dart';
import '../game/game_menu_page.dart';
import '../home_widget/home_widget_page.dart';
import '../showcase/showcase_util.dart';
import '../showcase/showcase_widget.dart';
import 'cubit/image_list_cubit.dart';
import 'grid_view.dart';
import 'page_view.dart';

const double iconSize = 36.0;

class ImageListPage extends StatefulWidget {
  const ImageListPage({
    Key? key,
  }) : super(key: key);

  @override
  _ImageListPageState createState() => _HandlePopImageListPageState();
}

class _HandlePopImageListPageState extends _ImageListPageState with HandlePopPage<ImageListPage> {}

class _ImageListPageState extends State<ImageListPage> {
  late final HeroController _heroControllerScope;

  ImageListCubit get cubit => context.read<ImageListCubit>();

  ThemeData get theme => Theme.of(context);

  BuildContext? myContext;

  @override
  void initState() {
    super.initState();
    _heroControllerScope = MaterialApp.createMaterialHeroController();
    cubit.init();
    //add frame call back
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      cubit.showPageView(0);
      Future.delayed(const Duration(milliseconds: 200), () {
        ShowcaseUtil.startShowcase(myContext!);
      });
    });
  }

  @override
  void dispose() {
    _heroControllerScope.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    AppHomeWidget.handleLaunch(context);
  }

  @override
  Widget build(BuildContext context) {
    return ShowCaseWidget(
      // enableShowcase: ShowcaseUtil.enableShowcase,
      onComplete: (p0, p1) {
        if (p0 == ShowcaseUtil.lastStepIndex) {
          Toast.makeText(message: LKey.enjoyAppDescription.tr(context: context), toastLength: Toast.LENGTH_LONG);
        }
      },
      builder: (context) {
        myContext = context;

        return Scaffold(body: buildContent(context));
      },
    );
  }

  Widget buildContent(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        buildImageView(context),
        buildMenuView(context),
        buildAppbar(context),
      ],
    );
  }

  Widget buildImageView(BuildContext) {
    return HeroControllerScope(
      controller: MaterialApp.createMaterialHeroController(),
      child: Navigator(
        key: cubit.navKey,
        initialRoute: '/',
        onGenerateRoute: (settings) {
          final viewType = ImageViewType.fromPath(settings.name!);

          switch (viewType) {
            case ImageViewType.grid:
              {
                return MaterialPageRoute(
                  allowSnapshotting: true,
                  fullscreenDialog: true,
                  settings: settings,
                  builder: (context) {
                    return Material(
                      color: theme.scaffoldBackgroundColor2,
                      child: ImageGridView(),
                    );
                  },
                  // settings: settings,
                );
              }
            case ImageViewType.page:
              {
                return PageRouteBuilder(
                  settings: settings,
                  fullscreenDialog: true,
                  transitionDuration: const Duration(milliseconds: 400),
                  reverseTransitionDuration: const Duration(milliseconds: 400),
                  pageBuilder: (context, animation, secondaryAnimation) {
                    return ImagePageView();
                  },
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    return FadeTransition(
                      opacity: animation,
                      child: child,
                    );
                  },
                );
              }
          }
        },
      ),
    );
  }

  Widget buildMenuView(BuildContext) {
    return BlocBuilder<AppMenuCubit, AppMenuState>(
      builder: (context, state) {
        if (state.isHideAll) {
          return const SizedBox();
        }

        return Positioned(
          bottom: 40,
          left: 40,
          right: 40,
          child: BlocBuilder<ImageListCubit, ImageListState>(
            builder: (context, state) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AppShowcase(
                    info: ShowcaseUtil.gridViewKey,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 400),
                      child: state.viewType == ImageViewType.page
                          ? IconButton(
                              onPressed: () {
                                cubit.showGridView();
                              },
                              icon: HugeIcon(
                                icon: HugeIcons.strokeRoundedGridView,
                                color: theme.iconColor,
                                size: iconSize,
                              ),
                            )
                          : const SizedBox(),
                    ),
                  ),
                  AppShowcase(
                    info: ShowcaseUtil.gameBoardKey,
                    child: TakeImageButton(
                      onTapAction: () async {
                        goToGameMenu(context);

                        return;

                        switch (state.viewType) {
                          case ImageViewType.grid:
                            //shows menu select image from gallery or camera
                            ImagePickerWidget.showOverlay(
                              context,
                              ImagePickerWidget(
                                onImageSelected: (path) {
                                  if (path != null) {
                                    goToCropImageView(path);
                                  }
                                },
                              ),
                            );
                            break;
                          case ImageViewType.page:
                            goToCropImageView(cubit.currentUrl!);

                            break;
                        }
                      },
                    ),
                  ),
                  AppShowcase(
                    info: ShowcaseUtil.shareViewKey,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 400),
                      child: state.viewType == ImageViewType.page
                          ? IconButton(
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
                            )
                          : const SizedBox(),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget buildAppbar(BuildContext) {
    return BlocBuilder<AppMenuCubit, AppMenuState>(
      builder: (context, state) {
        if (state.isHideAll) {
          return const SizedBox();
        }

        return Positioned(
          top: 16,
          left: 16,
          right: 16,
          child: SafeArea(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CircleAvatar(
                  backgroundColor: theme.actionBackground,
                  child: IconButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed(RouteManager.settingPage);
                    },
                    icon: HugeIcon(
                      icon: HugeIcons.strokeRoundedSettings01, color: theme.iconColor,
                      // size: iconSize,
                    ),
                  ),
                ),
                AppShowcase(
                  info: ShowcaseUtil.switchViewKey,
                  child: AnimalDropdown(
                    onTapAction: (value) {
                      cubit.switchView(value == 'Meow');
                    },
                  ),
                ),
                CircleAvatar(
                  backgroundColor: theme.actionBackground,
                  child: IconButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed(RouteManager.chatPage);
                    },
                    icon: HugeIcon(
                      icon: HugeIcons.strokeRoundedBubbleChatFavourite, color: theme.iconColor,
                      // size: iconSize,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class TakeImageButton extends StatefulWidget {
  final Future Function() onTapAction;
  final Widget? icon;

  const TakeImageButton({
    super.key,
    required this.onTapAction,
    this.icon,
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
    _onTap(); // Gọi action khi thả tay sau long press
  }

  void _onLongPressCancel() {
    setState(() {
      _scale = 1.0;
      _isLongPressing = false;
    });
  }

  bool _isLoading = false;

  void onTap() async {
    setState(() {
      _isLoading = true;
    });
    await widget.onTapAction.call();
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      // Tap một cái gọi ngay action
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
            child: Builder(
              builder: (context) {
                if (_isLoading) {
                  return Center(
                    child: const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    ),
                  );
                }

                return widget.icon ??
                    HugeIcon(
                      icon: HugeIcons.strokeRoundedGameboy,
                      color: theme.iconColor,
                      size: 32.0,
                    );
              },
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
  final VoidCallback? onDelete;

  Future show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      useSafeArea: true,
      // showDragHandle: true,
      backgroundColor: Theme.of(context).cardColor2,
      builder: (context) => this,
      isScrollControlled: true,
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
                  LKey.shareTo.tr(),
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
                      Icons.close, color: theme.iconColor,
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
                title: LKey.share.tr(),
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
                title: LKey.message.tr(),
                onTap: () {
                  ShareHelper.shareToMessage(url: url);
                },
              ),
              IconTitleWidget(
                icon: HugeIcons.strokeRoundedInstagram,
                title: LKey.instagram.tr(),
                onTap: () {
                  ShareHelper.shareToInstagram(url: url);
                },
              ),
              IconTitleWidget(
                icon: HugeIcons.strokeRoundedTwitter,
                title: LKey.telegram.tr(),
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
                          LKey.save.tr(context: context),
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
              if (onDelete != null) ...[
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
                            LKey.delete.tr(context: context),
                            style: textTheme.titleMedium?.copyWith(
                              color: textColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              ]
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
              shape: BoxShape.circle, border: Border.all(color: theme.actionBackground, width: 2),
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

class _LoadingButton extends StatefulWidget {
  const _LoadingButton({super.key, this.onPressed});

  final Future Function()? onPressed;

  @override
  State<_LoadingButton> createState() => _LoadingButtonState();
}

class _LoadingButtonState extends State<_LoadingButton> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        setState(() {
          _isLoading = true;
        });
        await widget.onPressed?.call();
        setState(() {
          _isLoading = false;
        });
      },
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor2,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Theme.of(context).highlightColor2,
            width: 3,
          ),
        ),
        alignment: Alignment.center,
        child: _isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(),
              )
            : Icon(
                Icons.crop,
                color: Theme.of(context).highlightColor2,
              ),
      ),
    );
  }
}
