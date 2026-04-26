import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:plovy/core/routing/app_router.dart';
import 'package:plovy/core/widgets/app_button.dart';
import 'package:plovy/core/widgets/app_text_field.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  AppTextField(controller: _emailController, hintText: 'Email'),
                  const SizedBox(height: 12),
                  AppTextField(
                    controller: _passwordController,
                    hintText: 'Password',
                    obscureText: true,
                  ),
                  const SizedBox(height: 16),
                  AppButton(
                    text: 'Login',
                    onPressed: () {
                      debugPrint('Login tapped: ${_emailController.text}');
                      context.go(AppRoutes.home);
                    },
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {
                      debugPrint('Go to Register tapped');
                      context.go(AppRoutes.register);
                    },
                    child: const Text('Go to Register'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
