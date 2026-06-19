import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:baladeyate/core/services/cache_service.dart';
import 'package:baladeyate/core/services/end_points.dart';
import 'package:baladeyate/core/services/interceptors/auth_interceptor.dart';

import 'package:baladeyate/core/services/fcm/fcm_service.dart';
import 'package:baladeyate/features/auth/cubits/auth_cubit/auth_cubit.dart';
import 'package:baladeyate/features/auth/repo/auth_repository.dart';
import 'package:baladeyate/features/complaints/cubits/complaints_cubit/complaints_cubit.dart';
import 'package:baladeyate/features/complaints/repo/complaints_repository.dart';
import 'package:baladeyate/features/profile/cubits/profile_cubit/profile_cubit.dart';
import 'package:baladeyate/features/profile/repo/citizen_repository.dart';

import 'api_services.dart';
import 'package:get_it/get_it.dart';

final sl = GetIt.instance;

Future<void> setupServiceLocator() async {
  sl.registerSingletonAsync<SharedPreferences>(
    () => SharedPreferences.getInstance(),
  );

  sl.registerLazySingleton<CacheService>(
    () => CacheService(sharedPreferences: sl()),
  );

  sl.registerLazySingleton<AuthInterceptor>(
    () => AuthInterceptor(cacheService: sl()),
  );

  sl.registerLazySingleton<Dio>(() {
    final dio = Dio(
      BaseOptions(
        baseUrl: EndPoints.baseUrl,
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
        headers: {'Accept': 'application/json'},
      ),
    );
    dio.interceptors.add(sl<AuthInterceptor>());
    dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        requestHeader: true,
        responseHeader: false,
        error: true,
      ),
    );

    return dio;
  });

  sl.registerLazySingleton<ApiService>(() => ApiService(dio: sl()));

  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepository(
      apiService: sl(),
      cacheService: sl(),
    ),
  );

  sl.registerLazySingleton<CitizenRepository>(
    () => CitizenRepository(apiService: sl()),
  );

  sl.registerLazySingleton<ComplaintsRepository>(
    () => ComplaintsRepository(apiService: sl()),
  );

  sl.registerLazySingleton<FcmService>(
    () => FcmService(
      authRepository: sl<AuthRepository>(),
      cacheService: sl<CacheService>(),
    ),
  );

  sl.registerLazySingleton<AuthCubit>(
    () => AuthCubit(
      authRepository: sl<AuthRepository>(),
      fcmService: sl<FcmService>(),
    ),
  );

  sl.registerFactory<ComplaintsCubit>(
    () => ComplaintsCubit(complaintsRepository: sl<ComplaintsRepository>()),
  );

  sl.registerFactory<ProfileCubit>(
    () => ProfileCubit(
      citizenRepository: sl<CitizenRepository>(),
      authCubit: sl<AuthCubit>(),
    ),
  );
}
