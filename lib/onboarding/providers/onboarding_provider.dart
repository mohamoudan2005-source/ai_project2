import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:ai_project/onboarding/application/onboarding_controller.dart';
import 'package:ai_project/onboarding/application/onboarding_state.dart';

final onboardingProvider =
    StateNotifierProvider<OnboardingController, OnboardingState>((ref) {
      OnboardingController onboardingController = OnboardingController();
      return onboardingController;
    });
