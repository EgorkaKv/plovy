import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:plovy/core/routing/app_router.dart';
import 'package:plovy/features/auth/presentation/bloc/auth_bloc.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (BuildContext context, AuthState state) {
          if (state is AuthAuthenticated) {
            context.go(AppRoutes.home);
          }
          if (state is AuthUnauthenticated) {
            context.go(AppRoutes.login);
          }
        },
        child: const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
