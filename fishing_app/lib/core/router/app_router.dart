import 'package:fishing_app/features/auth/provider/auth_provider.dart';
import 'package:fishing_app/features/auth/view/login_page.dart';
import 'package:fishing_app/features/auth/view/signup_page.dart';
import 'package:fishing_app/features/community/view/community_page.dart';
import 'package:fishing_app/features/home/view/home_shell.dart';
import 'package:fishing_app/features/point/view/point_create_page.dart';
import 'package:fishing_app/features/point/view/point_detail_page.dart';
import 'package:fishing_app/features/point/view/point_list_page.dart';
import 'package:fishing_app/features/point/view/visit_create_page.dart';
import 'package:fishing_app/features/prediction/view/prediction_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_router.g.dart';

@riverpod
GoRouter appRouter(Ref ref) {
  final authAsync = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/prediction',
    redirect: (context, state) {
      final isLoggedIn = authAsync.valueOrNull ?? false;
      final isAuthRoute = state.matchedLocation == '/login' ||
          state.matchedLocation == '/signup';

      if (!isLoggedIn && !isAuthRoute) return '/login';
      if (isLoggedIn && isAuthRoute) return '/prediction';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(path: '/signup', builder: (context, state) => const SignupPage()),
      GoRoute(path: '/points/create', builder: (context, state) => const PointCreatePage()),
      GoRoute(
        path: '/points/:id',
        builder: (context, state) => PointDetailPage(pointId: int.parse(state.pathParameters['id']!)),
      ),
      GoRoute(
        path: '/points/:id/visits/create',
        builder: (context, state) => VisitCreatePage(pointId: int.parse(state.pathParameters['id']!)),
      ),
      ShellRoute(
        builder: (context, state, child) => HomeShell(child: child),
        routes: [
          GoRoute(path: '/prediction', builder: (context, state) => const PredictionPage()),
          GoRoute(path: '/points', builder: (context, state) => const PointListPage()),
          GoRoute(path: '/community', builder: (context, state) => const CommunityPage()),
        ],
      ),
    ],
  );
}
