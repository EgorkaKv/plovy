import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:plovy/core/routing/app_router.dart';
import 'package:plovy/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:plovy/features/home/domain/entities/door_entry.dart';
import 'package:plovy/features/home/presentation/bloc/home_bloc.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Future<void> _confirmLogout(BuildContext context) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      context.read<AuthBloc>().add(const LogoutEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: <BlocListener<dynamic, dynamic>>[
        BlocListener<AuthBloc, AuthState>(
          listener: (BuildContext context, AuthState state) {
            if (state is AuthUnauthenticated) {
              context.go(AppRoutes.login);
            }
          },
        ),
        BlocListener<HomeBloc, HomeState>(
          listenWhen: (HomeState prev, HomeState curr) =>
              curr.showOfflineWarning && !prev.showOfflineWarning,
          listener: (BuildContext context, HomeState state) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('No internet connection'),
                backgroundColor: Colors.red,
              ),
            );
          },
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: BlocBuilder<AuthBloc, AuthState>(
            builder: (BuildContext context, AuthState state) {
              final String email =
                  state is AuthAuthenticated ? state.user.email : '';
              return Text(email, overflow: TextOverflow.ellipsis);
            },
          ),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () => context.push(AppRoutes.settings),
            ),
          ],
        ),
        body: BlocBuilder<HomeBloc, HomeState>(
          builder: (BuildContext context, HomeState state) {
            return Column(
              children: <Widget>[
                if (!state.isOnline)
                  MaterialBanner(
                    content: const Text('No internet connection'),
                    backgroundColor: Colors.red.shade100,
                    leading: const Icon(Icons.wifi_off, color: Colors.red),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () => ScaffoldMessenger.of(
                          context,
                        ).hideCurrentMaterialBanner(),
                        child: const Text('Dismiss'),
                      ),
                    ],
                  ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: <Widget>[
                      _MqttStatusChip(connected: state.isMqttConnected),
                      const Spacer(),
                      Text(
                        'Visitors: ${state.visitorCount}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: state.entries.isEmpty
                      ? const Center(
                          child: Text(
                            'No entries yet.\n'
                            'Waiting for door sensor events...',
                            textAlign: TextAlign.center,
                          ),
                        )
                      : ListView.builder(
                          itemCount: state.entries.length,
                          itemBuilder: (BuildContext context, int index) {
                            return _EntryTile(entry: state.entries[index]);
                          },
                        ),
                ),
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.face),
                          label: const Text('Scan face'),
                          onPressed: () => context.push(AppRoutes.camera),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: FilledButton.icon(
                          icon: const Icon(Icons.logout),
                          label: const Text('Logout'),
                          onPressed: () => _confirmLogout(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _MqttStatusChip extends StatelessWidget {
  const _MqttStatusChip({required this.connected});

  final bool connected;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(
        Icons.circle,
        size: 12,
        color: connected ? Colors.green : Colors.grey,
      ),
      label: Text(connected ? 'MQTT: connected' : 'MQTT: disconnected'),
      padding: EdgeInsets.zero,
    );
  }
}

class _EntryTile extends StatelessWidget {
  const _EntryTile({required this.entry});

  final DoorEntry entry;

  @override
  Widget build(BuildContext context) {
    final DateTime t = entry.timestamp;
    final String time =
        '${t.hour.toString().padLeft(2, '0')}:'
        '${t.minute.toString().padLeft(2, '0')}:'
        '${t.second.toString().padLeft(2, '0')}';
    return ListTile(
      leading: const Icon(Icons.sensor_door),
      title: Text('Sensor: ${entry.sensorId}'),
      subtitle: Text(time),
    );
  }
}
