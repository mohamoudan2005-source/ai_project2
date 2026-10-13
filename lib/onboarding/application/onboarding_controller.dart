import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ai_project/onboarding/application/onboarding_event.dart';
import 'package:ai_project/onboarding/application/onboarding_state.dart';

class OnboardingController extends StateNotifier<OnboardingState> {
  OnboardingController() : super(OnboardingState.initial());
  final _onboardingKey = 'snap_sort_onboarding_done';

  void nextPage() {
    if (state.isLastPage) return;
    state = state.copyWith(currentPage: state.currentPage + 1);
  }

  void prevPage() {
    if (state.currentPage == 0) return;
    state = state.copyWith(currentPage: state.currentPage - 1);
  }

  void goToPage({required int page}) {
    state = state.copyWith(currentPage: page);
  }

  Future<void> complete() async {
    print("object");
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingKey, true);
    print("object 00");

    state = state.copyWith(isComplete: true);
  }

  Future<bool> hasSeenOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardingKey) ?? false;
  }

  Future<void> mapEventToState(OnboardingEvent event) async {
    event.when(
      goToPage: (page) => goToPage(page: page),
      nextPage: nextPage,
      prevPage: prevPage,
      hasSeenOnboarding: hasSeenOnboarding,
      complete: complete,
    );
  }
}
