import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:plovy/core/routing/app_router.dart';
import 'package:plovy/core/widgets/app_button.dart';
import 'package:plovy/core/widgets/app_text_field.dart';
import 'package:plovy/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:plovy/features/auth/presentation/bloc/login_form_bloc.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (BuildContext context, AuthState state) {
          if (state is AuthAuthenticated) {
            context.go(AppRoutes.home);
          }
          if (state is AuthError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (BuildContext context, AuthState authState) {
          return SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      AppTextField(
                        hintText: 'Email',
                        onChanged: (v) => context
                            .read<LoginFormBloc>()
                            .add(LoginEmailChanged(v)),
                      ),
                      const SizedBox(height: 12),
                      AppTextField(
                        hintText: 'Password',
                        obscureText: true,
                        onChanged: (v) => context
                            .read<LoginFormBloc>()
                            .add(LoginPasswordChanged(v)),
                      ),
                      const SizedBox(height: 16),
                      BlocBuilder<LoginFormBloc, LoginFormState>(
                        builder: (context, formState) => AppButton(
                          text: 'Login',
                          isLoading: authState is AuthLoading,
                          onPressed: () {
                            context.read<AuthBloc>().add(
                                  LoginEvent(
                                    email: formState.email,
                                    password: formState.password,
                                  ),
                                );
                          },
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () => context.push(AppRoutes.register),
                        child: const Text('Go to Register'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
