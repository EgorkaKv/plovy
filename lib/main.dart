import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:plovy/core/di/injection.dart';
import 'package:plovy/core/routing/app_router.dart';
import 'package:plovy/features/auth/presentation/bloc/auth_bloc.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  runApp(const PlovyApp());
}

class PlovyApp extends StatelessWidget {
  const PlovyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthBloc>(
      create: (BuildContext context) => getIt<AuthBloc>(),
      child: MaterialApp.router(
        title: 'Plovy',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
          useMaterial3: true,
        ),
        routerConfig: appRouter,
      ),
    );
  }
}
