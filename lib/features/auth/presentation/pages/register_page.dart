import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:plovy/core/routing/app_router.dart';
import 'package:plovy/core/widgets/app_button.dart';
import 'package:plovy/core/widgets/app_text_field.dart';
import 'package:plovy/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:plovy/features/auth/presentation/bloc/register_form_bloc.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (BuildContext context, AuthState state) {
          if (state is AuthUnauthenticated) {
            context.go(AppRoutes.login);
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
                            .read<RegisterFormBloc>()
                            .add(RegisterEmailChanged(v)),
                      ),
                      const SizedBox(height: 12),
                      AppTextField(
                        hintText: 'Password',
                        obscureText: true,
                        onChanged: (v) => context
                            .read<RegisterFormBloc>()
                            .add(RegisterPasswordChanged(v)),
                      ),
                      const SizedBox(height: 12),
                      AppTextField(
                        hintText: 'Confirm password',
                        obscureText: true,
                        onChanged: (v) => context
                            .read<RegisterFormBloc>()
                            .add(RegisterConfirmPasswordChanged(v)),
                      ),
                      const SizedBox(height: 16),
                      BlocBuilder<RegisterFormBloc, RegisterFormState>(
                        builder: (context, formState) => AppButton(
                          text: 'Register',
                          isLoading: authState is AuthLoading,
                          onPressed: () {
                            if (formState.password !=
                                formState.confirmPassword) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Passwords do not match'),
                                ),
                              );
                              return;
                            }
                            context.read<AuthBloc>().add(
                                  RegisterEvent(
                                    email: formState.email,
                                    password: formState.password,
                                  ),
                                );
                          },
                        ),
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
