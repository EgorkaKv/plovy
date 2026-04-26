import 'package:flutter/material.dart';

import 'package:plovy/core/widgets/app_button.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
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
                  const Text('MQTT: disconnected', textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  AppButton(
                    text: 'Logout',
                    onPressed: () {
                      debugPrint('Logout tapped');
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
