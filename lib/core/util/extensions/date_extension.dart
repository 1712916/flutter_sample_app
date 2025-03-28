import 'package:intl/intl.dart';

extension DateFormatting on DateTime {
  String formatByLocale(String locale) {
    if (locale.startsWith('vi')) {
      return 'Ngày ${this.day}, tháng ${this.month}, năm ${this.year}';
    }

    // en, fr, etc. – format theo chuẩn locale
    return DateFormat.yMMMMd(locale).format(this);
  }
}
