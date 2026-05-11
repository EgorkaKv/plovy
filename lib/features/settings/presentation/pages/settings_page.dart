import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:plovy/core/di/injection.dart';
import 'package:plovy/core/mqtt/mqtt_service.dart';
import 'package:plovy/core/routing/app_router.dart';
import 'package:plovy/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:plovy/features/catalog/domain/repositories/hairstyle_repository.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (BuildContext context, AuthState state) {
          if (state is AuthUnauthenticated) {
            context.go(AppRoutes.login);
          }
        },
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    StreamBuilder<bool>(
                      stream: getIt<MqttService>().statusStream,
                      initialData: getIt<MqttService>().isConnected,
                      builder: (
                        BuildContext context,
                        AsyncSnapshot<bool> snap,
                      ) {
                        final bool connected = snap.data ?? false;
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(
                              Icons.circle,
                              size: 12,
                              color: connected ? Colors.green : Colors.grey,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              connected
                                  ? 'MQTT: connected'
                                  : 'MQTT: disconnected',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.delete_sweep),
                      label: const Text('Clear hairstyle cache'),
                      onPressed: () async {
                        await getIt<HairstyleRepository>().clearCache();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Cache cleared')),
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      icon: const Icon(Icons.logout),
                      label: const Text('Logout'),
                      onPressed: () {
                        context.read<AuthBloc>().add(const LogoutEvent());
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
