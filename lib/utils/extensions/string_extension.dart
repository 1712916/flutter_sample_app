extension StringX on String {
  bool get isUrl {
    return Uri.tryParse(this)?.isAbsolute ?? false;
  }
}
