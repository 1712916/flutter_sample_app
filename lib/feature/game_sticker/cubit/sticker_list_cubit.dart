import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repositories/image_storage_repository.dart';

class StickerListState extends Equatable {
  final List<ImageStorageModel> items;
  final int totalItems;

  StickerListState({required this.items, this.totalItems = 0});

  @override
  List<Object?> get props => [items, totalItems];
}

class StickerListCubit extends Cubit<StickerListState> {
  StickerListCubit() : super(StickerListState(items: []));

  final ImageStorageRepository imageStorageRepository = ImageStorageRepository.instance;

  void addFavouriteItem(String url) async {
    // final existingItem = await _landCertificateRepository.getOneByName(url);
    // if (existingItem != null) {
    //   return;
    // }
    //
    // final now = DateTime.now();
    // final today = DateTime(now.year, now.month, now.day);
    // final List<FavouriteGroupItem> updatedItems = [...state.items];
    //
    // final index = updatedItems.indexWhere((item) => isSameDate(item.date, today));
    // if (index != -1) {
    //   final urls = Set<String>.from(updatedItems[index].urls)..add(url);
    //   updatedItems[index] = FavouriteGroupItem(date: today, urls: urls.toList());
    // } else {
    //   updatedItems.add(FavouriteGroupItem(date: today, urls: [url]));
    // }
    //
    // emit(FavouriteState(items: updatedItems));
    //
    // _landCertificateRepository.create(FavouriteItem(url: url, favouritedAt: now));
  }

  void removeFavouriteItem(String url) async {
    // final existingItem = await _landCertificateRepository.getOneByName(url);
    // if (existingItem == null) {
    //   return;
    // }
    //
    // final List<FavouriteGroupItem> updatedItems = [];
    //
    // for (final item in state.items) {
    //   final filteredUrls = item.urls.where((u) => u != url).toList();
    //   if (filteredUrls.isNotEmpty) {
    //     updatedItems.add(FavouriteGroupItem(date: item.date, urls: filteredUrls));
    //   }
    // }
    //
    // emit(FavouriteState(items: updatedItems));
    //
    // _landCertificateRepository.delete(existingItem);
  }

  void loadItems() {
    imageStorageRepository.getAll().then((items) {
      emit(StickerListState(items: items));
    });
  }
}
