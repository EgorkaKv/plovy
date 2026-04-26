import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:plovy/core/routing/app_router.dart';
import 'package:plovy/core/widgets/app_button.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
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
                  Text(
                    'Home',
                    style: Theme.of(context).textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  AppButton(
                    text: 'Scan face',
                    onPressed: () {
                      debugPrint('Scan face tapped');
                    },
                  ),
                  const SizedBox(height: 12),
                  AppButton(
                    text: 'Go to Catalog',
                    onPressed: () {
                      debugPrint('Go to Catalog tapped');
                    },
                  ),
                  const SizedBox(height: 12),
                  AppButton(
                    text: 'Settings',
                    onPressed: () {
                      debugPrint('Go to Settings tapped');
                      context.go(AppRoutes.settings);
                    },
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
