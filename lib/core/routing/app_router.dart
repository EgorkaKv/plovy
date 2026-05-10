import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:plovy/features/auth/presentation/pages/login_page.dart';
import 'package:plovy/features/auth/presentation/pages/register_page.dart';
import 'package:plovy/features/auth/presentation/pages/splash_page.dart';
import 'package:plovy/features/face_mesh/presentation/pages/camera_page.dart';
import 'package:plovy/features/home/presentation/pages/home_page.dart';
import 'package:plovy/features/settings/presentation/pages/settings_page.dart';

class AppRoutes {
  static const String splash = '/splash';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String settings = '/settings';
  static const String camera = '/camera';
}

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  routes: <RouteBase>[
    GoRoute(
      path: AppRoutes.splash,
      builder: (BuildContext context, GoRouterState state) {
        return const SplashPage();
      },
    ),
    GoRoute(
      path: AppRoutes.login,
      builder: (BuildContext context, GoRouterState state) {
        return const LoginPage();
      },
    ),
    GoRoute(
      path: AppRoutes.register,
      builder: (BuildContext context, GoRouterState state) {
        return const RegisterPage();
      },
    ),
    GoRoute(
      path: AppRoutes.home,
      builder: (BuildContext context, GoRouterState state) {
        return const HomePage();
      },
    ),
    GoRoute(
      path: AppRoutes.settings,
      builder: (BuildContext context, GoRouterState state) {
        return const SettingsPage();
      },
    ),
    GoRoute(
      path: AppRoutes.camera,
      builder: (BuildContext context, GoRouterState state) {
        return const CameraPage();
      },
    ),
  ],
);
