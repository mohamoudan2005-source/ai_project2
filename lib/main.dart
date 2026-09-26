import 'package:ai_project/onboarding/ui/screens/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ai_project/app/ui/screens/main_screen.dart';
import 'package:ai_project/onboarding/providers/onboarding_provider.dart';
import 'package:ai_project/onboarding/ui/screens/onboarding_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ScreenUtil.ensureScreenSize();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final prefs = await SharedPreferences.getInstance();
  final bool onboardingDone =
      prefs.getBool("snap_sort_onboarding_done") ?? false;
  runApp(
    Sorty(initialScreen: onboardingDone ? MainScreen() : OnboardingRouter()),
  );
}

class Sorty extends StatelessWidget {
  const Sorty({super.key, required this.initialScreen});
  final Widget initialScreen;
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      minTextAdapt: true,
      splitScreenMode: true,
      designSize: const Size(430.0, 932.0),
      child: ProviderScope(
        child: MaterialApp(
          title: 'Lung Lens',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            scaffoldBackgroundColor: Colors.black,
            primaryColor: Color(0xFFC8F135),
          ),
          home: initialScreen,
        ),
      ),
    );
  }
}

class OnboardingRouter extends HookConsumerWidget {
  const OnboardingRouter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingProvider);

    // Welcome screen is page 0
    if (state.currentPage == 0) {
      return const WelcomeScreen();
    }

    // Pages 1+ are the onboarding slides
    return const OnboardingScreen();
  }
}
