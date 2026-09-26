import 'package:freezed_annotation/freezed_annotation.dart';

part 'onboarding_state.freezed.dart';

@freezed
class OnboardingState with _$OnboardingState {
  const factory OnboardingState({
    required int currentPage,
    required bool isComplete,
  }) = _OnboardingState;

  const OnboardingState._();

  factory OnboardingState.initial() =>
      OnboardingState(currentPage: 0, isComplete: false);

  bool get isLastPage => currentPage == OnboardingPage.values.length - 1;
}

enum OnboardingPage {
  welcome,
  snap,
  plan,
  streak,
  ready;

  String get title {
    switch (this) {
      case OnboardingPage.welcome:
        return "Hey, I'm Sorty. 👋";
      case OnboardingPage.snap:
        return 'Show me an X-ray.';
      case OnboardingPage.plan:
        return "I'll take it from here.";
      case OnboardingPage.streak:
        return 'Keep track over time.';
      case OnboardingPage.ready:
        return 'Ready when you are.';
    }
  }

  String get subtitle {
    switch (this) {
      case OnboardingPage.welcome:
        return "I take a quick look at chest X-rays and tell you what I see. A helpful first look, not a replacement for a doctor.";
      case OnboardingPage.snap:
        return "Upload a chest X-ray, or snap one with your camera. I'll get started right away.";
      case OnboardingPage.plan:
        return "Give me a few seconds. I'll tell you what I see, and how sure I am about it.";
      case OnboardingPage.streak:
        return "I'll keep a record of your past scans, so you can look back anytime.";
      case OnboardingPage.ready:
        return "One thing to remember: I'm a demo, not a doctor. Always check with a real one. Let's go. 🫁";
    }
  }

  String get emoji {
    switch (this) {
      case OnboardingPage.welcome:
        return '🫁';
      case OnboardingPage.snap:
        return '📸';
      case OnboardingPage.plan:
        return '🔬';
      case OnboardingPage.streak:
        return '📈';
      case OnboardingPage.ready:
        return '🚀';
    }
  }
}
