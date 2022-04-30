
abstract class Copyable<T> {
  T copy();
  T copyWith();
}

abstract class JsonConvert<T> {
  Map<String, dynamic> toJson();
}
