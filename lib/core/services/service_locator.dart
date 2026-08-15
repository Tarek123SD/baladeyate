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
import 'package:baladeyate/features/cemetery_map/cubits/cemetery_map_cubit/cemetery_map_cubit.dart';
import 'package:baladeyate/features/cemetery_map/repo/cemetery_map_repository.dart';
import 'package:baladeyate/features/daily_tasks/cubits/daily_tasks_cubit/daily_tasks_cubit.dart';
import 'package:baladeyate/features/daily_tasks/repo/daily_tasks_repository.dart';
import 'package:baladeyate/features/auth/repo/auth_repository.dart';
import 'package:baladeyate/features/complaints/cubits/complaints_cubit/complaints_cubit.dart';
import 'package:baladeyate/features/complaints/repo/complaints_repository.dart';
import 'package:baladeyate/features/donations/cubits/donate_cubit/donate_cubit.dart';
import 'package:baladeyate/features/donations/cubits/donations_cubit/donations_cubit.dart';
import 'package:baladeyate/features/donations/repo/donations_repository.dart';
import 'package:baladeyate/features/delegate/cubits/building_survey_cubit/building_survey_cubit.dart';
import 'package:baladeyate/features/delegate/repo/local_building_survey_store.dart';
import 'package:baladeyate/features/delegate/repo/local_survey_pin_store.dart';
import 'package:baladeyate/features/delegate/repo/delegate_repository.dart';
import 'package:baladeyate/features/notifications/cubits/notifications_cubit/notifications_cubit.dart';
import 'package:baladeyate/features/notifications/repo/notifications_repository.dart';
import 'package:baladeyate/features/profile/cubits/profile_cubit/profile_cubit.dart';
import 'package:baladeyate/features/profile/repo/citizen_repository.dart';
import 'package:baladeyate/features/transactions/cubits/submit_transaction_cubit/submit_transaction_cubit.dart';
import 'package:baladeyate/features/transactions/cubits/transactions_cubit/transactions_cubit.dart';
import 'package:baladeyate/features/transactions/cubits/delegate_transactions_cubit/delegate_transactions_cubit.dart';
import 'package:baladeyate/features/transactions/repo/transactions_repository.dart';
import 'package:baladeyate/features/digital_documents/cubits/digital_documents_cubit/digital_documents_cubit.dart';
import 'package:baladeyate/features/digital_documents/cubits/scanner_cubit/scanner_cubit.dart';
import 'package:baladeyate/features/digital_documents/repo/digital_documents_repository.dart';


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

  sl.registerLazySingleton<TransactionsRepository>(
    () => TransactionsRepository(apiService: sl()),
  );

  sl.registerLazySingleton<DigitalDocumentsRepository>(
    () => DigitalDocumentsRepository(apiService: sl()),
  );

  sl.registerLazySingleton<ComplaintsRepository>(
    () => ComplaintsRepository(apiService: sl()),
  );

  sl.registerLazySingleton<DonationsRepository>(
    () => DonationsRepository(apiService: sl()),
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

  sl.registerLazySingleton<DailyTasksRepository>(
    () => DailyTasksRepository(
      delegateRepository: sl<DelegateRepository>(),
    ),
  );

  sl.registerLazySingleton<AdminRepository>(
    () => AdminRepository(apiService: sl()),
  );

  sl.registerLazySingleton<CemeteryMapRepository>(
    () => CemeteryMapRepository(apiService: sl()),
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

  sl.registerFactory<SubmitTransactionCubit>(
    () => SubmitTransactionCubit(transactionsRepository: sl<TransactionsRepository>()),
  );

  sl.registerFactory<TransactionsCubit>(
    () => TransactionsCubit(transactionsRepository: sl<TransactionsRepository>()),
  );

  sl.registerFactory<DelegateTransactionsCubit>(
    () => DelegateTransactionsCubit(repository: sl<TransactionsRepository>()),
  );

  sl.registerFactory<DigitalDocumentsCubit>(
    () => DigitalDocumentsCubit(digitalDocumentsRepository: sl<DigitalDocumentsRepository>()),
  );

  sl.registerFactory<ScannerCubit>(
    () => ScannerCubit(repository: sl<DigitalDocumentsRepository>()),
  );


  sl.registerFactory<DonationsCubit>(
    () => DonationsCubit(donationsRepository: sl<DonationsRepository>()),
  );

  sl.registerFactory<DonateCubit>(
    () => DonateCubit(donationsRepository: sl<DonationsRepository>()),
  );

  sl.registerFactory<GravesCubit>(
    () => GravesCubit(adminRepository: sl<AdminRepository>()),
  );

  sl.registerFactory<CemeteryMapCubit>(
    () => CemeteryMapCubit(
      cemeteryMapRepository: sl<CemeteryMapRepository>(),
    ),
  );

  sl.registerLazySingleton<DailyTasksCubit>(
    () => DailyTasksCubit(
      dailyTasksRepository: sl<DailyTasksRepository>(),
    ),
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
