// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:plovy/core/connection/connectivity_service.dart' as _i669;
import 'package:plovy/core/di/injection.dart' as _i788;
import 'package:plovy/core/mqtt/mqtt_service.dart' as _i676;
import 'package:plovy/core/network/http_service.dart' as _i1055;
import 'package:plovy/core/storage/storage_service.dart' as _i829;
import 'package:plovy/features/auth/data/repositories/auth_repository_impl.dart'
    as _i221;
import 'package:plovy/features/auth/domain/repositories/auth_repository.dart'
    as _i781;
import 'package:plovy/features/auth/presentation/bloc/auth_bloc.dart' as _i122;
import 'package:plovy/features/catalog/data/datasources/hairstyle_local_datasource.dart'
    as _i1030;
import 'package:plovy/features/catalog/data/datasources/hairstyle_remote_datasource.dart'
    as _i972;
import 'package:plovy/features/catalog/data/repositories/hairstyle_repository_impl.dart'
    as _i811;
import 'package:plovy/features/catalog/domain/repositories/hairstyle_repository.dart'
    as _i979;
import 'package:plovy/features/home/presentation/bloc/home_bloc.dart' as _i472;
import 'package:shared_preferences/shared_preferences.dart' as _i460;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> $initGetIt({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final registerModule = _$RegisterModule();
    await gh.factoryAsync<_i460.SharedPreferences>(
      () => registerModule.prefs,
      preResolve: true,
    );
    gh.lazySingleton<_i669.ConnectivityService>(
      () => _i669.ConnectivityService(),
    );
    gh.lazySingleton<_i676.MqttService>(
      () => _i676.MqttService(),
      dispose: (i) => i.dispose(),
    );
    gh.lazySingleton<_i1055.HttpService>(() => _i1055.HttpService());
    gh.factory<_i472.HomeBloc>(
      () => _i472.HomeBloc(
        gh<_i676.MqttService>(),
        gh<_i669.ConnectivityService>(),
      ),
    );
    gh.lazySingleton<_i972.HairstyleRemoteDataSource>(
      () => _i972.HairstyleRemoteDataSource(gh<_i1055.HttpService>()),
    );
    gh.lazySingleton<_i829.StorageService>(
      () => _i829.StorageService(gh<_i460.SharedPreferences>()),
    );
    gh.lazySingleton<_i1030.HairstyleLocalDataSource>(
      () => _i1030.HairstyleLocalDataSource(gh<_i460.SharedPreferences>()),
    );
    gh.lazySingleton<_i781.AuthRepository>(
      () => _i221.AuthRepositoryImpl(gh<_i829.StorageService>()),
    );
    gh.lazySingleton<_i979.HairstyleRepository>(
      () => _i811.HairstyleRepositoryImpl(
        gh<_i972.HairstyleRemoteDataSource>(),
        gh<_i1030.HairstyleLocalDataSource>(),
      ),
    );
    gh.factory<_i122.AuthBloc>(
      () => _i122.AuthBloc(gh<_i781.AuthRepository>()),
    );
    return this;
  }
}

class _$RegisterModule extends _i788.RegisterModule {}
