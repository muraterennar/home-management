// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:connectivity_plus/connectivity_plus.dart' as _i6;
import 'package:dio/dio.dart' as _i5;
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as _i4;
import 'package:get_it/get_it.dart' as _i1;
import 'package:injectable/injectable.dart' as _i2;
import 'package:shared_preferences/shared_preferences.dart' as _i3;

import '../network/api_client.dart' as _i9;
import '../network/network_info.dart' as _i7;
import '../storage/local_storage.dart' as _i8;
import 'injection.dart' as _i10;

extension GetItInjectableX on _i1.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  Future<_i1.GetIt> init({
    String? environment,
    _i2.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i2.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    final registerModule = _$RegisterModule();
    await gh.factoryAsync<_i3.SharedPreferences>(
      () => registerModule.sharedPreferences,
      preResolve: true,
    );
    gh.lazySingleton<_i4.FlutterSecureStorage>(
        () => registerModule.secureStorage);
    gh.lazySingleton<_i5.Dio>(() => registerModule.dio);
    gh.lazySingleton<_i6.Connectivity>(() => registerModule.connectivity);
    gh.lazySingleton<_i7.NetworkInfo>(
        () => _i7.NetworkInfoImpl(gh<_i6.Connectivity>()));
    gh.lazySingleton<_i8.LocalStorage>(() => _i8.LocalStorageImpl(
          gh<_i3.SharedPreferences>(),
          gh<_i4.FlutterSecureStorage>(),
        ));
    gh.lazySingleton<_i9.ApiClient>(() => _i9.ApiClient(
          gh<_i5.Dio>(),
          gh<_i7.NetworkInfo>(),
        ));
    return this;
  }
}

class _$RegisterModule extends _i10.RegisterModule {}
