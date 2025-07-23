import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meow_app/feature/base_page.dart';
import 'package:meow_app/feature/game_sticker/cubit/sticker_list_cubit.dart';
import 'package:meow_app/resources/theme/theme_data.dart';
import 'package:meow_app/widgets/image_view.dart';

import '../../data/repositories/image_storage_repository.dart';
import '../../widgets/text.dart';

class StickerListPage extends StatefulWidget {
  const StickerListPage({super.key});

  @override
  State<StickerListPage> createState() => _StickerListPageState();
}

class _StickerListPageState extends CustomState<StickerListPage, StickerListCubit> {
  final Set<ImageStorageModel> selectedUrls = {};
  bool isSelectionMode = false;
  bool showCheckbox = false;

  final StickerListCubit _cubit = StickerListCubit();

  @override
  StickerListCubit get cubit => _cubit;

  @override
  void initState() {
    super.initState();
    _cubit.loadItems();
  }

  void toggleSelect(ImageStorageModel url) {
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
      // context.read<FavouriteCubit>().removeFavouriteItem(url);
    }
    clearSelection();
  }

  void viewImageDetail(ImageStorageModel url, String heroTag) {
    // DetailImagePage(
    //   url: url,
    //   heroTag: heroTag,
    // ).show(context);
  }

  @override
  PreferredSizeWidget? buildAppbar(BuildContext context) {
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
        LKey.sticker,
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
    return BlocBuilder<StickerListCubit, StickerListState>(
      builder: (context, state) {
        final items = state.items;
        if (items.isEmpty) {
          return Center(child: LText(LKey.noFavourite));
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          itemCount: items.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 3,
            mainAxisSpacing: 3,
          ),
          itemBuilder: (context, index) {
            final image = items[index];
            final isSelected = selectedUrls.contains(image);

            return GestureDetector(
              onTap: () {
                if (showCheckbox) {
                  toggleSelect(image);
                } else {
                  viewImageDetail(image, '$index');
                }
              },
              onLongPress: () {
                if (!showCheckbox) {
                  toggleSelect(image);
                  showCheckbox = true;
                }
              },
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Hero(
                      tag: '$index',
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: StrImageWidget(
                          key: ObjectKey(image),
                          image: image,
                        ),
                      ),
                    ),
                  ),
                  if (showCheckbox)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: IgnorePointer(
                        child: Radio<bool>(
                          value: selectedUrls.contains(image),
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
        );
      },
    );
  }
}
