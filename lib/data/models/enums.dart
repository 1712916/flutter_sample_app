enum ImageType {
  jpg, png, gif,
}

enum OrderType {
  desc, asc, rand,
}

extension ImageTypeString on String {
  ImageType? toImageType() {
    try {
      String name = split('.')[1];
      return ImageType.values.firstWhere((element) => element.name == name);
    } catch (e) {
      return null;
    }
  }

  OrderType? toOrderType() {
    try {
      String name = split('.')[1];
      return OrderType.values.firstWhere((element) => element.name == name);
    } catch (e) {
      return null;
    }
  }
}