import 'package:in_app_review/in_app_review.dart';
import 'package:meow_app/core/index.dart';

class InAppReviewUtil {
  final InAppReview _inAppReview = InAppReview.instance;

  final SimpleStorage _simpleStorage = SimpleStorage();

  static final String _isShowedKey = 'inAppReviewShowedKey';

  Future<void> checkAndShowReviewDialog() async {
    final bool isShowed = await _simpleStorage.getBool(_isShowedKey) ?? false;
    if (!isShowed) {
      if (await _inAppReview.isAvailable()) {
        await _inAppReview.requestReview();
        await _simpleStorage.saveBool(_isShowedKey, true);
      }
    }
  }

  Future<void> requestReview() async {
    if (await _inAppReview.isAvailable()) {
      await _inAppReview.requestReview();
    }
  }

  Future<void> openStoreListing() async {
    if (await _inAppReview.isAvailable()) {
      await _inAppReview.openStoreListing();
    }
  }

  Future<bool> isAvailable() async {
    return await _inAppReview.isAvailable();
  }
}
