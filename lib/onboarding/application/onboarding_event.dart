import 'package:freezed_annotation/freezed_annotation.dart';

part 'onboarding_event.freezed.dart';

@freezed
class OnboardingEvent with _$OnboardingEvent {
  const factory OnboardingEvent.nextPage() = NextPage;
  const factory OnboardingEvent.prevPage() = PrevPage;
  const factory OnboardingEvent.goToPage(int page) = GoToPage;
  const factory OnboardingEvent.hasSeenOnboarding() = HasSeenOnboarding;
  const factory OnboardingEvent.complete() = Complete;
}
