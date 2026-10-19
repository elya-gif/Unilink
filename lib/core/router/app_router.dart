import 'dart:async';
import '../../features/auth/presentation/register_page.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/data/auth_repository.dart';
import '../../features/auth/presentation/login_page.dart';
import '../../features/home/presentation/home_page.dart';
import '../../features/profile/data/profile_repository.dart';
import '../../features/profile/presentation/onboarding_page.dart';
import '../../features/profile/presentation/skills_page.dart';
import '../../features/projects/presentation/project_detail_page.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);

  final refresh = _RouterRefreshStream(authRepository.authStateChanges());
  ref.onDispose(refresh.dispose);

  // Profil yüklenince/değişince de redirect kurallarını tekrar çalıştır
  ref.listen(currentProfileProvider, (previous, next) => refresh.notify());

  return GoRouter(
    initialLocation: '/',
    refreshListenable: refresh,

    redirect: (context, state) {
      final loggedIn = authRepository.currentUser != null;
      final onAuthPage = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';

      if (!loggedIn && !onAuthPage) return '/login';
      if (loggedIn && onAuthPage) return '/';

      if (loggedIn) {
        final profileAsync = ref.read(currentProfileProvider);
        // Profil henüz yükleniyorsa karar verme; gelince listen tekrar tetikler
        if (profileAsync.isLoading) return null;

        final profile = profileAsync.value;
        final onOnboarding = state.matchedLocation == '/onboarding';
        if (profile != null && !profile.isComplete && !onOnboarding) {
          return '/onboarding';
        }
      }
      return null;
    },

    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const HomePage(),
      ),
       GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingPage(),
      ),
      GoRoute(
        path: '/skills',
        builder: (context, state) => const SkillsPage(),
      ),
      GoRoute(
        // :id = adresin değişken kısmı, örn. /projects/12
        path: '/projects/:id',
        builder: (context, state) => ProjectDetailPage(
          projectId: int.parse(state.pathParameters['id']!),
        ),
      ),
    ],
  );
});



class _RouterRefreshStream extends ChangeNotifier {
  _RouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  // Stream dışından da (örn. profil değişince) router'ı uyarabilmek için
  void notify() => notifyListeners();

  @override
  void dispose() {
    _subscription.cancel(); 
    super.dispose();
  }
}