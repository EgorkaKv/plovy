import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:plovy/core/di/injection.dart';
import 'package:plovy/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:plovy/features/auth/presentation/bloc/login_form_bloc.dart';
import 'package:plovy/features/auth/presentation/bloc/register_form_bloc.dart';
import 'package:plovy/features/auth/presentation/pages/login_page.dart';
import 'package:plovy/features/auth/presentation/pages/register_page.dart';
import 'package:plovy/features/auth/presentation/pages/splash_page.dart';
import 'package:plovy/features/catalog/domain/repositories/hairstyle_repository.dart';
import 'package:plovy/features/catalog/presentation/bloc/catalog_bloc.dart';
import 'package:plovy/features/catalog/presentation/pages/catalog_page.dart';
import 'package:plovy/features/face_mesh/presentation/pages/camera_page.dart';
import 'package:plovy/features/home/presentation/bloc/home_bloc.dart';
import 'package:plovy/features/home/presentation/pages/home_page.dart';
import 'package:plovy/features/settings/presentation/pages/settings_page.dart';

class AppRoutes {
  static const String splash = '/splash';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String settings = '/settings';
  static const String camera = '/camera';
  static const String catalog = '/catalog';
}

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  routes: <RouteBase>[
    GoRoute(
      path: AppRoutes.splash,
      builder: (BuildContext context, GoRouterState state) {
        context.read<AuthBloc>().add(const CheckAuthEvent());
        return const SplashPage();
      },
    ),
    GoRoute(
      path: AppRoutes.login,
      builder: (BuildContext context, GoRouterState state) {
        return BlocProvider(
          create: (_) => LoginFormBloc(),
          child: const LoginPage(),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.register,
      builder: (BuildContext context, GoRouterState state) {
        return BlocProvider(
          create: (_) => RegisterFormBloc(),
          child: const RegisterPage(),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.home,
      builder: (BuildContext context, GoRouterState state) {
        return BlocProvider<HomeBloc>(
          create: (_) => getIt<HomeBloc>()..add(const HomeStarted()),
          child: const HomePage(),
        );
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
    GoRoute(
      path: AppRoutes.catalog,
      builder: (BuildContext context, GoRouterState state) {
        return BlocProvider(
          create: (_) => CatalogBloc(getIt<HairstyleRepository>())
            ..add(const CatalogStarted()),
          child: const CatalogPage(),
        );
      },
    ),
  ],
);
