import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meow_app/core/index.dart';
import 'package:meow_app/feature/base_page.dart';
import 'package:meow_app/feature/favourite/cubit/favourite_cubit.dart';
import 'package:meow_app/resources/theme/theme_data.dart';
import 'package:meow_app/widgets/image_view.dart';

import '../../widgets/text.dart';
import '../image/detail_image_page.dart';

class FavouritePage extends StatefulWidget {
  const FavouritePage({super.key});

  @override
  State<FavouritePage> createState() => _FavouritePageState();
}

class _FavouritePageState extends StateTemplate<FavouritePage> {
  final Set<String> selectedUrls = {};
  bool isSelectionMode = false;
  bool showCheckbox = false;

  @override
  void initState() {
    super.initState();
    context.read<FavouriteCubit>().loadFavouriteItems();
  }

  void toggleSelect(String url) {
    setState(() {
      selectedUrls.contains(url) ? selectedUrls.remove(url) : selectedUrls.add(url);

      isSelectionMode = selectedUrls.isNotEmpty;
    });
  }

  void clearSelection() {
    setState(() {
      selectedUrls.clear();
      isSelectionMode = false;
      showCheckbox = false;
    });
  }

  void removeSelected(BuildContext context) {
    for (final url in selectedUrls) {
      context.read<FavouriteCubit>().removeFavouriteItem(url);
    }
    clearSelection();
  }

  void viewImageDetail(String url, String heroTag) {
    DetailImagePage(
      url: url,
      heroTag: heroTag,
    ).show(context);
  }

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context) {
    final textColor = theme.textColor2;

    if (isSelectionMode) {
      return AppBar(
        backgroundColor: theme.scaffoldBackgroundColor2,
        title: Text(
          '${selectedUrls.length} ${LKey.selected.tr(context: context)}',
          style: theme.textTheme.titleLarge?.copyWith(
            color: textColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: clearSelection,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => removeSelected(context),
          )
        ],
      );
    }

    return AppBar(
      backgroundColor: theme.scaffoldBackgroundColor2,
      title: LText(
        LKey.favourite,
        style: theme.textTheme.titleLarge?.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios,
          color: textColor,
        ),
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
      actions: [
        TextButton(
          onPressed: () {
            setState(() {
              showCheckbox = true;
              isSelectionMode = true;
            });
          },
          child: LText(
            LKey.choose,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
      ],
    );
  }

  @override
  Widget buildBody(BuildContext context) {
    return BlocBuilder<FavouriteCubit, FavouriteState>(
      builder: (context, state) {
        final items = state.items;
        if (items.isEmpty) {
          return Center(child: LText(LKey.noFavourite));
        }

        return ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) {
            final group = items[index];
            final formattedDate = group.date.formatByLocale(context.locale.languageCode);
            final urls = group.urls;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    formattedDate,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: urls.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 3,
                    mainAxisSpacing: 3,
                  ),
                  itemBuilder: (context, i) {
                    final url = urls[i];
                    final isSelected = selectedUrls.contains(url);

                    return GestureDetector(
                      onTap: () {
                        if (showCheckbox) {
                          toggleSelect(url);
                        } else {
                          viewImageDetail(url, '$index$url');
                        }
                      },
                      onLongPress: () {
                        if (!showCheckbox) {
                          toggleSelect(url);
                          showCheckbox = true;
                        }
                      },
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: Hero(
                              tag: '$index$url',
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: AppImage(image: url),
                              ),
                            ),
                          ),
                          if (showCheckbox)
                            Positioned(
                              top: 0,
                              right: 0,
                              child: IgnorePointer(
                                child: Radio<bool>(
                                  value: selectedUrls.contains(url),
                                  groupValue: true,
                                  onChanged: (_) {},
                                  activeColor: Colors.white,
                                  focusColor: Colors.white,
                                  fillColor: WidgetStateProperty.all(Colors.white),
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}
