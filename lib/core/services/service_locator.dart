import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:baladeyate/core/services/cache_service.dart';
import 'package:baladeyate/core/services/end_points.dart';
import 'package:baladeyate/core/services/interceptors/auth_interceptor.dart';

import 'package:baladeyate/core/services/fcm/fcm_service.dart';
import 'package:baladeyate/features/admin/cubits/graves_cubit/graves_cubit.dart';
import 'package:baladeyate/features/admin/repo/admin_repository.dart';
import 'package:baladeyate/features/auth/cubits/auth_cubit/auth_cubit.dart';
import 'package:baladeyate/features/auth/cubits/auth_form_cubit/auth_form_cubit.dart';
import 'package:baladeyate/features/auth/cubits/password_reset_cubit/password_reset_cubit.dart';
import 'package:baladeyate/features/daily_tasks/cubits/daily_tasks_cubit/daily_tasks_cubit.dart';
import 'package:baladeyate/features/auth/repo/auth_repository.dart';
import 'package:baladeyate/features/complaints/cubits/complaints_cubit/complaints_cubit.dart';
import 'package:baladeyate/features/complaints/repo/complaints_repository.dart';
import 'package:baladeyate/features/delegate/cubits/building_survey_cubit/building_survey_cubit.dart';
import 'package:baladeyate/features/delegate/data/local_building_survey_store.dart';
import 'package:baladeyate/features/delegate/data/local_survey_pin_store.dart';
import 'package:baladeyate/features/delegate/repo/delegate_repository.dart';
import 'package:baladeyate/features/notifications/cubits/notifications_cubit/notifications_cubit.dart';
import 'package:baladeyate/features/notifications/repo/notifications_repository.dart';
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
    if (kDebugMode) {
      dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          requestHeader: true,
          responseHeader: false,
          error: true,
        ),
      );
    }

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

  sl.registerLazySingleton<LocalSurveyPinStore>(
    () => LocalSurveyPinStore(cacheService: sl()),
  );

  sl.registerLazySingleton<LocalBuildingSurveyStore>(
    () => LocalBuildingSurveyStore(cacheService: sl()),
  );

  sl.registerLazySingleton<DelegateRepository>(
    () => DelegateRepository(
      apiService: sl(),
      localSurveyPinStore: sl(),
    ),
  );

  sl.registerLazySingleton<AdminRepository>(
    () => AdminRepository(apiService: sl()),
  );

  sl.registerLazySingleton<NotificationsRepository>(
    () => NotificationsRepository(apiService: sl()),
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
      citizenRepository: sl<CitizenRepository>(),
      fcmService: sl<FcmService>(),
    ),
  );

  sl.registerFactory<ComplaintsCubit>(
    () => ComplaintsCubit(complaintsRepository: sl<ComplaintsRepository>()),
  );

  sl.registerFactory<GravesCubit>(
    () => GravesCubit(adminRepository: sl<AdminRepository>()),
  );

  sl.registerFactory<DailyTasksCubit>(
    () => DailyTasksCubit(delegateRepository: sl<DelegateRepository>()),
  );

  sl.registerFactory<AuthFormCubit>(() => AuthFormCubit());

  sl.registerFactory<PasswordResetCubit>(
    () => PasswordResetCubit(authRepository: sl<AuthRepository>()),
  );

  sl.registerFactory<BuildingSurveyCubit>(
    () => BuildingSurveyCubit(
      delegateRepository: sl(),
      localSurveyStore: sl(),
    ),
  );

  sl.registerLazySingleton<NotificationsCubit>(
    () => NotificationsCubit(
      notificationsRepository: sl<NotificationsRepository>(),
    ),
  );

  sl.registerFactory<ProfileCubit>(
    () => ProfileCubit(
      citizenRepository: sl<CitizenRepository>(),
      authCubit: sl<AuthCubit>(),
    ),
  );
}
