import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/favourite_repository.dart';

class FavouriteGroupItem extends Equatable {
  final DateTime date;
  final List<String> urls;

  FavouriteGroupItem({required this.date, required this.urls});

  @override
  List<Object?> get props => [date, urls];
}

class FavouriteState extends Equatable {
  final List<FavouriteGroupItem> items;
  final int totalItems;

  FavouriteState({required this.items, this.totalItems = 0});

  @override
  List<Object?> get props => [items, totalItems];
}

class FavouriteCubit extends Cubit<FavouriteState> {
  FavouriteCubit() : super(FavouriteState(items: []));

  final LandCertificateRepository _landCertificateRepository = LandCertificateRepositoryImpl();

  void addFavouriteItem(String url) async {
    final existingItem = await _landCertificateRepository.getOneByName(url);
    if (existingItem != null) {
      return;
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final List<FavouriteGroupItem> updatedItems = [...state.items];

    final index = updatedItems.indexWhere((item) => isSameDate(item.date, today));
    if (index != -1) {
      final urls = Set<String>.from(updatedItems[index].urls)..add(url);
      updatedItems[index] = FavouriteGroupItem(date: today, urls: urls.toList());
    } else {
      updatedItems.add(FavouriteGroupItem(date: today, urls: [url]));
    }

    emit(FavouriteState(items: updatedItems));

    _landCertificateRepository.create(FavouriteItem(url: url, favouritedAt: now));
  }

  void removeFavouriteItem(String url) async {
    final existingItem = await _landCertificateRepository.getOneByName(url);
    if (existingItem == null) {
      return;
    }

    final List<FavouriteGroupItem> updatedItems = [];

    for (final item in state.items) {
      final filteredUrls = item.urls.where((u) => u != url).toList();
      if (filteredUrls.isNotEmpty) {
        updatedItems.add(FavouriteGroupItem(date: item.date, urls: filteredUrls));
      }
    }

    emit(FavouriteState(items: updatedItems));

    _landCertificateRepository.delete(existingItem);
  }

  void loadFavouriteItems() {
    _landCertificateRepository.getAll().then((items) {
      final grouped = <DateTime, List<String>>{};

      for (final item in items) {
        final date = DateTime(item.favouritedAt.year, item.favouritedAt.month, item.favouritedAt.day);
        grouped.putIfAbsent(date, () => []).add(item.url);
      }

      final updatedItems = grouped.entries
          .map((entry) => FavouriteGroupItem(date: entry.key, urls: entry.value))
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date)); // newest first

      emit(FavouriteState(items: updatedItems, totalItems: items.length));
    });
  }

  bool isSameDate(DateTime d1, DateTime d2) {
    return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
  }
}
