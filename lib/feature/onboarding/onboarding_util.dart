import 'package:meow_app/core/util/storage.dart';

/// Utility class for managing onboarding state
class OnboardingUtil {
  static const String _onboardingCompletedKey = 'onboarding_completed';

  /// Check if onboarding has been completed
  static Future<bool> isOnboardingCompleted() async {
    final storage = SimpleStorage();
    return await storage.getBool(_onboardingCompletedKey) ?? false;
  }

  /// Mark onboarding as completed
  static Future<void> completeOnboarding() async {
    final storage = SimpleStorage();
    await storage.saveBool(_onboardingCompletedKey, true);
  }

  /// Reset onboarding status (useful for testing)
  static Future<void> resetOnboarding() async {
    final storage = SimpleStorage();
    await storage.saveBool(_onboardingCompletedKey, false);
  }
}
